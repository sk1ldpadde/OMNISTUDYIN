import 'package:flutter_test/flutter_test.dart';
import 'package:omnistudin_flutter/register/registration.dart'; // Ersetzen Sie dies durch den tatsächlichen Pfad zu Ihrer Datei

void main() {
  group('isPasswordStrong', () {
    test('returns false when password is less than 8 characters', () {
      expect(isPasswordStrong('abc123!'), false);
    });

    test('returns false when password does not contain any uppercase letter', () {
      expect(isPasswordStrong('abc123!@#'), false);
    });

    test('returns false when password does not contain any lowercase letter', () {
      expect(isPasswordStrong('ABC123!@#'), false);
    });

    test('returns false when password does not contain any digit', () {
      expect(isPasswordStrong('ABCdef!@#'), false);
    });

    test('returns false when password does not contain any special character', () {
      expect(isPasswordStrong('ABCdef123'), false);
    });

    test('returns true when password is strong', () {
      expect(isPasswordStrong('ABCdef123!@#'), true);
    });
  });
}