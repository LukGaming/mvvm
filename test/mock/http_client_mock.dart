import 'dart:convert';
import 'dart:io';

import 'package:mocktail/mocktail.dart';

class MockHttpResponse extends Mock implements HttpClientResponse {}

class MockHttpRequest extends Mock implements HttpClientRequest {}

class MockHttpHeaders extends Mock implements HttpHeaders {}

class MockHttpClient extends Mock implements HttpClient {}

extension MockHttpMethods on MockHttpClient {
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

  void mockPost(String path, Object object) {
    when(() => post(any(), any(), path)).thenAnswer((_) {
      final request = MockHttpRequest();
      final response = MockHttpResponse();
      when(() => request.close()).thenAnswer((_) => Future.value(response));
      when(() => request.headers).thenReturn(MockHttpHeaders());
      when(() => response.statusCode).thenReturn(201);
      when(() => response.transform(utf8.decoder))
          .thenAnswer((_) => Stream.value(jsonEncode(object)));
      return Future.value(request);
    });
  }

  void mockPut(String path, Object object) {
    when(() => put(any(), any(), path)).thenAnswer((_) {
      final request = MockHttpRequest();
      final response = MockHttpResponse();
      when(() => request.close()).thenAnswer((_) => Future.value(response));
      when(() => request.headers).thenReturn(MockHttpHeaders());
      when(() => response.statusCode).thenReturn(200);
      when(() => response.transform(utf8.decoder))
          .thenAnswer((_) => Stream.value(jsonEncode(object)));
      return Future.value(request);
    });
  }

  void mockDelete(String path, Object object) {
    when(() => delete(any(), any(), path)).thenAnswer((_) {
      final request = MockHttpRequest();
      final response = MockHttpResponse();
      when(() => request.close()).thenAnswer((_) => Future.value(response));
      when(() => request.headers).thenReturn(MockHttpHeaders());
      when(() => response.statusCode).thenReturn(200);
      when(() => response.transform(utf8.decoder))
          .thenAnswer((_) => Stream.value(jsonEncode(object)));
      return Future.value(request);
    });
  }
}
