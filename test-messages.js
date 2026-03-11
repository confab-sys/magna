const API_URL = "https://magna-coders-api.magna-coders.workers.dev";

// Hardcoded user for seeding conversations
const user = {
  username: "ashwa",
  email: "ashwaashard@gmail.com",
  password: "Neptunium238",
};

let token = "";
let currentUserId = "";

async function ensureUserAndLogin() {
  console.log("1. Ensuring user exists and logging in...");

  // Try to register; if it fails because user exists, ignore and continue to login.
  try {
    const registerRes = await fetch(`${API_URL}/api/auth/register`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(user),
    });

    const text = await registerRes.text();
    let data;
    try {
      data = JSON.parse(text);
    } catch {
      data = { error: text };
    }

    if (registerRes.ok) {
      console.log("✅ Registered user ashwa");
    } else {
      console.log(
        `ℹ️ Register skipped/failed (likely already exists): ${
          data.error || registerRes.statusText
        }`
      );
    }
  } catch (e) {
    console.log(`ℹ️ Register request error (continuing to login): ${e.message}`);
  }

  // Login
  const loginRes = await fetch(`${API_URL}/api/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email: user.email, password: user.password }),
  });

  const loginData = await loginRes.json();
  if (!loginRes.ok) {
    throw new Error(loginData.error || loginRes.statusText);
  }

  token = loginData.token;
  console.log("✅ Logged in, token acquired");
}

async function loadProfile() {
  console.log("\n2. Loading profile to get user id...");
  const res = await fetch(`${API_URL}/api/users/profile`, {
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
  });

  const data = await res.json();
  if (!res.ok) {
    throw new Error(data.error || res.statusText);
  }

  currentUserId = data.user?.id;
  if (!currentUserId) {
    throw new Error("Profile did not return user.id");
  }

  console.log(`✅ Profile loaded for ${data.user.username} (${currentUserId})`);
}

async function createConversation({ conversationType, name, description, memberUserIds }) {
  const body = {
    conversationType,
    name: name ?? null,
    description: description ?? null,
    memberUserIds,
  };

  const res = await fetch(`${API_URL}/api/chat/conversations`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify(body),
  });

  const dataText = await res.text();
  let data;
  try {
    data = JSON.parse(dataText);
  } catch {
    throw new Error(`Invalid JSON from create conversation: ${dataText.substring(0, 80)}...`);
  }

  // Support both v1 (plain) and v2 (enveloped) shapes
  const success = data.success ?? res.ok;
  if (!success) {
    const err = data.error?.message || data.error || res.statusText;
    throw new Error(err || "Failed to create conversation");
  }

  const conv = data.data || data;
  if (!conv.id) {
    throw new Error("Conversation response missing id");
  }

  return conv;
}

async function sendConversationMessage(conversationId, content) {
  const v2Body = {
    content,
    messageType: "text",
    replyToMessageId: null,
    attachments: [],
  };

  // Prefer new v2 endpoint first
  let res = await fetch(
    `${API_URL}/api/chat/conversations/${conversationId}/messages`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify(v2Body),
    }
  );

  // If backend doesn't yet expose v2 path in this environment, fall back to legacy endpoint
  if (res.status === 404) {
    const legacyBody = {
      conversation_id: conversationId,
      content,
    };

    res = await fetch(`${API_URL}/api/chat/messages`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify(legacyBody),
    });
  }

  const dataText = await res.text();
  let data;
  try {
    data = JSON.parse(dataText);
  } catch {
    throw new Error(
      `Invalid JSON from send message (${res.status}): ${dataText.substring(0, 80)}...`
    );
  }

  const success = data.success ?? res.ok;
  if (!success) {
    const err = data.error?.message || data.error || res.statusText;
    throw new Error(err || "Failed to send message");
  }

  return data.data || data;
}

async function runMessagesSeed() {
  console.log("🚀 Starting Messages Seed for user ashwa...\n");

  try {
    await ensureUserAndLogin();
    await loadProfile();
  } catch (e) {
    console.error("❌ Auth/Profile failed:", e.message);
    return;
  }

  const memberUserIds = [currentUserId];

  // 3. Direct-style conversation (even if only self for now)
  let directConvId = "";
  try {
    console.log("\n3. Creating direct conversation for ashwa...");
    const conv = await createConversation({
      conversationType: "direct",
      name: null,
      description: null,
      memberUserIds,
    });
    directConvId = conv.id;
    console.log("✅ Direct conversation created:", directConvId);
  } catch (e) {
    console.error("❌ Direct conversation failed:", e.message);
  }

  // 4. Seed a few messages into direct conversation
  if (directConvId) {
    try {
      console.log("\n4. Seeding messages into direct conversation...");
      await sendConversationMessage(directConvId, "Hello from the messages seed script 👋");
      await sendConversationMessage(directConvId, "This is a test direct conversation for ashwa.");
      await sendConversationMessage(directConvId, "Feel free to reply from the Magna app.");
      console.log("✅ Seeded direct conversation messages");
    } catch (e) {
      console.error("❌ Seeding direct messages failed:", e.message);
    }
  }

  // 5. Group conversation for ashwa
  let groupConvId = "";
  try {
    console.log("\n5. Creating group conversation for ashwa...");
    const conv = await createConversation({
      conversationType: "group",
      name: "Ashwa Builders Group",
      description: "A seeded test group conversation for ashwa.",
      memberUserIds,
    });
    groupConvId = conv.id;
    console.log("✅ Group conversation created:", groupConvId);
  } catch (e) {
    console.error("❌ Group conversation failed:", e.message);
  }

  // 6. Seed a few messages into group conversation
  if (groupConvId) {
    try {
      console.log("\n6. Seeding messages into group conversation...");
      await sendConversationMessage(groupConvId, "Welcome to the Ashwa Builders Group 🎉");
      await sendConversationMessage(
        groupConvId,
        "This group was created by the Node seed script."
      );
      await sendConversationMessage(
        groupConvId,
        "You can now open this conversation in the Magna Messages UI."
      );
      console.log("✅ Seeded group conversation messages");
    } catch (e) {
      console.error("❌ Seeding group messages failed:", e.message);
    }
  }

  console.log("\n✅ Messages seed completed.");
}

runMessagesSeed().catch((e) => {
  console.error("❌ Unhandled error in messages seed:", e);
});

