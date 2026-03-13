export type Bindings = {
  DB: D1Database;
  CACHE: KVNamespace;
  MEDIA: R2Bucket;
  JWT_SECRET: string;
  REALTIME: Fetcher;
  REALTIME_INTERNAL_KEY: string;
  MAGNA_AI_BASE: string;
  R2_PUBLIC_URL: string;
  GOOGLE_CLIENT_ID: string;
  GOOGLE_CLIENT_SECRET: string;
  GITHUB_CLIENT_ID: string;
  GITHUB_CLIENT_SECRET: string;
};

export type Variables = {
  userId: string;
};
