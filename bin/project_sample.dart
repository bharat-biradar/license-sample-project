import 'package:project_sample/project_sample.dart' as project_sample;
import 'dart:io';
Future<void> main(List<String> arguments) async{
  final corpusLicense = File('licenses\\BSD-2-Clause.txt');
  final scenario1 = File('licenses\\scenario1.txt');
  final scenario2 = File('licenses\\scenario2.txt');
  final scenario0 = File('licenses\\scenario0.txt');

  var corpusTokens = project_sample.tokenizeText(await corpusLicense.readAsBytes());
  var scenario1Tokens = project_sample.tokenizeText(await scenario1.readAsBytes());
  var scenario2Tokens = project_sample.tokenizeText(await scenario2.readAsBytes());
  var scenario0Tokens = project_sample.tokenizeText(await scenario0.readAsBytes());

  var corpusCheckSums = project_sample.generateHashMap(corpusTokens);
  var scenario1Checksums = project_sample.generateHashMap(scenario1Tokens);
  var scenario2Checksums = project_sample.generateHashMap(scenario2Tokens);
  var scenario0Checksums = project_sample.generateHashMap(scenario0Tokens);

  final confidence1 = project_sample.confidenceLevel(scenario1Checksums, corpusCheckSums);
  final confidence2 = project_sample.confidenceLevel(scenario2Checksums, corpusCheckSums);
  final confidence0 = project_sample.confidenceLevel(scenario0Checksums, corpusCheckSums);

  print('Scenario 1 Confidence Level = $confidence1');
  print('Scenario 2 Confidence Level = $confidence2');
  print('Scenario 0 Confidence Level = $confidence0');
}
