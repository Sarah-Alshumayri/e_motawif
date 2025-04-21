<?php
header('Content-Type: application/json');
include 'config.php';

$motawif_id = $_POST['motawif_id'];
if (!$motawif_id) {
    echo json_encode(["success" => false, "message" => "Missing motawif_id"]);
    exit;
}

// Step 1: Get internal pilgrim IDs assigned to this Motawif
$assignedQuery = "SELECT pilgrim_id FROM motawif_pilgrim WHERE motawif_id = '$motawif_id'";
$result = mysqli_query($conn, $assignedQuery);

$internalIds = [];
while ($row = mysqli_fetch_assoc($result)) {
    $internalIds[] = (int)$row['pilgrim_id'];
}

if (empty($internalIds)) {
    echo json_encode(["success" => true, "data" => []]);
    exit;
}

// Step 2: Convert internal IDs to user_id strings
$internalIdsStr = implode(",", $internalIds);
$userIdQuery = "SELECT user_id FROM users WHERE id IN ($internalIdsStr)";
$userResult = mysqli_query($conn, $userIdQuery);

$userIds = [];
while ($row = mysqli_fetch_assoc($userResult)) {
    $userIds[] = "'" . mysqli_real_escape_string($conn, $row['user_id']) . "'";
}

if (empty($userIds)) {
    echo json_encode(["success" => true, "data" => []]);
    exit;
}

$userIdsStr = implode(",", $userIds);

// Step 3: Fetch SOS alerts
$sosQuery = "SELECT * FROM sos_alerts WHERE pilgrim_id IN ($userIdsStr) AND status != 'Resolved' ORDER BY timestamp DESC";
$sosResult = mysqli_query($conn, $sosQuery);

$data = [];
while ($row = mysqli_fetch_assoc($sosResult)) {
    $data[] = $row;
}

echo json_encode(["success" => true, "data" => $data]);
?>
