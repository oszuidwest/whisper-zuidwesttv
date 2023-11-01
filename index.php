<?php
$DB_PATH = '/path/to/your/tasks.db';  // Replace with your actual path
$SECRET_KEY = 'your-secret-key';      // Replace with your desired secret key

// Check if the source and key are set in the GET parameters
if (!isset($_GET['source'], $_GET['key'])) {
    header('HTTP/1.1 400 Bad Request');
    echo "Error: Missing parameters.";
    exit;
}

// Check for the secret key
if ($_GET['key'] !== $SECRET_KEY) {
    header('HTTP/1.1 401 Unauthorized');
    echo "Unauthorized.";
    exit;
}

$url = filter_var($_GET['source'], FILTER_SANITIZE_URL);

// Parse the ID from the URL
if (!preg_match("#https://[a-zA-Z0-9.]+/([a-f0-9\-]+)/play_.*\.mp4#", $url, $matches)) {
    header('HTTP/1.1 400 Bad Request');
    echo "Error: Invalid URL format.";
    exit;
}

$id = $matches[1];

// Open the SQLite database
$db = new SQLite3($DB_PATH, SQLITE3_OPEN_READWRITE | SQLITE3_OPEN_CREATE);

// Create the tasks table if it doesn't exist
$db->exec('
    CREATE TABLE IF NOT EXISTS tasks (
        id TEXT PRIMARY KEY,
        url TEXT NOT NULL,
        status TEXT NOT NULL
    )
');

// Check if the ID is already present
$query = $db->prepare('SELECT id FROM tasks WHERE id = :id');
$query->bindValue(':id', $id, SQLITE3_TEXT);
$result = $query->execute()->fetchArray(SQLITE3_ASSOC);

if ($result) {
    header('HTTP/1.1 409 Conflict');
    echo "Error: ID already exists in the database.";
    exit;
}

// Insert the new task into the database
$query = $db->prepare('INSERT INTO tasks (id, url, status) VALUES (:id, :url, "queued")');
$query->bindValue(':id', $id, SQLITE3_TEXT);
$query->bindValue(':url', $url, SQLITE3_TEXT);
$query->execute();

header('HTTP/1.1 200 OK');
echo "Task added successfully!";
?>
