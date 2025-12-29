import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'signin_toggle_provider.g.dart';

/// Sign-in toggle configuration from Firestore.
///
/// Reads from `config/signin_toggle` document to determine
/// which sign-in methods are enabled.
class SigninToggleConfig {
  final bool apple;
  final bool google;
  final bool phone;

  const SigninToggleConfig({
    this.apple = false,
    this.google = true,
    this.phone = false,
  });

  factory SigninToggleConfig.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) {
      return const SigninToggleConfig();
    }
    return SigninToggleConfig(
      apple: data['apple'] as bool? ?? false,
      google: data['google'] as bool? ?? true,
      phone: data['phone'] as bool? ?? false,
    );
  }
}

/// Provider that streams the sign-in toggle config from Firestore.
@riverpod
Stream<SigninToggleConfig> signinToggleConfig(SigninToggleConfigRef ref) {
  return FirebaseFirestore.instance
      .collection('config')
      .doc('signin_toggle')
      .snapshots()
      .map((snapshot) => SigninToggleConfig.fromFirestore(snapshot.data()));
}
