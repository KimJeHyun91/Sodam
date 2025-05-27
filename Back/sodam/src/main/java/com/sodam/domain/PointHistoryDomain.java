package com.sodam.domain;

import java.time.LocalDateTime;

import org.hibernate.annotations.ColumnDefault;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import com.sodam.id.PointHistoryId;

import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity(name="POINT_HISTORY")
@EntityListeners(AuditingEntityListener.class)
public class PointHistoryDomain {
	@EmbeddedId
	private PointHistoryId point_history_id;
	@NotNull
	@Column(nullable=false)
	private Long change;
	@NotNull
	@Column(nullable=false)
	@ColumnDefault("'M'") // Plus:P Minus:M
	private Character point_plus_minus;
	@CreatedDate
	private LocalDateTime created_date;
	@NotNull
	@Column(nullable=false)
	private String point_change_reason_code;

}
