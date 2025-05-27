package com.sodam.domain;

import java.time.LocalDateTime;

import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import com.sodam.id.UserRewardItemId;

import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity(name="USER_REWARD_ITEM")
@EntityListeners(AuditingEntityListener.class)
public class UserRewardItemDomain {
	@EmbeddedId
	private UserRewardItemId user_reward_item_id;
	@CreatedDate
	private LocalDateTime created_date;

}
