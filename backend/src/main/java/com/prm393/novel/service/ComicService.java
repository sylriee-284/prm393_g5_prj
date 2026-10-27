package com.prm393.novel.service;

import com.prm393.novel.exception.ResourceNotFoundException;
import com.prm393.novel.model.Chapter;
import com.prm393.novel.model.Comic;
import com.prm393.novel.repository.ChapterRepository;
import com.prm393.novel.repository.ComicRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ComicService {

    private final ComicRepository comicRepository;
    private final ChapterRepository chapterRepository;

    public ComicService(ComicRepository comicRepository, ChapterRepository chapterRepository) {
        this.comicRepository = comicRepository;
        this.chapterRepository = chapterRepository;
    }

    public List<Comic> getAllComics() {
        return comicRepository.findAll();
    }

    public Comic getComicById(String id) {
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
        // Kiểm tra truyện tồn tại
        getComicById(comicId);
        return chapterRepository.findByComicId(comicId);
    }

    public Chapter getChapter(String comicId, int number) {
        getComicById(comicId);
        return chapterRepository.findByComicIdAndNumber(comicId, number)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy chương " + number + " của truyện " + comicId));
    }
}
