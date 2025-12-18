class ApiUrls {
  // Base URLs
  static const String baseUrl = "http://10.125.54.104/artist_hub_api/";
  // Alternative: static const String baseUrl = "https://prakrutitech.xyz/gaurang/";

  // Auth Endpoints
  static const String loginUrl = "${baseUrl}login.php";
  static const String registerUrl = "${baseUrl}register.php";

  // Category Endpoints
  static const String addCategoryUrl = "${baseUrl}add_category.php";
  static const String updateCategoryUrl = "${baseUrl}update_category.php";
  static const String viewCategoryUrl = "${baseUrl}view_all_category.php";
  static const String deleteCategoryUrl = "${baseUrl}delete_category.php";

  // Booking Endpoints
  static const String addBookingUrl = "${baseUrl}book_artist.php";
  static const String updateBookingUrl = "${baseUrl}update_booking.php";
  static const String viewBookingUrl = "${baseUrl}view_all_bookings.php";
  static const String deleteBookingUrl = "${baseUrl}delete_booking.php";

  // Artist Endpoints
  static const String addArtistUrl = "${baseUrl}add_artist.php";
  static const String updateArtistUrl = "${baseUrl}update_artist.php";
  static const String viewArtistUrl = "${baseUrl}get_artists.php";
  static const String deleteArtistUrl = "${baseUrl}delete_artist.php";

  // User Endpoints
  static const String getUserProfileUrl = "${baseUrl}get_user_profile.php";
  static const String updateProfileUrl = "${baseUrl}update_profile.php";

  // Other Endpoints
  static const String forgotPasswordUrl = "${baseUrl}forgot_password.php";
  static const String resetPasswordUrl = "${baseUrl}reset_password.php";
  static const String verifyOtpUrl = "${baseUrl}verify_otp.php";
}