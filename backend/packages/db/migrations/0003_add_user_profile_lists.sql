-- Migration: Normalize user profile list columns
-- Goal:
-- - Use clean column names: categories, looking_for, skills
-- - Migrate any existing *_json data
-- - Drop old *_json columns

-- 1) Add new list columns (if they don't already exist in this schema)
ALTER TABLE users
ADD COLUMN categories TEXT;

ALTER TABLE users
ADD COLUMN looking_for TEXT;

ALTER TABLE users
ADD COLUMN skills TEXT;

-- 2) Migrate data from legacy *_json columns into the new columns (if present)
UPDATE users
SET
  categories   = COALESCE(categories, categories_json),
  looking_for  = COALESCE(looking_for, looking_for_json),
  skills       = COALESCE(skills, skills_json)
WHERE
  categories_json IS NOT NULL
  OR looking_for_json IS NOT NULL
  OR skills_json IS NOT NULL;

-- 3) Drop legacy *_json columns so only the new names remain
ALTER TABLE users
DROP COLUMN categories_json;

ALTER TABLE users
DROP COLUMN looking_for_json;

ALTER TABLE users
DROP COLUMN skills_json;
