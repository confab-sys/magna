const fs = require('fs');
const path = require('path');

const API_URL = "https://magna-coders-api.magna-coders.workers.dev";

const alvinUser = {
  email: "alvin@magna.com",
  password: "password123",
};

async function loginAlvin() {
  const res = await fetch(`${API_URL}/api/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      email: alvinUser.email,
      password: alvinUser.password,
    }),
  });

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Login failed: ${text}`);
  }

  const data = await res.json();
  if (!data.token) {
    throw new Error("No token in login response");
  }

  return data.token;
}

async function createPost(authHeaders) {
  console.log("📝 Creating demo post as Alvin...");

  const body = {
    title: "Alvin's demo post",
    content: "This is a demo post from Alvin to trigger notifications.",
    post_type: "regular",
    category_id: null,
  };

  const res = await fetch(`${API_URL}/api/posts`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...authHeaders,
    },
    body: JSON.stringify(body),
  });

  const data = await res.json();
  if (!res.ok) {
    throw new Error(`Post create failed: ${data.error || JSON.stringify(data)}`);
  }

  console.log("✅ Post created:", data.id);
  return data.id;
}

async function createProject(authHeaders) {
  console.log("📦 Creating demo project as Alvin...");

  const body = {
    title: "Alvin's AI Project",
    description: "End-to-end AI project posted from the Alvin seed script.",
    short_description: "AI demo project for notifications.",
    category_id: null,
    tech_stack: ["Python", "TensorFlow", "Flutter"],
    looking_for_contributors: true,
    max_contributors: 3,
    repository_url: "https://github.com/alvin/demo-ai-project",
    visibility: "public",
    status: "published",
  };

  const res = await fetch(`${API_URL}/api/projects`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...authHeaders,
    },
    body: JSON.stringify(body),
  });

  const data = await res.json();
  if (!res.ok) {
    throw new Error(`Project create failed: ${data.error || JSON.stringify(data)}`);
  }

  console.log("✅ Project created:", data.id);
  return data.id;
}

async function createJob(authHeaders) {
  console.log("💼 Creating demo job as Alvin...");

  const body = {
    title: "Senior AI Engineer (Demo)",
    description: "Demo job posting from Alvin to test notifications.",
    company_id: null,
    location: "Remote",
    salary: "Competitive",
    job_type: "Full-time",
    deadline: null,
    category_id: null,
  };

  const res = await fetch(`${API_URL}/api/jobs`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...authHeaders,
    },
    body: JSON.stringify(body),
  });

  const data = await res.json();
  if (!res.ok) {
    throw new Error(`Job create failed: ${data.error || JSON.stringify(data)}`);
  }

  console.log("✅ Job created:", data.id);
  return data.id;
}

async function run() {
  console.log("🚀 Starting Alvin content seed (post, project, job)...");

  try {
    const token = await loginAlvin();
    const authHeaders = {
      Authorization: `Bearer ${token}`,
    };

    const postId = await createPost(authHeaders);
    const projectId = await createProject(authHeaders);
    const jobId = await createJob(authHeaders);

    console.log("\n🎉 Done seeding Alvin content.");
    console.log("Post ID:", postId);
    console.log("Project ID:", projectId);
    console.log("Job ID:", jobId);
    console.log("\nOpen the Magna app as the appropriate recipient user to verify notifications in the Notifications screen.");
  } catch (e) {
    console.error("❌ Alvin content seed failed:", e.message);
  }
}

run();

