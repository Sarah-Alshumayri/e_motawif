<?php
header('Content-Type: application/json');
include 'config.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $user_id = $_POST["user_id"] ?? '';
    $password = $_POST["password"] ?? '';

    if (empty($user_id) || empty($password)) {
        echo json_encode(["status" => "error", "message" => "Missing credentials"]);
        exit();
    }

    $stmt = $conn->prepare("SELECT id, role FROM users WHERE user_id = ? AND password = ?");
    $stmt->bind_param("ss", $user_id, $password);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $user = $result->fetch_assoc();
        echo json_encode(["status" => "success", "role" => $user["role"]]);
    } else {
        echo json_encode(["status" => "error", "message" => "Invalid credentials"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request"]);
}
?>
