class ApiUrls {
  // Base URLs
  //static const String baseUrl = "http://10.125.54.104/artist_hub_api/";
  static const String baseUrl = "https://prakrutitech.xyz/gaurang/";

  // Auth Endpoints
  static const String loginUrl = "${baseUrl}login.php";
  static const String registerUrl = "${baseUrl}register.php";

  // Admin Approval
  static const String adminAprovalUrl = "${baseUrl}artist_aproval.php";

  // Booking Endpoints
  static const String addBookingUrl = "${baseUrl}add_bookings.php";
  static const String updateBookingUrl = "${baseUrl}update_bookings.php";
  static const String viewBookingUrl = "${baseUrl}view_bookings.php";
  static const String customerBookingCancel = "${baseUrl}customer_booking_cancel.php";
  static const String artistBookingCancel = "${baseUrl}artist_booking_cancel.php";

  // Artist Profile Endpoints
  static const String addArtistProfileUrl = "${baseUrl}add_artist_profile.php";
  static const String updateArtistProfileUrl = "${baseUrl}update_artist_profile.php";
  static const String deleteArtistProfileUrl = "${baseUrl}delete_artist_profile.php";
  static const String viewArtistProfileUrl = "${baseUrl}view_artist_profile.php";

  // User Endpoints
  static const String getUserProfileUrl = "${baseUrl}get_user_profile.php";
  static const String updateProfileUrl = "${baseUrl}update_profile.php";

  // Other Endpoints
  static const String forgotPasswordUrl = "${baseUrl}forgot_password.php";
  static const String resetPasswordUrl = "${baseUrl}reset_password.php";
  static const String verifyOtpUrl = "${baseUrl}verify_otp.php";
}