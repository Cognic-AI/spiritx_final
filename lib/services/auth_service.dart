import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sri_lanka_sports_app/models/user_model.dart';
import 'dart:convert';
import 'package:image/image.dart' as img;

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _fetchUserData(result.user!.uid);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchData(String uid) async {
    try {
      await _fetchUserData(uid);
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role,
    required String? nicNumber,
    File? nicImage,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? nicImageUrl;
      if (nicImage != null && role == 'sportsperson') {
        nicImageUrl = await _uploadNicImage(nicImage);
      }

      // print('nicImageUrl: $nicImageUrl');

      UserModel newUser = UserModel(
        uid: result.user!.uid,
        email: email,
        name: name,
        role: role,
        nicNumber: nicNumber,
        profileImageUrl: null,
        interests: [],
        favoriteEquipmentSites: [],
      );

      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(newUser.toJson());

      if (role == 'sportsperson') {
        await _firestore.collection('verifications').doc(result.user!.uid).set({
          'uid': result.user!.uid,
          'nicNumber': nicNumber,
          'nicImageUrl': nicImageUrl.toString(),
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      _userModel = newUser;
      notifyListeners();
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Upload NIC image

  Future<String> _uploadNicImage(File imageFile) async {
    try {
      // 1. Read the file as bytes
      final imageBytes = await imageFile.readAsBytes();

      // 2. Decode the image (for compression)
      final decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) {
        throw Exception("Failed to decode the image");
      }

      // 3. Compress & resize the image (adjust as needed)
      final compressedImage = img.copyResize(
        decodedImage,
        width: 800, // Resize to max 800px width (adjust as needed)
      );
      final compressedBytes = img.encodeJpg(compressedImage, quality: 85);

      // 4. Convert compressed bytes to Base64
      final base64Image = base64Encode(compressedBytes);

      // 5. Return with MIME type prefix (for web display)
      return 'data:image/jpeg;base64,$base64Image';
    } catch (e) {
      print("Error compressing/encoding image: $e");
      throw e; // Re-throw to handle in the calling function
    }
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _userModel = UserModel.fromJson(doc.data() as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    _userModel = null;
    notifyListeners();
  }

  // Check if user is verified sportsperson
  Future<bool> isSportspersonVerified() async {
    if (_userModel == null || _userModel!.role != 'sportsperson') {
      return false;
    }

    try {
      DocumentSnapshot doc = await _firestore
          .collection('verifications')
          .doc(_userModel!.uid)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['status'] == 'approved';
      }
      return false;
    } catch (e) {
      print('Error checking verification status: $e');
      return false;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    List<String>? interests,
    List<String>? favoriteEquipmentSites,
    File? profileImage,
  }) async {
    try {
      if (_userModel == null) return;

      String? profileImageUrl = _userModel!.profileImageUrl;

      if (profileImage != null) {
        Reference ref = _storage
            .ref()
            .child('profile_images')
            .child('${_userModel!.uid}.jpg');
        UploadTask uploadTask = ref.putFile(profileImage);
        TaskSnapshot snapshot = await uploadTask;
        profileImageUrl = await snapshot.ref.getDownloadURL();
      }

      UserModel updatedUser = _userModel!.copyWith(
        name: name,
        interests: interests,
        favoriteEquipmentSites: favoriteEquipmentSites,
        profileImageUrl: profileImageUrl,
      );

      await _firestore
          .collection('users')
          .doc(_userModel!.uid)
          .update(updatedUser.toJson());

      _userModel = updatedUser;
      notifyListeners();
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }
}
