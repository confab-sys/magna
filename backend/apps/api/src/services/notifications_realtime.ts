import type { Bindings } from '../types';

type NotificationPayload = {
  id: string;
  type: string;
  title: string;
  message: string;
  is_read: number | boolean;
  created_at: string;
  actor_id?: string | null;
  actor_name?: string | null;
  actor_avatar_url?: string | null;
  target_type?: string | null;
  target_id?: string | null;
  metadata_json?: string | null;
};

export async function broadcastNotificationCreated(
  env: Bindings,
  userId: string,
  notification: NotificationPayload,
): Promise<void> {
  await sendNotificationEvent(env, userId, 'notification.created', {
    notification: mapRowToDto(notification),
  });
}

export async function broadcastNotificationUpdated(
  env: Bindings,
  userId: string,
  notification: NotificationPayload,
): Promise<void> {
  await sendNotificationEvent(env, userId, 'notification.updated', {
    notification: mapRowToDto(notification),
  });
}

export async function broadcastNotificationRead(
  env: Bindings,
  userId: string,
  notificationId: string,
): Promise<void> {
  await sendNotificationEvent(env, userId, 'notification.read', {
    id: notificationId,
  });
}

export async function broadcastUnreadCount(
  env: Bindings,
  userId: string,
  unreadCount: number,
): Promise<void> {
  await sendNotificationEvent(env, userId, 'notifications.count.updated', {
    unreadCount,
  });
}

async function sendNotificationEvent(
  env: Bindings,
  userId: string,
  type: string,
  payload: Record<string, unknown>,
): Promise<void> {
  try {
    await env.REALTIME.fetch(`https://realtime.internal/notifications/${userId}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Internal-Key': env.REALTIME_INTERNAL_KEY,
      },
      body: JSON.stringify({
        type,
        payload,
      }),
    });
  } catch {
    // Realtime failures should not break API calls; rely on REST as fallback.
  }
}

function mapRowToDto(row: NotificationPayload) {
  return {
    id: row.id,
    type: row.type,
    title: row.title,
    message: row.message,
    is_read: typeof row.is_read === 'boolean' ? row.is_read : row.is_read === 1,
    created_at: row.created_at,
    actor_id: row.actor_id ?? null,
    actor_name: row.actor_name ?? null,
    actor_avatar_url: row.actor_avatar_url ?? null,
    target_type: row.target_type ?? null,
    target_id: row.target_id ?? null,
    metadata: row.metadata_json ? safeParseJson(row.metadata_json) : null,
  };
}

function safeParseJson(input: string | null): any | null {
  if (!input) return null;
  try {
    return JSON.parse(input);
  } catch {
    return null;
  }
}

