import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import 'package:args/args.dart';
import 'dart:convert';
import 'dart:io';

var debug = false;
var active = false;

const cbrOption = 'cbr';
const dryRunFlag = 'dry-run';
const debugFlag = 'debug';
const helpFlag = 'help';

main(List<String> arguments) {
  final argParser = new ArgParser()
    ..addOption(
        cbrOption, defaultsTo: '128',
        abbr: 'c',
        allowed: ['64', '128', '192', '256'],
        help: 'Specify the constant bit rate')
    ..addFlag(dryRunFlag, negatable: false,
        abbr: 'd',
        help: 'dry run without download')..addFlag(debugFlag, negatable: false,
        abbr: 'D',
        help: 'specify debug mode')..addFlag(
        helpFlag, negatable: false, abbr: 'h', help: 'Show Usage');

  ArgResults argResults = argParser.parse(arguments);

  if (argResults[helpFlag]) {
    print(argParser.usage);
    return;
  }

  debug = argResults[debugFlag];

  var rest = argResults.rest;

  if (rest.length == 0) {
    print('There are no links to download...');
    return;
  }

  rest.forEach((link) {
    if (!argResults[dryRunFlag]) {
      dl(link, argResults[cbrOption]);
    }
  });
}

dl(String link, String cbr) async {
  var split = link.split('/');
  var name = split[split.length - 1];
  http.Response response = await http.get(link);

  Document document = parser.parse(response.body);

  var x = document.getElementsByTagName('script')
      .where((Element el) => el.text.contains('INITIAL'))
      .map((Element el) => el.text.substring(27))
      .toList().toString();
  var begin = x.indexOf(name);
  var sub1 = x.substring(begin);
  var begin2 = sub1.indexOf('audioURL');
  var end2 = sub1.indexOf('background');
  var dl = '${sub1.substring(begin2 + 11, end2 - 3)}?cbr=$cbr';
  if (debug) {
    print(dl);
  }
  new HttpClient().getUrl(Uri.parse(dl))
      .then((HttpClientRequest request) => request.close())
      .then((HttpClientResponse response) {
    print('Writing bytes...');
    response.pipe(new File('$name.mp3').openWrite())
        .then((x) => print('ready'));
  });
}
