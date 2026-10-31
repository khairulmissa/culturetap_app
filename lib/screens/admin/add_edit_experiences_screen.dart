import 'package:flutter/material.dart';
import '../../models/destination.dart';
import '../../services/database_service.dart';

class AddEditExperienceScreen extends StatefulWidget {
  final Destination? destination;
  final VoidCallback onSave;

  const AddEditExperienceScreen({
    super.key,
    this.destination,
    required this.onSave,
  });

  @override
  State<AddEditExperienceScreen> createState() => _AddEditExperienceScreenState();
}

class _AddEditExperienceScreenState extends State<AddEditExperienceScreen> {
  final DatabaseService _dbService = DatabaseService();
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _ticketPriceController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _totalReviewsController = TextEditingController();
  final TextEditingController _operatingHoursController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();
  final TextEditingController _categoriesController = TextEditingController();
  final TextEditingController _galleryImagesController = TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;

  // Available states in Malaysia
  final List<String> _malaysianStates = [
    'Kuala Lumpur',
    'Selangor',
    'Johor',
    'Penang',
    'Melaka',
    'Terengganu',
    'Kelantan',
    'Pahang',
    'Perak',
    'Kedah',
    'Negeri Sembilan',
    'Perlis',
    'Sabah',
    'Sarawak',
    'Labuan',
    'Putrajaya',
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.destination != null;
    
    
    if (_isEditing) {
      final dest = widget.destination!;
      _nameController.text = dest.name;
      _descriptionController.text = dest.description;
      _locationController.text = dest.location;
      _stateController.text = dest.state;
      _imageUrlController.text = dest.imageUrl;
      _ticketPriceController.text = dest.ticketPrice.toString();
      _ratingController.text = dest.rating.toString();
      _totalReviewsController.text = dest.totalReviews.toString();
      _operatingHoursController.text = dest.openingHours ?? '';
      _contactInfoController.text = dest.contactInfo ?? '';
      _categoriesController.text = dest.categories.join(', ');
      _galleryImagesController.text = dest.galleryImages.join(', ');
    } else {
      
      _imageUrlController.text = 'https://via.placeholder.com/400x300/4A6572/FFFFFF?text=Culture+Destination';
    }
  }

  Future<void> _saveDestination() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      
      List<String> categories = _categoriesController.text
          .split(',')
          .map((cat) => cat.trim())
          .where((cat) => cat.isNotEmpty)
          .toList();

      
      List<String> galleryImages = _galleryImagesController.text
          .split(',')
          .map((img) => img.trim())
          .where((img) => img.isNotEmpty)
          .toList();

      final destination = Destination(
        id: _isEditing ? widget.destination!.id : 0,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        state: _stateController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        ticketPrice: double.parse(_ticketPriceController.text),
        rating: double.parse(_ratingController.text),
        totalReviews: int.parse(_totalReviewsController.text),
        categories: categories,
        openingHours: _operatingHoursController.text.trim().isEmpty 
            ? null 
            : _operatingHoursController.text.trim(),
        contactInfo: _contactInfoController.text.trim().isEmpty 
            ? null 
            : _contactInfoController.text.trim(),
        galleryImages: galleryImages,
      );

