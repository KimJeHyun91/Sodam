package com.sodam.id;

import java.io.Serializable;

import jakarta.persistence.Embeddable;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.SequenceGenerator;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Embeddable
public class PointHistoryId implements Serializable{
	private static final long serialVersionUID=1L;
	
	private Long point_history_no;
	private Long point_no;
	
}
