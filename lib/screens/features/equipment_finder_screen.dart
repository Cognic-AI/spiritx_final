import 'package:flutter/material.dart';
import 'package:sri_lanka_sports_app/models/equipment_model.dart';
import 'package:sri_lanka_sports_app/repositories/equipment_repository.dart';
import 'package:sri_lanka_sports_app/utils/app_theme.dart';
import 'package:sri_lanka_sports_app/widgets/custom_text_field.dart';

class EquipmentFinderScreen extends StatefulWidget {
  const EquipmentFinderScreen({super.key});

  @override
  State<EquipmentFinderScreen> createState() => _EquipmentFinderScreenState();
}

class _EquipmentFinderScreenState extends State<EquipmentFinderScreen> {
  final _searchController = TextEditingController();
  final EquipmentRepository _equipmentRepository = EquipmentRepository();

  final List<String> _tags = [];
  List<String> _favoriteSites = [];
  bool _isLoading = false;
  List<EquipmentModel>? _searchResults;

  final List<String> _allPossibleSites = [
    'SportsSL.com',
    'CricketGear.lk',
    'SportsEquipment.lk',
    'AthleticWorld.lk',
    'ProSports.lk',
  ];

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

  final TextEditingController _customSiteController = TextEditingController();
  final TextEditingController _customTagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFavoriteSites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customSiteController.dispose();
    _customTagController.dispose();
    super.dispose();
  }

  Future<void> _loadFavoriteSites() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final sites = await _equipmentRepository.getFavoriteEquipmentSites();

      setState(() {
        _favoriteSites = sites.isNotEmpty
            ? sites
            : ['SportsSL.com', 'CricketGear.lk', 'SportsEquipment.lk'];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading favorite sites: $e');
      setState(() {
        _favoriteSites = [
          'SportsSL.com',
          'CricketGear.lk',
          'SportsEquipment.lk'
        ];
        _isLoading = false;
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
      final results = await _equipmentRepository.searchEquipment(
        searchTerm: _searchController.text.trim(),
        tags: _tags.isNotEmpty ? _tags : null,
        stores: _favoriteSites,
      );

      setState(() {
        _searchResults = results;
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

  Future<void> _updateFavoriteSites(String site, bool selected) async {
    try {
      List<String> updatedSites = List.from(_favoriteSites);

      if (selected) {
        if (!updatedSites.contains(site)) {
          updatedSites.add(site);
        }
      } else {
        updatedSites.remove(site);
      }

      await _equipmentRepository.updateFavoriteEquipmentSites(updatedSites);

      setState(() {
        _favoriteSites = updatedSites;
      });
    } catch (e) {
      print('Error updating favorite sites: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating favorite sites: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _addCustomSite() {
    final site = _customSiteController.text.trim();
    if (site.isNotEmpty && !_favoriteSites.contains(site)) {
      _updateFavoriteSites(site, true);
      _customSiteController.clear();
    }
  }

  void _addCustomTag() {
    final tag = _customTagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      _addTag(tag);
      _customTagController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Finder'),
      ),
      body: SingleChildScrollView(
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
                  const SizedBox(height: 8),

                  // Add custom tag
                  CustomTextField(
                    controller: _customTagController,
                    labelText: 'Add Custom Tag',
                    prefixIcon: Icons.label,
                    suffixIcon: Icons.add,
                    onSuffixIconPressed: _addCustomTag,
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
                  Column(
                    children: _allPossibleSites.map((site) {
                      final isSelected = _favoriteSites.contains(site);
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (selected) {
                          _updateFavoriteSites(site, selected ?? false);
                        },
                        title: Text(site),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Add custom site
                  CustomTextField(
                    controller: _customSiteController,
                    labelText: 'Add Custom Site',
                    prefixIcon: Icons.link,
                    suffixIcon: Icons.add,
                    onSuffixIconPressed: _addCustomSite,
                  ),
                  const SizedBox(height: 16),

                  // Search button
                  ElevatedButton(
                      onPressed: _searchEquipment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (_isLoading)
                                  const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                else
                                  Row(children: [
                                    const Text('Find Equipment'),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.search,
                                      color: Colors.white,
                                    ),
                                  ])
                              ]),
                        ],
                      )),
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
                        _showFilterOptions();
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
                              child: item.imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        item.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            _getEquipmentIcon(item.name),
                                            size: 40,
                                            color: Colors.grey,
                                          );
                                        },
                                      ),
                                    )
                                  : Icon(
                                      _getEquipmentIcon(item.name),
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
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.price,
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
                                        item.store,
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
                                        item.rating.toString(),
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
                                            _showEquipmentDetails(item);
                                          },
                                          child: const Text('Details'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Open URL
                                            _openEquipmentUrl(item);
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

  void _showFilterOptions() {
    // Show filter options dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filter options would go here
              const Text('Sort by:'),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Price: Low to High'),
                onTap: () {
                  Navigator.pop(context);
                  _sortResults('price_asc');
                },
              ),
              ListTile(
                title: const Text('Price: High to Low'),
                onTap: () {
                  Navigator.pop(context);
                  _sortResults('price_desc');
                },
              ),
              ListTile(
                title: const Text('Rating: High to Low'),
                onTap: () {
                  Navigator.pop(context);
                  _sortResults('rating_desc');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _sortResults(String sortBy) {
    if (_searchResults == null) return;

    setState(() {
      switch (sortBy) {
        case 'price_asc':
          _searchResults!.sort((a, b) {
            // Extract numeric value from price string
            double priceA = _extractPrice(a.price);
            double priceB = _extractPrice(b.price);
            return priceA.compareTo(priceB);
          });
          break;
        case 'price_desc':
          _searchResults!.sort((a, b) {
            // Extract numeric value from price string
            double priceA = _extractPrice(a.price);
            double priceB = _extractPrice(b.price);
            return priceB.compareTo(priceA);
          });
          break;
        case 'rating_desc':
          _searchResults!.sort((a, b) => b.rating.compareTo(a.rating));
          break;
      }
    });
  }

  double _extractPrice(String priceString) {
    // Extract numeric value from price string (e.g., "Rs. 15,000" -> 15000)
    try {
      String numericString = priceString.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.parse(numericString);
    } catch (e) {
      return 0.0;
    }
  }

  void _showEquipmentDetails(EquipmentModel equipment) {
    // Show equipment details dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(equipment.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Price: ${equipment.price}'),
              const SizedBox(height: 8),
              Text('Store: ${equipment.store}'),
              const SizedBox(height: 8),
              Text('Rating: ${equipment.rating}'),
              const SizedBox(height: 8),
              if (equipment.tags != null && equipment.tags!.isNotEmpty) ...[
                const Text('Tags:'),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: equipment.tags!.map((tag) {
                    return Chip(
                      label: Text(tag),
                      labelStyle: const TextStyle(fontSize: 12),
                      padding: EdgeInsets.zero,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _openEquipmentUrl(equipment);
              },
              child: const Text('Visit Store'),
            ),
          ],
        );
      },
    );
  }

  void _openEquipmentUrl(EquipmentModel equipment) {
    // In a real app, this would open the URL in a browser
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${equipment.url ?? equipment.store}'),
      ),
    );
  }

  IconData _getEquipmentIcon(String name) {
    name = name.toLowerCase();

    if (name.contains('cricket') || name.contains('bat')) {
      return Icons.sports_cricket;
    } else if (name.contains('football') || name.contains('soccer')) {
      return Icons.sports_soccer;
    } else if (name.contains('swimming') || name.contains('goggles')) {
      return Icons.pool;
    } else if (name.contains('running') || name.contains('shoes')) {
      return Icons.directions_run;
    } else if (name.contains('protein') || name.contains('supplement')) {
      return Icons.fitness_center;
    } else {
      return Icons.sports;
    }
  }
}
