<?php
header("Content-Type: application/json; charset=UTF-8");
include 'config.php';

// Prepare the response array
$response = [
    'success' => false,
    'message' => 'Something went wrong.'
];

// Check if required fields exist
if (isset($_POST['sender_id']) && isset($_POST['receiver_id']) && isset($_POST['message'])) {
    $sender_id = trim($_POST['sender_id']);
    $receiver_id = trim($_POST['receiver_id']);
    $message = trim($_POST['message']);

    // Optional: Check if fields are empty
    if ($sender_id === '' || $receiver_id === '' || $message === '') {
        $response['message'] = "Empty fields are not allowed.";
    } else {
        // Prepare and execute the query
        $sql = "INSERT INTO messages (sender_id, receiver_id, message) VALUES (?, ?, ?)";
        $stmt = $conn->prepare($sql);
        
        if ($stmt) {
            $stmt->bind_param("sss", $sender_id, $receiver_id, $message);
            if ($stmt->execute()) {
                $response['success'] = true;
                $response['message'] = "Message sent successfully.";
            } else {
                $response['message'] = "Database execution error.";
            }
        } else {
            $response['message'] = "Query preparation failed.";
        }
    }
} else {
    $response['message'] = "Required fields are missing.";
}

echo json_encode($response);
?>
