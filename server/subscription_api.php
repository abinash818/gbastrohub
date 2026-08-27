<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-Signature");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

$host = "127.0.0.1";
$db_name = "u682341828_gbastro";
$username = "u682341828_gbastro";
$password = "Gbastro@2026";

try {
    $conn = new PDO("mysql:host=" . $host . ";dbname=" . $db_name, $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Auto-create table if not exists (for easy setup)
    $createTableQuery = "CREATE TABLE IF NOT EXISTS subscription_plans (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        price DECIMAL(10,2) NOT NULL,
        duration_days INT NOT NULL,
        features TEXT NOT NULL, 
        is_active TINYINT(1) DEFAULT 1,
        plan_order INT DEFAULT 0
    )";
    $conn->exec($createTableQuery);

} catch(PDOException $e) {
    echo json_encode(["success" => false, "message" => "Connection failed: " . $e->getMessage()]);
    exit();
}

$method = $_SERVER['REQUEST_METHOD'];

try {
    if ($method == 'GET') {
        $query = "SELECT * FROM subscription_plans WHERE is_active = 1 ORDER BY plan_order ASC";
        $stmt = $conn->prepare($query);
        $stmt->execute();
        $plans = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Convert features string (comma-separated) back to array for Flutter
        foreach ($plans as &$plan) {
            $plan['features'] = $plan['features'] ? explode(',', $plan['features']) : [];
        }

        echo json_encode(["success" => true, "plans" => $plans]);
    } else if ($method == 'POST') {
        $data = json_decode(file_get_contents("php://input"));
        if (!empty($data->action)) {
            $action = $data->action;
            if ($action == 'get_all_plans') {
                $stmt = $conn->prepare("SELECT * FROM subscription_plans ORDER BY plan_order ASC");
                $stmt->execute();
                echo json_encode(["success" => true, "plans" => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
            } else if ($action == 'create_plan') {
                $stmt = $conn->prepare("INSERT INTO subscription_plans (name, price, duration_days, features, is_active, plan_order) VALUES (:name, :price, :duration_days, :features, :is_active, :plan_order)");
                $stmt->execute([
                    ':name' => $data->name,
                    ':price' => $data->price,
                    ':duration_days' => $data->duration_days,
                    ':features' => $data->features,
                    ':is_active' => $data->is_active,
                    ':plan_order' => $data->plan_order
                ]);
                echo json_encode(["success" => true, "message" => "Plan created successfully"]);
            } else if ($action == 'update_plan') {
                $stmt = $conn->prepare("UPDATE subscription_plans SET name=:name, price=:price, duration_days=:duration_days, features=:features, is_active=:is_active, plan_order=:plan_order WHERE id=:id");
                $stmt->execute([
                    ':name' => $data->name,
                    ':price' => $data->price,
                    ':duration_days' => $data->duration_days,
                    ':features' => $data->features,
                    ':is_active' => $data->is_active,
                    ':plan_order' => $data->plan_order,
                    ':id' => $data->id
                ]);
                echo json_encode(["success" => true, "message" => "Plan updated successfully"]);
            } else if ($action == 'delete_plan') {
                $stmt = $conn->prepare("DELETE FROM subscription_plans WHERE id=:id");
                $stmt->execute([':id' => $data->id]);
                echo json_encode(["success" => true, "message" => "Plan deleted successfully"]);
            } else {
                echo json_encode(["success" => false, "message" => "Unknown action"]);
            }
        }
    }
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Server Error: " . $e->getMessage()]);
}
?>
