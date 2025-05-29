package com.sodam.controller;

import java.security.Principal;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/admin")
public class AdminController {

	@GetMapping("/dashboard")
	public String dashboard(Principal principal) {
	    if (principal == null) {
	        System.out.println("❌ principal is null - 인증 실패");
	        return "redirect:/admin/login";  // 무한루프 방지용
	    }
	    System.out.println("✅ principal = " + principal.getName());
	    return "admin/dashboard";
	}


}

