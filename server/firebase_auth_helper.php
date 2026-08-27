<?php
// server/firebase_auth_helper.php

/**
 * Encodes data to Base64URL format.
 */
function base64UrlEncode($data) {
    return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
}

/**
 * Generates an OAuth2 Access Token using the Firebase Service Account JSON.
 */
function getFirebaseAccessToken($credentialsPath) {
    if (!file_exists($credentialsPath)) {
        return null;
    }

    $json = file_get_contents($credentialsPath);
    $credentials = json_decode($json, true);

    if (!$credentials || !isset($credentials['client_email']) || !isset($credentials['private_key'])) {
        return null;
    }

    $header = json_encode([
        'alg' => 'RS256',
        'typ' => 'JWT'
    ]);

    $now = time();
    $payload = json_encode([
        'iss' => $credentials['client_email'],
        'scope' => 'https://www.googleapis.com/auth/identitytoolkit https://www.googleapis.com/auth/firebase',
        'aud' => 'https://oauth2.googleapis.com/token',
        'exp' => $now + 3600,
        'iat' => $now
    ]);

    $base64UrlHeader = base64UrlEncode($header);
    $base64UrlPayload = base64UrlEncode($payload);

    $signatureInput = $base64UrlHeader . "." . $base64UrlPayload;

    $signature = '';
    $privateKey = $credentials['private_key'];
    
    $success = openssl_sign($signatureInput, $signature, $privateKey, OPENSSL_ALGO_SHA256);
    
    if (!$success) {
        return null;
    }

    $base64UrlSignature = base64UrlEncode($signature);
    $jwt = $signatureInput . "." . $base64UrlSignature;

    $postFields = http_build_query([
        'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion' => $jwt
    ]);

    $ch = curl_init('https://oauth2.googleapis.com/token');
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $postFields);
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/x-www-form-urlencoded']);

    $response = curl_exec($ch);
    curl_close($ch);

    $responseData = json_decode($response, true);
    return isset($responseData['access_token']) ? $responseData['access_token'] : null;
}

/**
 * Gets a user's UID by email or phone number.
 */
function getFirebaseUserUid($accessToken, $projectId, $email = null, $phone = null) {
    $payload = [];
    if (!empty($email)) {
        $payload['email'] = [$email];
    } else if (!empty($phone)) {
        // Phone numbers in Firebase Auth usually require the + prefix. 
        // We will try looking it up as is. If your DB doesn't have '+', you might need to append it based on country code.
        $payload['phoneNumber'] = [$phone]; 
    } else {
        return null;
    }

    $ch = curl_init("https://identitytoolkit.googleapis.com/v1/projects/{$projectId}/accounts:lookup");
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Authorization: Bearer ' . $accessToken
    ]);

    $response = curl_exec($ch);
    curl_close($ch);

    $responseData = json_decode($response, true);
    if (isset($responseData['users']) && count($responseData['users']) > 0) {
        return $responseData['users'][0]['localId']; // UID
    }

    return null;
}

/**
 * Deletes a Firebase user by UID.
 */
function deleteFirebaseUserByUid($accessToken, $projectId, $uid) {
    $payload = ['localId' => $uid];

    $ch = curl_init("https://identitytoolkit.googleapis.com/v1/projects/{$projectId}/accounts:delete");
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Authorization: Bearer ' . $accessToken
    ]);

    $response = curl_exec($ch);
    curl_close($ch);

    $responseData = json_decode($response, true);
    // An empty JSON object {} indicates success
    return true; 
}

/**
 * High-level function to delete a user from Firebase Auth using their email or phone.
 */
function deleteUserFromFirebase($email, $phone) {
    $credentialsPath = __DIR__ . '/firebase_credentials.json';
    
    if (!file_exists($credentialsPath)) {
        // No credentials file found, cannot delete from Firebase
        return false;
    }

    $json = file_get_contents($credentialsPath);
    $credentials = json_decode($json, true);
    if (!$credentials || !isset($credentials['project_id'])) {
        return false;
    }
    $projectId = $credentials['project_id'];

    $accessToken = getFirebaseAccessToken($credentialsPath);
    if (!$accessToken) {
        return false;
    }

    // Try looking up by email first, then phone
    $uid = getFirebaseUserUid($accessToken, $projectId, $email, null);
    if (!$uid && !empty($phone)) {
        $uid = getFirebaseUserUid($accessToken, $projectId, null, $phone);
    }
    // Some formats of phone number might need a '+' prefix if missing.
    if (!$uid && !empty($phone) && substr($phone, 0, 1) !== '+') {
        $uid = getFirebaseUserUid($accessToken, $projectId, null, '+' . $phone);
    }
    if (!$uid && !empty($phone) && substr($phone, 0, 3) !== '+91') {
        // Try India format if no country code provided
        $uid = getFirebaseUserUid($accessToken, $projectId, null, '+91' . $phone);
    }

    if ($uid) {
        return deleteFirebaseUserByUid($accessToken, $projectId, $uid);
    }

    // User not found in Firebase, nothing to delete
    return true; 
}
?>
