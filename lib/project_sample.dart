import 'dart:collection';
import 'dart:convert';
import 'package:crclib/catalog.dart';
import 'dart:typed_data';

var extraWhiteSpaces = RegExp(r'\s\s+');
var hyperLinkProtocol = RegExp(r'https://');
var copyrightRegex = RegExp(r'^copyright (\(c\))?([0-9]{4})(\(c\))?');


String normalizeText(Uint8List bytes) {
  var unknownText = utf8.decode(bytes);
  unknownText = unknownText.trim();
  unknownText = unknownText.toLowerCase();
  var lineSplitter = LineSplitter();
  var lines = lineSplitter.convert(unknownText);
  var linesTruncated = <String>[];
  for (var z in lines) {
    if (copyrightRegex.hasMatch(z.trim())) continue;
    linesTruncated.add(z.trim());
  }
  unknownText = linesTruncated.join('\n');
  unknownText = unknownText.replaceAll(hyperLinkProtocol, 'http://');
  return unknownText;
}

List<String> tokenizeText(Uint8List bytes) {
  var tokens = <String>[];
  var normText = normalizeText(bytes);
  var runes = normText.runes;
  var s = '';
  for (var rune in runes) {
    if (isSpace(rune)) {
      if (s != '') tokens.add(s);
      if (rune == 10) tokens.add('\n');
      s = '';
      continue;
    }
    s += utf8.decode([rune]);
  }
  if (s != '') tokens.add(s);
  tokens = cleanupTokens(tokens);
  return tokens;
}

bool isSpace(int r) {
  final x = [10, 20, 9, 32];
  return x.contains(r);
}

const markers =
    'a b c d e f g h i j k l m n o p q r ii iii iv v vi vii viii ix xi xii xiii xiv xv';
final isAplha = RegExp(r'[\w]');
final markerSet = HashSet.from(markers.split(' '));

bool isHeaders(String text, int prev) {
  var marker = text.substring(0, text.length - 1);
  var punct = text[text.length - 1];
  if (!markerSet.contains(marker)) return false;
  if (['.', ':', ')'].contains(punct)) {
    return true;
  }
  return false;
}

List<String> cleanupTokens(List<String> tokens) {
  var cleanedTokens = <String>[];
  var i = 0;
  var newLine = false;
  while (i < tokens.length) {
    if (tokens[i] == '\n') {
      i++;
      newLine = true;
      continue;
    }

    if (newLine && isHeaders(tokens[i], (tokens[i]).codeUnitAt(0))) {
      newLine = false;
      i++;
      continue;
    }
    newLine = false;
    var z = 0;
    var temp = '';
    while (z < tokens[i].length) {
      if (isAplha.hasMatch(tokens[i][z])) temp += tokens[i][z];
      z++;
    }
    if (temp != '') cleanedTokens.add(temp);
    i++;
  }
  return cleanedTokens;
}

HashMap<int, int> generateHashMap(List<String> tokens) {
  var tokensHash = HashMap<int, int>();
  var i = 0;
  var crc = Crc32Xz();
  while (i < tokens.length - 2) {
    var str = tokens[i] + ' ' + tokens[i + 1] + ' ' + tokens[i + 2];
    var d = crc.convert(utf8.encode(str));
    tokensHash.update(d.hashCode, (value) => value++,ifAbsent: ()=> 0);
    i++;
  }
  return tokensHash;
}

double confidenceLevel(HashMap<int,int> unknown,HashMap<int,int> license){
  var matchCount = 0;
  unknown.forEach((key, value) { 
    if(license.containsKey(key) && value>=license[key]) matchCount++;
  });

  return matchCount/license.length.toDouble();
}
