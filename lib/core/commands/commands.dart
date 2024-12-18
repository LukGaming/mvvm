import 'package:flutter/material.dart';
import 'package:mvvm/core/result/result.dart';

//Command 0 não possui parametros de entrada
typedef CommandAction0<Output extends Object> = Future<Result<Output>>
    Function();

//Command 1  possui parametros de entrada
typedef CommandAction1<Output extends Object, Input extends Object>
    = Future<Result<Output>> Function(Input);

abstract class Command<Output extends Object> extends ChangeNotifier {
  //Verifica se o command está em execução
  bool _running = false;

  bool get running => _running;

  //representação do nosso estado => Ok ou Error ou Null
  Result<Output>? _result;

  Result<Output>? get result => _result;

  bool get completed =>
      _result is Ok; // Verifica se o nosso estado foi gerado com sucesso

  bool get error =>
      _result is ResultError; //Verifica se o nosso estado é de erro

  Future<void> _execute(CommandAction0<Output> action) async {
    //Impede com que a action seja reexecutada mais de uma vez simutaneamente
    if (_running) return;

    _running = true; //Agora nossa action está em execução
    _result = null; // Result voltou para nulo

    notifyListeners();

    try {
      _result = await action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

class Commmand0<Output extends Object> extends Command<Output> {
  final CommandAction0<Output> action;
  Commmand0(this.action);

  Future<void> execute() async {
    await _execute(() => action());
  }
}

class Command1<Output extends Object, Input extends Object>
    extends Command<Output> {
  final CommandAction1<Output, Input> action;

  Command1(this.action);

  Future<void> execute(Input params) async {
    await _execute(() => action(params));
  }
}
