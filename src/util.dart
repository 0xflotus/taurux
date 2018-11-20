import 'dart:io';

bool isOk(int statusCode) => statusCode == HttpStatus.ok;

String splitLink(String link) => link.split('/').last;
