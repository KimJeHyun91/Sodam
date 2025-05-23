package com.sodam;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@EnableJpaAuditing
@SpringBootApplication
public class SodamApplication {

	public static void main(String[] args) {
		SpringApplication.run(SodamApplication.class, args);
	}

}
