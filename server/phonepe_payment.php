<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

error_reporting(0);
ini_set('display_errors', 0);
ini_set('log_errors', 1);
ini_set('error_log', dirname(__FILE__) . '/error_log.txt');

function logDebug($msg) {
    file_put_contents(dirname(__FILE__) . '/error_log.txt', "[" . date('Y-m-d H:i:s') . "] [PHONEPE] " . $msg . "\n", FILE_APPEND);
}

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once dirname(__FILE__) . '/phonepe_config.php';

$clientId = PHONEPE_CLIENT_ID;
$clientSecret = PHONEPE_CLIENT_SECRET;
$merchantId = PHONEPE_MERCHANT_ID;
$env = PHONEPE_ENV;
$baseUrl = ($env === 'SANDBOX') ? 'https://api-preprod.phonepe.com/apis/pg-sandbox' : 'https://api.phonepe.com/apis/pg';

$rawInput = file_get_contents("php://input");
$input = json_decode($rawInput, true);
$action = $_GET['action'] ?? $input['action'] ?? '';

try {
    if ($action === 'initiate') {
        $orderId = "SUB" . time() . rand(100, 999);
        $amount = $input['amount'] ?? 0; // Amount in paisa
        $userId = $input['user_id'] ?? 'test_user';
        $planId = $input['plan_id'] ?? 0;
        
        if ($amount <= 0) throw new Exception("Invalid amount");

        // 1. Get OAuth Token
        $tokenUrl = ($env === 'SANDBOX') 
            ? 'https://api-preprod.phonepe.com/apis/pg-sandbox/v1/oauth/token' 
            : 'https://api.phonepe.com/apis/identity-manager/v1/oauth/token';

        $params = [
            'grant_type' => 'client_credentials',
            'client_id' => $clientId,
            'client_secret' => $clientSecret,
            'client_version' => '1'
        ];

        $ch = curl_init($tokenUrl);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($params));
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/x-www-form-urlencoded',
            'Accept: application/json'
        ]);
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $tokenData = json_decode($response, true);
        curl_close($ch);

        if (!isset($tokenData['access_token'])) {
            logDebug("Token generation failed (HTTP $httpCode)");
            throw new Exception("Failed to authorize with PhonePe");
        }

        $accessToken = $tokenData['access_token'];

        // 2. Create Payment Request
        $paymentUrl = $baseUrl . '/checkout/v2/pay';
        
        // Save pending order info to DB so webhook can activate subscription
        try {
            $conn = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME, DB_USER, DB_PASS);
            $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            
            // Temporary table for pending orders
            $conn->exec("CREATE TABLE IF NOT EXISTS pending_subscriptions (
                order_id VARCHAR(50) PRIMARY KEY,
                user_id VARCHAR(255),
                plan_id INT,
                amount DECIMAL(10,2),
                status VARCHAR(50) DEFAULT 'pending',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )");

            $stmt = $conn->prepare("INSERT INTO pending_subscriptions (order_id, user_id, plan_id, amount) VALUES (?, ?, ?, ?)");
            $stmt->execute([$orderId, $userId, $planId, ($amount/100)]);
        } catch (Exception $e) {
            logDebug("DB Error: " . $e->getMessage());
        }

        $payload = [
            "merchantOrderId" => $orderId,
            "amount" => (int)$amount,
            "paymentFlow" => [
                "type" => "PG_CHECKOUT",
                "merchantUrls" => [
                "redirectUrl" => "https://deeppink-hedgehog-734715.hostingersite.com/payment_success.php?orderId=" . $orderId
            ]
        ];

        $ch = curl_init($paymentUrl);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/json',
            'Authorization: O-Bearer ' . $accessToken
        ]);

        $res = curl_exec($ch);
        $paymentData = json_decode($res, true);
        curl_close($ch);

        if (!isset($paymentData['redirectUrl'])) {
            logDebug("Payment initiation failed: " . $res);
            throw new Exception("Failed to initiate payment");
        }

        echo json_encode([
            "success" => true,
            "orderId" => $orderId,
            "redirectUrl" => $paymentData['redirectUrl']
        ]);
    } 
    elseif ($action === 'status') {
        $orderId = $_GET['orderId'] ?? '';
        if (!$orderId) throw new Exception("Order ID missing");

        $tokenUrl = ($env === 'SANDBOX') 
            ? 'https://api-preprod.phonepe.com/apis/pg-sandbox/v1/oauth/token' 
            : 'https://api.phonepe.com/apis/identity-manager/v1/oauth/token';

        $ch = curl_init($tokenUrl);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query([
            'client_id' => $clientId,
            'client_version' => '1',
            'client_secret' => $clientSecret,
            'grant_type' => 'client_credentials'
        ]));
        curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/x-www-form-urlencoded']);
        
        $response = curl_exec($ch);
        $tokenData = json_decode($response, true);
        curl_close($ch);

        $accessToken = $tokenData['access_token'];

        $statusUrl = $baseUrl . '/checkout/v2/order/' . $orderId . '/status';
        $ch = curl_init($statusUrl);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: O-Bearer ' . $accessToken
        ]);

        $res = curl_exec($ch);
        echo $res;
        curl_close($ch);
    }
    elseif ($action === 'activate_after_success') {
        // Internal endpoint called by App after successful status poll
        $orderId = $input['orderId'] ?? '';
        
        try {
            $conn = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME, DB_USER, DB_PASS);
            $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            
            $stmt = $conn->prepare("SELECT * FROM pending_subscriptions WHERE order_id = ? AND status = 'pending'");
            $stmt->execute([$orderId]);
            $order = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($order) {
                // Activate it via the same logic used in user_subscription_api.php
                $planStmt = $conn->prepare("SELECT duration_days FROM subscription_plans WHERE id = ?");
                $planStmt->execute([$order['plan_id']]);
                $plan = $planStmt->fetch(PDO::FETCH_ASSOC);

                if ($plan) {
                    $durationDays = $plan['duration_days'];
                    $start_date = date('Y-m-d H:i:s');
                    $end_date = date('Y-m-d H:i:s', strtotime("+$durationDays days"));

                    $insert = $conn->prepare("INSERT INTO user_subscriptions (user_id, plan_id, start_date, end_date, payment_id, status) VALUES (?, ?, ?, ?, ?, 'active')");
                    $insert->execute([$order['user_id'], $order['plan_id'], $start_date, $end_date, $orderId]);

                    $upd = $conn->prepare("UPDATE pending_subscriptions SET status = 'completed' WHERE order_id = ?");
                    $upd->execute([$orderId]);

                    echo json_encode(["success" => true, "message" => "Subscription activated successfully!"]);
                } else {
                    throw new Exception("Invalid plan in pending order.");
                }
            } else {
                echo json_encode(["success" => true, "message" => "Order already processed or not found."]);
            }
        } catch (Exception $e) {
            echo json_encode(["success" => false, "message" => "DB Error: " . $e->getMessage()]);
        }
    }
    else {
        throw new Exception("Invalid action");
    }
} catch (Exception $e) {
    logDebug("Error: " . $e->getMessage());
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>
