<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Status</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #FFF9EE;
            text-align: center;
            padding-top: 50px;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
            display: inline-block;
            border: 2px solid #B58D3D;
        }
        h2 { color: #5D1204; }
        p { font-size: 16px; color: #333; }
    </style>
</head>
<body>
    <div class="container">
        <h2>Payment Processed</h2>
        <p>Your payment attempt has been recorded.</p>
        <p>Please close this browser tab and go back to the app to verify your payment status.</p>
        <button style="padding: 10px 20px; background-color: #B58D3D; color: white; border: none; border-radius: 5px; font-size: 16px; cursor: pointer;" onclick="window.close()">Close Window</button>
    </div>
</body>
</html>
