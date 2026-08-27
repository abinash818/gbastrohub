<?php
// aadhiguru_checkout.php
// This file serves as a bridge between the Flutter app and PhonePe Web SDK.
// It generates the token using aadhiguru_payment.php logic and auto-opens the SDK.

$amount = $_GET['amount'] ?? 0;
$userId = $_GET['user_id'] ?? '';
$planId = $_GET['plan_id'] ?? '';
$orderId = $_GET['order_id'] ?? ("APP" . time() . rand(10, 99));

if (empty($userId) || empty($planId)) {
    die("Invalid parameters");
}

// 1. We call our own API locally to get the token URL
$apiUrl = "https://abinaasananthaguruji.com/api/aadhiguru_payment.php?action=initiate&amount=$amount&user_id=$userId&plan_id=$planId&order_id=$orderId";

// Fetch token
$ch = curl_init($apiUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$res = curl_exec($ch);
curl_close($ch);

$data = json_decode($res, true);

if (!$data || !isset($data['success']) || !$data['success']) {
    die("Failed to initialize payment: " . ($data['message'] ?? $res));
}

$tokenUrl = $data['paymentUrl'];
$orderId = $data['orderId'];
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Aadhiguru Secure Payment</title>
    <!-- Load PhonePe Web SDK -->
    <?php if ($tokenUrl !== "DEMO"): ?>
    <script src="https://mercury.phonepe.com/web/bundle/checkout.js"></script>
    <?php endif; ?>
    <style>
        body { font-family: 'Inter', Arial, sans-serif; background-color: #FFF9EE; text-align: center; padding-top: 100px; margin: 0; }
        .loader { border: 4px solid #f3f3f3; border-top: 4px solid #B58D3D; border-radius: 50%; width: 40px; height: 40px; animation: spin 1s linear infinite; margin: 20px auto; }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
        h3 { color: #5D1204; font-size: 20px; font-weight: bold; }
        p { color: #666; font-size: 15px; max-width: 80%; margin: 10px auto; line-height: 1.5; }
        .success-box { display: none; background: white; border: 2px solid #4CAF50; padding: 30px; border-radius: 12px; margin: 20px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
    </style>
</head>
<body>
    
    <div id="loadingBox">
        <h3><?php echo ($tokenUrl === "DEMO") ? "Activating Demo..." : "Starting Secure Payment..."; ?></h3>
        <div class="loader"></div>
        <p>Please do not press back or close this window.</p>
    </div>

    <div id="successBox" class="success-box">
        <h3 style="color: #4CAF50;"><?php echo ($tokenUrl === "DEMO") ? "Demo Plan Activated Successfully! 🎉" : "Payment Completed Successfully! 🎉"; ?></h3>
        <p>You can now safely close this browser tab, go back to the Aadhiguru App, and click <b>Verify Payment</b> to activate your subscription.</p>
    </div>

    <div id="errorBox" class="success-box" style="border-color: #f44336;">
        <h3 style="color: #f44336;">Payment Canceled or Failed</h3>
        <p>If money was deducted, it will be refunded. Please close this window and try again from the app.</p>
    </div>

    <script>
        document.addEventListener("DOMContentLoaded", function() {
            var tokenUrl = "<?php echo $tokenUrl; ?>";
            
            if (tokenUrl === "DEMO") {
                document.getElementById('loadingBox').style.display = 'none';
                document.getElementById('successBox').style.display = 'block';
                return;
            }
            
            // Open PhonePe SDK
            if (window.PhonePeCheckout) {
                window.PhonePeCheckout.transact({
                    tokenUrl: tokenUrl,
                    callback: function(response) {
                        document.getElementById('loadingBox').style.display = 'none';
                        
                        // Check response
                        if (response === 'CONCLUDED' || response === 'SUCCESS') {
                            document.getElementById('successBox').style.display = 'block';
                        } else {
                            document.getElementById('errorBox').style.display = 'block';
                        }
                    }
                });
            } else {
                alert("Payment gateway failed to load. Please try again.");
            }
        });
    </script>
</body>
</html>
