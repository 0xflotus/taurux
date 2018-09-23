import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import 'package:args/args.dart';
import 'dart:convert';
import 'dart:io';

var debug = false;
var showDownloadLink = false;

const cbrOption = 'cbr';
const dryRunFlag = 'dry-run';
const debugFlag = 'debug';
const helpFlag = 'help';
const targetOption = 'target';
const bestTryFlag = 'best-try';
const showLinkFlag = 'show-link';

main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('No arguments');
  }

  final argParser = new ArgParser()
    ..addOption(
        cbrOption,
        abbr: 'c',
        allowed: ['64', '128', '192', '256'],
        help: 'Specify the constant bit rate')..addOption(
        targetOption, defaultsTo: '.', help: 'specify a target directory')
    ..addFlag(dryRunFlag, negatable: false,
        abbr: 'd',
        help: 'dry run without download')..addFlag(
        bestTryFlag, negatable: false,
        abbr: 'b',
        help: 'trying to find the best cbr')..addFlag(
        showLinkFlag, negatable: false,
        help: 'display the download link')..addFlag(
        debugFlag, negatable: false,
        abbr: 'D',
        help: 'specify debug mode')..addFlag(
        helpFlag, negatable: false, abbr: 'h', help: 'Show Usage');

  ArgResults argResults;
  try {
    argResults = argParser.parse(arguments);
  } catch (e) {
    print('Error: Wrong option or flag');
    return;
  }

  if (argResults[helpFlag]) {
    print(argParser.usage);
    return;
  }

  debug = argResults[debugFlag];
  showDownloadLink = argResults[showLinkFlag];

  var rest = argResults.rest;

  if (rest.isEmpty) {
    print('There are no links to download...');
    return;
  }

  for (var link in rest) {
    if (argResults[dryRunFlag]) break;
    dl(link, argResults[cbrOption], argResults[targetOption]);
  }
}

String getBestTry(String link) async {
  var cbrs = ['64', '128', '192', '256', '320'];
  for (var i = cbrs.length - 1; i >= 0; i--) {
    http.Response res = await http.get('$link${cbrs[i]}');
    if (res.statusCode == 200) {
      return '$link${cbrs[i]}';
    }
  }
}

dl(String link, String cbr, String target) async {
  var split = link.split('/');
  var name = split[split.length - 1];
  try {
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
    var base = '${sub1.substring(begin2 + 11, end2 - 3)}?cbr=';
    var dl = cbr == null ? await getBestTry(base) : '$base$cbr';

    if (showDownloadLink) {
      print(dl);
      return;
    }

    if (debug) print(dl);

    new HttpClient().getUrl(Uri.parse(dl))
        .then((HttpClientRequest request) => request.close())
        .then((HttpClientResponse response) {
      if (debug) print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Writing bytes...');
        response.pipe(new File('$target/$name.mp3').openWrite());
      } else {
        print('Resource not available');
      }
    });
  } catch (e) {
    print('An error occured, Please check your previous command');
  }
}
