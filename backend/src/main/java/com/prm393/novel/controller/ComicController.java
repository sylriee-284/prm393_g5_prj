package com.prm393.novel.controller;

import com.prm393.novel.dto.response.ApiResponse;
import com.prm393.novel.model.Chapter;
import com.prm393.novel.model.Comic;
import com.prm393.novel.service.ComicService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/comics")
public class ComicController {

    private final ComicService comicService;

    public ComicController(ComicService comicService) {
        this.comicService = comicService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Comic>>> getAllComics(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String status) {
        List<Comic> comics;
        if (search != null && !search.isBlank()) {
            comics = comicService.searchComics(search);
        } else if (status != null && !status.isBlank()) {
            comics = comicService.getComicsByStatus(status);
        } else {
            comics = comicService.getAllComics();
        }
        return ResponseEntity.ok(ApiResponse.ok(comics));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Comic>> getComicById(@PathVariable String id) {
        Comic comic = comicService.getComicById(id);
        return ResponseEntity.ok(ApiResponse.ok(comic));
    }

    @GetMapping("/{id}/chapters")
    public ResponseEntity<ApiResponse<List<Chapter>>> getChapters(@PathVariable String id) {
        List<Chapter> chapters = comicService.getChapters(id);
        return ResponseEntity.ok(ApiResponse.ok(chapters));
    }

    @GetMapping("/{id}/chapters/{number}")
    public ResponseEntity<ApiResponse<Chapter>> getChapter(
            @PathVariable String id,
            @PathVariable int number) {
        Chapter chapter = comicService.getChapter(id, number);
        return ResponseEntity.ok(ApiResponse.ok(chapter));
    }
}
