import '../models/user.dart';

/// Minimal AuthService stub used to satisfy imports during development.
/// Implement real authentication logic (login, logout, current user retrieval)
/// in the full app.
class AuthService {
  AuthService();

  /// Return the currently authenticated user or null if none.
  Future<User?> getCurrentUser() async {
    return null;
  }

  // Add real methods (login, logout, register) when implementing auth.
}
