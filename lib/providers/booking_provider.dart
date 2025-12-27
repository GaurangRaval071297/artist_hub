import 'package:flutter/material.dart';

class Booking {
  final String id;
  final String customerId;
  final String artistId;
  final String customerName;
  final String artistName;
  final String eventType;
  final String eventDate;
  final String eventTime;
  final String venue;
  final String budget;
  final String status;
  final String createdAt;

  Booking({
    required this.id,
    required this.customerId,
    required this.artistId,
    required this.customerName,
    required this.artistName,
    required this.eventType,
    required this.eventDate,
    required this.eventTime,
    required this.venue,
    required this.budget,
    required this.status,
    required this.createdAt,
  });
}

class BookingProvider extends ChangeNotifier {
  List<Booking> _bookings = [];
  bool _isLoading = false;
  String _error = '';

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String get error => _error;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  void addBooking(Booking newBooking) {
    _bookings.insert(0, newBooking);
    _error = '';
    notifyListeners();
  }

  void addBookings(List<Booking> newBookings) {
    _bookings = newBookings;
    _error = '';
    notifyListeners();
  }

  void updateBookingStatus(String bookingId, String newStatus) {
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index != -1) {
      final oldBooking = _bookings[index];
      _bookings[index] = Booking(
        id: oldBooking.id,
        customerId: oldBooking.customerId,
        artistId: oldBooking.artistId,
        customerName: oldBooking.customerName,
        artistName: oldBooking.artistName,
        eventType: oldBooking.eventType,
        eventDate: oldBooking.eventDate,
        eventTime: oldBooking.eventTime,
        venue: oldBooking.venue,
        budget: oldBooking.budget,
        status: newStatus,
        createdAt: oldBooking.createdAt,
      );
      notifyListeners();
    }
  }

  void deleteBooking(String bookingId) {
    _bookings.removeWhere((booking) => booking.id == bookingId);
    notifyListeners();
  }

  void clearBookings() {
    _bookings.clear();
    notifyListeners();
  }

  List<Booking> getArtistBookings(String artistId) {
    return _bookings.where((booking) => booking.artistId == artistId).toList();
  }

  List<Booking> getCustomerBookings(String customerId) {
    return _bookings.where((booking) => booking.customerId == customerId).toList();
  }
}