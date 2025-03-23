<?php
header('Content-Type: application/json');
include 'config.php'; // Ensure this file has DB connection code

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $user_id = $_POST['user_id'] ?? '';

    if (empty($user_id)) {
        echo json_encode(["status" => "error", "message" => "Missing user_id"]);
        exit();
    }

    $stmt = $conn->prepare("SELECT name, email, phone, dob, role FROM users WHERE user_id = ?");
    $stmt->bind_param("s", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result && $result->num_rows > 0) {
        $userData = $result->fetch_assoc();
        echo json_encode(["status" => "success", "data" => $userData]);
    } else {
        echo json_encode(["status" => "error", "message" => "User not found"]);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method"]);
}
