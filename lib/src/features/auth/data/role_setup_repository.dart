import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitx/src/core/auth/app_role.dart';
import 'package:fitx/src/core/auth/auth_repository.dart';

class RoleSetupRepository {
  RoleSetupRepository(
    this._firestore,
    this._authRepository,
  );

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  /// Verify that the provided gym access code matches the gym's stored code
  Future<bool> verifyGymCode(String gymId, String code) async {
    final doc = await _firestore.collection('gyms').doc(gymId).get();

    if (!doc.exists) return false;

    final data = doc.data();
    final validCode = data?['accessCode'] as String?;

    return validCode != null && validCode.toUpperCase() == code.toUpperCase();
  }

  /// Save user role and generate access code for ALL users
  Future<void> saveRole(AppRole role) async {
    final user = _authRepository.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    // Save role using auth repository
    await _authRepository.saveUserRole(
      uid: user.uid,
      role: role,
      email: user.email,
    );

    // Generate access code for the user
    await _generateAccessCode(user.uid);
  }

  /// Save user role with gym association
  Future<void> saveRoleWithGym(
    AppRole role,
    String gymId,
    String gymName,
  ) async {
    final user = _authRepository.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    // Save role using auth repository
    await _authRepository.saveUserRole(
      uid: user.uid,
      role: role,
      email: user.email,
    );

    // Save gym association
    await _firestore.collection('users').doc(user.uid).update({
      'gymId': gymId,
      'gymName': gymName,
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Generate access code for user
  Future<void> _generateAccessCode(String userId) async {
    final code =
        (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();

    await _firestore.collection('users').doc(userId).update({
      'accessCode': code,
      'qrData': 'fitx:$userId:$code',
      'codeGeneratedAt': FieldValue.serverTimestamp(),
    });
  }
}
