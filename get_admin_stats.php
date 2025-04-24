<?php
include 'config.php';

header('Content-Type: application/json'); // Ensure JSON response

$response = [];

if (!$conn) {
    $response['status'] = 'error';
    $response['message'] = 'Database connection failed: ' . mysqli_connect_error();
    echo json_encode($response);
    exit;
}

try {
    // Count total pilgrims
    $totalPilgrimsQuery = "SELECT COUNT(*) AS total FROM users WHERE role = 'pilgrim'";
    $pilgrimsResult = mysqli_query($conn, $totalPilgrimsQuery);
    if (!$pilgrimsResult) throw new Exception(mysqli_error($conn));
    $totalPilgrims = mysqli_fetch_assoc($pilgrimsResult)['total'];

    // Count total motawifs
    $totalMotawifsQuery = "SELECT COUNT(*) AS total FROM users WHERE role = 'motawif'";
    $motawifsResult = mysqli_query($conn, $totalMotawifsQuery);
    if (!$motawifsResult) throw new Exception(mysqli_error($conn));
    $totalMotawifs = mysqli_fetch_assoc($motawifsResult)['total'];

    // Count unassigned pilgrims
    $unassignedQuery = "SELECT COUNT(*) AS total FROM users 
                        WHERE role = 'pilgrim' AND id NOT IN 
                        (SELECT pilgrim_id FROM motawif_pilgrim)";
    $unassignedResult = mysqli_query($conn, $unassignedQuery);
    if (!$unassignedResult) throw new Exception(mysqli_error($conn));
    $unassignedPilgrims = mysqli_fetch_assoc($unassignedResult)['total'];

    $response['status'] = 'success';
    $response['total_pilgrims'] = $totalPilgrims;
    $response['total_motawifs'] = $totalMotawifs;
    $response['unassigned_pilgrims'] = $unassignedPilgrims;
} catch (Exception $e) {
    $response['status'] = 'error';
    $response['message'] = $e->getMessage();
}

echo json_encode($response);
?>
