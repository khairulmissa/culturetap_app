import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../models/user.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';


import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

class ManageBookingsScreen extends StatefulWidget {
  const ManageBookingsScreen({super.key});

  @override
  State<ManageBookingsScreen> createState() => _ManageBookingsScreenState();
}

class _ManageBookingsScreenState extends State<ManageBookingsScreen> {
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();
  
  List<Booking> _bookings = [];
  List<Booking> _filteredBookings = [];
  Map<int, String> _userNames = {};
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'All';
  DateTime? _selectedDate;
  
  final List<String> _statusOptions = ['All', 'pending', 'confirmed', 'cancelled', 'completed'];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final bookings = await _dbService.getAllBookings();
      await _loadUserNames(bookings);
      setState(() {
        _bookings = bookings;
        _filteredBookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadUserNames(List<Booking> bookings) async {
    final userIds = bookings.map((b) => b.userId).toSet();
    for (final userId in userIds) {
      if (!_userNames.containsKey(userId)) {
        try {
          final user = await _dbService.getUserById(userId);
          if (user != null) _userNames[userId] = user.name;
        } catch (e) {
          print('❌ Error user $userId: $e');
        }
      }
    }
  }

  void _filterBookings() {
    List<Booking> filtered = _bookings;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((booking) {
        final userName = _userNames[booking.userId] ?? '';
        return userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               booking.destinationName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (booking.bookingReference ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (_selectedStatus != 'All') {
      filtered = filtered.where((booking) => booking.status == _selectedStatus).toList();
    }

    if (_selectedDate != null) {
      filtered = filtered.where((booking) {
        return booking.visitDate.year == _selectedDate!.year &&
               booking.visitDate.month == _selectedDate!.month &&
               booking.visitDate.day == _selectedDate!.day;
      }).toList();
    }

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    setState(() => _filteredBookings = filtered);
  }

  Future<void> _updateBookingStatus(int bookingId, String newStatus) async {
    try {
      await _dbService.updateBookingStatus(bookingId, newStatus);
      
      _loadBookings();
      
      setState(() {
        final index = _bookings.indexWhere((b) => b.id == bookingId);
        if (index != -1) {
          final oldBooking = _bookings[index];
          _bookings[index] = Booking(
            id: oldBooking.id,
            userId: oldBooking.userId,
            destinationId: oldBooking.destinationId,
            destinationName: oldBooking.destinationName,
            destinationImage: oldBooking.destinationImage,
            bookingDate: oldBooking.bookingDate,
            visitDate: oldBooking.visitDate,
            numberOfPeople: oldBooking.numberOfPeople,
            totalPrice: oldBooking.totalPrice,
            status: newStatus,
            createdAt: oldBooking.createdAt,
            specialRequest: oldBooking.specialRequest,
            bookingReference: oldBooking.bookingReference ?? 'N/A',
          );
        }
      });
      
      _filterBookings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Updated to $newStatus'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      print('❌ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showBookingDetails(Booking booking) async {
    final user = await _dbService.getUserById(booking.userId);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Details', style: TextStyle(fontSize: 16, color: Colors.teal)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Booking ID:', '#${booking.id}'),
              _buildDetailRow('Reference:', booking.bookingReference ?? 'N/A'),
              _buildDetailRow('Status:', booking.status.toUpperCase()),
              const SizedBox(height: 12),
              const Text('User Info', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal)),
              _buildDetailRow('Name:', user?.name ?? 'Unknown'),
              _buildDetailRow('Email:', user?.email ?? 'Unknown'),
              const SizedBox(height: 12),
              const Text('Destination', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal)),
              _buildDetailRow('Place:', booking.destinationName),
              _buildDetailRow('Visit Date:', _formatDate(booking.visitDate)),
              const SizedBox(height: 12),
              const Text('Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal)),
              _buildDetailRow('People:', booking.numberOfPeople.toString()),
              _buildDetailRow('Price:', booking.formattedPrice),
              if (booking.specialRequest?.isNotEmpty ?? false)
                _buildDetailRow('Request:', booking.specialRequest!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(fontSize: 12, color: Colors.teal)),
          ),
          
          ElevatedButton(
            onPressed: () => _generateBookingReport(booking, user),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Generate Report', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  

  Future<void> _generateBookingReport(Booking booking, User? user) async {
    try {
      Navigator.pop(context); // Close details dialog
      
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.teal)),
      );
      
      // Generate PDF
      final pdfFile = await _createBookingPdf(booking, user);
      
      // Close loading
      if (mounted) Navigator.pop(context);
      
      // Show success dialog
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Report Generated', style: TextStyle(fontSize: 14, color: Colors.teal)),
            content: const Text('Booking report has been generated successfully.', style: TextStyle(fontSize: 12)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK', style: TextStyle(color: Colors.teal)),
              ),
              TextButton(
                onPressed: () => _shareReport(pdfFile),
                child: const Text('Share', style: TextStyle(color: Colors.teal)),
              ),
              TextButton(
                onPressed: () => _openReport(pdfFile),
                child: const Text('View', style: TextStyle(color: Colors.teal)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('❌ Error generating report: $e');
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate report: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<File> _createBookingPdf(Booking booking, User? user) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Text(
                  'BOOKING REPORT',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Booking Details
              pw.Text(
                'Booking Details',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue700,
                ),
              ),
              pw.Divider(),
              _buildPdfRow('Booking ID:', '#${booking.id}'),
              _buildPdfRow('Reference:', booking.bookingReference ?? 'N/A'),
              _buildPdfRow('Status:', booking.status.toUpperCase()),
              _buildPdfRow('Booking Date:', _formatDate(booking.bookingDate)),
              _buildPdfRow('Visit Date:', _formatDate(booking.visitDate)),
              pw.SizedBox(height: 15),
              
              // User Information
              pw.Text(
                'User Information',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue700,
                ),
              ),
              pw.Divider(),
              _buildPdfRow('Name:', user?.name ?? 'Unknown'),
              _buildPdfRow('Email:', user?.email ?? 'Unknown'),
              pw.SizedBox(height: 15),
              
              // Destination Information
              pw.Text(
                'Destination Information',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue700,
                ),
              ),
              pw.Divider(),
              _buildPdfRow('Destination:', booking.destinationName),
              pw.SizedBox(height: 15),
              
              // Booking Summary
              pw.Text(
                'Booking Summary',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue700,
                ),
              ),
              pw.Divider(),
              _buildPdfRow('Number of People:', booking.numberOfPeople.toString()),
              _buildPdfRow('Total Price:', booking.formattedPrice),
              pw.SizedBox(height: 15),
              
              // Special Requests (if any)
              if (booking.specialRequest != null && booking.specialRequest!.isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Special Requests',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue700,
                      ),
                    ),
                    pw.Divider(),
                    pw.Text(booking.specialRequest!),
                  ],
                ),
              
              // Footer
              pw.Spacer(),
              pw.Divider(),
              pw.Center(
                child: pw.Text(
                  'Generated on ${_formatDate(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );
    
    // Save to file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/booking_report_${booking.id}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _openReport(File file) async {
    try {
      await OpenFile.open(file.path);
    } catch (e) {
      print('❌ Error opening file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot open file: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _shareReport(File file) async {
    try {
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Booking Report',
        text: 'Booking report from Travel App',
      );
      
      if (result.status == ShareResultStatus.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report shared successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      print('❌ Error sharing file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

 

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 70, child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black87))),
          const SizedBox(width: 4),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 11, color: Colors.black87))),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'cancelled': return Colors.red;
      case 'completed': return Colors.blue;
      default: return Colors.grey;
    }
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _getStatusColor(status)),
      ),
      child: Text(
        status.length > 3 ? status.substring(0, 3).toUpperCase() : status.toUpperCase(),
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _getStatusColor(status)),
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
      _filterBookings();
    }
  }

  void _clearDateFilter() {
    setState(() => _selectedDate = null);
    _filterBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bookings', style: TextStyle(fontSize: 16, color: Colors.white)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20, color: Colors.white),
            onPressed: _loadBookings,
            tooltip: 'Refresh',
          ),
        ],
      ),
      
      body: Column(
        children: [
          // FILTER BAR
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.teal[50],
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterBookings();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search bookings...',
                    hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, size: 18, color: Colors.teal),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Status Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          labelStyle: const TextStyle(fontSize: 11, color: Colors.teal),
                          prefixIcon: const Icon(Icons.filter_list, size: 16, color: Colors.teal),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        style: const TextStyle(fontSize: 11, color: Colors.black87),
                        items: _statusOptions.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(
                              status == 'All' ? 'All Statuses' : status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11, 
                                color: status == 'All' ? Colors.grey : _getStatusColor(status)
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedStatus = value!);
                          _filterBookings();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Date Filter
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                        child: TextButton(
                          onPressed: _showDatePicker,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Colors.teal),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _selectedDate == null ? 'All Dates' : _formatDate(_selectedDate!),
                                  style: const TextStyle(fontSize: 11, color: Colors.teal),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_selectedDate != null)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 12, color: Colors.teal),
                                  onPressed: _clearDateFilter,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // STATS BAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredBookings.length} bookings found',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.teal),
                ),
                if (_selectedDate != null || _selectedStatus != 'All')
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedStatus = 'All';
                        _selectedDate = null;
                      });
                      _filterBookings();
                    },
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: const Text('Clear Filters', style: TextStyle(fontSize: 11, color: Colors.teal)),
                  ),
              ],
            ),
          ),
          
          // BOOKINGS LIST
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.teal, strokeWidth: 2))
                : _filteredBookings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.book_online, size: 48, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            const Text('No bookings', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              _searchQuery.isNotEmpty || _selectedStatus != 'All' || _selectedDate != null
                                  ? 'Adjust filters'
                                  : 'No bookings yet',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _filteredBookings.length,
                        itemBuilder: (context, index) {
                          final booking = _filteredBookings[index];
                          final userName = _userNames[booking.userId] ?? 'Unknown User';
                          return _buildBookingCard(booking, userName);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // BOOKING CARD
  Widget _buildBookingCard(Booking booking, String userName) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.destinationName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'by $userName',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(booking.status),
              ],
            ),
            
            const SizedBox(height: 10),
            
            // Details
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 12, color: Colors.teal.shade600),
                          const SizedBox(width: 4),
                          Text('Visit:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.teal.shade600)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _formatDate(booking.visitDate),
                              style: const TextStyle(fontSize: 10, color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.people, size: 12, color: Colors.teal.shade600),
                          const SizedBox(width: 4),
                          Text('People:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.teal.shade600)),
                          const SizedBox(width: 4),
                          Text(booking.numberOfPeople.toString(), style: const TextStyle(fontSize: 10, color: Colors.black87)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.confirmation_number, size: 12, color: Colors.teal.shade600),
                          const SizedBox(width: 4),
                          Text('Ref:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.teal.shade600)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              booking.bookingReference ?? 'N/A',
                              style: const TextStyle(fontSize: 10, color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Price & ID
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      booking.formattedPrice,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '#${booking.id}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showBookingDetails(booking),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      side: const BorderSide(color: Colors.teal),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.visibility, size: 14, color: Colors.teal),
                        SizedBox(width: 4),
                        Text('View', style: TextStyle(fontSize: 11, color: Colors.teal)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: booking.status,
                    decoration: InputDecoration(
                      labelText: 'Update Status',
                      labelStyle: const TextStyle(fontSize: 10, color: Colors.teal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Colors.teal),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    style: const TextStyle(fontSize: 10, color: Colors.black87),
                    items: ['pending', 'confirmed', 'cancelled', 'completed'].map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(color: _getStatusColor(status), shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              status.length > 3 ? status.substring(0, 3).toUpperCase() : status.toUpperCase(),
                              style: TextStyle(fontSize: 10, color: _getStatusColor(status)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newStatus) {
                      if (newStatus != null && newStatus != booking.status) {
                        _updateBookingStatus(booking.id!, newStatus);
                      }
                    },
                  ),
                ),
              ],
            ),
            
            // Special Request
            if (booking.specialRequest != null && booking.specialRequest!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.note, size: 12, color: Colors.blue.shade700),
                            const SizedBox(width: 4),
                            const Text('Request:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(booking.specialRequest!, style: const TextStyle(fontSize: 10, color: Colors.black87)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}