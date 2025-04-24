<?php
include 'config.php'; // DB connection

header('Content-Type: application/json');

// Decode input
$data = json_decode(file_get_contents("php://input"), true);

// Validate input
if (!isset($data['motawif_id']) || !isset($data['pilgrim_ids']) || !is_array($data['pilgrim_ids'])) {
    echo json_encode(["success" => false, "message" => "Missing or invalid parameters"]);
    exit;
}

$motawif_user_id = trim($data['motawif_id']);
$pilgrim_user_ids = $data['pilgrim_ids'];

// Log input
error_log("🛠️ Received motawif_id: $motawif_user_id");
error_log("🛠️ Received pilgrim_user_ids: " . json_encode($pilgrim_user_ids));

// Get internal Motawif ID
$motawif_stmt = $conn->prepare("SELECT id FROM users WHERE user_id = ? AND role = 'motawif' LIMIT 1");
$motawif_stmt->bind_param("s", $motawif_user_id);
$motawif_stmt->execute();
$motawif_result = $motawif_stmt->get_result();

if ($motawif_result->num_rows === 0) {
    echo json_encode(["success" => false, "message" => "Motawif not found"]);
    exit;
}
$motawif_id = $motawif_result->fetch_assoc()['id'];

$assigned = 0;

// Loop through pilgrim user_ids
$results = [];

foreach ($pilgrim_user_ids as $pilgrim_user_id) {
    $pilgrim_user_id = trim($pilgrim_user_id);
    if (empty($pilgrim_user_id)) continue;

    $status = ["user_id" => $pilgrim_user_id, "status" => ""];

    // Get internal pilgrim ID
    $pilgrim_stmt = $conn->prepare("SELECT id FROM users WHERE user_id = ? AND role = 'pilgrim' LIMIT 1");
    $pilgrim_stmt->bind_param("s", $pilgrim_user_id);
    $pilgrim_stmt->execute();
    $pilgrim_result = $pilgrim_stmt->get_result();

    if ($pilgrim_result->num_rows === 0) {
        $status["status"] = "not_found";
        $results[] = $status;
        continue;
    }

    $pilgrim_id = $pilgrim_result->fetch_assoc()['id'];

    // Check if already assigned
    $check_stmt = $conn->prepare("SELECT id FROM motawif_pilgrim WHERE pilgrim_id = ?");
    $check_stmt->bind_param("i", $pilgrim_id);
    
    $check_stmt->execute();
    $check_result = $check_stmt->get_result();

    if ($check_result->num_rows > 0) {
        $status["status"] = "already_assigned";
        $results[] = $status;
        continue;
    }

    // Assign
    $insert_stmt = $conn->prepare("INSERT INTO motawif_pilgrim (motawif_id, pilgrim_id) VALUES (?, ?)");
    $insert_stmt->bind_param("ii", $motawif_id, $pilgrim_id);
    if ($insert_stmt->execute()) {
        $assigned++;
        $status["status"] = "assigned";
    } else {
        $status["status"] = "error";
    }

    $results[] = $status;
}

echo json_encode([
    "success" => true,
    "assigned" => $assigned,
    "details" => $results
]);


$conn->close();
?>
