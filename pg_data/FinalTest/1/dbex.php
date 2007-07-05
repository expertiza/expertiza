<?php
$user="wrri_admin";
$password="kp050807WR";
$database="wrri";
mysql_connect("mysql01.unity.ncsu.edu",$user,$password);
@mysql_select_db($database) or die( "Unable to select database");

$no_of_authors = $_POST["no_of_authors"];
for ($count=1;$count<=$no_of_authors;$count+=1)
{
	$first_name[$count]=$_POST["first_name$count"];
	$last_name[$count]=$_POST["last_name$count"];
	$affiliation[$count]=$_POST["affiliation$count"];
	$fax[$count]=$_POST["Fax$count"];
	$email[$count]=$_POST["email$count"];
	$address[$count]=$_POST["address$count"];
	$city[$count]=$_POST["city$count"];
	$state[$count]=$_POST["state$count"];
	$zip[$count]=$_POST["zip$count"];
	insertAuthors($first_name[$count],$last_name[$count],$affiliation[$count],$fax[$count],$email[$count],$address[$count],$city[$count],$state[$count],$zip[$count]);
}
$title=$_POST["title"];
$presentation=$_POST["presentation"];
$topic=$POST["Topic"];
$student=$_POST["Student"];
$abstract=$_POST["Abstract"];
#insert members into a team
for ($count=1;$count<=$no_of_authors;$count+=1)
{
	$first_name[$count]=$_POST["first_name$count"];
	$last_name[$count]=$_POST["last_name$count"];
	$affiliation[$count]=$_POST["affiliation$count"];
	$result = mysql_query("SELECT id from author where first_name='$first_name[$count]' AND last_name='$last_name[$count]'AND affiliation='$affiliation[$count]'");
	$row=mysql_fetch_row($result);
	$author_id = $row[0];
	insertTeam($title,$author_id);
}

mkdir("/afs/unity.ncsu.edu/project/www/ncsu/wrri/mortimer/uploads");
$target_path = "/afs/unity.ncsu.edu/project/www/ncsu/wrri/mortimer/uploads_".$title."/";
$target_path = $target_path . basename( $_FILES['uploadedfile']['name']);
//echo $target_path;
if(move_uploaded_file($_FILES['uploadedfile']['tmp_name'], $target_path)) {
	//echo "The file ".  basename( $_FILES['uploadedfile']['name']).
	//" has been uploaded";
} else{
	echo "There was an error uploading the file, please try again!";
}
$author_first_name=$_POST["first_name1"];
$author_last_name=$_POST["last_name1"];
$author_affiliation=$_POST["affiliation1"];
$result = mysql_query("SELECT id from author where first_name='$author_first_name' AND last_name='$author_last_name'AND affiliation='$author_affiliation'");
$row=mysql_fetch_row($result);
$presenter_id = $row[0];
$file_location = "uploads/".basename( $_FILES['uploadedfile']['name']);
insertPresentation($title,$presenter_id,$file_location);
echo "<br/><label>Your proposal has been submitted. Thank you.</label>";
function insertAuthors($first_name,$last_name,$affiliation,$fax,$email,$address,$city,$state,$zip){
	$result = mysql_query("SELECT * from author where last_name='$last_name' AND first_name='$first_name' AND affiliation='$affiliation'");
	$rows = mysql_num_rows($result);
	//echo $rows;
	if($rows==0)
	{
		$query="INSERT into author(last_name,first_name,affiliation,phone,fax,email,Address,City,State,Zip) values ('$last_name','$first_name','$affiliation','$phone','$fax','$email','$address','$city','$state','$zip')";
		mysql_query($query);
	}
}
function insertTeam($title,$author_id)
{
	$result = mysql_query("SELECT * from team where author_id='$author_id' AND title='$title'");
	$rows = mysql_num_rows($result);
	//echo $rows;
	if($rows==0)
	{
		$query="INSERT into team(title,author_id) values ('$title','$author_id')";
		mysql_query($query);
	}
}
function insertPresentation($title,$presenter_id,$file_location)
{
	$result = mysql_query("SELECT * from presentations where title='$title' AND presenter_id='$presenter_id'");
	$rows = mysql_num_rows($result);
	if($rows==0)
	{
		$query="INSERT into presentations(title,presenter_id,upload_location) values('$title',$presenter_id,'$file_location')";
		mysql_query($query);
	}
}
?>