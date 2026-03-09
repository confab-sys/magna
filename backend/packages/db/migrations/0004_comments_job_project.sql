-- Support comments on jobs and projects: add job_id, project_id; make post_id nullable.

-- SQLite: recreate comments table with new columns and nullable post_id
CREATE TABLE IF NOT EXISTS comments_new (
    id TEXT PRIMARY KEY,
    content TEXT NOT NULL,
    author_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id TEXT REFERENCES posts(id) ON DELETE CASCADE,
    job_id TEXT REFERENCES jobs(id) ON DELETE CASCADE,
    project_id TEXT REFERENCES projects(id) ON DELETE CASCADE,
    parent_id TEXT REFERENCES comments(id) ON DELETE CASCADE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Copy existing rows (do not select updated_at from source in case it does not exist)
INSERT INTO comments_new (id, content, author_id, post_id, parent_id, created_at, updated_at)
SELECT id, content, author_id, post_id, parent_id, created_at, CURRENT_TIMESTAMP FROM comments;

DROP TABLE comments;

ALTER TABLE comments_new RENAME TO comments;

CREATE INDEX IF NOT EXISTS idx_comments_post ON comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_job ON comments(job_id);
CREATE INDEX IF NOT EXISTS idx_comments_project ON comments(project_id);
