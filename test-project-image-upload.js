const fs = require('fs');
const path = require('path');

const API_URL = "https://magna-coders-api.magna-coders.workers.dev";
const EMAIL = "test@example.com";
const PASSWORD = "password123";

async function testProjectImageUpload() {
    console.log("🚀 Testing Project Image Upload with Multipart/Form-Data...");
    const UNIQUE_ID = Date.now();
    const EMAIL = `test-user-${UNIQUE_ID}@example.com`;
    const PASSWORD = "password123";

    try {
        // Step 1: Register and Login
        console.log("Step 1: Registering new test user...");
        const registerRes = await fetch(`${API_URL}/api/auth/register`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ 
                username: `tester_${UNIQUE_ID}`,
                email: EMAIL, 
                password: PASSWORD 
            })
        });
        
        console.log("Step 1.5: Logging in...");
        const loginRes = await fetch(`${API_URL}/api/auth/login`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ email: EMAIL, password: PASSWORD })
        });
        const loginData = await loginRes.json();
        if (!loginRes.ok) throw new Error(`Login failed: ${JSON.stringify(loginData)}`);
        
        const token = loginData.token;
        const authHeaders = { "Authorization": `Bearer ${token}` };
        console.log("✅ Auth Success");

        // Step 2: Prepare Multipart Data
        console.log("Step 2: Preparing Multipart Request...");
        const formData = new FormData();
        
        // Basic fields
        formData.append("title", "Frontend Emulation Test Project");
        formData.append("short_description", "Testing image upload using exact frontend logic");
        formData.append("description", "This is a test mimicking the updated Flutter toFormData logic.");
        formData.append("category_id", "tech");
        formData.append("visibility", "public");
        formData.append("status", "published");
        
        // Exact frontend logic: jsonEncode for tech_stack and .toString() for bools/ints
        formData.append("tech_stack", JSON.stringify(["Flutter", "Dart", "R2", "D1"]));
        formData.append("looking_for_contributors", "true");
        formData.append("max_contributors", "10");
        formData.append("start_date", new Date().toISOString());
        formData.append("end_date", new Date(Date.now() + 86400000 * 30).toISOString());
        formData.append("repository_url", "https://github.com/magna-coders/magna-platform");

        // The Image File
        const imagePath = path.join(__dirname, "manual-project-image.png");
        if (!fs.existsSync(imagePath)) {
            throw new Error(`Image file not found at: ${imagePath}`);
        }
        
        const imageBuffer = fs.readFileSync(imagePath);
        const imageBlob = new Blob([imageBuffer], { type: 'image/png' });
        formData.append("image", imageBlob, "manual-project-image.png");

        console.log("Step 3: Sending Request...");
        const res = await fetch(`${API_URL}/api/projects`, {
            method: "POST",
            headers: authHeaders,
            body: formData
        });

        const data = await res.json();
        if (res.ok) {
            console.log("✅ SUCCESS! Project Created with Image.");
            console.log("Response Status:", res.status);
            console.log("Response Body:", JSON.stringify(data, null, 2));
            
            // Check if we can fetch the project to verify image_url
            const getRes = await fetch(`${API_URL}/api/projects/${data.id}`, {
                headers: authHeaders
            });
            const projectData = await getRes.json();
            console.log("\n--- Verified Project Data ---");
            console.log("Image URL:", projectData.project.image_url);
            console.log("----------------------------");
            
            if (projectData.project.image_url && projectData.project.image_url.includes("/api/files/projects/")) {
                console.log("🎉 Verification Successful: Image is uploaded and linked correctly.");
            } else {
                console.log("⚠️ Verification Warning: image_url is missing or incorrect.");
            }
        } else {
            console.log("❌ FAILED! Backend rejected the request.");
            console.log("Response Status:", res.status);
            console.log("Error Details:", JSON.stringify(data, null, 2));
        }

    } catch (error) {
        console.error("💥 Error during test:", error.message);
    }
}

testProjectImageUpload();
