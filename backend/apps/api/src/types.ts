export type Bindings = {
  DB: D1Database;
  CACHE: KVNamespace;
  MEDIA: R2Bucket;
  JWT_SECRET: string;
  MAGNA_AI_BASE: string;
  R2_PUBLIC_URL: string;
};

export type Variables = {
  userId: string;
};
