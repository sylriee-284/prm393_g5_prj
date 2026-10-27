package com.prm393.novel.controller;

import com.prm393.novel.dto.request.UpdateProgressRequest;
import com.prm393.novel.dto.response.ApiResponse;
import com.prm393.novel.dto.response.HistoryItemResponse;
import com.prm393.novel.model.Comic;
import com.prm393.novel.security.UserPrincipal;
import com.prm393.novel.service.LibraryService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/library")
public class LibraryController {

    private final LibraryService libraryService;

    public LibraryController(LibraryService libraryService) {
        this.libraryService = libraryService;
    }

    @GetMapping("/history")
    public ResponseEntity<ApiResponse<List<HistoryItemResponse>>> getHistory(
            @AuthenticationPrincipal UserPrincipal currentUser) {
        List<HistoryItemResponse> list = libraryService.getReadingHistory(currentUser.getId());
        return ResponseEntity.ok(ApiResponse.ok(list));
    }

    @PostMapping("/progress")
    public ResponseEntity<ApiResponse<Void>> updateProgress(
            @AuthenticationPrincipal UserPrincipal currentUser,
            @Valid @RequestBody UpdateProgressRequest request) {
        libraryService.updateProgress(currentUser.getId(), request.getComicId(), request.getCurrentChapter());
        return ResponseEntity.ok(ApiResponse.ok("Cập nhật tiến độ đọc thành công", null));
    }

    @PostMapping("/notify/{comicId}")
    public ResponseEntity<ApiResponse<Void>> toggleNotify(
            @AuthenticationPrincipal UserPrincipal currentUser,
            @PathVariable String comicId) {
        libraryService.toggleNotify(currentUser.getId(), comicId);
        return ResponseEntity.ok(ApiResponse.ok("Đã thay đổi trạng thái nhận thông báo", null));
    }

    @DeleteMapping("/history/{comicId}")
    public ResponseEntity<ApiResponse<Void>> removeFromHistory(
            @AuthenticationPrincipal UserPrincipal currentUser,
            @PathVariable String comicId) {
        libraryService.removeFromHistory(currentUser.getId(), comicId);
        return ResponseEntity.ok(ApiResponse.ok("Đã xóa khỏi lịch sử đọc", null));
    }

    @GetMapping("/bookmarks")
    public ResponseEntity<ApiResponse<List<Comic>>> getBookmarks(
            @AuthenticationPrincipal UserPrincipal currentUser) {
        List<Comic> bookmarks = libraryService.getBookmarks(currentUser.getId());
        return ResponseEntity.ok(ApiResponse.ok(bookmarks));
    }

    @PostMapping("/bookmarks/{comicId}")
    public ResponseEntity<ApiResponse<Map<String, Boolean>>> toggleBookmark(
            @AuthenticationPrincipal UserPrincipal currentUser,
            @PathVariable String comicId) {
        boolean bookmarked = libraryService.toggleBookmark(currentUser.getId(), comicId);
        String msg = bookmarked ? "Đã thêm vào danh sách đánh dấu" : "Đã xóa khỏi danh sách đánh dấu";
        return ResponseEntity.ok(ApiResponse.ok(msg, Map.of("bookmarked", bookmarked)));
    }
}
