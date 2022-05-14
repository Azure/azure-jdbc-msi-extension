package com.azure.jdbc.web;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class SampleController {

    private final JdbcTemplate jdbcTemplate;

    public SampleController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping("/")
    public String getServerDate() {
        return "server date is : " + jdbcTemplate.queryForObject("SELECT now() as now", String.class);
    }

}
