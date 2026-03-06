-- Migration: Add cover_photo_url column to users table

ALTER TABLE users
ADD COLUMN cover_photo_url TEXT;

