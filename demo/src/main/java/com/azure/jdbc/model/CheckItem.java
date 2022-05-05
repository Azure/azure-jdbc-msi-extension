package com.azure.jdbc.model;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name="checkitem")
public class CheckItem {
    
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    private Integer id;

    @JsonIgnore
    @JoinColumn(name="checklist_id")
    @ManyToOne    
    private Checklist checklist;

    private String description;

    public Integer getId() {
        return id;
    }

    public void setId(final Integer id) {
        this.id = id;
    }

    @JsonIgnore
    public Checklist getCheckList() {
        return checklist;
    }

    public void setCheckList(Checklist checklist) {
        this.checklist = checklist;
    }

    
    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }   
    
}
