package com.azure.jdbc.model;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.OneToMany;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
// import javax.validation.constraints.NotEmpty;

@Entity
@Table(name = "checklist")
public class Checklist {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "name")
    // @NotEmpty
    private String name;

    @Column(name = "date")
    @Temporal(TemporalType.DATE)
    // @NotEmpty
    private Date date;

    @Column(name = "description")
    private String description;

    @OneToMany(cascade = CascadeType.ALL, fetch = FetchType.LAZY, mappedBy = "checklist")
    private Set<CheckItem> items;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    protected Set<CheckItem> getCheckItemsInternal() {
        if (this.items == null) {
            this.items = new HashSet<>();
        }
        return this.items;
    }

    public List<CheckItem> getItems() {
        return Collections.unmodifiableList(new ArrayList<>(getCheckItemsInternal()));
    }

    public void addItem(CheckItem item){
        getCheckItemsInternal().add(item);
        item.setCheckList(this);
    }

}
