<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

$clientId = 'SU2603051136065347672044';
$clientSecret = '3b614f73-5af0-4765-9395-188fb1d3fd53';
$merchantId = 'M2363TYUYEP52';
$baseUrl = 'https://api.phonepe.com/apis/pg';

$tokenUrl = 'https://api.phonepe.com/apis/identity-manager/v1/oauth/token';

$ch = curl_init($tokenUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query([
    'grant_type' => 'client_credentials',
    'client_id' => $clientId,
    'client_secret' => $clientSecret,
    'client_version' => '1'
]));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/x-www-form-urlencoded']);

$res = curl_exec($ch);
$tokenData = json_decode($res, true);
curl_close($ch);

if (!isset($tokenData['access_token'])) {
    die("Token failed: " . $res);
}
echo "Token success.\n";

$accessToken = $tokenData['access_token'];
$orderId = "TEST" . time();

$payload = [
    "merchantOrderId" => $orderId,
    "amount" => 100, // 1 INR
    "paymentFlow" => [
        "type" => "PG_CHECKOUT",
        "merchantUrls" => [
            "redirectUrl" => "https://abinasanandaguruji.com/payment-status"
        ]
    ]
];

$ch = curl_init($baseUrl . '/checkout/v2/pay');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Authorization: O-Bearer ' . $accessToken
]);

$res = curl_exec($ch);
echo "Payment Init: " . $res . "\n";
