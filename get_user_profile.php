<?php
header('Content-Type: application/json');
include 'config.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $user_id = $_POST['user_id'] ?? '';

    if (empty($user_id)) {
        echo json_encode(["status" => "error", "message" => "Missing user_id"]);
        exit();
    }

    $stmt = $conn->prepare("SELECT name, email, phone, dob, id_type, user_id, emergencyContact, sickness FROM users WHERE user_id = ?");
    $stmt->bind_param("s", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result && $result->num_rows > 0) {
        $row = $result->fetch_assoc();
        echo json_encode([
            "status" => "success",
            "data" => [
                "name" => $row["name"],
                "email" => $row["email"],
                "phone" => $row["phone"],
                "dob" => $row["dob"],
                "id_type" => $row["id_type"],
                "user_id" => $row["user_id"],
                "emergencyContact" => $row["emergencyContact"] ?? "",
                "sickness" => $row["sickness"] ?? ""
            ]
        ]);
    } else {
        echo json_encode(["status" => "error", "message" => "User not found"]);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method"]);
}
