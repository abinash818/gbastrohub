<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-Signature");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

$host = "127.0.0.1";
$db_name = "u682341828_gbastro";
$username = "u682341828_gbastro";
$password = "Gbastro@2026";

try {
    $conn = new PDO("mysql:host=" . $host . ";dbname=" . $db_name, $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Auto-create tables if not exists
    $createTableQuery = "CREATE TABLE IF NOT EXISTS user_subscriptions (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id VARCHAR(255) NOT NULL,
        plan_id INT NOT NULL,
        start_date DATETIME NOT NULL,
        end_date DATETIME NOT NULL,
        payment_id VARCHAR(255) NOT NULL,
        status VARCHAR(50) DEFAULT 'active',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    $conn->exec($createTableQuery);

    $createOrderTableQuery = "CREATE TABLE IF NOT EXISTS payment_orders (
        id INT AUTO_INCREMENT PRIMARY KEY,
        order_id VARCHAR(255) NOT NULL UNIQUE,
        user_id VARCHAR(255) NOT NULL,
        plan_id INT NOT NULL,
        amount INT NOT NULL,
        status VARCHAR(50) DEFAULT 'PENDING',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    )";
    $conn->exec($createOrderTableQuery);

} catch(PDOException $e) {
    echo json_encode(["success" => false, "message" => "Connection failed: " . $e->getMessage()]);
    exit();
}

$method = $_SERVER['REQUEST_METHOD'];
define('S2S_SECRET', 'Gbastro_S2S_Secret_2026!');

function verifyS2SAuth($data) {
    $headers = getallheaders();
    $signature = $headers['X-Signature'] ?? ($headers['x-signature'] ?? '');
    
    // We expect the sender to send JSON encoded data. We recreate hash.
    $payloadString = json_encode($data);
    $expectedSignature = hash_hmac('sha256', $payloadString, S2S_SECRET);
    
    if (!hash_equals($expectedSignature, $signature)) {
        echo json_encode(["success" => false, "message" => "S2S Authentication Failed"]);
        exit();
    }
}

