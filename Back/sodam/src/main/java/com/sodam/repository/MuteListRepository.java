package com.sodam.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.sodam.entity.MuteList;

public interface MuteListRepository extends JpaRepository<MuteList, Long> {
    boolean existsByMuterIdAndMutedUserId(Long muterId, Long mutedUserId);
}
