<?php
require_once 'config.php';

// Ensure the logs directory exists
$log_dir = __DIR__ . '/logs';
if (!is_dir($log_dir)) {
    mkdir($log_dir, 0755, true);
}

// 1. Get raw input and headers
$input = file_get_contents('php://input');
$headers = getallheaders();
$auth_header = $headers['Authorization'] ?? ($headers['authorization'] ?? '');

// 2. Validate Authorization
// PhonePe V2 Standard Checkout matches: SHA256(username:password)
$expected_auth = hash('sha256', WEBHOOK_USERNAME . ':' . WEBHOOK_PASSWORD);

if (empty($auth_header) || $auth_header !== $expected_auth) {
    // Log unauthorized attempt
    file_put_contents($log_dir . '/webhook_errors.log', date('[Y-m-d H:i:s] ') . "Unauthorized Webhook Attempt. IP: " . $_SERVER['REMOTE_ADDR'] . "\n", FILE_APPEND);
    http_response_code(401);
    exit("Unauthorized");
}

// 3. Process Payload
$data = json_decode($input, true);

if ($data) {
    // Log the successful notification
    $order_id = $data['orderId'] ?? ($data['payload']['orderId'] ?? 'Unknown');
    $state = $data['state'] ?? ($data['payload']['state'] ?? 'Unknown');
    
    $log_entry = date('[Y-m-d H:i:s] ') . "Order ID: $order_id | State: $state | Raw: $input\n";
    file_put_contents($log_dir . '/payments.log', $log_entry, FILE_APPEND);
    
    // Respond with 200 OK
    http_response_code(200);
    echo "OK";
} else {
    // Invalid JSON
    file_put_contents($log_dir . '/webhook_errors.log', date('[Y-m-d H:i:s] ') . "Invalid JSON received: $input\n", FILE_APPEND);
    http_response_code(400);
    echo "Bad Request";
}
?>
