class Endpoints {
  // Traditional email/password auth
  static const login = "/auth/login";
  static const register = "/auth/register";
  static const profile = "/auth/profile";
  
  // Firebase authentication endpoints
  static const firebaseAuth = "/auth/firebase/auth";
  static const googleSignIn = "/auth/google/signin";
  static const appleSignIn = "/auth/apple/signin";
  static const phoneAuth = "/auth/phone/auth";
  static const feed = "/offers/feed";
  static const offers = "/offers";
  static const savedOffers = "/offers/saved";
  static const crazyDeals = "/offers/crazy-deals";
  static const ads = "/ads";
  static const registerDevice = "/notifications/register-device";
  static const shops = "/shops";
  static const followingShops = "/shops/following";
  static const userNotifications = "/users/me/notifications";
  static const myReviews = "/reviews/my-reviews";
  static const cities = "/cities";
  static const areas = "/areas";
  
  // 🔥 New Feature Endpoints
  static const search = "/search";
  static const chat = "/chat";
  static const notificationHistory = "/notifications/history";
  static const markNotificationsRead = "/notifications/mark-read";
  static const markAllNotificationsRead = "/notifications/mark-all-read";
  static const categories = "/categories";
  static const followCategory = "/categories"; // + /:category/follow
  static const reviews = "/reviews";
  static const uploadImage = "/media/upload";
  
  // Shop Analytics
  static String shopAnalyticsReviews(String shopId) => "/shops/$shopId/analytics/reviews";
  static String shopAnalyticsEarnings(String shopId) => "/shops/$shopId/analytics/earnings";
  static String shopAnalyticsEngagement(String shopId) => "/shops/$shopId/analytics/engagement";
  
  // Offer actions
  static String offerShare(String offerId) => "/offers/$offerId/share";
  
  // 🎯 Claim Management
  static const myClaims = "/offers/my-claims";
  static String offerClaims(String offerId) => "/offers/$offerId/claims";
  static String redeemClaim(String claimId) => "/offers/claims/$claimId/redeem";
}
