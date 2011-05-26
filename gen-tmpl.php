#!/usr/bin/env php
<?php
require ("jsontemplate.php");
$tmpl = file_get_contents('index.tmpl');
$content = file_get_contents('content.html');
$config = file_get_contents('config.json');

$data = json_decode($config, TRUE);

$data['menu-items'] = json_decode('
 [
   {
     "url": "#",
     "text": "Home",
     "class": ""
   },
   {
     "url": "#",
     "text": "Blog",
     "class": ""
   },
   {
     "url": "#",
     "text": "About",
     "class": ""
   },
   {
     "url": "#",
     "text": "DragonFly",
     "class": "selected"
   },
   {
     "url": "#",
     "text": "Software",
     "class": ""
   }
 ]
', TRUE);

$data['sidebar'] = json_decode('
 [
   {
     "menu-title": "Test 1",
     "elements": [
      {
       "url": "http://www.alexhornung.com",
       "text": "My actual web"
      }
     ]
   },
   {
     "menu-title": "Test 2",
     "elements": [
      {
       "url": "http://www.alexhornung.com",
       "text": "My actual web"
      } 
     ] 
   }
 ]
', TRUE);

$data['main']['title']="DragonFly";
$data['main']['content'] = $content;


try {
	print JsonTemplateModule::expand($tmpl,$data);
} catch(Exception $e) {
	$class = preg_replace('/^JsonTemplate/','',get_class($e));
	print "EXCEPTION: ".$class.": ".$e->getMessage()."\n";
}


?>