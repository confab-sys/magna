class Endpoints {
  static const authLogin = '/api/auth/login';
  static const authRegister = '/api/auth/register';
  static const postsFeed = '/api/posts/feed';
  static const posts = '/api/posts';
  static const comments = '/api/comments';
  static String commentsByPost(String postId) => '/api/comments/post/$postId';
  static String likeComment(String id) => '/api/comments/$id/like';
  static const users = '/api/users';
  static const usersProfile = '/api/users/profile';
  static const projects = '/api/projects';
  static const jobs = '/api/jobs';
  static const chatConversations = '/api/chat/conversations';
  static const chatMessages = '/api/chat/messages';
  static const notifications = '/api/notifications';
  static const aiChat = '/api/ai/chat';
  static const aiQuery = '/api/ai/query';
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
  static String messagesByConversation(String conversationId) =>
      '/api/chat/messages/$conversationId'; // Note: Check backend if it's path param or query
  static String markNotificationRead(String id) =>
      '/api/notifications/$id/read';
}
