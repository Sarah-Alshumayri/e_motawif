<?php
include 'config.php';

header('Content-Type: application/json');

$user_id = $_POST['user_id'] ?? '';

$response = [];

if (empty($user_id)) {
    $response['success'] = false;
    $response['message'] = "User ID is missing.";
    echo json_encode($response);
    exit;
}

$sql = "SELECT sender_name, title, message, timestamp FROM notifications WHERE user_id = ? ORDER BY timestamp DESC";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $user_id);

if ($stmt->execute()) {
    $result = $stmt->get_result();
    $notifications = [];

    while ($row = $result->fetch_assoc()) {
        $notifications[] = [
            'sender_name' => $row['sender_name'],
            'title' => $row['title'],
            'message' => $row['message'],
            'timestamp' => $row['timestamp']
        ];
    }

    $response['success'] = true;
    $response['notifications'] = $notifications;
} else {
    $response['success'] = false;
    $response['message'] = "Failed to fetch notifications.";
}

echo json_encode($response);
?>
