import 'dart:convert';
import 'dart:io';

import 'package:mocktail/mocktail.dart';

class MockHttpResponse extends Mock implements HttpClientResponse {}

class MockHttpRequest extends Mock implements HttpClientRequest {}

class MockHttpHeaders extends Mock implements HttpHeaders {}

class HttpClientMock extends Mock implements HttpClient {}

extension MockHttpMethods on HttpClientMock {
  void mockGet(String path, Object object) {
    when(() => get(any(), any(), path)).thenAnswer((_) {
      final request = MockHttpRequest();
      final response = MockHttpResponse();
      when(() => request.close())
          .thenAnswer((invocation) => Future.value(response));
      when(() => request.headers).thenReturn(MockHttpHeaders());
      when(() => response.statusCode).thenReturn(200);
      when(() => response.transform(utf8.decoder))
          .thenAnswer((_) => Stream.value(jsonEncode(object)));
      return Future.value(request);
    });
  }
}
