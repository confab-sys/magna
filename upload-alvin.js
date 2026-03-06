
const fs = require('fs');
const path = require('path');

const API_URL = "https://magna-coders-api.magna-coders.workers.dev";
const ALVIN_IMAGE_PATH = path.join(__dirname, 'alvin.png');

const alvinUser = {
    username: "Alvin",
    email: "alvin@magna.com",
    password: "password123",
    tagline: "Data Scientist and AI Specialist",
    role: "AI/ML Engineer",
    categories: ["AI/ML Engineer", "Backend Developer", "Designer", "Developer"],
    lookingFor: ["Frontend Developer", "UI Designer", "Mobile Engineer"],
    skills: ["Python", "SQL", "JavaScript", "Machine Learning", "Data Analytics"],
    location: "Nairobi, Kenya",
    website_url: "https://alvin.com",
    github_url: "https://github.com/alvin",
    twitter_url: "https://twitter.com/alvin",
    whatsapp_url: "https://whatsapp.com/alvin"
};

async function uploadAlvin() {
    console.log("🚀 Starting Alvin User Upload...\n");

    // 1. Register or Login Alvin
    let token = "";
    try {
        console.log("1. Attempting to Login first...");
        const loginRes = await fetch(`${API_URL}/api/auth/login`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ email: alvinUser.email, password: alvinUser.password })
        });

        if (loginRes.ok) {
            const data = await loginRes.json();
            token = data.token;
            console.log("✅ Logged in successfully.");
        } else {
            console.log("⚠️ Login failed, attempting to register...");
            const regRes = await fetch(`${API_URL}/api/auth/register`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    username: alvinUser.username,
                    email: alvinUser.email,
                    password: alvinUser.password
                })
            });

            if (!regRes.ok) {
                const text = await regRes.text();
                // Check if user already exists
                if (text.includes("already exists")) {
                    console.log("ℹ️ User exists but login failed (maybe wrong password?), retrying login with original creds or manual fix needed.");
                }
                throw new Error(`Registration failed: ${text}`);
            }
            console.log("✅ Registered successfully. Now logging in...");
            
            // Login after register
            const loginAfterReg = await fetch(`${API_URL}/api/auth/login`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ email: alvinUser.email, password: alvinUser.password })
            });
            const data = await loginAfterReg.json();
            token = data.token;
            console.log("✅ Logged in successfully.");
        }
    } catch (e) {
        console.error("❌ Auth Failed:", e.message);
        return;
    }

    const authHeaders = { 
        "Authorization": `Bearer ${token}` 
    };

    // 2. Upload Profile Image
    let avatarUrl = "";
    try {
        console.log("\n2. Uploading Profile Image...");
        
        if (!fs.existsSync(ALVIN_IMAGE_PATH)) {
            throw new Error(`Image file not found at ${ALVIN_IMAGE_PATH}`);
        }

        const fileContent = fs.readFileSync(ALVIN_IMAGE_PATH);
        const filename = "alvin.png";

        // Get Upload URL
        const uploadUrlRes = await fetch(`${API_URL}/api/files/upload-url?filename=${filename}`, {
            headers: authHeaders
        });
        const uploadData = await uploadUrlRes.json();
        
        if (!uploadUrlRes.ok) throw new Error(uploadData.error || "Failed to get upload URL");
        
        console.log(`ℹ️ Got upload URL for key: ${uploadData.key}`);

        // Upload to R2 via the signed URL (or direct PUT if the API proxies it)
        // The API returns `uploadUrl` which is the endpoint to PUT to.
        
        const putRes = await fetch(uploadData.uploadUrl, {
            method: "PUT",
            headers: {
                "Content-Type": "image/png",
                ...authHeaders
            },
            body: fileContent
        });

        if (!putRes.ok) {
            const text = await putRes.text();
            throw new Error(`File upload failed: ${text}`);
        }

        console.log("✅ Image uploaded successfully.");
        avatarUrl = uploadData.publicUrl;
        console.log(`ℹ️ Public URL: ${avatarUrl}`);

    } catch (e) {
        console.error("❌ Image Upload Failed:", e.message);
        return;
    }

    // 3. Update User Profile with all details
    try {
        console.log("\n3. Updating User Profile...");
        
        const updateBody = {
            avatar_url: avatarUrl,
            location: alvinUser.location,
            bio: alvinUser.tagline, 
            tagline: alvinUser.tagline,
            role: alvinUser.role,
            website_url: alvinUser.website_url,
            github_url: alvinUser.github_url,
            twitter_url: alvinUser.twitter_url,
            whatsapp_url: alvinUser.whatsapp_url,
            categories: alvinUser.categories,
            skills: alvinUser.skills,
            lookingFor: alvinUser.lookingFor
        };

        const updateRes = await fetch(`${API_URL}/api/users/profile`, {
            method: "PUT",
            headers: { 
                "Content-Type": "application/json",
                ...authHeaders
            },
            body: JSON.stringify(updateBody)
        });

        const updateData = await updateRes.json();
        if (!updateRes.ok) throw new Error(updateData.error || "Profile update failed");

        console.log("✅ Profile updated successfully.");

    } catch (e) {
        console.error("❌ Profile Update Failed:", e.message);
    }
}

uploadAlvin();
