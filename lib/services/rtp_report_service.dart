import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sri_lanka_sports_app/models/rtp_calculator_model.dart';

class RtpReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save RTP report to Firebase
  Future<bool> saveRtpReport(
      RehabilitationPlan plan, AnkleInjuryAssessment assessment) async {
    try {
      // Check if user is logged in
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return false;
      }

      // Create report data
      final Map<String, dynamic> reportData = {
        'userId': currentUser.uid,
        'userName': currentUser.displayName ?? 'Anonymous User',
        'createdAt': FieldValue.serverTimestamp(),
        'title': plan.title,
        'description': plan.description,
        'estimatedDaysToReturn': plan.estimatedDaysToReturn,
        'precautions': plan.precautions,
        'followUpRecommendations': plan.followUpRecommendations,
        'bracingRecommendations': plan.bracingRecommendations,
        'assessment': assessment.toMap(),
        'phases': plan.phases
            .map((phase) => {
                  'name': phase.name,
                  'duration': phase.duration,
                  'goal': phase.goal,
                  'bracingGuidance': phase.bracingGuidance,
                  'criteria': phase.criteria,
                  'exercises': phase.exercises
                      .map((exercise) => {
                            'name': exercise.name,
                            'description': exercise.description,
                            'frequency': exercise.frequency,
                            'imageUrl': exercise.imageUrl,
                          })
                      .toList(),
                })
            .toList(),
      };

      // Save to Firestore
      await _firestore.collection('RTP_Reports').add(reportData);
      return true;
    } catch (e) {
      print('Error saving RTP report: $e');
      return false;
    }
  }

  // Get all RTP reports for current user
  Future<List<Map<String, dynamic>>> getUserRtpReports() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return [];
      }

      final QuerySnapshot snapshot = await _firestore
          .collection('RTP_Reports')
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error getting RTP reports: $e');
      return [];
    }
  }

  // Delete RTP report
  Future<bool> deleteRtpReport(String reportId) async {
    try {
      await _firestore.collection('RTP_Reports').doc(reportId).delete();
      return true;
    } catch (e) {
      print('Error deleting RTP report: $e');
      return false;
    }
  }
}
