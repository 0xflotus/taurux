import 'dart:io';

bool isOk(int statusCode) => statusCode == HttpStatus.ok;

String splitLink(String link) {
  var split = link.split('/');
  return split[split.length - 1];
}