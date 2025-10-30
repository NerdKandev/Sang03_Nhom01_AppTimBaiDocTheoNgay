-- Migration 004: Add role column to users table
-- Created: 2024-01-01
-- Description: Add role column to users table for admin/user distinction

-- Add role column to users table
ALTER TABLE users ADD COLUMN role TEXT DEFAULT 'user';

-- Update existing users to have 'user' role
UPDATE users SET role = 'user' WHERE role IS NULL;
