import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../models/user.dart';
import '../models/wishlist_item.dart';
import '../services/database_service.dart';

class LocationDetailScreen extends StatefulWidget {
  final Location location;
  final User currentUser;

  const LocationDetailScreen({
    super.key, 
    required this.location,
    required this.currentUser,
  });

  @override
  State<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen> {
  final DatabaseService _dbService = DatabaseService();
  bool _isInWishlist = false;
  bool _isLoadingWishlist = false;

  @override
  void initState() {
    super.initState();
    _checkIfInWishlist();
  }

  Future<void> _checkIfInWishlist() async {
    try {
      final isInWishlist = await _dbService.isInWishlist(
        widget.currentUser.id,
        int.parse(widget.location.id),
      );
      
      setState(() {
        _isInWishlist = isInWishlist;
      });
    } catch (e) {
      print('❌ Error checking wishlist: $e');
    }
  }

  Future<void> _toggleWishlist() async {
    setState(() {
      _isLoadingWishlist = true;
    });

    try {
      if (_isInWishlist) {
        await _dbService.removeFromWishlist(
          widget.currentUser.id,
          int.parse(widget.location.id),
        );
        
        setState(() {
          _isInWishlist = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from wishlist'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        final wishlistItem = WishlistItem(
          id: null,
          userId: widget.currentUser.id,
          destinationId: int.parse(widget.location.id),
          destinationName: widget.location.name,
          destinationImage: widget.location.imageUrl,
          destinationLocation: widget.location.state,
          destinationPrice: 0.0,
          addedDate: DateTime.now(),
        );

        await _dbService.addToWishlist(wishlistItem);
        
        setState(() {
          _isInWishlist = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${widget.location.name} to wishlist!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error toggling wishlist: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isLoadingWishlist = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.location.name),
        backgroundColor: Colors.deepOrangeAccent,
        actions: [
          IconButton(
            icon: _isLoadingWishlist
                ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  )
                : Icon(
                    _isInWishlist ? Icons.favorite : Icons.favorite_border,
                    color: _isInWishlist ? Colors.red : Colors.white,
                    size: 28,
                  ),
            onPressed: _isLoadingWishlist ? null : _toggleWishlist,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Name
              Center(
                child: Text(
                  widget.location.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  widget.location.imageUrl,
                  width: double.infinity,
                  height: 200, 
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),

              // Location
              _buildDetailRow(
                title: 'Location:',
                content: widget.location.state,
              ),
              const SizedBox(height: 16),

              // Details
              _buildDetailRow(
                title: 'Details:',
                content: widget.location.description,
              ),
              const SizedBox(height: 16),

              // Category
              _buildDetailRow(
                title: 'Category:',
                content: widget.location.category,
              ),
              const SizedBox(height: 20),

              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, color: Colors.blue[700], size: 24),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Coordinates:',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${widget.location.latitude.toStringAsFixed(4)}, ${widget.location.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              
              if (_isInWishlist)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[800], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'This location is in your wishlist',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              
              if (_isInWishlist) const SizedBox(height: 20),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _toggleWishlist,
                  icon: _isInWishlist 
                      ? const Icon(Icons.favorite, color: Colors.red)
                      : const Icon(Icons.favorite_border),
                  label: Text(
                    _isInWishlist 
                        ? 'Remove from Wishlist' 
                        : 'Add to Wishlist',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isInWishlist ? Colors.red[400] : Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}