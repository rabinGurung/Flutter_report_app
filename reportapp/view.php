<?php
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');
require_once "database.php";
$email= $_POST['email'];
$sql = "SELECT * from users Except SELECT * from users where username = '{$email}'";
$result = mysqli_query($link, $sql);
if (mysqli_num_rows($result) > 0) {
    // output data of each row
    $rows = array();
    while($row = mysqli_fetch_assoc($result)) {
        $rows[] = $row;
    }
} else {
    echo "0 results";
}
echo json_encode($rows);

mysqli_close($link);

?>