package com.azure.jdbc.web;

import java.util.List;
import java.util.Optional;


import com.azure.jdbc.model.CheckItem;
import com.azure.jdbc.model.CheckItemRepository;
import com.azure.jdbc.model.Checklist;
import com.azure.jdbc.model.ChecklistRepository;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RequestMapping("/checklist")
@RestController
public class CheckListController {

    private final ChecklistRepository checklistRepository;
    private final CheckItemRepository checkItemRepository;

    public CheckListController(ChecklistRepository checklistRepository, CheckItemRepository checkItemRepository) {
        this.checklistRepository = checklistRepository;
        this.checkItemRepository = checkItemRepository;
    }

    @GetMapping
    public List<Checklist> getAll() {
        return checklistRepository.findAll();
    }

    @GetMapping(value = "/{checklistId}")
    public Optional<Checklist> findCheckList(@PathVariable("checklistId") int checklistId) {
        return checklistRepository.findById(checklistId);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Checklist createChecklist(@RequestBody Checklist list) {
        return checklistRepository.save(list);
    }

    @PostMapping("/{checklistId}/item")
    @ResponseStatus(HttpStatus.CREATED)
    public CheckItem addCheckItem(
            @RequestBody CheckItemRequest itemRequest,
            @PathVariable("checklistId") int checklistId) {

        final CheckItem item = new CheckItem();
        final Optional<Checklist> optionalChecklist = checklistRepository.findById(checklistId);
        Checklist checklist = optionalChecklist
                .orElseThrow(() -> new ResourceNotFoundException("Checklist " + checklistId + " not found"));
        item.setDescription(itemRequest.getDescription());
        checklist.addItem(item);

        return checkItemRepository.save(item);
    }

}
