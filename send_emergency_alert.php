<?php
header('Content-Type: application/json');
include 'config.php';

$pilgrim_id = $_POST['user_id']; // external user_id
$message = $_POST['message'];
$latitude = $_POST['latitude'];
$longitude = $_POST['longitude'];

if (!$pilgrim_id || !$message || !$latitude || !$longitude) {
    echo json_encode(["success" => false, "message" => "Missing required fields."]);
    exit();
}

// Insert SOS alert
$sql = "INSERT INTO sos_alerts (pilgrim_id, message, latitude, longitude, status)
        VALUES ('$pilgrim_id', '$message', '$latitude', '$longitude', 'Active')";

if (mysqli_query($conn, $sql)) {
    // Get pilgrim name and internal ID
    $userQuery = mysqli_query($conn, "SELECT id, name FROM users WHERE user_id = '$pilgrim_id'");
    $userRow = mysqli_fetch_assoc($userQuery);
    $pilgrimName = $userRow ? $userRow['name'] : 'Pilgrim';
    $internalPilgrimId = $userRow ? $userRow['id'] : null;

    if ($internalPilgrimId) {
        // Get internal motawif ID assigned to this pilgrim
        $linkQuery = mysqli_query($conn, "SELECT motawif_id FROM motawif_pilgrim WHERE pilgrim_id = '$internalPilgrimId'");
        $linkRow = mysqli_fetch_assoc($linkQuery);
        $motawifInternalId = $linkRow ? $linkRow['motawif_id'] : null;

        if ($motawifInternalId) {
            // Get motawif EXTERNAL user_id
            $motawifQuery = mysqli_query($conn, "SELECT user_id FROM users WHERE id = '$motawifInternalId'");
            $motawifRow = mysqli_fetch_assoc($motawifQuery);
            $motawifExternalId = $motawifRow ? $motawifRow['user_id'] : null;

            if ($motawifExternalId) {
                // Insert notification to Motawif
                $notifTitle = "🚨 SOS Alert";
                $notifMessage = "$pilgrimName has sent an SOS: $message";
                $timestamp = date("Y-m-d H:i:s");

                $notifSql = "INSERT INTO notifications (user_id, title, message, timestamp, sender_name)
                             VALUES ('$motawifExternalId', '$notifTitle', '$notifMessage', '$timestamp', '$pilgrimName')";
                mysqli_query($conn, $notifSql);
            }
        }
    }

    echo json_encode(["success" => true, "message" => "SOS alert sent and Motawif notified!"]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "MySQL error: " . mysqli_error($conn)
    ]);
}
?>
