<?php
// server/muruga_api.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

$host = "127.0.0.1";
$db_name = "u682341828_gbastro";
$username = "u682341828_gbastro";
$password = "Gbastro@2026";

try {
    $conn = new PDO("mysql:host=" . $host . ";dbname=" . $db_name, $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $exception) {
    echo json_encode(array("error" => "Connection error: " . $exception->getMessage()));
    exit();
}

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->action)) {
    $action = $data->action;

    // 1. Check Device Status & Expiry
    if ($action == "check_status") {
        $email = $data->email;
        $device_id = $data->device_id;

        // Bypass device verification for Play Store Reviewer account
        if (strtolower($email) === 'playstore@gbastro.com') {
            echo json_encode(array("status" => "APPROVED", "message" => "Reviewer access granted", "access" => (object)array()));
            exit();
        }

        $query = "SELECT u.*, p.features FROM app_users u LEFT JOIN subscription_plans p ON u.plan_id = p.id WHERE u.email = :email LIMIT 1";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(":email", $email);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            $user = $stmt->fetch(PDO::FETCH_ASSOC);

            // Construct access map
            $access = new stdClass();
            $allowed = array();
            
            if ($user['custom_features'] !== null) {
                // Admin manually saved custom features, so override plan features
                $custom_arr = json_decode($user['custom_features'], true);
                if (is_array($custom_arr)) {
                    $allowed = $custom_arr;
                }
            } else {
                // Default to Plan features
                if (!empty($user['features'])) {
                    $allowed = array_map('trim', explode(',', $user['features']));
                }
            }

            $access->can_view_jathagam = in_array('ஜாதகம்', $allowed) || in_array('jathagam', $allowed);
            $access->can_view_matching = in_array('பொருத்தம்', $allowed) || in_array('porutham', $allowed);
            $access->can_view_kp = in_array('KP', $allowed) || in_array('kp_astrology', $allowed);
            $access->can_view_numerology = in_array('எண் கணிதம்', $allowed) || in_array('numerology', $allowed);
            $access->can_view_jamakkol = in_array('ஜாமக்கோள்', $allowed) || in_array('jamakkol', $allowed);
            $access->can_view_nadi = in_array('நாடி', $allowed) || in_array('nadi', $allowed);
            $access->can_view_muhurtham = in_array('சுபநேரம்', $allowed) || in_array('muhurtham', $allowed);
            $access->can_view_panchangam = in_array('பஞ்சாங்கம்', $allowed) || in_array('panchangam', $allowed);
            
            // Check Expiry Date
            if (!empty($user['expiry_date'])) {
                $expiry = strtotime($user['expiry_date']);
                $today = strtotime(date('Y-m-d'));
                if ($expiry < $today) {
                    echo json_encode(array("status" => "EXPIRED", "message" => "Your subscription expired on " . $user['expiry_date']));
                    exit();
                }
            }

            // Check if device is already registered for this user
            $dev_query = "SELECT id FROM user_devices WHERE user_id = :user_id AND device_id = :device_id";
            $dev_stmt = $conn->prepare($dev_query);
            $dev_stmt->bindParam(":user_id", $user['id']);
            $dev_stmt->bindParam(":device_id", $device_id);
            $dev_stmt->execute();

            if ($dev_stmt->rowCount() > 0) {
                // Device matched
                echo json_encode(array("status" => $user['status'], "message" => "Device matched", "access" => $access));
            } else {
                // New device check
                $count_query = "SELECT COUNT(*) as count FROM user_devices WHERE user_id = :user_id";
                $count_stmt = $conn->prepare($count_query);
                $count_stmt->bindParam(":user_id", $user['id']);
                $count_stmt->execute();
                $count = $count_stmt->fetch(PDO::FETCH_ASSOC)['count'];

                if ($count < $user['device_limit']) {
                    echo json_encode(array("status" => "NEW_DEVICE", "message" => "You can register " . ($user['device_limit'] - $count) . " more devices."));
                } else {
                    echo json_encode(array("status" => "LIMIT_REACHED", "message" => "Device limit reached (" . $user['device_limit'] . "). Contact Admin."));
                }
            }
        } else {
            echo json_encode(array("status" => "NOT_REGISTERED", "message" => "User not found"));
        }
    }

    // 2. Register / Update Device Info
    else if ($action == "register_device") {
        $email = $data->email;
        $device_id = $data->device_id;
        $device_model = $data->device_model;
        $phone_number = $data->phone_number;

        // Find or Create User
        $user_query = "SELECT id, status, device_limit FROM app_users WHERE email = :email";
        $u_stmt = $conn->prepare($user_query);
        $u_stmt->bindParam(":email", $email);
        $u_stmt->execute();

        if ($u_stmt->rowCount() > 0) {
            $user = $u_stmt->fetch(PDO::FETCH_ASSOC);
            $user_id = $user['id'];
            
            // Check if limit is reached
            $count_query = "SELECT COUNT(*) as count FROM user_devices WHERE user_id = :user_id";
            $count_stmt = $conn->prepare($count_query);
            $count_stmt->bindParam(":user_id", $user_id);
            $count_stmt->execute();
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC)['count'];

            if ($count >= $user['device_limit']) {
                echo json_encode(array("success" => false, "message" => "Device limit reached."));
                exit();
            }

            // Update user info
            $update = $conn->prepare("UPDATE app_users SET phone_number = :phone WHERE id = :id");
            $update->execute([':phone' => $phone_number, ':id' => $user_id]);
        } else {
            // New user registration
            $insert = $conn->prepare("INSERT INTO app_users (email, phone_number, status, device_limit) VALUES (:email, :phone, 'PENDING', 1)");
            $insert->execute([':email' => $email, ':phone' => $phone_number]);
            $user_id = $conn->lastInsertId();
        }

        // Add device to user_devices
        $dev_insert = $conn->prepare("INSERT INTO user_devices (user_id, device_id, device_model) VALUES (:user_id, :device_id, :device_model)");
        $dev_insert->bindParam(":user_id", $user_id);
        $dev_insert->bindParam(":device_id", $device_id);
        $dev_insert->bindParam(":device_model", $device_model);

        if ($dev_insert->execute()) {
            echo json_encode(array("success" => true, "message" => "Device registration pending approval."));
        } else {
            echo json_encode(array("success" => false, "message" => "Failed to add device."));
        }
    }
}
?>
