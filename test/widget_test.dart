import 'package:flutter_test/flutter_test.dart';
import 'package:studio/core/error/failure.dart';

void main() {
  test('Failure exposes message', () {
    expect(Failure('network error').message, 'network error');
  });
}
