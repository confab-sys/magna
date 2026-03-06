-- Create new table with nullable post_id and job_id
CREATE TABLE comments_new (
  id TEXT PRIMARY KEY,
  content TEXT NOT NULL,
  author_id TEXT NOT NULL,
  post_id TEXT, -- Nullable
  job_id TEXT,  -- Nullable
  parent_id TEXT,
  likes_count INTEGER DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (author_id) REFERENCES users(id),
  FOREIGN KEY (post_id) REFERENCES posts(id),
  FOREIGN KEY (job_id) REFERENCES jobs(id)
);

-- Copy data from old table (assuming job_id exists from previous partial migration or is null)
-- If job_id column exists:
INSERT INTO comments_new (id, content, author_id, post_id, job_id, parent_id, likes_count, created_at)
SELECT id, content, author_id, post_id, job_id, parent_id, likes_count, created_at FROM comments;

-- Drop old table
DROP TABLE comments;

-- Rename new table
ALTER TABLE comments_new RENAME TO comments;
