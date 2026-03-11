-- Magna Messages V2
-- Canonical term: conversation
-- Database naming: snake_case
-- API contract naming recommendation: camelCase at response boundary, explicitly mapped

-- 1) Extend conversations with inbox summary fields
ALTER TABLE conversations ADD COLUMN conversation_type TEXT NOT NULL DEFAULT 'direct';
-- direct | group | system

ALTER TABLE conversations ADD COLUMN last_message_id TEXT REFERENCES messages(id);
ALTER TABLE conversations ADD COLUMN last_message_preview TEXT;
ALTER TABLE conversations ADD COLUMN last_message_at DATETIME;
ALTER TABLE conversations ADD COLUMN last_sender_id TEXT REFERENCES users(id);
ALTER TABLE conversations ADD COLUMN is_archived BOOLEAN NOT NULL DEFAULT 0;
ALTER TABLE conversations ADD COLUMN is_locked BOOLEAN NOT NULL DEFAULT 0;

-- 2) Extend conversation_members with per-user conversation state
ALTER TABLE conversation_members ADD COLUMN last_read_message_id TEXT REFERENCES messages(id);
ALTER TABLE conversation_members ADD COLUMN last_read_at DATETIME;
ALTER TABLE conversation_members ADD COLUMN muted_until DATETIME;
ALTER TABLE conversation_members ADD COLUMN is_pinned BOOLEAN NOT NULL DEFAULT 0;
ALTER TABLE conversation_members ADD COLUMN is_archived BOOLEAN NOT NULL DEFAULT 0;
ALTER TABLE conversation_members ADD COLUMN notification_preference TEXT NOT NULL DEFAULT 'all';
-- all | mentions | none

-- 3) Extend messages to support modern chat features
ALTER TABLE messages ADD COLUMN message_type TEXT NOT NULL DEFAULT 'text';
-- text | image | file | audio | video | system

ALTER TABLE messages ADD COLUMN reply_to_message_id TEXT REFERENCES messages(id) ON DELETE SET NULL;
ALTER TABLE messages ADD COLUMN status TEXT NOT NULL DEFAULT 'sent';
-- sending | sent | delivered | read | failed

ALTER TABLE messages ADD COLUMN edited_at DATETIME;
ALTER TABLE messages ADD COLUMN deleted_at DATETIME;
ALTER TABLE messages ADD COLUMN delivered_at DATETIME;
ALTER TABLE messages ADD COLUMN read_at DATETIME;
ALTER TABLE messages ADD COLUMN metadata_json TEXT;
-- attachment info / audio duration / image dimensions / custom payloads

-- 4) Attachments table (cleaner than stuffing everything into metadata_json)
CREATE TABLE IF NOT EXISTS message_attachments (
    id TEXT PRIMARY KEY,
    message_id TEXT NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    media_id TEXT REFERENCES media(id) ON DELETE SET NULL,
    file_name TEXT,
    file_url TEXT NOT NULL,
    mime_type TEXT,
    file_size_bytes INTEGER,
    width INTEGER,
    height INTEGER,
    duration_seconds INTEGER,
    thumbnail_url TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 5) Optional delivery receipts per member for stronger read-state modeling in groups
CREATE TABLE IF NOT EXISTS message_receipts (
    id TEXT PRIMARY KEY,
    message_id TEXT NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    delivered_at DATETIME,
    read_at DATETIME,
    UNIQUE(message_id, user_id)
);

-- 6) Typing/presence event support if persisted briefly
CREATE TABLE IF NOT EXISTS conversation_typing_states (
    id TEXT PRIMARY KEY,
    conversation_id TEXT NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    started_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME NOT NULL,
    UNIQUE(conversation_id, user_id)
);

-- 7) Recommended indices
CREATE INDEX IF NOT EXISTS idx_conversations_last_message_at ON conversations(last_message_at DESC);
CREATE INDEX IF NOT EXISTS idx_conversation_members_user_conversation ON conversation_members(user_id, conversation_id);
CREATE INDEX IF NOT EXISTS idx_conversation_members_user_archived ON conversation_members(user_id, is_archived, is_pinned);
CREATE INDEX IF NOT EXISTS idx_messages_conversation_created ON messages(conversation_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_reply_to ON messages(reply_to_message_id);
CREATE INDEX IF NOT EXISTS idx_message_receipts_user_read ON message_receipts(user_id, read_at);
CREATE INDEX IF NOT EXISTS idx_message_attachments_message ON message_attachments(message_id);
