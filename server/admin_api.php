<?php
// server/admin_api.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

$host = "127.0.0.1";
$db_name = "u682341828_gbastro";
$username = "u682341828_gbastro";
$password = "Gbastro@2026";

try {
    $conn = new PDO("mysql:host=" . $host . ";dbname=" . $db_name, $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Auto-create plan_id column if not exists
    try {
        $conn->exec("ALTER TABLE app_users ADD COLUMN plan_id INT DEFAULT NULL");
    } catch(PDOException $e) { /* Ignore if exists */ }

    // Auto-create custom_features column if not exists
    try {
        $conn->exec("ALTER TABLE app_users ADD COLUMN custom_features TEXT DEFAULT NULL");
    } catch(PDOException $e) { /* Ignore if exists */ }

    // Auto-create purchased_date column if not exists
    try {
        $conn->exec("ALTER TABLE app_users ADD COLUMN purchased_date DATE DEFAULT NULL");
    } catch(PDOException $e) { /* Ignore if exists */ }
} catch(PDOException $e) {
    echo json_encode(["success" => false, "message" => "Connection failed: " . $e->getMessage()]);
    exit();
}

$method = $_SERVER['REQUEST_METHOD'];

try {
    if ($method == 'GET') {
        // Fetch users with their device counts
        $query = "SELECT u.*, 
                  (SELECT COUNT(*) FROM user_devices d WHERE d.user_id = u.id) as current_devices,
                  (SELECT GROUP_CONCAT(CONCAT(device_model, ' (', device_id, ')') SEPARATOR ', ') FROM user_devices d WHERE d.user_id = u.id) as device_list
                  FROM app_users u ORDER BY u.id DESC";
        $stmt = $conn->prepare($query);
        $stmt->execute();
        $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode(["success" => true, "users" => $users]);
    } 
    else if ($method == 'POST') {
        $data = json_decode(file_get_contents("php://input"));
        
        if (!empty($data->action) && !empty($data->id)) {
            $id = $data->id;
            $action = $data->action;
            $stmt = null;

            if ($action == 'approve') {
                $stmt = $conn->prepare("UPDATE app_users SET status = 'APPROVED' WHERE id = :id");
            } else if ($action == 'approve_with_settings') {
                $expiry = !empty($data->expiry_date) ? $data->expiry_date : null;
                $purchased = !empty($data->purchased_date) ? $data->purchased_date : null;
                $limit = !empty($data->device_limit) ? $data->device_limit : 1;
                $plan_id = !empty($data->plan_id) ? $data->plan_id : null;
                $stmt = $conn->prepare("UPDATE app_users SET status = 'APPROVED', expiry_date = :expiry, purchased_date = :purchased, device_limit = :limit, plan_id = :plan_id WHERE id = :id");
                $stmt->bindParam(':expiry', $expiry);
                $stmt->bindParam(':purchased', $purchased);
                $stmt->bindParam(':limit', $limit);
                $stmt->bindParam(':plan_id', $plan_id);
            } else if ($action == 'block') {
                $stmt = $conn->prepare("UPDATE app_users SET status = 'BLOCKED' WHERE id = :id");
            } else if ($action == 'delete') {
                // First get the user's email and phone from MySQL
                require_once __DIR__ . '/firebase_auth_helper.php';
                $stmtGet = $conn->prepare("SELECT email, phone_number FROM app_users WHERE id = :id");
                $stmtGet->bindParam(':id', $id);
                $stmtGet->execute();
                $userData = $stmtGet->fetch(PDO::FETCH_ASSOC);

                if ($userData) {
                    // Try to delete from Firebase
                    deleteUserFromFirebase($userData['email'], $userData['phone_number']);
                }

                // Proceed with deleting from MySQL
                $stmt = $conn->prepare("DELETE FROM app_users WHERE id = :id");
            } else if ($action == 'update_settings') {
                $expiry = !empty($data->expiry_date) ? $data->expiry_date : null;
                $purchased = !empty($data->purchased_date) ? $data->purchased_date : null;
                $limit = !empty($data->device_limit) ? $data->device_limit : 1;
                $plan_id = !empty($data->plan_id) ? $data->plan_id : null;
                $stmt = $conn->prepare("UPDATE app_users SET expiry_date = :expiry, purchased_date = :purchased, device_limit = :limit, plan_id = :plan_id WHERE id = :id");
                $stmt->bindParam(':expiry', $expiry);
                $stmt->bindParam(':purchased', $purchased);
                $stmt->bindParam(':limit', $limit);
                $stmt->bindParam(':plan_id', $plan_id);
            } else if ($action == 'clear_devices') {
                $stmt = $conn->prepare("DELETE FROM user_devices WHERE user_id = :id");
            } else if ($action == 'reset_password') {
                // If password column doesn't exist, this will fail
                $stmt = $conn->prepare("UPDATE app_users SET password = 'password@123' WHERE id = :id");
            } else if ($action == 'update_features') {
                $features = isset($data->features) ? json_encode($data->features) : null;
                $stmt = $conn->prepare("UPDATE app_users SET custom_features = :features WHERE id = :id");
                $stmt->bindParam(':features', $features);
            } else if ($action == 'update_features_and_approve') {
                $features = isset($data->features) ? json_encode($data->features) : null;
                $expiry = !empty($data->expiry_date) ? $data->expiry_date : null;
                $purchased = !empty($data->purchased_date) ? $data->purchased_date : null;
                $limit = !empty($data->device_limit) ? $data->device_limit : 1;
                $plan_id = !empty($data->plan_id) ? $data->plan_id : null;
                $stmt = $conn->prepare("UPDATE app_users SET status = 'APPROVED', custom_features = :features, expiry_date = :expiry, purchased_date = :purchased, device_limit = :limit, plan_id = :plan_id WHERE id = :id");
                $stmt->bindParam(':features', $features);
                $stmt->bindParam(':expiry', $expiry);
                $stmt->bindParam(':purchased', $purchased);
                $stmt->bindParam(':limit', $limit);
                $stmt->bindParam(':plan_id', $plan_id);
            }

            if ($stmt) {
                $stmt->bindParam(':id', $id);
                $stmt->execute();
                echo json_encode(["success" => true, "message" => "Operation $action successful"]);
            } else {
                echo json_encode(["success" => false, "message" => "Invalid action: $action"]);
            }
        } else {
            echo json_encode(["success" => false, "message" => "Invalid parameters"]);
        }
    }
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Server Error: " . $e->getMessage()]);
}
?>
