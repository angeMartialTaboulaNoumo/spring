package tuto.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ConnexionController {

	@GetMapping( "/" )
	public String page1() {
		return "/connexion/home.html";
	}

	@GetMapping( "/connect" )
	public String page2() {
		return "/connexion/bonjour.html";
	}

}
