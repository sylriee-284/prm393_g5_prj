package com.prm393.novel.service;

import com.prm393.novel.dto.request.SaveChapterRequest;
import com.prm393.novel.dto.request.SaveComicRequest;
import com.prm393.novel.exception.ResourceNotFoundException;
import com.prm393.novel.model.Chapter;
import com.prm393.novel.model.Comic;
import com.prm393.novel.repository.ChapterRepository;
import com.prm393.novel.repository.ComicRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
@Service
public class ComicService {

    private final ComicRepository comicRepository;
    private final ChapterRepository chapterRepository;

    public ComicService(ComicRepository comicRepository, ChapterRepository chapterRepository) {
        this.comicRepository = comicRepository;
        this.chapterRepository = chapterRepository;
    }

    private boolean isCallerAdmin() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            return false;
        }
        return auth.getAuthorities().stream()
                .anyMatch(a -> "ROLE_ADMIN".equals(a.getAuthority()));
    }

    public List<Comic> getAllComics() {
        return comicRepository.findAll();
    }

    public List<Comic> getAllComicsAdmin() {
        return comicRepository.findAllAdmin();
    }

    public Comic getComicById(String id) {
        Comic comic = comicRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy truyện với mã: " + id));
        if (comic.isHidden() && !isCallerAdmin()) {
            throw new ResourceNotFoundException("Truyện này hiện đang tạm ẩn hoặc không tồn tại.");
        }
        return comic;
    }

    public Comic getComicByIdAdmin(String id) {
        return comicRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy truyện với mã: " + id));
    }

    public List<Comic> searchComics(String query) {
        if (query == null || query.trim().isEmpty()) {
            return getAllComics();
        }
        return comicRepository.search(query);
    }

    public List<Comic> getComicsByStatus(String status) {
        return comicRepository.findByStatus(status);
    }

    public List<Chapter> getChapters(String comicId) {
        // Kiểm tra truyện tồn tại và kiểm tra quyền xem nếu truyện bị ẩn
        getComicById(comicId);
        return chapterRepository.findByComicId(comicId);
    }

    public Chapter getChapter(String comicId, int number) {
        getComicById(comicId);
        return chapterRepository.findByComicIdAndNumber(comicId, number)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy chương " + number + " của truyện " + comicId));
    }

    // ====================================================================
    // NGHIỆP VỤ DÀNH CHO ADMIN
    // ====================================================================

    public Comic createComic(SaveComicRequest request) {
        String id = request.getId();
        if (id == null || id.trim().isEmpty()) {
            id = "c_" + UUID.randomUUID().toString().substring(0, 8);
        }
        Comic comic = new Comic();
        comic.setId(id);
        comic.setTitle(request.getTitle().trim());
        comic.setAuthor(request.getAuthor().trim());
        comic.setDescription(request.getDescription() != null ? request.getDescription().trim() : "");
        comic.setCoverColor(request.getCoverColor() != null ? request.getCoverColor() : 4280424541L);
        comic.setCoverLabel(request.getCoverLabel() != null && !request.getCoverLabel().isBlank()
                ? request.getCoverLabel().trim()
                : (request.getTitle().length() > 10 ? request.getTitle().substring(0, 10).toUpperCase() : request.getTitle().toUpperCase()));
        comic.setCoverUrl(request.getCoverUrl() != null ? request.getCoverUrl().trim() : "");
        comic.setGenre(request.getGenre() != null ? request.getGenre().trim() : "Tiên hiệp");
        comic.setStatus(request.getStatus() != null ? request.getStatus().trim() : "ongoing");
        comic.setHidden(Boolean.TRUE.equals(request.getIsHidden()));
        comic.setTotalChapters(0);
        comic.setViews(0);
        comic.setRating(5.0);

        comicRepository.save(comic);
        return comic;
    }

    public Comic updateComic(String id, SaveComicRequest request) {
        Comic comic = getComicByIdAdmin(id);
        comic.setTitle(request.getTitle().trim());
        comic.setAuthor(request.getAuthor().trim());
        if (request.getDescription() != null) comic.setDescription(request.getDescription().trim());
        if (request.getCoverColor() != null) comic.setCoverColor(request.getCoverColor());
        if (request.getCoverLabel() != null) comic.setCoverLabel(request.getCoverLabel().trim());
        if (request.getCoverUrl() != null) comic.setCoverUrl(request.getCoverUrl().trim());
        if (request.getGenre() != null) comic.setGenre(request.getGenre().trim());
        if (request.getStatus() != null) comic.setStatus(request.getStatus().trim());
        if (request.getIsHidden() != null) comic.setHidden(request.getIsHidden());

        comicRepository.save(comic);
        return comic;
    }

    public Comic toggleVisibility(String id, Boolean isHidden) {
        Comic comic = getComicByIdAdmin(id);
        boolean newHidden = (isHidden != null) ? isHidden : !comic.isHidden();
        comic.setHidden(newHidden);
        comicRepository.updateVisibility(id, newHidden);
        return comic;
    }

    public Chapter saveChapter(String comicId, SaveChapterRequest request) {
        Comic comic = getComicByIdAdmin(comicId);
        String chapterId = comicId + "_ch" + request.getNumber();
        Chapter chapter = new Chapter(
                chapterId,
                comicId,
                request.getNumber(),
                request.getTitle().trim(),
                request.getContent().trim()
        );
        chapterRepository.save(chapter);

        // Tự động tính lại tổng số chương của truyện
        int count = chapterRepository.countByComicId(comicId);
        int maxChapterNumber = Math.max(count, request.getNumber());
        if (maxChapterNumber > comic.getTotalChapters() || count > comic.getTotalChapters()) {
            int newTotal = Math.max(maxChapterNumber, count);
            comic.setTotalChapters(newTotal);
            comicRepository.updateTotalChapters(comicId, newTotal);
        }

        return chapter;
    }

    public void deleteChapter(String comicId, int number) {
        getComicByIdAdmin(comicId);
        chapterRepository.deleteByComicIdAndNumber(comicId, number);
        int count = chapterRepository.countByComicId(comicId);
        comicRepository.updateTotalChapters(comicId, count);
    }

    public void deleteComic(String id) {
        getComicByIdAdmin(id);
        comicRepository.delete(id);
    }
}
