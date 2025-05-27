package com.sodam.id;

import java.io.Serializable;

import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Embeddable
public class UserRewardItemId implements Serializable{
	private static final long serialVersionUID=1L;

	private String id;
	private Long reward_item_no;
}
