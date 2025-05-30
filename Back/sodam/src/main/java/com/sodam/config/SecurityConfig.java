package com.sodam.config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
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
			.passwordEncoder(password_encoder);
		return authentication_manager_builder.build();
	}
	
	@Bean
	public SecurityFilterChain security_filter_chain(HttpSecurity http_security) throws Exception{
		http_security
			.csrf(AbstractHttpConfigurer::disable)
			.authorizeHttpRequests(
					auth->
					auth.requestMatchers(
								"/member/login",        
		                        "/member/add",          
		                        "/member/id_check",     
		                        "/member/nickname_check",
		                        "/member/email_check",  
		                        "/auth/**"
						).permitAll()
						.requestMatchers(
							"/member/add_image/**",
							"/member/update_image/**",
							"/member/delete_image",
							"/member/get_image"
						).authenticated()
						
						.requestMatchers("/admin").hasRole("ADMIN")
						.anyRequest().authenticated()
			)
			.sessionManagement(
					session->
					session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
			);
		http_security
			.addFilterBefore(jwt_request_filter, UsernamePasswordAuthenticationFilter.class);
		
		return http_security.build();
	}
	
	
}
