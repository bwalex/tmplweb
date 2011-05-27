#!/usr/bin/env php

<?php
require('oauth/OAuth.php');
//require("jsontemplate.php");

$tags = array(
 "{{linkedin-profile}}"
);

class LinkedInProfile {
	private $conf = array();

	private function fix_up($str)
	{
		if (is_string($str)) {
			$str = htmlentities($str, null, FALSE);
			$str = str_replace("\n", "<br/>", $str);
			//$str = str_replace("\n", "<br/>", $str);
			//$str = str_replace("•", "&bull;", $str);
		}
		return $str;
	}

	private function fix_dates(&$arr) {
		$months = array(
			1 => "January",
			2 => "February",
			3 => "March",
			4 => "April",
			5 => "May",
			6 => "June",
			7 => "July",
			8 => "August",
			9 => "September",
			10 => "October",
			11 => "November",
			12 => "December"
		);

		foreach ($arr as $key => $position) {
			$period = '';
			if (isset($position['start-date'])) {
				if (isset($position['start-date']['month'])) {
					$period = $period.$months[$position['start-date']['month']].' ';
				}
				$period = $period.$position['start-date']['year'];
			}
			$period = $period.' &ndash; ';
			if ($position['is-current'] == "true") {
				$period = $period.'Present';
			} else if (isset($position['end-date'])) {
				if (isset($position['end-date']['month'])) {
					$period = $period.$months[$position['end-date']['month']].' ';
				}
				$period = $period.$position['end-date']['year'];
			}
			
			$arr[$key]['period'] = $period;
		}
	}

	private function objectsIntoArray($arrObjData, $arrSkipIndices = array())
	{
		$arrData = array();
		
		// if input is object, convert into array
		if (is_object($arrObjData)) {
			$arrObjData = get_object_vars($arrObjData);
		}
		
		if (is_array($arrObjData)) {
			foreach ($arrObjData as $index => $value) {
			if (is_object($value) || is_array($value)) {
				$value = $this->objectsIntoArray($value, $arrSkipIndices); // recursive call
			}
			if (in_array($index, $arrSkipIndices)) {
				continue;
			}
			$arrData[$index] = $this->fix_up($value);
			}
		}
		return $arrData;
	}

	function __construct() {
		$config = file_get_contents('my-linkedin-config.json');
		$this->conf = json_decode($config, TRUE);
		print "I was called!\n";
	}

	// $url = "https://api.linkedin.com/v1/people/~:public:(first-name,last-name,headline,location,industry,summary,specialties,honors,publications,patents,languages,skills,educations,certifications,picture-url,positions)";

	private function APICall($url) {
		$consumer = new OAuthConsumer($this->conf['consumer_key'], $this->conf['consumer_secret'], NULL);
		$token = new OAuthConsumer($this->conf['oauth_token'], $this->conf['oauth_secret']);
		//three-current-positions or :public: but not both :(
		$req = OAuthRequest::from_consumer_and_token($consumer, $token, "GET", $url, array());
		$req->sign_request(new OAuthSignatureMethod_HMAC_SHA1(), $consumer, $token);
		//print "URL is: ".$acc_req->to_url();

		$data = file_get_contents($req->to_url());
		$xml = new SimpleXMLElement($data);
		$data = $this->objectsIntoArray($xml);
		return $data;
	}

	public function getProfile() {
		$data = $this->APICall("https://api.linkedin.com/v1/people/~:public:(first-name,last-name,headline,location,industry,summary,specialties,honors,publications,patents,languages,skills,educations,certifications,picture-url,positions)");

		$this->fix_dates($data['positions']['position']);
		$this->fix_dates($data['educations']['education']);
		return $data;
	}

	public function getHTML($tag) {
		if ($tag == '{{linkedin-profile}}') {
			$tmpl = file_get_contents('profile.tmpl');
			$data = $this->getProfile();
			$profile_html = JsonTemplateModule::expand($tmpl,$data);
			return $profile_html;
		} else {
			throw new Exception('Unknown tag');
		}
	}
}

register_module($tags, new LinkedInProfile());

?>