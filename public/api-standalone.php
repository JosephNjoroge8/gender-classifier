<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Accept');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$name = $_GET['name'] ?? null;

// Gate 1: Presence/Empty
if ($name === null || $name === '') {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'The name parameter is required and cannot be empty.']);
    exit;
}

// Gate 2: Type (before trim)
if (!is_string($name)) {
    http_response_code(422);
    echo json_encode(['status' => 'error', 'message' => 'The name parameter must be a string.']);
    exit;
}

// Gate 3: Content (after trim)
$trimmed = trim($name);
if ($trimmed === '') {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'The name parameter is required and cannot be empty.']);
    exit;
}

// Call Genderize API
$url = 'https://api.genderize.io/?name=' . urlencode($trimmed);
$context = stream_context_create(['http' => ['timeout' => 15]]);
$response = @file_get_contents($url, false, $context);

if (!$response) {
    http_response_code(502);
    echo json_encode(['status' => 'error', 'message' => 'Unable to reach the gender prediction service. Please try again later.']);
    exit;
}

$data = json_decode($response, true);

// Edge case
if ($data['gender'] === null || $data['count'] === 0) {
    http_response_code(200);
    echo json_encode(['status' => 'error', 'message' => 'No prediction available for the provided name']);
    exit;
}

// Confidence logic
$is_confident = ($data['probability'] >= 0.7) && ($data['count'] >= 100);

// Response
http_response_code(200);
echo json_encode([
    'status' => 'success',
    'data' => [
        'name' => $trimmed,
        'gender' => $data['gender'],
        'probability' => $data['probability'],
        'sample_size' => $data['count'],
        'is_confident' => $is_confident,
        'processed_at' => gmdate('Y-m-d\TH:i:s.u\Z')
    ]
]);
?>
