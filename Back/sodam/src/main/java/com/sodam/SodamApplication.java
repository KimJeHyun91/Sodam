package com.sodam;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

import io.github.cdimascio.dotenv.Dotenv;

@EnableJpaAuditing
@SpringBootApplication
public class SodamApplication {

	public static void main(String[] args) {
		// ✅ .env 파일에서 환경 변수 읽어와 시스템 속성에 설정
		Dotenv dotenv = Dotenv.configure().ignoreIfMissing().load();
		System.setProperty("JWT_SECRET", dotenv.get("JWT_SECRET"));

		SpringApplication.run(SodamApplication.class, args);
	}

}
