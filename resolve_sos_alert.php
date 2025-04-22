<?php
header('Content-Type: application/json');
include 'config.php';

if (!isset($_POST['id'])) {
    echo json_encode([
        "success" => false,
        "message" => "Missing SOS alert ID"
    ]);
    exit();
}

$id = $_POST['id'];

// Step 1: Update SOS alert to resolved
$sql = "UPDATE sos_alerts SET status = 'Resolved' WHERE id = '$id'";

if (mysqli_query($conn, $sql)) {
    // Step 2: Get the alert details
    $query = mysqli_query($conn, "SELECT pilgrim_id FROM sos_alerts WHERE id = '$id'");
    $row = mysqli_fetch_assoc($query);
    $pilgrimUserId = $row ? $row['pilgrim_id'] : null;

    if ($pilgrimUserId) {
        // Get pilgrim name
        $pilgrimQuery = mysqli_query($conn, "SELECT name FROM users WHERE user_id = '$pilgrimUserId'");
        $pilgrimRow = mysqli_fetch_assoc($pilgrimQuery);
        $pilgrimName = $pilgrimRow ? $pilgrimRow['name'] : "Pilgrim";

        // Find Motawif name (who resolved this - we don't have sender_id, so we use generic)
        $senderName = "Your Motawif";

        // Send notification to pilgrim
        $notifTitle = "✅ SOS Resolved";
        $notifMessage = "Your SOS alert has been resolved by $senderName.";
        $timestamp = date("Y-m-d H:i:s");

        $notifInsert = "INSERT INTO notifications (user_id, title, message, timestamp, sender_name)
                        VALUES ('$pilgrimUserId', '$notifTitle', '$notifMessage', '$timestamp', '$senderName')";
        mysqli_query($conn, $notifInsert);
    }

    echo json_encode([
        "success" => true,
        "message" => "SOS alert marked as resolved"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Failed to update SOS alert"
    ]);
}
?>
