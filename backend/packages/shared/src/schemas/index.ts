import { z } from 'zod';

export const userSchema = z.object({
  id: z.string().uuid(),
  username: z.string().min(3),
  email: z.string().email(),
  avatar_url: z.string().url().nullable().optional(),
  cover_photo_url: z.string().url().nullable().optional(),
  bio: z.string().max(500).nullable().optional(),
  tagline: z.string().max(100).nullable().optional(),
  location: z.string().nullable().optional(),
});

export const postSchema = z.object({
  id: z.string().uuid(),
  title: z.string().min(1),
  content: z.string().optional(),
  post_type: z.enum(['regular', 'job', 'project', 'tech_news']).default('regular'),
  author_id: z.string().uuid(),
  category_id: z.string().uuid().nullable().optional(),
  created_at: z.string().datetime(),
});

export const commentSchema = z.object({
  id: z.string().uuid(),
  content: z.string().min(1),
  author_id: z.string().uuid(),
  post_id: z.string().uuid(),
  parent_id: z.string().uuid().nullable().optional(),
  created_at: z.string().datetime(),
});

export const opportunitySchema = z.object({
  id: z.string().uuid(),
  title: z.string().min(1),
  description: z.string().optional(),
  company_id: z.string().uuid().nullable().optional(),
  location: z.string().optional(),
  salary: z.string().optional(),
  job_type: z.string().optional(),
  deadline: z.string().datetime().nullable().optional(),
});

export const projectSchema = z.object({
  id: z.string().uuid(),
  title: z.string().min(1),
  description: z.string().optional(),
  owner_id: z.string().uuid(),
  status: z.string().default('draft'),
  tech_stack: z.string().optional(),
  looking_for_contributors: z.boolean().default(false),
});

export type User = z.infer<typeof userSchema>;
export type Post = z.infer<typeof postSchema>;
export type Comment = z.infer<typeof commentSchema>;
export type Opportunity = z.infer<typeof opportunitySchema>;
export type Project = z.infer<typeof projectSchema>;
