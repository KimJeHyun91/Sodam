package com.sodam.config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
 
 
import org.springframework.core.annotation.Order;
  
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.password.PasswordEncoder; // Encoder.java에서 빈으로 등록된 PasswordEncoder 사용
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import com.sodam.service.UserDetailsServiceImplement;
import com.sodam.util.JwtRequestFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {
	@Autowired
 
	private UserDetailsServiceImplement user_detail_service;
 
	private UserDetailsServiceImplement user_detail_service_implement;
  
	@Autowired
	private JwtRequestFilter jwt_request_filter;
	@Autowired
	private PasswordEncoder password_encoder;
	
	@Bean
	public AuthenticationManager authentication_manager(HttpSecurity http_security) throws Exception{
		AuthenticationManagerBuilder authentication_manager_builder=
				http_security.getSharedObject(AuthenticationManagerBuilder.class);
		authentication_manager_builder
 
			.userDetailsService(user_detail_service)
 
			.userDetailsService(user_detail_service_implement)
  
			.passwordEncoder(password_encoder);
		return authentication_manager_builder.build();
	}
	
	@Bean
 
	public SecurityFilterChain security_filter_chain(HttpSecurity http_security) throws Exception{
		http_security
 
	@Order(1)
	public SecurityFilterChain api_filter_chain(HttpSecurity http_security) throws Exception{
		http_security
			.securityMatcher("/member/**", "/auth/**", "/chat/**", "/gameroom/**", "/point/**", "/reward/**", "/bluetooth/**")
  
			.csrf(AbstractHttpConfigurer::disable)
			.authorizeHttpRequests(
					auth->
					auth.requestMatchers(
								"/member/login",        
		                        "/member/add",          
		                        "/member/id_check",     
		                        "/member/nickname_check",
 
		                        "/member/email_check",  
 
		                        "/member/email_check",
  
		                        "/auth/**"
						).permitAll()
						.requestMatchers("/admin").hasRole("ADMIN")
						.anyRequest().authenticated()
			)
			.sessionManagement(
					session->
					session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
 
			);
		http_security
 
			)
  
			.addFilterBefore(jwt_request_filter, UsernamePasswordAuthenticationFilter.class);
		
		return http_security.build();
	}
	
 
	
}
 
	@Bean
	@Order(2)
	public SecurityFilterChain form_login_filter_chain(HttpSecurity http_security) throws Exception{
		http_security
			.authorizeHttpRequests(
					auth->auth
					.requestMatchers("/admin_login").permitAll()
                    .requestMatchers("/admin", "/admin/**").hasRole("ADMIN")
                    .anyRequest().permitAll()
			)
			.formLogin(
					form->form
					.loginPage("/admin_login")
					.defaultSuccessUrl("/admin/access", true)
					.permitAll()
			)
			.logout(
					logout->logout
					.logoutSuccessUrl("/admin_login")
			)
			.sessionManagement(
					session->session
					.sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED)
			);
		return http_security.build();
		
	}
	
	
}
  
