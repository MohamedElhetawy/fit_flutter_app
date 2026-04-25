import 'package:cloud_firestore/cloud_firestore.dart';

/// Base repository class that all repositories should extend
/// Provides common error handling and Firestore utilities
abstract class BaseRepository {
  final FirebaseFirestore firestore;

  const BaseRepository({required this.firestore});

  /// Generic error handler for Firestore operations
  Future<T> handleFirestoreOperation<T>(
    Future<T> operation, {
    String? errorMessage,
  }) async {
    try {
      return await operation;
    } on FirebaseException catch (e) {
      throw RepositoryException(
        errorMessage ?? 'Firestore error: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw RepositoryException(errorMessage ?? 'Unknown error: $e');
    }
  }

  /// Generic stream handler with error catching
  Stream<T> handleFirestoreStream<T>(
    Stream<T> stream, {
    String? errorMessage,
  }) {
    return stream.handleError((error) {
      if (error is FirebaseException) {
        throw RepositoryException(
          errorMessage ?? 'Firestore stream error: ${error.message}',
          code: error.code,
        );
      }
      throw RepositoryException(errorMessage ?? 'Stream error: $error');
    });
  }
}

/// Generic repository exception
class RepositoryException implements Exception {
  final String message;
  final String? code;

  const RepositoryException(this.message, {this.code});

  @override
  String toString() => message;
}
