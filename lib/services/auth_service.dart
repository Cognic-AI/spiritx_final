import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:sri_lanka_sports_app/models/user_model.dart';
import 'dart:convert';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  // Constructor to initialize the service and listen for auth changes
  AuthService() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _fetchUserData(user.uid);
      } else {
        _userModel = null;
        notifyListeners();
      }
    });
  }

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
        nicImageUrl = await _uploadNicImage(result.user!.uid, nicImage);
      }

      UserModel newUser = UserModel(
        uid: result.user!.uid,
        email: email,
        name: name,
        role: role,
        nicNumber: nicNumber,
        profileImageUrl: null,
        interests: [],
        favoriteEquipmentSites: [],
        isVerified:
            role != 'sportsperson', // Students are automatically verified
      );

      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(newUser.toJson());

      if (role == 'sportsperson') {
        await _firestore.collection('verifications').doc(result.user!.uid).set({
          'uid': result.user!.uid,
          'nicNumber': nicNumber,
          'nicImageUrl': nicImageUrl,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
          'reviewedAt': null,
          'reviewedBy': null,
          'comments': null,
        });
      }

      _userModel = newUser;
      notifyListeners();
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Upload NIC image to Firebase Storage
  Future<String> _uploadNicImage(String uid, File image) async {
    // Fallback to base64 encoding if Firebase Storage fails
    try {
      // Resize the image to reduce its size
      final img.Image originalImage =
          img.decodeImage(await image.readAsBytes())!;
      final img.Image resizedImage = img.copyResize(originalImage,
          width: 300); // Resize to width of 300 pixels
      List<int> imageBytes =
          img.encodeJpg(resizedImage); // Convert resized image to bytes
      String base64Image = base64Encode(imageBytes);
      return 'data:image/jpeg;base64,$base64Image';
    } catch (e2) {
      print('Error encoding image: $e2');
      rethrow;
    }
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        _userModel = UserModel.fromJson(userDoc.data() as Map<String, dynamic>);

        // Check verification status for sportsperson
        // if (_userModel!.role == 'sportsperson') {
        //   DocumentSnapshot verificationDoc =
        //       await _firestore.collection('verifications').doc(uid).get();

        //   if (verificationDoc.exists) {
        //     Map<String, dynamic> verificationData =
        //         verificationDoc.data() as Map<String, dynamic>;
        //     bool isVerified = verificationData['status'] == 'approved';

        //     // Update user model with verification status
        //     _userModel = _userModel!.copyWith(isVerified: isVerified);

        //     // Update user document if verification status changed
        //     if (isVerified != userDoc.get('isVerified')) {
        //       await _firestore
        //           .collection('users')
        //           .doc(uid)
        //           .update({'isVerified': isVerified});
        //     }
        //   }
        // }

        notifyListeners();
      } else {
        print('User document does not exist for uid: $uid');
        _userModel = null;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching user data: $e');
      _userModel = null;
      notifyListeners();
    }
  }

  Future<void> splashFetchUserData(String uid) async {
    await _fetchUserData(uid);
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _userModel = null;
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Check if user is verified sportsperson
  Future<bool> isSportspersonVerified() async {
    if (_userModel == null) {
      return false;
    }

    if (_userModel!.role != 'sportsperson') {
      return false; // Not a sportsperson
    }

    return _userModel!.isVerified;
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    List<String>? interests,
    List<String>? favoriteEquipmentSites,
    File? profileImage,
    String? phone,
    String? address,
    String? dateOfBirth,
    int? height,
    int? weight,
    String? emergencyContact,
    double? latitude,
    double? longitude,
  }) async {
    try {
      if (_userModel == null || currentUser == null) {
        throw Exception('User not authenticated');
      }

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

      Map<String, dynamic> updateData = {};

      if (name != null && name.isNotEmpty) {
        updateData['name'] = name;
      }

      if (interests != null) {
        updateData['interests'] = interests;
      }

      if (favoriteEquipmentSites != null) {
        updateData['favoriteEquipmentSites'] = favoriteEquipmentSites;
      }

      if (profileImageUrl != null) {
        updateData['profileImageUrl'] = profileImageUrl;
      }

      if (phone != null) {
        updateData['phone'] = phone;
      }

      if (address != null) {
        updateData['address'] = address;
      }

      if (dateOfBirth != null) {
        updateData['dateOfBirth'] = dateOfBirth;
      }

      if (height != null) {
        updateData['height'] = height;
      }

      if (weight != null) {
        updateData['weight'] = weight;
      }

      if (emergencyContact != null) {
        updateData['emergencyContact'] = emergencyContact;
      }

      if (latitude != null) {
        updateData['latitude'] = latitude;
      }

      if (longitude != null) {
        updateData['longitude'] = longitude;
      }

      if (updateData.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(_userModel!.uid)
            .update(updateData);

        // Update local user model
        _userModel = _userModel!.copyWith(
          name: name ?? _userModel!.name,
          interests: interests ?? _userModel!.interests,
          favoriteEquipmentSites:
              favoriteEquipmentSites ?? _userModel!.favoriteEquipmentSites,
          profileImageUrl: profileImageUrl ?? _userModel!.profileImageUrl,
          phone: phone ?? _userModel!.phone,
          address: address ?? _userModel!.address,
          dateOfBirth: dateOfBirth ?? _userModel!.dateOfBirth,
          height: height ?? _userModel!.height,
          weight: weight ?? _userModel!.weight,
          emergencyContact: emergencyContact ?? _userModel!.emergencyContact,
          latitude: latitude ?? _userModel!.latitude,
          longitude: longitude ?? _userModel!.longitude,
        );

        notifyListeners();
      }
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      String uid = currentUser!.uid;

      // Delete user data from Firestore
      await _firestore.collection('users').doc(uid).delete();

      // Delete verification data if exists
      await _firestore.collection('verifications').doc(uid).delete();

      // Delete profile image if exists
      try {
        await _storage.ref().child('profile_images').child('$uid.jpg').delete();
      } catch (e) {
        // Ignore if image doesn't exist
      }

      // Delete NIC image if exists
      try {
        await _storage.ref().child('nic_images').child('$uid.jpg').delete();
      } catch (e) {
        // Ignore if image doesn't exist
      }

      // Delete Firebase Auth user
      await currentUser!.delete();

      _userModel = null;
      notifyListeners();
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }
}
