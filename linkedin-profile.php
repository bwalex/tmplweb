<?php
require('oauth/OAuth.php');
//require("jsontemplate.php");

$tags = array(
 "{{linkedin-profile}}"
);

class LinkedInProfile {
	private $conf = array();

	private function htmlify($obj) {
		foreach ($obj as $key => $val) {
			if (is_array($val)) {
				$obj[$key] = $this->htmlify($val);
			} else {
				if (is_string($val)) {
					$val = htmlentities($val, null, FALSE);
					$obj[$key] = str_replace("\n", "<br/>", $val);
				}
			}
		}
		return $obj;
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
			if (isset($position['startDate'])) {
				if (isset($position['startDate']['month'])) {
					$period = $period.$months[$position['startDate']['month']].' ';
				}
				$period = $period.$position['startDate']['year'];
			}
			$period = $period.' &ndash; ';
			if ($position['isCurrent'] == "true") {
				$period = $period.'Present';
			} else if (isset($position['endDate'])) {
				if (isset($position['endDate']['month'])) {
					$period = $period.$months[$position['endDate']['month']].' ';
				}
				$period = $period.$position['endDate']['year'];
			}
			
			$arr[$key]['period'] = $period;
		}
	}

	function __construct() {
		$config = file_get_contents('my-linkedin-config.json');
		$this->conf = json_decode($config, TRUE);
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
		$data = json_decode($data, TRUE);
		$data = $this->htmlify($data);
		return $data;
	}

	public function getProfile() {
		$data = $this->APICall("https://api.linkedin.com/v1/people/~:public:(first-name,last-name,headline,location,industry,summary,specialties,honors,publications,patents,languages,skills,educations,certifications,picture-url,positions)?format=json");

		$this->fix_dates($data['positions']['values']);
		$this->fix_dates($data['educations']['values']);
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