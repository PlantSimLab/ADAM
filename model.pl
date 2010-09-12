#!/usr/bin/perl

use CGI;
$cgi = new CGI;
$model = $cgi->url_param('model');
print "Content-type: text/html\n\n";
print <<ENDHTML;
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN">
<html>
	<head>
		<title>
			ADAM Model repository
		</title>
		<link rel="stylesheet" type="text/css" href="/adam_style.css">
	</head>
	<body>
		<div id="header">
ENDHTML

$header = &Constant_HTML('header.html');
print $header;
print <<ENDHTML;
		</div>
		<div id="main" >
			<div id="nav">

ENDHTML

$navigation = &Constant_HTML('navigation.html');
print $navigation;
print <<ENDHTML;
<h1>
	Model repository of Discrete Biological Systems
</h1>

ENDHTML

$filename = 'models/' . $model . '.html';
#print $filename;
$content = &Constant_HTML($filename);
print $content;

# read in a file to include it
sub Constant_HTML {
  local(*FILE); # filehandle
  local($file); # file path
  local($HTML); # HTML data

  $file = $_[0] || die "There was no file specified!\n";

  open(FILE, "<$file") || die "Couldn't open $file!\n";
  $HTML = do { local $/; <FILE> }; #read whole file in through slurp #mode (by setting $/ to undef)
  close(FILE);

  return $HTML;
}
