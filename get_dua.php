<?php
include 'config.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $ritualName = $_POST['ritual_name'];

    $stmt = $conn->prepare("SELECT * FROM duas WHERE ritual_name = ?");
    $stmt->bind_param("s", $ritualName);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($row = $result->fetch_assoc()) {
        echo json_encode([
            'success' => true,
            'data' => $row
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Dua not found'
        ]);
    }
    
    $stmt->close();
}
?>
