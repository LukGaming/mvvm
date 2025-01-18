import 'dart:convert';
import 'dart:io';

import 'package:mvvm/domain/models/todo.dart';
import 'package:mvvm/utils/result/result.dart';

class ApiClient {
  ApiClient({
    String? host,
    int? port,
    HttpClient Function()? clientHttpFactory,
  })  : _host = host ?? "localhost",
        _port = port ?? 3000,
        _clientHttpFactory = clientHttpFactory ?? HttpClient.new;

  final String _host;
  final int _port;
  final HttpClient Function() _clientHttpFactory;

  Future<Result<List<Todo>>> getTodos() async {
    final client = _clientHttpFactory();
    try {
      final request = await client.get(_host, _port, "/todos");

      final response = await request.close();

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final json = jsonDecode(stringData) as List<dynamic>;
        final List<Todo> todos = json.map((e) => Todo.fromJson(e)).toList();
        return Result.ok(todos);
      } else {
        return Result.error(const HttpException("Invalid response"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }
}
