<?php
include 'config.php';
header('Content-Type: application/json');

$response = [];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $user_id = $_POST['user_id'] ?? '';
    $name = $_POST['name'] ?? '';
    $email = $_POST['email'] ?? '';
    $role = $_POST['role'] ?? '';

    $stmt = $conn->prepare("UPDATE users SET name = ?, email = ?, role = ? WHERE user_id = ?");
    $stmt->bind_param("ssss", $name, $email, $role, $user_id);

    if ($stmt->execute()) {
        $response['success'] = true;
        $response['message'] = "User updated successfully.";
    } else {
        $response['success'] = false;
        $response['message'] = "Update failed: " . $stmt->error;
    }

    $stmt->close();
} else {
    $response['success'] = false;
    $response['message'] = "Invalid request.";
}

echo json_encode($response);
?>
