import { Hono } from 'hono';
import { Bindings, Variables } from '../types';
import { authMiddleware } from '../middleware';

export const userGuideRoutes = new Hono<{ Bindings: Bindings; Variables: Variables }>();

userGuideRoutes.post('/', authMiddleware, async (c) => {
  try {
    const userId = c.get('userId');
    const body = await c.req.parseBody({ all: true });

    // Extract fields
    const gender = body['gender'] as string;
    const rolesStr = body['roles'] as string;
    const goalsStr = body['goals'] as string;
    const specialisationsStr = body['specialisations'] as string;
    const skillsStr = body['skills'] as string;
    const availabilityStr = body['availability'] as string;
    const bio = body['bio'] as string;
    const country = body['country'] as string;
    const county = body['county'] as string;
    const profilePicture = body['profile_picture'];

    // Construct location
    let location = country;
    if (county) {
      location = `${county}, ${country}`;
    }

    // Handle Profile Picture Upload
    let avatarUrl: string | undefined;
    if (profilePicture && typeof profilePicture === 'object' && 'name' in profilePicture) {
      const file = profilePicture as File;
      const key = `avatars/${userId}-${Date.now()}.jpg`; // Assuming jpg or derive from type
      
      await c.env.MEDIA.put(key, await file.arrayBuffer(), {
        httpMetadata: {
          contentType: file.type || 'image/jpeg',
        },
      });
      
      // Use R2_PUBLIC_URL if available, otherwise fallback to worker proxy pattern
      if (c.env.R2_PUBLIC_URL) {
        avatarUrl = `https://${c.env.R2_PUBLIC_URL}/${key}`;
      } else {
        const origin = new URL(c.req.url).origin;
        avatarUrl = `${origin}/api/files/${key}`;
      }
    }

    // Prepare arrays for DB columns
    // Merge roles and specialisations into 'categories'
    let categories: string[] = [];
    try {
      if (rolesStr) categories.push(...JSON.parse(rolesStr));
      if (specialisationsStr) categories.push(...JSON.parse(specialisationsStr));
    } catch (e) {
      console.error('Error parsing roles/specialisations:', e);
    }

    // goals -> looking_for
    let lookingFor: string[] = [];
    try {
      if (goalsStr) lookingFor.push(...JSON.parse(goalsStr));
    } catch (e) {
      console.error('Error parsing goals:', e);
    }

    // skills -> skills
    let skills: string[] = [];
    try {
      if (skillsStr) skills.push(...JSON.parse(skillsStr));
    } catch (e) {
      console.error('Error parsing skills:', e);
    }

    // Prepare SQL update
    // We update bio, location, profile_complete_percentage, categories, looking_for, skills
    // And avatar_url if new one exists
    
    let sql = `UPDATE users SET 
      bio = ?, 
      location = ?, 
      profile_complete_percentage = 100,
      updated_at = datetime('now')`;
    
    const params: any[] = [bio, location];

    if (avatarUrl) {
      sql += `, avatar_url = ?`;
      params.push(avatarUrl);
    }

    // Add JSON columns
    // We store them as JSON strings
    if (categories.length > 0) {
      sql += `, categories = ?`;
      params.push(JSON.stringify(categories));
    }

    if (lookingFor.length > 0) {
      sql += `, looking_for = ?`;
      params.push(JSON.stringify(lookingFor));
    }

    if (skills.length > 0) {
      sql += `, skills = ?`;
      params.push(JSON.stringify(skills));
    }

    // Add gender if supported (schema check needed, but let's assume not for now or check)
    // 0000_init.sql didn't show gender.

    sql += ` WHERE id = ?`;
    params.push(userId);

    const result = await c.env.DB.prepare(sql).bind(...params).run();

    if (!result.success) {
      throw new Error('Database update failed');
    }

    return c.json({ success: true });
  } catch (e: any) {
    console.error('User guide submission error:', e);
    return c.json({ error: e.message }, 500);
  }
});
