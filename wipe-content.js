// wipe-content.js
// Danger: deletes posts, projects, and jobs via Magna API for the authenticated user.

const API_URL = "https://magna-coders-api.magna-coders.workers.dev";

// Configure these via env or hard-code for now
const EMAIL = process.env.MAGNA_ADMIN_EMAIL || "ashwaashard@gmail.com";
const PASSWORD = process.env.MAGNA_ADMIN_PASSWORD || "Neptunium238";
const ADMIN_KEY = process.env.MAGNA_ADMIN_API_KEY || "ks93jhfs8sdf9sdf9sdf9sdf9sdf9sdf";

let token = "";

async function login() {
  console.log("🔐 Logging in...");
  const res = await fetch(`${API_URL}/api/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email: EMAIL, password: PASSWORD }),
  });

  const data = await res.json();
  if (!res.ok || !data.token) {
    throw new Error(data.error || "Login failed");
  }

  token = data.token;
  console.log("✅ Logged in, token acquired.\n");
}

function getAuthHeaders() {
  return {
    "Content-Type": "application/json",
    Authorization: `Bearer ${token}`,
    ...(ADMIN_KEY ? { "x-admin-key": ADMIN_KEY } : {}),
  };
}

async function wipePosts() {
  console.log("🧹 Wiping posts...");

  // Fetch posts (assuming backend returns { posts: [...] })
  const listRes = await fetch(`${API_URL}/api/posts`, {
    headers: getAuthHeaders(),
  });
  const listData = await listRes.json();
  const posts = listData.posts || [];

  console.log(`Found ${posts.length} posts.`);

  for (const post of posts) {
    const id = post.id;
    if (!id) continue;
    try {
      const delRes = await fetch(`${API_URL}/api/posts/${id}`, {
        method: "DELETE",
        headers: getAuthHeaders(),
      });
      if (!delRes.ok) {
        const body = await delRes.text();
        console.error(`  ❌ Failed to delete post ${id}: ${body}`);
      } else {
        console.log(`  ✅ Deleted post ${id}`);
      }
    } catch (e) {
      console.error(`  ❌ Error deleting post ${id}:`, e.message);
    }
  }

  console.log("Posts wipe complete.\n");
}

async function wipeProjects() {
  console.log("🧹 Wiping projects...");

  const listRes = await fetch(`${API_URL}/api/projects`, {
    headers: getAuthHeaders(),
  });
  const listData = await listRes.json();
  const projects = listData.projects || [];

  console.log(`Found ${projects.length} projects.`);

  for (const project of projects) {
    const id = project.id;
    if (!id) continue;
    try {
      const delRes = await fetch(`${API_URL}/api/projects/${id}`, {
        method: "DELETE",
        headers: getAuthHeaders(),
      });
      if (!delRes.ok) {
        const body = await delRes.text();
        console.error(`  ❌ Failed to delete project ${id}: ${body}`);
      } else {
        console.log(`  ✅ Deleted project ${id}`);
      }
    } catch (e) {
      console.error(`  ❌ Error deleting project ${id}:`, e.message);
    }
  }

  console.log("Projects wipe complete.\n");
}

async function wipeJobs() {
  console.log("🧹 Wiping jobs...");

  const listRes = await fetch(`${API_URL}/api/jobs`, {
    headers: getAuthHeaders(),
  });
  const listData = await listRes.json();
  const jobs = listData.opportunities || listData.jobs || [];

  console.log(`Found ${jobs.length} jobs.`);

  for (const job of jobs) {
    const id = job.id;
    if (!id) continue;
    try {
      const delRes = await fetch(`${API_URL}/api/jobs/${id}`, {
        method: "DELETE",
        headers: getAuthHeaders(),
      });
      if (!delRes.ok) {
        const body = await delRes.text();
        console.error(`  ❌ Failed to delete job ${id}: ${body}`);
      } else {
        console.log(`  ✅ Deleted job ${id}`);
      }
    } catch (e) {
      console.error(`  ❌ Error deleting job ${id}:`, e.message);
    }
  }

  console.log("Jobs wipe complete.\n");
}

async function wipeUsers() {
  console.log("🧹 Wiping users...");

  const listRes = await fetch(`${API_URL}/api/users`, {
    headers: getAuthHeaders(),
  });
  const listData = await listRes.json();
  const users = listData.users || [];

  console.log(`Found ${users.length} users.`);

  for (const user of users) {
    const id = user.id;
    if (!id) continue;
    try {
      const delRes = await fetch(`${API_URL}/api/users/${id}`, {
        method: "DELETE",
        headers: getAuthHeaders(),
      });
      if (!delRes.ok) {
        const body = await delRes.text();
        console.error(`  ❌ Failed to delete user ${id}: ${body}`);
      } else {
        console.log(`  ✅ Deleted user ${id}`);
      }
    } catch (e) {
      console.error(`  ❌ Error deleting user ${id}:`, e.message);
    }
  }

  console.log("Users wipe complete.\n");
}

async function run() {
  console.log("🚨 Magna API content wipe (posts, projects, jobs) starting…\n");

  if (!EMAIL || !PASSWORD) {
    console.error("Set MAGNA_ADMIN_EMAIL and MAGNA_ADMIN_PASSWORD env vars first.");
    process.exit(1);
  }

  await login();
  await wipePosts();
  await wipeProjects();
  await wipeJobs();
  await wipeUsers();

  console.log("✅ Done. Content wiped for this API.");
}

run().catch((e) => {
  console.error("❌ Unhandled error:", e);
  process.exit(1);
});