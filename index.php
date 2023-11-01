<?php
$DB_PATH = '/path/to/your/tasks.db';  // Replace with your actual path
$SECRET_KEY = 'your-secret-key';      // Replace with your desired secret key

// Check for the secret key
if ($_GET['key'] !== $SECRET_KEY) {
    die("Unauthorized.");
}

$url = $_GET['source'];

// Parse the ID from the URL
preg_match("#https://[a-zA-Z0-9.]+/([a-f0-9\-]+)/play_.*\.mp4#", $url, $matches);
$id = $matches[1];

// Open the SQLite database
$db = new SQLite3($DB_PATH);

// Check if the ID is already present
$query = $db->prepare("SELECT id FROM tasks WHERE id = :id");
$query->bindValue(':id', $id, SQLITE3_TEXT);
$result = $query->execute()->fetchArray();

if ($result) {
    die("Error: ID already exists in the database.");
}

// Insert the new task into the database
$query = $db->prepare("INSERT INTO tasks (id, url, status) VALUES (:id, :url, 'queued')");
$query->bindValue(':id', $id, SQLITE3_TEXT);
$query->bindValue(':url', $url, SQLITE3_TEXT);
$query->execute();

echo "Task added successfully!";
?>
