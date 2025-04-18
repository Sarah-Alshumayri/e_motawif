<?php
include 'config.php';

$user_id = $_POST['user_id'] ?? '';
$title = $_POST['title'] ?? '';
$message = $_POST['message'] ?? '';
$sender_name = $_POST['sender_name'] ?? '';

$response = [];

if (!$user_id || !$message) {
    $response['success'] = false;
    $response['message'] = "Required fields are missing.";
} else {
    $sql = "INSERT INTO notifications (user_id, sender_name, title, message) VALUES (?, ?, ?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ssss", $user_id, $sender_name, $title, $message);

    if ($stmt->execute()) {
        $response['success'] = true;
        $response['message'] = "Notification sent successfully.";
    } else {
        $response['success'] = false;
        $response['message'] = "Failed to send notification.";
    }
}

echo json_encode($response);
?>
