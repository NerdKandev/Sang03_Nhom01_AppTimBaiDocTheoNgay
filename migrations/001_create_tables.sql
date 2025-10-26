-- Migration 001: Create all tables
-- Created: 2024-01-01
-- Description: Create all 8 tables for Bible App

-- 1. Users table
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  created_at TEXT NOT NULL,
  last_login_at TEXT,
  is_active INTEGER NOT NULL DEFAULT 1
);

-- 2. Bible books table
CREATE TABLE bible_books (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  abbreviation TEXT NOT NULL,
  chapter_count INTEGER NOT NULL,
  testament TEXT NOT NULL,
  order_index INTEGER NOT NULL
);

-- 3. Daily readings table
CREATE TABLE daily_readings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  day_of_year INTEGER NOT NULL,
  date TEXT NOT NULL,
  book_id INTEGER NOT NULL,
  chapter INTEGER NOT NULL,
  start_verse INTEGER NOT NULL,
  end_verse INTEGER NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  FOREIGN KEY (book_id) REFERENCES bible_books (id)
);

-- 4. Bible verses table
CREATE TABLE bible_verses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  book_id INTEGER NOT NULL,
  chapter INTEGER NOT NULL,
  verse INTEGER NOT NULL,
  text TEXT NOT NULL,
  FOREIGN KEY (book_id) REFERENCES bible_books (id)
);

-- 5. User progress table
CREATE TABLE user_progress (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  reading_id INTEGER NOT NULL,
  completed_at TEXT NOT NULL,
  reading_time INTEGER,
  FOREIGN KEY (user_id) REFERENCES users (id),
  FOREIGN KEY (reading_id) REFERENCES daily_readings (id)
);

-- 6. Favorites table
CREATE TABLE favorites (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  reading_id INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users (id),
  FOREIGN KEY (reading_id) REFERENCES daily_readings (id)
);

-- 7. Bookmarks table
CREATE TABLE bookmarks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  book_id INTEGER NOT NULL,
  chapter INTEGER NOT NULL,
  verse INTEGER NOT NULL,
  title TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users (id),
  FOREIGN KEY (book_id) REFERENCES bible_books (id)
);

-- 8. Notes table
CREATE TABLE notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  reading_id INTEGER,
  book_id INTEGER,
  chapter INTEGER,
  verse INTEGER,
  title TEXT,
  content TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users (id),
  FOREIGN KEY (reading_id) REFERENCES daily_readings (id),
  FOREIGN KEY (book_id) REFERENCES bible_books (id)
);

-- Create indexes for better performance
CREATE INDEX idx_daily_readings_date ON daily_readings(date);
CREATE INDEX idx_daily_readings_day ON daily_readings(day_of_year);
CREATE INDEX idx_bible_verses_book_chapter ON bible_verses(book_id, chapter);
CREATE INDEX idx_user_progress_user ON user_progress(user_id);
CREATE INDEX idx_favorites_user ON favorites(user_id);
CREATE INDEX idx_bookmarks_user ON bookmarks(user_id);
CREATE INDEX idx_notes_user ON notes(user_id);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