try {
    if ($method == 'POST') {
        $rawInput = file_get_contents("php://input");
        $data = json_decode($rawInput);
        
        // PhonePe webhook sends "response" in base64, so it won't have an "action" field.
        if (isset($data->response) && empty($data->action)) {
            $data->action = 'webhook';
        }
        
        if (!empty($data->action)) {
            $action = $data->action;
            
            // Check active subscription status
            if ($action == 'check_status') {
                if (empty($data->user_id)) {
                    echo json_encode(["success" => false, "message" => "User ID is required"]);
                    exit();
                }

                $stmt = $conn->prepare("
                    SELECT us.*, p.name as plan_name, p.features 
                    FROM user_subscriptions us 
                    JOIN subscription_plans p ON us.plan_id = p.id 
                    WHERE us.user_id = :user_id AND us.status = 'active' AND us.end_date > NOW() 
                    ORDER BY us.end_date DESC LIMIT 1
                ");
                $stmt->execute([':user_id' => $data->user_id]);
                $sub = $stmt->fetch(PDO::FETCH_ASSOC);

                if ($sub) {
                    $sub['features'] = $sub['features'] ? explode(',', $sub['features']) : [];

                    // Sync with app_users so the admin panel shows them as APPROVED
                    if (!empty($data->email)) {
                        $syncStmt = $conn->prepare("UPDATE app_users SET status = 'APPROVED', expiry_date = :end_date, purchased_date = :start_date, plan_id = :plan_id WHERE email = :email");
                        $syncStmt->execute([
                            ':end_date' => $sub['end_date'],
                            ':start_date' => $sub['start_date'],
                            ':plan_id' => $sub['plan_id'],
                            ':email' => $data->email
                        ]);
                    }

                    echo json_encode(["success" => true, "is_premium" => true, "subscription" => $sub]);
                } else {
                    // Check if they are manually approved in app_users (i.e. status is APPROVED and expiry_date > NOW())
                    $manCheck = null;
                    if (!empty($data->email)) {
                        $manStmt = $conn->prepare("SELECT * FROM app_users WHERE email = :email LIMIT 1");
                        $manStmt->execute([':email' => $data->email]);
                        $manCheck = $manStmt->fetch(PDO::FETCH_ASSOC);
                    }

                    if ($manCheck && $manCheck['status'] === 'APPROVED' && !empty($manCheck['expiry_date']) && strtotime($manCheck['expiry_date']) >= strtotime(date('Y-m-d'))) {
                        // Keep manual approval active, don't reset to PENDING.
                        $plan_id = $manCheck['plan_id'] ?? 0;
                        $plan_name = 'Manual Plan';
                        $features = '';
                        if ($plan_id) {
                            $pStmt = $conn->prepare("SELECT name, features FROM subscription_plans WHERE id = :plan_id LIMIT 1");
                            $pStmt->execute([':plan_id' => $plan_id]);
                            $planData = $pStmt->fetch(PDO::FETCH_ASSOC);
                            if ($planData) {
                                $plan_name = $planData['name'];
                                $features = $planData['features'];
                            }
                        }

                        $sub = [
                            'user_id' => $data->user_id,
                            'plan_id' => $plan_id,
                            'start_date' => $manCheck['purchased_date'],
                            'end_date' => $manCheck['expiry_date'],
                            'status' => 'active',
                            'plan_name' => $plan_name,
                            'features' => $features ? explode(',', $features) : []
                        ];

                        echo json_encode(["success" => true, "is_premium" => true, "subscription" => $sub]);
                    } else {
                        $upd = $conn->prepare("UPDATE user_subscriptions SET status = 'expired' WHERE user_id = :user_id AND end_date <= NOW()");
                        $upd->execute([':user_id' => $data->user_id]);

                        // Sync with app_users if expired
                        if (!empty($data->email)) {
                            $syncExp = $conn->prepare("UPDATE app_users SET status = 'PENDING' WHERE email = :email AND status = 'APPROVED'");
                            $syncExp->execute([':email' => $data->email]);
                        }

                        echo json_encode(["success" => true, "is_premium" => false, "message" => "No active subscription found"]);
                    }
                }
            } 
            
            // Initiate Order
            else if ($action == 'initiate_order') {
                verifyS2SAuth($data);
                
                if (empty($data->order_id) || empty($data->user_id) || empty($data->plan_id)) {
                    echo json_encode(["success" => false, "message" => "Missing fields"]);
                    exit();
                }
                
                $stmt = $conn->prepare("INSERT INTO payment_orders (order_id, user_id, plan_id, amount, status) VALUES (:order_id, :user_id, :plan_id, :amount, 'PENDING') ON DUPLICATE KEY UPDATE status = 'PENDING'");
                $stmt->execute([
                    ':order_id' => $data->order_id,
                    ':user_id' => $data->user_id,
                    ':plan_id' => $data->plan_id,
                    ':amount' => $data->amount ?? 0
                ]);
                echo json_encode(["success" => true]);
            }
            
            // Activate Demo Plan (0 Rs)
            else if ($action == 'activate_demo') {
                verifyS2SAuth($data);
                
                if (empty($data->order_id) || empty($data->user_id) || empty($data->plan_id)) {
                    echo json_encode(["success" => false, "message" => "Missing fields"]);
                    exit();
                }
                
                // Add to payment orders as COMPLETED
                $stmt = $conn->prepare("INSERT INTO payment_orders (order_id, user_id, plan_id, amount, status) VALUES (:order_id, :user_id, :plan_id, :amount, 'COMPLETED') ON DUPLICATE KEY UPDATE status = 'COMPLETED'");
                $stmt->execute([
                    ':order_id' => $data->order_id,
                    ':user_id' => $data->user_id,
                    ':plan_id' => $data->plan_id,
                    ':amount' => 0
                ]);
                
                // Create Subscription
                $dupCheck = $conn->prepare("SELECT id FROM user_subscriptions WHERE payment_id = :payment_id LIMIT 1");
                $dupCheck->execute([':payment_id' => $data->order_id]);
                if ($dupCheck->rowCount() == 0) {
                    $planStmt = $conn->prepare("SELECT duration_days FROM subscription_plans WHERE id = :plan_id");
                    $planStmt->execute([':plan_id' => $data->plan_id]);
                    $plan = $planStmt->fetch(PDO::FETCH_ASSOC);

                    if ($plan) {
                        $durationDays = $plan['duration_days'];
                        $start_date = date('Y-m-d H:i:s');
                        $end_date = date('Y-m-d H:i:s', strtotime("+$durationDays days"));

                        $stmtSub = $conn->prepare("INSERT INTO user_subscriptions (user_id, plan_id, start_date, end_date, payment_id, status) VALUES (:user_id, :plan_id, :start_date, :end_date, :payment_id, 'active')");
                        $stmtSub->execute([
                            ':user_id' => $data->user_id,
                            ':plan_id' => $data->plan_id,
                            ':start_date' => $start_date,
                            ':end_date' => $end_date,
                            ':payment_id' => $data->order_id
                        ]);
                    }
                }
                echo json_encode(["success" => true, "status" => "COMPLETED"]);
                exit();
            }
            
            // Check Order Status (Polled by Guruji Server)
            else if ($action == 'check_order_status') {
                verifyS2SAuth($data);
                
                if (empty($data->order_id)) {
                    echo json_encode(["success" => false, "message" => "Order ID required"]);
                    exit();
                }
                
                $stmt = $conn->prepare("SELECT * FROM payment_orders WHERE order_id = :order_id");
                $stmt->execute([':order_id' => $data->order_id]);
                $order = $stmt->fetch(PDO::FETCH_ASSOC);
                
                if ($order) {
                    if ($order['status'] === 'PENDING') {
                        // Proactively check PhonePe in case Webhook is delayed
                        $pp_clientId = 'SU2603051136065347672044';
                        $pp_clientSecret = '3b614f73-5af0-4765-9395-188fb1d3fd53';
                        $pp_env = 'PRODUCTION';
                        $pp_baseUrl = ($pp_env === 'SANDBOX') ? 'https://api-preprod.phonepe.com/apis/pg-sandbox' : 'https://api.phonepe.com/apis/pg';
                        
                        $tokenUrl = ($pp_env === 'SANDBOX') ? 'https://api-preprod.phonepe.com/apis/pg-sandbox/v1/oauth/token' : 'https://api.phonepe.com/apis/identity-manager/v1/oauth/token';

                        $ch = curl_init($tokenUrl);
                        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                        curl_setopt($ch, CURLOPT_POST, true);
                        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
                        curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query([
                            'client_id' => $pp_clientId,
                            'client_version' => '1',
                            'client_secret' => $pp_clientSecret,
                            'grant_type' => 'client_credentials'
                        ]));
                        curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/x-www-form-urlencoded']);
                        $tokenRes = curl_exec($ch);
                        $tokenData = json_decode($tokenRes, true);
                        curl_close($ch);
                        
                        if (isset($tokenData['access_token'])) {
                            $statusUrl = $pp_baseUrl . '/checkout/v2/order/' . $data->order_id . '/status';
                            $ch = curl_init($statusUrl);
                            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
                            curl_setopt($ch, CURLOPT_HTTPHEADER, ['Authorization: O-Bearer ' . $tokenData['access_token']]);
                            $statusRes = curl_exec($ch);
                            $statusData = json_decode($statusRes, true);
                            curl_close($ch);
                            
                            $ppCode = $statusData['code'] ?? '';
                            $ppState = $statusData['state'] ?? '';
                            
                            if ($ppCode === 'PAYMENT_SUCCESS' || $ppState === 'COMPLETED') {
                                // Payment Successful! Update DB
                                $updOrd = $conn->prepare("UPDATE payment_orders SET status = 'COMPLETED' WHERE order_id = :order_id");
                                $updOrd->execute([':order_id' => $data->order_id]);
                                
                                // Create Subscription
                                $dupCheck = $conn->prepare("SELECT id FROM user_subscriptions WHERE payment_id = :payment_id LIMIT 1");
                                $dupCheck->execute([':payment_id' => $data->order_id]);
                                if ($dupCheck->rowCount() == 0) {
                                    $planStmt = $conn->prepare("SELECT duration_days FROM subscription_plans WHERE id = :plan_id");
                                    $planStmt->execute([':plan_id' => $order['plan_id']]);
                                    $plan = $planStmt->fetch(PDO::FETCH_ASSOC);

                                    if ($plan) {
                                        $durationDays = $plan['duration_days'];
                                        $start_date = date('Y-m-d H:i:s');
                                        $end_date = date('Y-m-d H:i:s', strtotime("+$durationDays days"));

                                        $stmtSub = $conn->prepare("INSERT INTO user_subscriptions (user_id, plan_id, start_date, end_date, payment_id, status) VALUES (:user_id, :plan_id, :start_date, :end_date, :payment_id, 'active')");
                                        $stmtSub->execute([
                                            ':user_id' => $order['user_id'],
                                            ':plan_id' => $order['plan_id'],
                                            ':start_date' => $start_date,
                                            ':end_date' => $end_date,
                                            ':payment_id' => $data->order_id
                                        ]);
                                    }
                                }
                                echo json_encode(["success" => true, "status" => "COMPLETED"]);
                                exit();
                            } else if ($ppState === 'FAILED') {
                                $updOrd = $conn->prepare("UPDATE payment_orders SET status = 'FAILED' WHERE order_id = :order_id");
                                $updOrd->execute([':order_id' => $data->order_id]);
                                echo json_encode(["success" => true, "status" => "FAILED"]);
                                exit();
                            }
                        }
                    }
                    echo json_encode(["success" => true, "status" => $order['status']]);
                } else {
                    echo json_encode(["success" => false, "message" => "Order not found"]);
                }
            }
            
            // Webhook for PhonePe
            else if ($action == 'webhook' || $action == 'create_subscription') {
                // Log the webhook hit
                file_put_contents(dirname(__FILE__) . '/webhook_log.txt', "[" . date('Y-m-d H:i:s') . "] Webhook Triggered: " . $rawInput . "\n", FILE_APPEND);
                
                // If it's webhook, phonepe sends base64 payload. But just to be safe and avoid complex signature parsing,
                // We will extract order_id and proactively query PhonePe status API.
                
                $orderId = $data->order_id ?? $data->payment_id ?? '';
                if (isset($data->response)) {
                    // PhonePe S2S payload
                    $decoded = json_decode(base64_decode($data->response), true);
                    $orderId = $decoded['data']['merchantOrderId'] ?? $orderId;
                }
                
                if (empty($orderId)) {
                    echo json_encode(["success" => false, "message" => "Order ID missing"]);
                    exit();
                }

                // Check DB if already COMPLETED
                $ordStmt = $conn->prepare("SELECT * FROM payment_orders WHERE order_id = :order_id");
                $ordStmt->execute([':order_id' => $orderId]);
                $order = $ordStmt->fetch(PDO::FETCH_ASSOC);
                
                if ($order && $order['status'] === 'COMPLETED') {
                    echo json_encode(["success" => true, "message" => "Already processed"]);
                    exit();
                }

                // PhonePe Verification
                $pp_clientId = 'SU2603051136065347672044';
                $pp_clientSecret = '3b614f73-5af0-4765-9395-188fb1d3fd53';
                $pp_env = 'PRODUCTION';
                $pp_baseUrl = ($pp_env === 'SANDBOX') ? 'https://api-preprod.phonepe.com/apis/pg-sandbox' : 'https://api.phonepe.com/apis/pg';
                
                $tokenUrl = ($pp_env === 'SANDBOX') ? 'https://api-preprod.phonepe.com/apis/pg-sandbox/v1/oauth/token' : 'https://api.phonepe.com/apis/identity-manager/v1/oauth/token';

                $ch = curl_init($tokenUrl);
                curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                curl_setopt($ch, CURLOPT_POST, true);
                curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
                curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query([
                    'client_id' => $pp_clientId,
                    'client_version' => '1',
                    'client_secret' => $pp_clientSecret,
                    'grant_type' => 'client_credentials'
                ]));
                curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/x-www-form-urlencoded']);
                $tokenRes = curl_exec($ch);
                $tokenData = json_decode($tokenRes, true);
                curl_close($ch);
                
                if (!isset($tokenData['access_token'])) {
                    echo json_encode(["success" => false, "message" => "Token failed"]);
                    exit();
                }
                
                $statusUrl = $pp_baseUrl . '/checkout/v2/order/' . $orderId . '/status';
                $ch = curl_init($statusUrl);
                curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
                curl_setopt($ch, CURLOPT_HTTPHEADER, ['Authorization: O-Bearer ' . $tokenData['access_token']]);
                $statusRes = curl_exec($ch);
                $statusData = json_decode($statusRes, true);
                curl_close($ch);
                
                $ppCode = $statusData['code'] ?? '';
                $ppState = $statusData['state'] ?? '';
                
                if ($ppCode === 'PAYMENT_SUCCESS' || $ppState === 'COMPLETED') {
                    // Payment is truly successful!
                    
                    if ($order) {
                        $userId = $order['user_id'];
                        $planId = $order['plan_id'];
                    } else {
                        // Fallback if initiate_order missed it
                        $userId = $data->user_id ?? '';
                        $planId = $data->plan_id ?? '';
                    }

                    if (empty($userId) || empty($planId)) {
                        echo json_encode(["success" => false, "message" => "User/Plan info missing"]);
                        exit();
                    }

                    // Update payment_orders
                    $updOrd = $conn->prepare("UPDATE payment_orders SET status = 'COMPLETED' WHERE order_id = :order_id");
                    $updOrd->execute([':order_id' => $orderId]);

                    // Check duplicate subscription
                    $dupCheck = $conn->prepare("SELECT id FROM user_subscriptions WHERE payment_id = :payment_id LIMIT 1");
                    $dupCheck->execute([':payment_id' => $orderId]);
                    if ($dupCheck->rowCount() == 0) {
                        $planStmt = $conn->prepare("SELECT duration_days FROM subscription_plans WHERE id = :plan_id");
                        $planStmt->execute([':plan_id' => $planId]);
                        $plan = $planStmt->fetch(PDO::FETCH_ASSOC);

                        if ($plan) {
                            $durationDays = $plan['duration_days'];
                            $start_date = date('Y-m-d H:i:s');
                            $end_date = date('Y-m-d H:i:s', strtotime("+$durationDays days"));

                            $stmt = $conn->prepare("INSERT INTO user_subscriptions (user_id, plan_id, start_date, end_date, payment_id, status) VALUES (:user_id, :plan_id, :start_date, :end_date, :payment_id, 'active')");
                            $stmt->execute([
                                ':user_id' => $userId,
                                ':plan_id' => $planId,
                                ':start_date' => $start_date,
                                ':end_date' => $end_date,
                                ':payment_id' => $orderId
                            ]);
                        }
                    }
                    echo json_encode(["success" => true, "message" => "Subscription active"]);
                } else {
                    if ($order) {
                        $updOrd = $conn->prepare("UPDATE payment_orders SET status = 'FAILED' WHERE order_id = :order_id");
                        $updOrd->execute([':order_id' => $orderId]);
                    }
                    echo json_encode(["success" => false, "message" => "Payment not completed"]);
                }
            } else {
                echo json_encode(["success" => false, "message" => "Unknown action"]);
            }
        } else {
            echo json_encode(["success" => false, "message" => "Action is required"]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Invalid Request Method"]);
    }
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Server Error: " . $e->getMessage()]);
}
?>
