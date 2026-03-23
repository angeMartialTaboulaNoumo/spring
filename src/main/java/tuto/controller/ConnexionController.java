package tuto.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.SessionAttributes;
import org.springframework.web.bind.support.SessionStatus;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;


@Controller
@SessionAttributes( "connected" )
public class ConnexionController {

	@GetMapping( "/" )
	public String home() {
		return "/connexion/home.html";
	}

	@PostMapping( "/connect" )
	public String connect(String username, String password, Model model) {
		var sb = new StringBuilder( username );
		if ( sb.reverse().toString().equals( password ) ) {
			model.addAttribute( "connected", "Bonjour\t"+username );
			return "redirect:/bonjour";
		} else {
			model.addAttribute( "alert", "mot de passe incorrect" );
			model.addAttribute( "password", password );
			model.addAttribute( "username", username );
			return "connexion/home.html";
		}
	}
	
	@PostMapping( "/disconnect" )
	public String disconnected(SessionStatus status, RedirectAttributes ra) {
		ra.addFlashAttribute( "alert", "Déconnexion effectuée avec succès" );
		status.setComplete();
		return "redirect:/";
	}
	
	@GetMapping( "/bonjour" )
	public String bonjour() {
		return "/connexion/bonjour.html";
	}

}
