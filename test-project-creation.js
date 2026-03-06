const API_URL = "https://magna-coders-api.magna-coders.workers.dev";
const timestamp = Date.now();
const user = {
    email: `test${timestamp}@example.com`,
    password: "password123",
    username: `testuser${timestamp}`
};

async function testProjectCreation() {
    console.log("🚀 Testing Project Creation Endpoint...\n");

    let token = "";

    // 1. Register & Login to get token
    try {
        console.log("Step 1: Registering & Logging In...");
        await fetch(`${API_URL}/api/auth/register`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(user)
        });
        
        const loginRes = await fetch(`${API_URL}/api/auth/login`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ email: user.email, password: user.password })
        });
        const loginData = await loginRes.json();
        token = loginData.token;
        console.log("✅ Auth Success\n");
    } catch (e) {
        console.error("❌ Auth Failed:", e.message);
        return;
    }

    const authHeaders = { 
        "Content-Type": "application/json",
        "Authorization": `Bearer ${token}` 
    };

    // 2. Test Project Creation with various fields to see what the DB accepts
    try {
        console.log("Step 2: Sending Project Creation Request...");
        
        // This payload matches what we currently have in Flutter
        const projectPayload = {
            title: "Final Full Compatibility Test Project",
            short_description: "Testing all fields including category and visibility",
            description: "Detailed description for the final compatibility test project.",
            visibility: "private", // Testing non-default
            status: "published",
            tech_stack: ["Flutter", "Dart", "Node.js", "Cloudflare", "Hono"], 
            looking_for_contributors: true,
            max_contributors: 10,
            start_date: new Date().toISOString(),
            end_date: new Date(Date.now() + 86400000 * 30).toISOString(),
            repository_url: "https://github.com/magna-coders/magna-platform",
            category_id: null // Testing with null to avoid FK constraint errors
        };

        console.log("Payload sent:", JSON.stringify(projectPayload, null, 2));

        const res = await fetch(`${API_URL}/api/projects`, {
            method: "POST",
            headers: authHeaders,
            body: JSON.stringify(projectPayload)
        });
        
        const responseBody = await res.json();
        
        if (res.ok) {
            console.log("\n✅ SUCCESS! Project Created.");
            console.log("Response Status:", res.status);
            console.log("Response Body:", JSON.stringify(responseBody, null, 2));
        } else {
            console.log("\n❌ FAILED! Backend rejected the request.");
            console.log("Response Status:", res.status);
            console.log("Error Details:", JSON.stringify(responseBody, null, 2));
        }
    } catch (e) {
        console.error("\n❌ Request Error:", e.message);
    }
}

testProjectCreation();
