package com.prm393.novel.service;

import com.prm393.novel.dto.response.HistoryItemResponse;
import com.prm393.novel.model.Bookmark;
import com.prm393.novel.model.Comic;
import com.prm393.novel.model.ReadingHistory;
import com.prm393.novel.repository.BookmarkRepository;
import com.prm393.novel.repository.ComicRepository;
import com.prm393.novel.repository.ReadingHistoryRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class LibraryService {

    private final ReadingHistoryRepository readingHistoryRepository;
    private final BookmarkRepository bookmarkRepository;
    private final ComicRepository comicRepository;

    public LibraryService(ReadingHistoryRepository readingHistoryRepository,
                          BookmarkRepository bookmarkRepository,
                          ComicRepository comicRepository) {
        this.readingHistoryRepository = readingHistoryRepository;
        this.bookmarkRepository = bookmarkRepository;
        this.comicRepository = comicRepository;
    }

    public List<HistoryItemResponse> getReadingHistory(Long userId) {
        List<ReadingHistory> list = readingHistoryRepository.findByUserId(userId);
        List<HistoryItemResponse> result = new ArrayList<>();

        for (ReadingHistory entry : list) {
            Optional<Comic> comicOpt = comicRepository.findById(entry.getComicId());
            comicOpt.ifPresent(comic -> result.add(new HistoryItemResponse(
                    entry.getComicId(),
                    entry.getCurrentChapter(),
                    entry.isNotifyEnabled(),
                    comic,
                    entry.getUpdatedAt()
            )));
        }
        return result;
    }

    @Transactional
    public void updateProgress(Long userId, String comicId, int currentChapter) {
        readingHistoryRepository.upsert(userId, comicId, currentChapter);
    }

    @Transactional
    public void toggleNotify(Long userId, String comicId) {
        readingHistoryRepository.toggleNotify(userId, comicId);
    }

    @Transactional
    public void removeFromHistory(Long userId, String comicId) {
        readingHistoryRepository.delete(userId, comicId);
    }

    public List<Comic> getBookmarks(Long userId) {
        List<Bookmark> bookmarks = bookmarkRepository.findByUserId(userId);
        List<Comic> comics = new ArrayList<>();
        for (Bookmark b : bookmarks) {
            comicRepository.findById(b.getComicId()).ifPresent(comics::add);
        }
        return comics;
    }

    public boolean isBookmarked(Long userId, String comicId) {
        return bookmarkRepository.exists(userId, comicId);
    }

    @Transactional
    public void addBookmark(Long userId, String comicId) {
        bookmarkRepository.add(userId, comicId);
    }

    @Transactional
    public boolean toggleBookmark(Long userId, String comicId) {
        if (bookmarkRepository.exists(userId, comicId)) {
            bookmarkRepository.remove(userId, comicId);
            return false;
        } else {
            bookmarkRepository.add(userId, comicId);
            return true;
        }
    }
}

