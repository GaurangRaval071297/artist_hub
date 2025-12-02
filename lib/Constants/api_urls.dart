class ApiUrls {
  static const String baseUrl = "https://prakrutitech.xyz/gaurang/";

  // Auth
  static const String loginUrl = "${baseUrl}login.php";
  static const String registerUrl = "${baseUrl}register.php";

  // Category
  static const String addCategoryUrl = "${baseUrl}add_category.php";
  static const String updateCategoryUrl = "${baseUrl}update_category.php";
  static const String viewCategoryUrl = "${baseUrl}view_all_category.php";
  static const String deleteCategoryUrl = "${baseUrl}delete_category.php";

  // Bookings
  static const String addBookingUrl = "${baseUrl}book_artist.php";
  static const String updateBookingUrl = "${baseUrl}update_booking.php";
  static const String viewBookingUrl = "${baseUrl}view_all_bookings.php";
  static const String deleteBookingUrl = "${baseUrl}delete_booking.php";

  // Artist
  static const String addArtistUrl = "${baseUrl}add_artist.php";
  static const String updateArtistUrl = "${baseUrl}update_artist.php";
  static const String viewArtistUrl = "${baseUrl}get_artists.php";
  static const String deletertistUrl = "${baseUrl}delete_artist.php";

}