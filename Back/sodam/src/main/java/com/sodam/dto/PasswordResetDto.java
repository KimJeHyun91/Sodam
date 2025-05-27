package com.sodam.dto;

import lombok.Data;

@Data
public class PasswordResetDto {
    private String email;
    private String newPassword;
}
