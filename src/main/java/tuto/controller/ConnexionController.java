package tuto.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.SessionAttributes;
import org.springframework.web.bind.support.SessionStatus;


@Controller
@SessionAttributes( "connected" )
public class ConnexionController {

	@GetMapping( "/" )
	public String page1() {
		return "/connexion/home.html";
	}

	@GetMapping( "/connect" )
	public String page2(String username, String password, Model model) {
		var sb = new StringBuilder( username );
		if ( sb.reverse().toString().equals( password ) ) {
			model.addAttribute( "connected", "Bonjour\t"+username );
			return "connexion/bonjour.html";
		} else {
			model.addAttribute( "alert", "mot de passe incorrect" );
			return "connexion/home.html";
		}
	}
	
	@GetMapping( "/disconnect" )
	public String disconnected(SessionStatus status) {
		status.setComplete();
		return "redirect:/";
	}

}
