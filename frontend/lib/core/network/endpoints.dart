class Endpoints {
  static const authLogin = '/api/auth/login';
  static const authRegister = '/api/auth/register';
  static const googleAuthStart = '/api/auth/google';
  static const githubAuthStart = '/api/auth/github';
  static const forgotPassword = '/api/auth/forgot-password';
  static const resetPassword = '/api/auth/reset-password';

  // Frontend route the backend should redirect back to.
  static const oauthCallback = '/oauth/callback';
  static const postsFeed = '/api/posts/feed';
  static const posts = '/api/posts';
  static const comments = '/api/comments';
  static String commentsByPost(String postId) => '/api/comments/post/$postId';
  static String likeComment(String id) => '/api/comments/$id/like';
  static const users = '/api/users';
  static const usersProfile = '/api/users/profile';
  static const projects = '/api/projects';
  static const jobs = '/api/jobs';

  // Messages / conversations (v2, conversation-centric)
  static const conversations = '/api/chat/conversations';
  static String conversationById(String conversationId) =>
      '/api/chat/conversations/$conversationId';
  static String conversationMessages(String conversationId) =>
      '/api/chat/conversations/$conversationId/messages';
  static String createConversationMessage(String conversationId) =>
      '/api/chat/conversations/$conversationId/messages';
  static String markConversationRead(String conversationId) =>
      '/api/chat/conversations/$conversationId/read';
  static String updateConversationPreferences(String conversationId) =>
      '/api/chat/conversations/$conversationId/preferences';
  static String messageById(String messageId) =>
      '/api/chat/messages/$messageId';
  static String directConversation(String userId) =>
      '/api/chat/direct/$userId';

  // Legacy chat endpoints kept for backward compatibility where still used.
  static const chatConversations = '/api/chat/conversations';
  static const chatMessages = '/api/chat/messages';

  static const notifications = '/api/notifications';
  static const aiChat = '/api/ai/chat';
  static const aiQuery = '/api/ai/query';
  static const aiConversations = '/api/ai/conversations';
  static String aiConversationMessages(String conversationId) => '/api/ai/conversations/$conversationId/messages';
  static const coinsBalance = '/api/coins/balance';
  static const courses = '/api/courses';
  static const podcasts = '/api/podcasts';
  static const contracts = '/api/contracts';

  static String postById(String id) => '/api/posts/$id';
  static String likePost(String id) => '/api/posts/$id/like';
  static String likeJob(String id) => '/api/jobs/$id/like';
  static String likeProject(String id) => '/api/projects/$id/like';
  static String userById(String id) => '/api/users/$id';
  static String projectById(String id) => '/api/projects/$id';
  static String jobById(String id) => '/api/jobs/$id';
  static String courseById(String id) => '/api/courses/$id';

  static String markNotificationRead(String id) =>
      '/api/notifications/$id/read';
  static const markAllNotificationsRead = '/api/notifications/read-all';
}
