import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sri_lanka_sports_app/services/auth_service.dart';
import 'package:sri_lanka_sports_app/utils/app_theme.dart';
import 'package:sri_lanka_sports_app/widgets/custom_button.dart';
import 'package:sri_lanka_sports_app/widgets/custom_text_field.dart';

class EquipmentFinderScreen extends StatefulWidget {
  const EquipmentFinderScreen({Key? key}) : super(key: key);

  @override
  State<EquipmentFinderScreen> createState() => _EquipmentFinderScreenState();
}

class _EquipmentFinderScreenState extends State<EquipmentFinderScreen> {
  final _searchController = TextEditingController();
  final List<String> _tags = [];
  final List<String> _suggestedTags = [
    'Cricket',
    'Football',
    'Swimming',
    'Running',
    'Affordable',
    'Professional',
    'Beginner',
    'Training',
    'Shoes',
    'Clothing',
    'Accessories',
    'Equipment',
  ];

  List<String> _favoriteSites = [];
  bool _isLoading = false;
  List<Map<String, dynamic>>? _searchResults;

  @override
  void initState() {
    super.initState();
    _loadFavoriteSites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavoriteSites() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userModel = authService.userModel;

    if (userModel != null && userModel.favoriteEquipmentSites != null) {
      setState(() {
        _favoriteSites = userModel.favoriteEquipmentSites!;
      });
    } else {
      setState(() {
        _favoriteSites = [
          'SportsSL.com',
          'CricketGear.lk',
          'SportsEquipment.lk',
        ];
      });
    }
  }

  Future<void> _searchEquipment() async {
    if (_searchController.text.isEmpty && _tags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a search term or select tags'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, this would be a call to your API endpoint
      // For demo purposes, we'll simulate a response
      await Future.delayed(const Duration(seconds: 2));

      // Simulated response
      setState(() {
        _searchResults = [
          {
            'name': 'Kookaburra Cricket Bat',
            'price': 'Rs. 15,000',
            'store': 'SportsSL.com',
            'rating': 4.5,
            'image': 'cricket_bat.jpg',
            'url': 'https://sportsslcom/cricket-bat',
          },
          {
            'name': 'Adidas Football Shoes',
            'price': 'Rs. 8,500',
            'store': 'SportsEquipment.lk',
            'rating': 4.2,
            'image': 'football_shoes.jpg',
            'url': 'https://sportsequipment.lk/adidas-shoes',
          },
          {
            'name': 'Swimming Goggles Pro',
            'price': 'Rs. 3,200',
            'store': 'AquaticsSL.com',
            'rating': 4.7,
            'image': 'swimming_goggles.jpg',
            'url': 'https://aquaticsslcom/goggles',
          },
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _addTag(String tag) {
    if (!_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Finder'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: _searchController,
                    labelText: 'Search for equipment or medicine',
                    prefixIcon: Icons.search,
                    suffixIcon: Icons.clear,
                    onSuffixIconPressed: () {
                      _searchController.clear();
                    },
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  if (_tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => _removeTag(tag),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Suggested tags
                  const Text(
                    'Suggested Tags:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _suggestedTags.map((tag) {
                      return ActionChip(
                        label: Text(tag),
                        onPressed: () => _addTag(tag),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Favorite sites
                  const Text(
                    'Search in:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _favoriteSites.map((site) {
                      return FilterChip(
                        label: Text(site),
                        selected: true,
                        onSelected: (selected) {
                          // In a real app, you would toggle the selection
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Search button
                  CustomButton(
                    text: 'Find Equipment',
                    isLoading: _isLoading,
                    onPressed: _searchEquipment,
                  ),
                ],
              ),
            ),

            // Results
            if (_searchResults != null) ...[
              const Divider(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Results (${_searchResults!.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.filter_list),
                      label: const Text('Filter'),
                      onPressed: () {
                        // Show filter options
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _searchResults!.length,
                  itemBuilder: (context, index) {
                    final item = _searchResults![index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product image
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.sports_cricket,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Product details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['price'],
                                    style: TextStyle(
                                      color: AppTheme.secondaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.store,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item['store'],
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item['rating'].toString(),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            // View details
                                          },
                                          child: const Text('Details'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Open URL
                                          },
                                          child: const Text('Visit'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
