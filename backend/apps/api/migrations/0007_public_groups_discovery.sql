-- Public group discovery support for Messages

-- Mark which conversations are discoverable public groups.
ALTER TABLE conversations
  ADD COLUMN is_public BOOLEAN NOT NULL DEFAULT 0;

-- Helpful index for discovery queries.
CREATE INDEX IF NOT EXISTS idx_conversations_public_groups
  ON conversations (is_public, conversation_type);

