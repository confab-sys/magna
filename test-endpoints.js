const API_URL = "https://magna-coders-api.magna-coders.workers.dev";
const timestamp = Date.now();
const user = {
    username: `testuser${timestamp}`,
    email: `test${timestamp}@example.com`,
    password: "password123"
};

let token = "";
let postId = "";
let convoId = "";

async function runTests() {
    console.log("🚀 Starting Smoke Tests...\n");

    // 1. Register
    try {
        console.log("1. Registering User...");
        const res = await fetch(`${API_URL}/api/auth/register`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(user)
        });
        
        const text = await res.text();
        let data;
        try {
            data = JSON.parse(text);
        } catch (e) {
            console.error("❌ Failed to parse response:", text);
            throw new Error(`Invalid JSON: ${text.substring(0, 50)}...`);
        }

        if (!res.ok) throw new Error(data.error || res.statusText);
        console.log("✅ Success:", data.message);
    } catch (e) {
        console.error("❌ Register Failed:", e.message);
        return; // Stop if register fails
    }

    // 2. Login
    try {
        console.log("\n2. Logging In...");
        const res = await fetch(`${API_URL}/api/auth/login`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ email: user.email, password: user.password })
        });
        const data = await res.json();
        if (!res.ok) throw new Error(data.error || res.statusText);
        token = data.token;
        console.log("✅ Success: Token received");
    } catch (e) {
        console.error("❌ Login Failed:", e.message);
        return;
    }

    const authHeaders = { 
        "Content-Type": "application/json",
        "Authorization": `Bearer ${token}` 
    };

    // 3. Feed
    try {
        console.log("\n3. Checking Feed...");
        const res = await fetch(`${API_URL}/api/posts/feed`, { headers: authHeaders });
        const data = await res.json();
        console.log(`✅ Success: Retrieved ${data.posts?.length || 0} posts`);
    } catch (e) {
        console.error("❌ Feed Failed:", e.message);
    }

    // 4. Create Post
    try {
        console.log("\n4. Creating Post...");
        const res = await fetch(`${API_URL}/api/posts`, {
            method: "POST",
            headers: authHeaders,
            body: JSON.stringify({
                title: "Smoke Test Node",
                content: "Testing from Node.js",
                post_type: "regular"
            })
        });
        const data = await res.json();
        if (!res.ok) throw new Error(data.error);
        postId = data.id;
        console.log("✅ Success: Post created ID:", postId);
    } catch (e) {
        console.error("❌ Create Post Failed:", e.message);
    }

    // 5. Like Post
    if (postId) {
        try {
            console.log("\n5. Liking Post...");
            const res = await fetch(`${API_URL}/api/posts/${postId}/like`, {
                method: "POST",
                headers: authHeaders
            });
            const data = await res.json();
            console.log("✅ Success:", data.message);
        } catch (e) {
            console.error("❌ Like Post Failed:", e.message);
        }
    }

    // 6. Create Conversation
    try {
        console.log("\n6. Creating Conversation...");
        const res = await fetch(`${API_URL}/api/chat/conversations`, {
            method: "POST",
            headers: authHeaders,
            body: JSON.stringify({
                name: "Node Test Chat",
                is_group: true
            })
        });
        const data = await res.json();
        if (!res.ok) throw new Error(data.error);
        convoId = data.id;
        console.log("✅ Success: Conversation created ID:", convoId);
    } catch (e) {
        console.error("❌ Create Convo Failed:", e.message);
    }

    // 7. Send Message
    if (convoId) {
        try {
            console.log("\n7. Sending Message...");
            const res = await fetch(`${API_URL}/api/chat/messages`, {
                method: "POST",
                headers: authHeaders,
                body: JSON.stringify({
                    conversation_id: convoId,
                    content: "Hello from Node.js"
                })
            });
            const data = await res.json();
            console.log("✅ Success:", data.message);
        } catch (e) {
            console.error("❌ Send Message Failed:", e.message);
        }
    }

    // 8. Public Endpoints
    try {
        console.log("\n8. Checking Public Endpoints...");
        const cRes = await fetch(`${API_URL}/api/courses`);
        const cData = await cRes.json();
        console.log(`✅ Courses: ${cData.courses?.length || 0} found`);

        const pRes = await fetch(`${API_URL}/api/podcasts`);
        const pData = await pRes.json();
        console.log(`✅ Podcasts: ${pData.podcasts?.length || 0} found`);
    } catch (e) {
        console.error("❌ Public Endpoints Failed:", e.message);
    }

    // 9. Notifications
    try {
        console.log("\n9. Checking Notifications...");
        const res = await fetch(`${API_URL}/api/notifications`, { headers: authHeaders });
        const data = await res.json();
        console.log(`✅ Success: ${data.notifications?.length || 0} notifications`);
    } catch (e) {
        console.error("❌ Notifications Failed:", e.message);
    }

    // 10. Coin Balance
    try {
        console.log("\n10. Checking Coin Balance...");
        const res = await fetch(`${API_URL}/api/coins/balance`, { headers: authHeaders });
        const data = await res.json();
        console.log(`✅ Success: Balance is ${data.balance}`);
    } catch (e) {
        console.error("❌ Coins Failed:", e.message);
    }

    // 11. Projects
    let projectId = "";
    try {
        console.log("\n11. Creating Project...");
        // 1. Ensure category exists (optional but good practice, though FK might fail if strict)
        // For this test, we'll rely on the backend handling or assume 'tech' exists if seeded.
        // Actually, let's create a category first if we can, or use NULL.
        // But the schema says category_id REFERENCES categories(id). 
        // If 'tech' doesn't exist, this will fail.
        // Let's try creating with NULL category_id to be safe for smoke tests.
        
        const res = await fetch(`${API_URL}/api/projects`, {
            method: "POST",
            headers: authHeaders,
            body: JSON.stringify({
                title: "Test Project",
                description: "This is a test project created by smoke test script",
                short_description: "Test Project",
                category_id: null, // Avoid FK error
                tech_stack: "Node.js",
                looking_for_contributors: true,
                max_contributors: 3
            })
        });
        const data = await res.json();
        if (res.ok) {
            projectId = data.id;
            console.log(`✅ Success: Project created (ID: ${projectId})`);
        } else {
            console.error("❌ Create Project Failed:", data.error);
        }

        console.log("Checking Projects List...");
        const listRes = await fetch(`${API_URL}/api/projects`, { headers: authHeaders });
        const listData = await listRes.json();
        console.log(`✅ Success: ${listData.projects?.length || 0} projects found`);
    } catch (e) {
        console.error("❌ Projects Failed:", e.message);
    }

    // 12. Jobs
    let jobId = "";
    try {
        console.log("\n12. Creating Job...");
        const res = await fetch(`${API_URL}/api/jobs`, {
            method: "POST",
            headers: authHeaders,
            body: JSON.stringify({
                title: "Test Job Opportunity",
                description: "We are hiring for a test position",
                company_id: null, // Avoid FK error if company doesn't exist
                location: "Remote",
                salary: "$100k",
                job_type: "full-time",
                deadline: "2025-12-31",
                category_id: null // Avoid FK error
            })
        });
        const data = await res.json();
        if (res.ok) {
            jobId = data.id;
            console.log(`✅ Success: Job created (ID: ${jobId})`);
        } else {
            console.error("❌ Create Job Failed:", data.error);
        }

        console.log("Checking Jobs List...");
        const listRes = await fetch(`${API_URL}/api/jobs`, { headers: authHeaders });
        const listData = await listRes.json();
        console.log(`✅ Success: ${listData.opportunities?.length || 0} jobs found`);
    } catch (e) {
        console.error("❌ Jobs Failed:", e.message);
    }

    // 13. AI Query
    try {
        console.log("\n13. Checking AI Query...");
        const res = await fetch(`${API_URL}/api/ai/query`, { 
            method: "POST",
            headers: authHeaders,
            body: JSON.stringify({ prompt: "Hello AI" })
        });
        const data = await res.json();
        console.log(`✅ Success: AI Response received (ID: ${data.interactionId})`);
    } catch (e) {
        console.error("❌ AI Query Failed:", e.message);
    }

    // 14. Contracts
    try {
        console.log("\n14. Checking Contracts...");
        const res = await fetch(`${API_URL}/api/contracts`, { headers: authHeaders });
        const data = await res.json();
        console.log(`✅ Success: ${data.contracts?.length || 0} contracts`);
    } catch (e) {
        console.error("❌ Contracts Failed:", e.message);
    }

    // 15. User Profile
    try {
        console.log("\n15. Checking User Profile...");
        const res = await fetch(`${API_URL}/api/users/profile`, { headers: authHeaders });
        const data = await res.json();
        console.log(`✅ Success: Profile loaded for ${data.user?.username}`);
    } catch (e) {
        console.error("❌ Profile Failed:", e.message);
    }

    // 16. Projects Detail
    try {
        console.log("\n16. Checking Project Details (Skipping detail fetch if list empty)...");
        const res = await fetch(`${API_URL}/api/projects`, { headers: authHeaders });
        const data = await res.json();
        if (data.projects && data.projects.length > 0) {
            const pid = data.projects[0].id;
            const res2 = await fetch(`${API_URL}/api/projects/${pid}`, { headers: authHeaders });
            const pData = await res2.json();
            console.log(`✅ Success: Project ${pData.project.title} loaded`);
        } else {
             console.log("⚠️ No projects to fetch detail for.");
        }
    } catch (e) {
        console.error("❌ Project Detail Failed:", e.message);
    }

    // 17. Jobs Detail
    try {
        console.log("\n17. Checking Job Details (Skipping detail fetch if list empty)...");
        const res = await fetch(`${API_URL}/api/jobs`, { headers: authHeaders });
        const data = await res.json();
        if (data.opportunities && data.opportunities.length > 0) {
            const jid = data.opportunities[0].id;
            const res2 = await fetch(`${API_URL}/api/jobs/${jid}`, { headers: authHeaders });
            const jData = await res2.json();
            console.log(`✅ Success: Job ${jData.opportunity.title} loaded`);
        } else {
            console.log("⚠️ No jobs to fetch detail for.");
        }
    } catch (e) {
        console.error("❌ Job Detail Failed:", e.message);
    }

    // 18. Files Upload URL
    try {
        console.log("\n18. Checking File Upload URL...");
        const res = await fetch(`${API_URL}/api/files/upload-url?filename=test.png`, { headers: authHeaders });
        const fData = await res.json();
        console.log(`✅ Success: Upload URL generated for ${fData.key}`);
    } catch (e) {
        console.error("❌ File Upload URL Failed:", e.message);
    }

    // 19. Comments List
    try {
        console.log("\n19. Checking Comments...");
        const res = await fetch(`${API_URL}/api/comments`, { headers: authHeaders });
        const cData = await res.json();
        console.log(`✅ Success: ${cData.comments?.length || 0} comments found`);
    } catch (e) {
        console.error("❌ Comments Failed:", e.message);
    }
}

runTests();
