<?php
include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $pilgrim_user_id = $_POST['pilgrim_id'];

    $stmt = $conn->prepare("SELECT u.name FROM motawif_pilgrim mp
                            JOIN users u ON mp.motawif_id = u.id
                            JOIN users p ON mp.pilgrim_id = p.id
                            WHERE p.user_id = ?");
    $stmt->bind_param("s", $pilgrim_user_id);
    $stmt->execute();
    $stmt->bind_result($motawifName);
    
    if ($stmt->fetch()) {
        echo json_encode(['success' => true, 'motawif_name' => $motawifName]);
    } else {
        echo json_encode(['success' => false, 'message' => 'No motawif found']);
    }

    $stmt->close();
    $conn->close();
}
?>
