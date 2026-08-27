<?php
$orderId = $_GET['orderId'] ?? '';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Status</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #2b2b2b;
            color: white;
            text-align: center;
            padding: 50px;
            margin: 0;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .container {
            background-color: #3b3b3b;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.5);
            max-width: 400px;
        }
        h2 {
            color: #4CAF50;
            margin-bottom: 10px;
        }
        p {
            font-size: 16px;
            line-height: 1.5;
            color: #ccc;
        }
        .close-btn {
            display: inline-block;
            margin-top: 20px;
            padding: 12px 25px;
            background-color: #B58D3D;
            color: white;
            text-decoration: none;
            font-weight: bold;
            border-radius: 5px;
            border: none;
            font-size: 16px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Payment Completed!</h2>
        <p>Your payment process has been recorded.</p>
        <p>Please click the <strong>'X' (Close)</strong> button at the top left corner of this screen to return to the app and activate your subscription.</p>
    </div>
</body>
</html>
