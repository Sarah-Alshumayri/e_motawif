<?php
include 'config.php';

// Force download with proper headers
header("Content-Type: application/octet-stream");
header("Content-Disposition: attachment; filename=\"assignments.txt\"");
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Pragma: no-cache");
header("Expires: 0");

// Open the output stream
$output = fopen('php://output', 'w');

// Add UTF-8 BOM for Excel compatibility
fwrite($output, "\xEF\xBB\xBF");

// Write column headers
fputcsv($output, ['Motawif Name', 'Motawif ID', 'Pilgrim Name', 'Pilgrim ID']);

// Fetch data
$query = "
    SELECT 
        m.name AS motawif_name,
        m.user_id AS motawif_user_id,
        p.name AS pilgrim_name,
        p.user_id AS pilgrim_user_id
    FROM motawif_pilgrim mp
    JOIN users m ON mp.motawif_id = m.id
    JOIN users p ON mp.pilgrim_id = p.id
    ORDER BY m.name, p.name
";

$result = mysqli_query($conn, $query);

while ($row = mysqli_fetch_assoc($result)) {
    fputcsv($output, [
        $row['motawif_name'],
        $row['motawif_user_id'],
        $row['pilgrim_name'],
        $row['pilgrim_user_id']
    ]);
}

fclose($output);
exit;
?>
