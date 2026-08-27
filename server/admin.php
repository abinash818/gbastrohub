<?php
// server/admin.php

// --- DATABASE CONFIGURATION ---
$host = "localhost";
$db_name = "u682341828_gbastro";
$username = "u682341828_gbastro";
$password = "Gbastro@2026";

try {
    $conn = new PDO("mysql:host=" . $host . ";dbname=" . $db_name, $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    die("Connection failed: " . $e->getMessage());
}

// Handle Actions (Approve, Block, Delete)
if (isset($_GET['action']) && isset($_GET['id'])) {
    $id = $_GET['id'];
    $action = $_GET['action'];

    if ($action == 'approve') {
        $stmt = $conn->prepare("UPDATE app_users SET status = 'APPROVED' WHERE id = :id");
    } else if ($action == 'block') {
        $stmt = $conn->prepare("UPDATE app_users SET status = 'BLOCKED' WHERE id = :id");
    } else if ($action == 'delete') {
        $stmt = $conn->prepare("DELETE FROM app_users WHERE id = :id");
    }

    if (isset($stmt)) {
        $stmt->bindParam(':id', $id);
        $stmt->execute();
    }
    header("Location: admin.php"); // Refresh page
    exit();
}

// Fetch all users with device details
$stmt = $conn->prepare("SELECT u.*, (SELECT d.device_model FROM user_devices d WHERE d.user_id = u.id LIMIT 1) as device_model, u.created_at as last_login FROM app_users u ORDER BY u.id DESC");
$stmt->execute();
$users = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html lang="ta">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GB Astro - Admin Panel</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f7f6; margin: 0; padding: 20px; }
        .container { max-width: 1000px; margin: auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h2 { color: #d35400; border-bottom: 2px solid #d35400; padding-bottom: 10px; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #d35400; color: white; }
        tr:hover { background-color: #f9f9f9; }
        .status { padding: 5px 10px; border-radius: 4px; font-size: 12px; font-weight: bold; }
        .status-PENDING { background-color: #f39c12; color: white; }
        .status-APPROVED { background-color: #27ae60; color: white; }
        .status-BLOCKED { background-color: #c0392b; color: white; }
        .btn { padding: 6px 12px; text-decoration: none; border-radius: 4px; font-size: 13px; margin-right: 5px; }
        .btn-approve { background-color: #2ecc71; color: white; }
        .btn-block { background-color: #e67e22; color: white; }
        .btn-delete { background-color: #e74c3c; color: white; }

        @media (max-width: 768px) {
            body { padding: 10px; }
            .container { padding: 15px; }
            h2 { font-size: 20px; }
            
            table, thead, tbody, th, td, tr { 
                display: block; 
            }
            thead tr { 
                position: absolute;
                top: -9999px;
                left: -9999px;
            }
            tr {
                background: white;
                border-radius: 12px;
                margin-bottom: 15px;
                padding: 15px;
                border: 1px solid #ddd;
                box-shadow: 0 2px 5px rgba(0,0,0,0.05);
            }
            td { 
                border: none;
                padding: 8px 0;
                position: relative;
                padding-left: 45%; 
                text-align: left;
                border-bottom: 1px dashed #eee;
            }
            td:last-child {
                border-bottom: none;
                padding-bottom: 0;
            }
            td:before { 
                position: absolute;
                top: 50%;
                left: 6px;
                transform: translateY(-50%);
                width: 40%; 
                padding-right: 10px; 
                white-space: nowrap;
                font-weight: bold;
                color: #555;
                font-size: 11px;
                text-transform: uppercase;
            }
            
            td:nth-of-type(1) { padding-left: 0; border-bottom: 1.5px solid #ddd; padding-bottom: 10px; margin-bottom: 5px; font-weight: bold; font-size: 14px; }
            td:nth-of-type(1):before { content: ""; }
            
            td:nth-of-type(2):before { content: "Phone"; }
            td:nth-of-type(3):before { content: "Device Model"; }
            td:nth-of-type(4):before { content: "Status"; }
            td:nth-of-type(5):before { content: "Last Seen"; }
            td:nth-of-type(6):before { content: "Actions"; }
            
            td:nth-of-type(6) {
                padding-left: 0;
                margin-top: 10px;
                display: flex;
                gap: 5px;
                flex-wrap: wrap;
            }
            td:nth-of-type(6):before { content: ""; }
            
            .btn {
                flex: 1;
                text-align: center;
                margin-right: 0;
                padding: 8px;
            }
        }
    </style>
</head>
<body>

<div class="container">
    <h2>GB Astro - User Management</h2>
    <p>மொத்தம் <strong><?php echo count($users); ?></strong> பயனர்கள் உள்ளனர்.</p>

    <table>
        <thead>
            <tr>
                <th>Email</th>
                <th>Phone</th>
                <th>Device Model</th>
                <th>Status</th>
                <th>Last Seen</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($users as $user): ?>
            <tr>
                <td><?php echo htmlspecialchars($user['email']); ?></td>
                <td><?php echo htmlspecialchars($user['phone_number']); ?></td>
                <td><?php echo htmlspecialchars($user['device_model']); ?></td>
                <td><span class="status status-<?php echo $user['status']; ?>"><?php echo $user['status']; ?></span></td>
                <td><?php echo $user['last_login']; ?></td>
                <td>
                    <?php if ($user['status'] != 'APPROVED'): ?>
                        <a href="admin.php?action=approve&id=<?php echo $user['id']; ?>" class="btn btn-approve">Approve</a>
                    <?php endif; ?>
                    
                    <?php if ($user['status'] != 'BLOCKED'): ?>
                        <a href="admin.php?action=block&id=<?php echo $user['id']; ?>" class="btn btn-block">Block</a>
                    <?php endif; ?>
                    
                    <a href="admin.php?action=delete&id=<?php echo $user['id']; ?>" class="btn btn-delete" onclick="return confirm('நிச்சயமாக நீக்க வேண்டுமா?')">Delete</a>
                </td>
            </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
</div>

</body>
</html>
