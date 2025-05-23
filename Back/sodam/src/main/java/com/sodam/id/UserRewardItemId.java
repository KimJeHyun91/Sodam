package com.sodam.id;

import jakarta.persistence.Embeddable;

@Embeddable
public class UserRewardItemId {
	private static final long serialVersionUID=1L;

	private String id;
	private Long reward_item_no;
}
