import 'package:cloud_functions/cloud_functions.dart';

Future<void> callTestFunction() async {
  final functions = FirebaseFunctions.instance;
  final callable = functions.httpsCallable('testCallable');
  final result = await callable.call({
    'name': 'Alice',
    'age': 30,
  });
  print(result.data); // 서버에서 반환된 데이터 출력
}