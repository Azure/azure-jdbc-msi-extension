package com.azure.jdbc.model;

import org.springframework.data.jpa.repository.JpaRepository;

public interface ChecklistRepository extends JpaRepository<Checklist, Integer> {
    
}
