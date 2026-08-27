<?php
$clientId = 'SU2603051136065347672044';
$clientSecret = '3b614f73-5af0-4765-9395-188fb1d3fd53';
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
$token = json_decode($res)->access_token;
curl_close($ch);

// Replace this with the actual Order ID the user just created: OMO2607261720524399947956V
$ch2 = curl_init('https://api.phonepe.com/apis/pg/checkout/v2/order/OMO2607261720524399947956V/status');
curl_setopt($ch2, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch2, CURLOPT_HTTPHEADER, ['Authorization: O-Bearer ' . $token]);
$res2 = curl_exec($ch2);
echo $res2;
