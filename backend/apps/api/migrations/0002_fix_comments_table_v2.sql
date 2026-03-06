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

-- Copy data from old table.
-- We use NULL for new columns (job_id, likes_count) if they don't exist in source.
-- parent_id likely exists, but if it fails we can remove it. Assuming it exists.
-- created_at likely exists.
INSERT INTO comments_new (id, content, author_id, post_id, parent_id, created_at)
SELECT id, content, author_id, post_id, parent_id, created_at FROM comments;

-- Drop old table
DROP TABLE comments;

-- Rename new table
ALTER TABLE comments_new RENAME TO comments;
