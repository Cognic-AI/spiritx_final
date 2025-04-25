import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sri_lanka_sports_app/models/progress_model.dart';

class ProgressRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'progress_entries';

  // Get all progress entries for a user
  Future<List<ProgressEntry>> getUserProgressEntries(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ProgressEntry.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
    } catch (e) {
      print('Error fetching progress entries: $e');
      return [];
    }
  }

  // Get a specific progress entry by ID
  Future<ProgressEntry?> getProgressEntryById(String id) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection(_collection).doc(id).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return ProgressEntry.fromJson({
          'id': doc.id,
          ...data,
        });
      }
      return null;
    } catch (e) {
      print('Error fetching progress entry: $e');
      return null;
    }
  }

  // Add a new progress entry
  Future<String> addProgressEntry(ProgressEntry entry) async {
    try {
      final docRef =
          await _firestore.collection(_collection).add(entry.toJson());

      // Update the document with its ID
      await docRef.update({'id': docRef.id});

      return docRef.id;
    } catch (e) {
      print('Error adding progress entry: $e');
      rethrow;
    }
  }

  // Update a progress entry
  Future<void> updateProgressEntry(ProgressEntry entry) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(entry.id)
          .update(entry.toJson());
    } catch (e) {
      print('Error updating progress entry: $e');
      rethrow;
    }
  }

  // Delete a progress entry
  Future<void> deleteProgressEntry(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      print('Error deleting progress entry: $e');
      rethrow;
    }
  }

  // Get progress statistics for a user
  Future<Map<String, dynamic>> getUserProgressStats(String userId) async {
    try {
      final entries = await getUserProgressEntries(userId);

      if (entries.isEmpty) {
        return {
          'averageOverallScore': 0.0,
          'averagePhysicalScore': 0.0,
          'averageTechnicalScore': 0.0,
          'averageMentalScore': 0.0,
          'averageNutritionScore': 0.0,
          'totalEntries': 0,
          'latestEntry': null,
        };
      }

      final averageOverallScore =
          entries.map((e) => e.overallScore).reduce((a, b) => a + b) /
              entries.length;
      final averagePhysicalScore =
          entries.map((e) => e.physicalScore).reduce((a, b) => a + b) /
              entries.length;
      final averageTechnicalScore =
          entries.map((e) => e.technicalScore).reduce((a, b) => a + b) /
              entries.length;
      final averageMentalScore =
          entries.map((e) => e.mentalScore).reduce((a, b) => a + b) /
              entries.length;
      final averageNutritionScore =
          entries.map((e) => e.nutritionScore).reduce((a, b) => a + b) /
              entries.length;

      return {
        'averageOverallScore': averageOverallScore,
        'averagePhysicalScore': averagePhysicalScore,
        'averageTechnicalScore': averageTechnicalScore,
        'averageMentalScore': averageMentalScore,
        'averageNutritionScore': averageNutritionScore,
        'totalEntries': entries.length,
        'latestEntry': entries.first,
      };
    } catch (e) {
      print('Error calculating progress stats: $e');
      rethrow;
    }
  }
}
