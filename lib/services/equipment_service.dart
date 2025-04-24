import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sri_lanka_sports_app/models/equipment_model.dart';
import 'package:flutter/material.dart';

class EquipmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // URL for the equipment recommendation API
  final String _recommendationApiUrl = 'http://YOUR_IP:8000/api/recommend';
  
  // Search for equipment
  Future<List<EquipmentModel>> searchEquipment(EquipmentSearchQuery query, BuildContext context) async {
    try {
      // Save search query to Firestore
      await _saveSearchQuery(query);
      
      // Get user's location from Firestore
      double? lat;
      double? lon;
      if (_auth.currentUser != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          lat = userData['latitude'];
          lon = userData['longitude'];
        }
      }

      // Prepare data for the recommendation API
      final requestBody = {
        'item_name': query.searchTerm ?? '',
        'custom_domains': query.stores,
        'tags': query.tags ?? [],
        'location': [lat ?? 0.0, lon ?? 0.0],
      };

      // Call recommendation API to get results
      final response = await http.post(
        Uri.parse(_recommendationApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['results'] != null) {
          List<dynamic> results = data['results'];
          
          List<EquipmentModel> equipmentResults = results.map((result) {
            // Generate a unique ID for each result
            result['id'] = result['id'] ?? '${result['item_name']}_${result['store']}';
            return EquipmentModel.fromJson(result);
          }).toList();
          
          // Show a message indicating that the recommended products are sent to the user's email
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Your recommended products are sent to your email!'),
              backgroundColor: Colors.green,
            ),
          );

          return equipmentResults;
        }
      }
      
      // If API call fails or returns invalid data, use fallback results
      return await _getFallbackResults(query);
    } catch (e) {
      print('Error searching equipment: $e');
      
      // Use fallback results in case of error
      return await _getFallbackResults(query);
    }
  }
  
  // Save search query to Firestore
  Future<void> _saveSearchQuery(EquipmentSearchQuery query) async {
    try {
      if (_auth.currentUser != null) {
        // Add user ID to query if authenticated
        EquipmentSearchQuery userQuery = EquipmentSearchQuery(
          searchTerm: query.searchTerm,
          tags: query.tags,
          stores: query.stores,
          userId: _auth.currentUser!.uid,
        );
        
        await _firestore.collection('equipment_searches').add(userQuery.toJson());
      }
    } catch (e) {
      print('Error saving search query: $e');
      // Continue even if saving fails
    }
  }
  
  // Get fallback results
  Future<List<EquipmentModel>> _getFallbackResults(EquipmentSearchQuery query) async {
    try {
      // Create some fallback results based on the query
      List<EquipmentModel> fallbackResults = [];
      
      // Example fallback data
      List<Map<String, dynamic>> fallbackData = [
        {
          'id': '1',
          'name': 'Kookaburra Cricket Bat',
          'price': 'Rs. 15,000',
          'store': 'SportsSL.com',
          'rating': 4.5,
          'imageUrl': null,
          'url': 'https://sportsslcom/cricket-bat',
          'tags': ['Cricket', 'Professional', 'Equipment'],
          'category': 'Cricket',
        },
        {
          'id': '2',
          'name': 'Adidas Football Shoes',
          'price': 'Rs. 8,500',
          'store': 'SportsEquipment.lk',
          'rating': 4.2,
          'imageUrl': null,
          'url': 'https://sportsequipment.lk/adidas-shoes',
          'tags': ['Football', 'Professional', 'Shoes'],
          'category': 'Football',
        },
        {
          'id': '3',
          'name': 'Swimming Goggles Pro',
          'price': 'Rs. 3,200',
          'store': 'AquaticsSL.com',
          'rating': 4.7,
          'imageUrl': null,
          'url': 'https://aquaticsslcom/goggles',
          'tags': ['Swimming', 'Professional', 'Accessories'],
          'category': 'Swimming',
        },
        {
          'id': '4',
          'name': 'Protein Supplement',
          'price': 'Rs. 5,500',
          'store': 'HealthSL.com',
          'rating': 4.3,
          'imageUrl': null,
          'url': 'https://healthsl.com/protein',
          'tags': ['Nutrition', 'Supplement'],
          'category': 'Nutrition',
        },
        {
          'id': '5',
          'name': 'Running Shoes',
          'price': 'Rs. 7,200',
          'store': 'SportsEquipment.lk',
          'rating': 4.6,
          'imageUrl': null,
          'url': 'https://sportsequipment.lk/running-shoes',
          'tags': ['Running', 'Shoes'],
          'category': 'Running',
        },
      ];
      
      // Filter fallback data based on query
      for (var item in fallbackData) {
        bool matches = true;
        
        // Match search term
        if (query.searchTerm != null && query.searchTerm!.isNotEmpty) {
          String searchTerm = query.searchTerm!.toLowerCase();
          String name = item['name'].toLowerCase();
          String category = (item['category'] ?? '').toLowerCase();
          
          if (!name.contains(searchTerm) && !category.contains(searchTerm)) {
            matches = false;
          }
        }
        
        // Match tags
        if (query.tags != null && query.tags!.isNotEmpty) {
          List<String> itemTags = List<String>.from(item['tags'] ?? []);
          bool hasMatchingTag = false;
          
          for (var tag in query.tags!) {
            if (itemTags.contains(tag)) {
              hasMatchingTag = true;
              break;
            }
          }
          
          if (!hasMatchingTag) {
            matches = false;
          }
        }
        
        // Match stores
        if (query.stores != null && query.stores!.isNotEmpty) {
          String store = item['store'];
          
          if (!query.stores!.contains(store)) {
            matches = false;
          }
        }
        
        if (matches) {
          fallbackResults.add(EquipmentModel.fromJson(item));
        }
      }
      
      return fallbackResults;
    } catch (e) {
      print('Error getting fallback results: $e');
      return [];
    }
  }
  
  // Get user's favorite equipment sites
  Future<List<String>> getFavoriteEquipmentSites() async {
    try {
      if (_auth.currentUser == null) {
        return [];
      }
      
      DocumentSnapshot doc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        if (data['favoriteEquipmentSites'] != null) {
          return List<String>.from(data['favoriteEquipmentSites']);
        }
      }
      
      return [];
    } catch (e) {
      print('Error getting favorite equipment sites: $e');
      return [];
    }
  }
  
  // Update user's favorite equipment sites
  Future<void> updateFavoriteEquipmentSites(List<String> sites) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'favoriteEquipmentSites': sites,
      });
    } catch (e) {
      print('Error updating favorite equipment sites: $e');
      rethrow;
    }
  }
}
