package com.prm393.novel.controller;

import com.prm393.novel.dto.request.SaveChapterRequest;
import com.prm393.novel.dto.request.SaveComicRequest;
import com.prm393.novel.dto.request.ToggleVisibilityRequest;
import com.prm393.novel.dto.response.ApiResponse;
import com.prm393.novel.model.Chapter;
import com.prm393.novel.model.Comic;
import com.prm393.novel.service.ComicService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/comics")
@PreAuthorize("hasRole('ADMIN')")
public class AdminComicController {

    private final ComicService comicService;

    public AdminComicController(ComicService comicService) {
        this.comicService = comicService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Comic>>> getAllComics() {
        List<Comic> list = comicService.getAllComicsAdmin();
        return ResponseEntity.ok(ApiResponse.ok(list));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Comic>> getComicById(@PathVariable String id) {
        Comic comic = comicService.getComicByIdAdmin(id);
        return ResponseEntity.ok(ApiResponse.ok(comic));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Comic>> createComic(@Valid @RequestBody SaveComicRequest request) {
        Comic comic = comicService.createComic(request);
        return ResponseEntity.ok(ApiResponse.ok("Thêm truyện mới thành công", comic));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Comic>> updateComic(
            @PathVariable String id,
            @Valid @RequestBody SaveComicRequest request) {
        Comic comic = comicService.updateComic(id, request);
        return ResponseEntity.ok(ApiResponse.ok("Cập nhật thông tin truyện thành công", comic));
    }

    @PatchMapping("/{id}/visibility")
    public ResponseEntity<ApiResponse<Comic>> toggleVisibility(
            @PathVariable String id,
            @RequestBody(required = false) ToggleVisibilityRequest request) {
        Boolean isHidden = request != null ? request.getIsHidden() : null;
        Comic comic = comicService.toggleVisibility(id, isHidden);
        String msg = comic.isHidden() ? "Đã chuyển trạng thái sang ẨN truyện" : "Đã chuyển trạng thái sang CÔNG KHAI truyện";
        return ResponseEntity.ok(ApiResponse.ok(msg, comic));
    }

    @PostMapping("/{id}/chapters")
    public ResponseEntity<ApiResponse<Chapter>> saveChapter(
            @PathVariable String id,
            @Valid @RequestBody SaveChapterRequest request) {
        Chapter chapter = comicService.saveChapter(id, request);
        return ResponseEntity.ok(ApiResponse.ok("Lưu chương truyện thành công", chapter));
    }

    @DeleteMapping("/{id}/chapters/{number}")
    public ResponseEntity<ApiResponse<Void>> deleteChapter(
            @PathVariable String id,
            @PathVariable int number) {
        comicService.deleteChapter(id, number);
        return ResponseEntity.ok(ApiResponse.ok("Đã xóa chương " + number, null));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteComic(@PathVariable String id) {
        comicService.deleteComic(id);
        return ResponseEntity.ok(ApiResponse.ok("Đã xóa truyện", null));
    }
}