      if (_isEditing) {
        await _dbService.updateDestination(destination);
      } else {
        await _dbService.insertDestination(destination);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing 
                  ? 'Destination updated successfully' 
                  : 'Destination added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        widget.onSave(); 
        Navigator.pop(context); 
      }
    } catch (e) {
      print('❌ Error saving destination: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save destination: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Destination' : 'Add New Destination'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // Show delete confirmation
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Destination'),
                    content: const Text('Are you sure you want to delete this destination?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          try {
                            await _dbService.deleteDestination(widget.destination!.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Destination deleted successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              widget.onSave();
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to delete: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Delete', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Delete',
            ),
        ],
      ),
      
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ FORM TITLE
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.teal[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isEditing ? Icons.edit : Icons.add_circle,
                            color: Colors.teal,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isEditing ? 'Edit Experience' : 'Create New Experience',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _isEditing 
                                      ? 'Update destination details'
                                      : 'Add a new cultural destination to the platform',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    
                    const Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Essential details about the destination',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Destination Name *',
                        prefixIcon: const Icon(Icons.place, color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.teal, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter destination name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Description Field
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Description *',
                        prefixIcon: const Icon(Icons.description, color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.teal, width: 2),
                        ),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description';
                        }
                        if (value.length < 20) {
                          return 'Description should be at least 20 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Location and State Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              labelText: 'Location *',
                              prefixIcon: const Icon(Icons.location_on, color: Colors.teal),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.teal, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter location';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _stateController.text.isEmpty ? null : _stateController.text,
                            decoration: InputDecoration(
                              labelText: 'State *',
                              prefixIcon: const Icon(Icons.map, color: Colors.teal),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.teal, width: 2),
                              ),
                            ),
                            items: _malaysianStates.map((state) {
                              return DropdownMenuItem(
                                value: state,
                                child: Text(state),
                              );
                            }).toList(),
                            onChanged: (value) {
                              _stateController.text = value!;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select state';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    
                    const Text(
                      'Media',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Images and visual content',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    
                    
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: InputDecoration(
                        labelText: 'Main Image URL *',
                        prefixIcon: const Icon(Icons.image, color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.teal, width: 2),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.help),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Image URL Help'),
                                content: const Text(
                                  'Enter a valid image URL (JPG/PNG).\n\nExample: https://example.com/image.jpg\n\nFor testing, you can use placeholder images:\nhttps://via.placeholder.com/400x300/4A6572/FFFFFF?text=Destination',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter image URL';
                        }
                        if (!value.startsWith('http')) {
                          return 'Please enter a valid URL';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    
                    TextFormField(
                      controller: _galleryImagesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Gallery Images (comma separated)',
                        prefixIcon: const Icon(Icons.photo_library, color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.teal, width: 2),
                        ),
                        hintText: 'https://img1.jpg, https://img2.jpg, ...',
                      ),
                    ),
                    
                    
                    const SizedBox(height: 24),
                    const Text(
                      'Pricing & Ratings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ticket price and visitor ratings',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ticketPriceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Ticket Price (RM) *',
                              prefixIcon: const Icon(Icons.attach_money, color: Colors.teal),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.teal, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter ticket price';
                              }
                              final price = double.tryParse(value);
                              if (price == null || price < 0) {
                                return 'Please enter a valid price';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _ratingController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Rating (0-5)',
                              prefixIcon: const Icon(Icons.star, color: Colors.teal),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.teal, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return null; // Optional field
                              }
                              final rating = double.tryParse(value);
                              if (rating == null || rating < 0 || rating > 5) {
                                return 'Rating must be between 0-5';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _totalReviewsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Total Reviews',
                              prefixIcon: const Icon(Icons.reviews, color: Colors.teal),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.teal, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // ✅ CATEGORIES SECTION
                    const SizedBox(height: 24),
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Destination categories (comma separated)',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _categoriesController,
                      decoration: InputDecoration(
                        labelText: 'Categories',
                        prefixIcon: const Icon(Icons.category, color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.teal, width: 2),
                        ),
                        hintText: 'Museum, Cultural, Historical, ...',
                      ),
                    ),
                    
                    // ✅ ADDITIONAL INFO SECTION
                    const SizedBox(height: 24),
                    const Text(
                      'Additional Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Optional details',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    
                    // Operating Hours
                    TextFormField(
                      controller: _operatingHoursController,
                      decoration: InputDecoration(
                        labelText: 'Operating Hours',
                        prefixIcon: const Icon(Icons.access_time, color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.teal, width: 2),
                        ),
                        hintText: '9:00 AM - 6:00 PM, Daily',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Contact Info
                    TextFormField(
                      controller: _contactInfoController,
                      decoration: InputDecoration(
                        labelText: 'Contact Information',
                        prefixIcon: const Icon(Icons.phone, color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.teal, width: 2),
                        ),
                        hintText: 'Phone: +60 12-345 6789',
                      ),
                    ),
                    
                    // ACTION BUTTONS
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.teal,
                              side: const BorderSide(color: Colors.teal),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveDestination,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(_isEditing ? 'Update Destination' : 'Add Destination'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _stateController.dispose();
    _imageUrlController.dispose();
    _ticketPriceController.dispose();
    _ratingController.dispose();
    _totalReviewsController.dispose();
    _operatingHoursController.dispose();
    _contactInfoController.dispose();
    _categoriesController.dispose();
    _galleryImagesController.dispose();
    super.dispose();
  }
}