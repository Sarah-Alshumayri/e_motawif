<?php
ob_start(); // Capture all warnings and output
header('Content-Type: application/json');
require 'config.php';

$response = [];
$action = $_POST['action'] ?? '';

if ($action === "report") {
    if (!isset($_POST['user_id'])) {
        echo json_encode(["status" => "error", "message" => "Missing user_id."]);
        exit;
    }

    $userId = trim($_POST['user_id']);
    $itemName = trim($_POST['itemName']);
    $description = trim($_POST['description']);
    $location = trim($_POST['location']);
    $date = trim($_POST['date']);

    $stmt = $conn->prepare("INSERT INTO lost_found (user_id, itemName, description, location, date) VALUES (?, ?, ?, ?, ?)");
    $stmt->bind_param("sssss", $userId, $itemName, $description, $location, $date);

    if ($stmt->execute()) {
        $response = ["status" => "success", "message" => "Item reported successfully."];
    } else {
        $response = ["status" => "error", "message" => "Failed to report item: " . $stmt->error];
    }

    $stmt->close();
    echo json_encode($response);
    exit;

} elseif ($action === "search") {
    $itemName = $_POST['itemName'] ?? '';
    $description = $_POST['description'] ?? '';
    $location = $_POST['location'] ?? '';
    $date = $_POST['date'] ?? '';

    ob_clean(); // clean up any previous output

    $cmd = "\"C:\\Users\\Samal\\AppData\\Local\\Programs\\Python\\Python313\\python.exe\" semantic_fuzzy_matcher.py " .
    escapeshellarg($itemName) . " " .
    escapeshellarg($description) . " " .
    escapeshellarg($location) . " " .
    escapeshellarg($date);


    // Optional: Log command for debug
    file_put_contents("debug_log.txt", "CMD: $cmd\n", FILE_APPEND);

    $output = shell_exec($cmd);

    if (!$output) {
        echo json_encode([
            "status" => "error",
            "message" => "AI script returned no output or failed to execute.",
            "debug" => $cmd
        ]);
        exit;
    }

    $decoded = json_decode($output, true);
    if (json_last_error() !== JSON_ERROR_NONE) {
        echo json_encode([
            "status" => "error",
            "message" => "Invalid JSON from Python script.",
            "raw" => $output
        ]);
        exit;
    }

    echo $output;
    exit;

} else {
    echo json_encode(["status" => "error", "message" => "Invalid action"]);
    exit;
}
?>
