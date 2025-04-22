<?php
include 'config.php';
header('Content-Type: application/json');

$user_id = trim($_POST['user_id'] ?? '');

$response = [];

if (empty($user_id)) {
    $response['success'] = false;
    $response['message'] = "User ID is missing.";
    echo json_encode($response);
    exit;
}

// 🔍 DEBUG
file_put_contents("debug_notifications.log", "Incoming user_id: '$user_id'\n", FILE_APPEND);

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

    // 🔍 DEBUG
    file_put_contents("debug_notifications.log", "Found: " . json_encode($notifications) . "\n", FILE_APPEND);

    $response['success'] = true;
    $response['notifications'] = $notifications;
} else {
    $response['success'] = false;
    $response['message'] = "Failed to fetch notifications.";
}

echo json_encode($response);
?>
