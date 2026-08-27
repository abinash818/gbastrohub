<?php
header("Access-Control-Allow-Origin: *");

error_reporting(0);
ini_set('display_errors', 0);
ini_set('log_errors', 1);
ini_set('error_log', dirname(__FILE__) . '/error_log.txt');

function logDebug($msg) {
    file_put_contents(dirname(__FILE__) . '/error_log.txt', "[" . date('Y-m-d H:i:s') . "] [AADHIGURU-PAY] " . $msg . "\n", FILE_APPEND);
}

// Require Guruji's PhonePe config (assuming this file is placed in Guruji's api folder)
require_once dirname(__FILE__) . '/phonepe_config.php';

$clientId = PHONEPE_CLIENT_ID;
$clientSecret = PHONEPE_CLIENT_SECRET;
$merchantId = PHONEPE_MERCHANT_ID;
$env = PHONEPE_ENV;
$baseUrl = ($env === 'SANDBOX') ? 'https://api-preprod.phonepe.com/apis/pg-sandbox' : 'https://api.phonepe.com/apis/pg';

$action = $_GET['action'] ?? '';

define('S2S_SECRET', 'Gbastro_S2S_Secret_2026!');
$hostingerApiUrl = "https://deeppink-hedgehog-734715.hostingersite.com/user_subscription_api.php";

function callHostingerApi($action, $data) {
    global $hostingerApiUrl;
    $data['action'] = $action;
    $payloadString = json_encode($data);
    $signature = hash_hmac('sha256', $payloadString, S2S_SECRET);
    
    $ch = curl_init($hostingerApiUrl);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $payloadString);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'X-Signature: ' . $signature
    ]);
    $res = curl_exec($ch);
    if(curl_errno($ch)) {
        logDebug("cURL Error calling Hostinger ($action): " . curl_error($ch));
        curl_close($ch);
        return ["success" => false, "message" => "Connection to Hostinger failed"];
    }
    curl_close($ch);
    $decoded = json_decode($res, true);
    return $decoded ?: ["success" => false, "message" => "Invalid JSON from Hostinger: " . $res];
}

try {
    if ($action === 'initiate') {
        $amount = isset($_GET['amount']) ? (int)$_GET['amount'] : 0; // Amount in paisa
        $userId = $_GET['user_id'] ?? '';
        $planId = $_GET['plan_id'] ?? '';
        
        if (empty($userId) || empty($planId)) {
            echo json_encode(["success" => false, "message" => "Invalid parameters"]);
            exit();
        }

        $orderId = $_GET['order_id'] ?? ("AADHI" . time() . rand(100, 999));

        if ($amount < 100) {
            // Activate Demo immediately through Hostinger API
            $demoRes = callHostingerApi('activate_demo', [
                'order_id' => $orderId,
                'user_id' => $userId,
                'plan_id' => $planId,
                'amount' => 0
            ]);

            if (isset($demoRes['success']) && $demoRes['success']) {
                echo json_encode([
                    "success" => true,
                    "paymentUrl" => "DEMO",
                    "orderId" => $orderId
                ]);
                exit();
            } else {
                echo json_encode(["success" => false, "message" => "Failed to activate demo plan"]);
                exit();
            }
        }


        // IMPORTANT: Tell Hostinger about this order before hitting PhonePe
        $initRes = callHostingerApi('initiate_order', [
            'order_id' => $orderId,
            'user_id' => $userId,
            'plan_id' => $planId,
            'amount' => $amount
        ]);
        
        if (!isset($initRes['success']) || !$initRes['success']) {
            echo json_encode(["success" => false, "message" => "Failed to initialize order in DB"]);
            exit();
        }

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
        $tokenData = json_decode($response, true);
        curl_close($ch);

        if (!isset($tokenData['access_token'])) {
            logDebug("Token generation failed");
            die("Failed to authorize with PhonePe");
        }

        $accessToken = $tokenData['access_token'];

        // 2. Create Payment Request
        $paymentUrl = $baseUrl . '/checkout/v2/pay';
        
        $redirectUrl = "https://abinaasananthaguruji.com/api/payment_status.php?orderId=$orderId";
        // Setup webhook callback url pointing directly to Hostinger
        $webhookUrl = "https://deeppink-hedgehog-734715.hostingersite.com/user_subscription_api.php?action=webhook";

        $payload = [
            "merchantId" => $merchantId,
            "merchantOrderId" => $orderId,
            "amount" => $amount,
            "callbackUrl" => $webhookUrl,
            "paymentFlow" => [
                "type" => "PG_CHECKOUT",
                "merchantUrls" => [
                    "redirectUrl" => $redirectUrl
                ]
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
            echo json_encode(["success" => false, "message" => "Failed to initiate payment"]);
            exit();
        }

        // Return JSON instead of redirecting
        echo json_encode([
            "success" => true,
            "paymentUrl" => $paymentData['redirectUrl'],
            "orderId" => $orderId
        ]);
        exit();

    } elseif ($action === 'check_status') {
        $orderId = $_GET['orderId'] ?? '';
        
        if (!$orderId) die(json_encode(["success" => false, "message" => "Order ID missing"]));

        // We DO NOT hit PhonePe directly here anymore! 
        // We just query our payment_orders table via Hostinger
        $statusRes = callHostingerApi('check_order_status', [
            'order_id' => $orderId
        ]);
        
        if (isset($statusRes['success']) && $statusRes['success']) {
            if ($statusRes['status'] === 'COMPLETED') {
                echo json_encode(["success" => true, "is_premium" => true, "message" => "Subscription created"]);
            } else if ($statusRes['status'] === 'FAILED') {
                echo json_encode(["success" => false, "message" => "Payment Failed"]);
            } else {
                echo json_encode(["success" => false, "message" => "Payment Pending"]);
            }
        } else {
            echo json_encode(["success" => false, "message" => "Could not fetch status: " . ($statusRes['message'] ?? 'Unknown')]);
        }
        exit();

    } else {
        die(json_encode(["success" => false, "message" => "Invalid action"]));
    }
} catch (Exception $e) {
    logDebug("Error: " . $e->getMessage());
    echo json_encode(["success" => false, "message" => "Error occurred. Please try again."]);
}
?>
