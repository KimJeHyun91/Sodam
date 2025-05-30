package com.sodam.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class LoginController {
	@GetMapping("/admin_login")
	public String admin_login() {
		return "admin_login";
	}
}
