// This imports the necessary packages for testing and mocking.
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Import the file where your fetchData function is defined.
import 'package:omnistudin_flutter/Logic/Frontend_To_Backend_Connection.dart';

// Create a MockClient using the Mock class provided by Mockito.
class MockClient extends Mock implements http.Client {}

void main() {
  group('FrontendToBackendConnection', () {
    // Mock HTTP client
    MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
    });

    test('getData returns data if the HTTP call completes successfully',
        () async {
      mockClient = MockClient();
      // Setup the mock client to return a successful response when it calls the provided URL.
      when(mockClient.get(Uri.parse("http://10.0.2.2:8000/test_200"),
              headers: anyNamed('headers')))
          .thenAnswer(
              (_) async => http.Response(json.encode({'key': 'value'}), 200));

      // Call the method with the mock client
      var result = await FrontendToBackendConnection.getData('test_200',
          client: mockClient);

      // Verify the results
      expect(result, isA<Map<String, dynamic>>());
      expect(result['key'], 'value');
    });

    test('getData throws an exception if the HTTP call completes with an error',
        () {
      mockClient = MockClient();
      // Setup the mock client to return an unsuccessful response
      when(mockClient.get(Uri.parse("http://10.0.2.2:8000/test_404"),
              headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      // Verify that an exception is thrown
      expect(
          FrontendToBackendConnection.getData('test_404', client: mockClient),
          throwsException);
    });
  });
}
