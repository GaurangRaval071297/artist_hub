import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artist_hub/providers/auth_provider.dart';
import 'package:artist_hub/providers/booking_provider.dart';
import 'package:artist_hub/shared/constants/app_colors.dart';

class BookingScreens extends StatefulWidget {
  final String userId;
  final String userType;
  const BookingScreens({
    required this.userId,
    required this.userType,
    super.key,
  });

  @override
  State<BookingScreens> createState() => _BookingScreensState();
}

class _BookingScreensState extends State<BookingScreens> {
  int _selectedTab = 0; // 0: Pending, 1: Confirmed, 2: Completed, 3: Cancelled

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() async {
    // Here you would load bookings from API
    // For now, we'll use mock data
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    // Example: Mock bookings
    // In real app, you would fetch from API based on userType
    if (widget.userType == 'artist') {
      // Fetch artist bookings
    } else {
      // Fetch customer bookings
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);

    // Filter bookings based on selected tab
    List<Booking> filteredBookings = bookingProvider.bookings.where((booking) {
      switch (_selectedTab) {
        case 0: return booking.status == 'pending';
        case 1: return booking.status == 'confirmed';
        case 2: return booking.status == 'completed';
        case 3: return booking.status == 'cancelled';
        default: return true;
      }
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.appBarGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Bookings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  widget.userType == 'artist'
                      ? 'Manage your artist bookings'
                      : 'View your bookings',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildTab('Pending', 0),
                _buildTab('Confirmed', 1),
                _buildTab('Completed', 2),
                _buildTab('Cancelled', 3),
              ],
            ),
          ),

          // Bookings List
          Expanded(
            child: bookingProvider.isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: AppColors.appBarGradient.colors[0],
              ),
            )
                : filteredBookings.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No bookings found',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'You have no ${_getTabTitle(_selectedTab).toLowerCase()} bookings',
                    style: TextStyle(
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: filteredBookings.length,
              itemBuilder: (context, index) {
                final booking = filteredBookings[index];
                return _buildBookingCard(booking, index);
              },
            ),
          ),
        ],
      ),

      // Add Booking Button (only for customers)
      floatingActionButton: widget.userType == 'customer'
          ? FloatingActionButton(
        onPressed: () {
          // Navigate to add booking screen
        },
        backgroundColor: AppColors.appBarGradient.colors[0],
        child: Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }

  Widget _buildTab(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _selectedTab == index
                  ? AppColors.appBarGradient.colors[0]
                  : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: _selectedTab == index
                ? AppColors.appBarGradient.colors[0]
                : Colors.grey[600],
            fontWeight: _selectedTab == index
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, int index) {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.eventType,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                SizedBox(width: 5),
                Text(
                  '${booking.eventDate} at ${booking.eventTime}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                SizedBox(width: 5),
                Text(
                  booking.venue,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userType == 'artist'
                          ? 'Customer: ${booking.customerName}'
                          : 'Artist: ${booking.artistName}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Budget: ₹${booking.budget}',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (widget.userType == 'artist' && booking.status == 'pending')
                      ElevatedButton(
                        onPressed: () {
                          _updateBookingStatus(booking.id, 'confirmed');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Accept'),
                      ),
                    SizedBox(width: 10),
                    if (widget.userType == 'artist' && booking.status == 'pending')
                      ElevatedButton(
                        onPressed: () {
                          _updateBookingStatus(booking.id, 'cancelled');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Reject'),
                      ),
                    if (widget.userType == 'customer' && booking.status == 'pending')
                      ElevatedButton(
                        onPressed: () {
                          _updateBookingStatus(booking.id, 'cancelled');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Cancel'),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getTabTitle(int index) {
    switch (index) {
      case 0: return 'Pending';
      case 1: return 'Confirmed';
      case 2: return 'Completed';
      case 3: return 'Cancelled';
      default: return '';
    }
  }

  void _updateBookingStatus(String bookingId, String newStatus) {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    bookingProvider.updateBookingStatus(bookingId, newStatus);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking status updated to $newStatus'),
        backgroundColor: Colors.green,
      ),
    );
  }
}