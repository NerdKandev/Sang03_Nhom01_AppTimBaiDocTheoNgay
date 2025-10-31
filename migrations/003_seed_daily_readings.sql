-- Migration 003: Seed Daily Readings
-- Created: 2024-01-01
-- Description: Insert sample daily readings for 365 days

-- Sample daily readings (first 10 days as example)
INSERT INTO daily_readings (day_of_year, date, book_id, chapter, start_verse, end_verse, title, description) VALUES
(1, '2024-01-01', 1, 1, 1, 31, 'Sự Sáng Tạo', 'Bài đọc về sự sáng tạo trời đất và muôn vật'),
(2, '2024-01-02', 1, 2, 1, 25, 'Vườn Ê-đen', 'Bài đọc về vườn Ê-đen và sự tạo dựng người nam và người nữ'),
(3, '2024-01-03', 1, 3, 1, 24, 'Sự Sa Ngã', 'Bài đọc về sự sa ngã của A-đam và Ê-va'),
(4, '2024-01-04', 1, 4, 1, 26, 'Ca-in và A-bên', 'Bài đọc về Ca-in và A-bên, sự giết người đầu tiên'),
(5, '2024-01-05', 1, 5, 1, 32, 'Dòng Dõi A-đam', 'Bài đọc về dòng dõi từ A-đam đến Nô-ê'),
(6, '2024-01-06', 1, 6, 1, 22, 'Nô-ê và Trận Lụt', 'Bài đọc về Nô-ê và trận lụt lớn'),
(7, '2024-01-07', 1, 7, 1, 24, 'Giao Ước với Nô-ê', 'Bài đọc về giao ước của Đức Chúa Trời với Nô-ê'),
(8, '2024-01-08', 1, 8, 1, 22, 'Tháp Ba-bên', 'Bài đọc về tháp Ba-bên và sự phân tán loài người'),
(9, '2024-01-09', 1, 9, 1, 29, 'Dòng Dõi Sê-m', 'Bài đọc về dòng dõi của Sê-m'),
(10, '2024-01-10', 1, 10, 1, 32, 'Dòng Dõi Áp-ram', 'Bài đọc về dòng dõi của Áp-ram');

-- Note: In a real application, you would have 365 daily readings
-- This is just a sample for the first 10 days
-- The full dataset would be loaded from JSON files or generated programmatically

