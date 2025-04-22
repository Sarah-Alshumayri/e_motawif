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
$userIdQuery = "SELECT id, user_id FROM users WHERE id IN ($internalIdsStr)";
$userResult = mysqli_query($conn, $userIdQuery);

$userIdMap = []; // key = user_id, value = internal id
while ($row = mysqli_fetch_assoc($userResult)) {
    $userIdMap[$row['user_id']] = $row['id'];
}
$userIds = array_keys($userIdMap);
if (empty($userIds)) {
    echo json_encode(["success" => true, "data" => []]);
    exit;
}
$userIdsEscaped = array_map(function($id) use ($conn) {
    return "'" . mysqli_real_escape_string($conn, $id) . "'";
}, $userIds);
$userIdsStr = implode(",", $userIdsEscaped);

// ✅ Step 3: Fetch SOS alerts with pilgrim names
$sosQuery = "
    SELECT sa.*, u.name AS pilgrim_name 
    FROM sos_alerts sa 
    JOIN users u ON sa.pilgrim_id = u.user_id 
    WHERE sa.pilgrim_id IN ($userIdsStr) 
      AND sa.status != 'Resolved' 
    ORDER BY sa.timestamp DESC";

$sosResult = mysqli_query($conn, $sosQuery);

$data = [];
while ($row = mysqli_fetch_assoc($sosResult)) {
    $data[] = $row;
}

echo json_encode(["success" => true, "data" => $data]);
?>
