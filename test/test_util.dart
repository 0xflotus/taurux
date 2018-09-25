import "package:test/test.dart";
import "../src/util.dart";

void main() {
  test('splitLink', () {
    expect(splitLink('https://www.example.org/zeit/co'), equals('co'));
    
    expect(splitLink('svfsd'), equals('svfsd'));
  });

  test('statusCode == 200', () {
    expect(isOk(200), isTrue);
    expect(isOk(201), isFalse);
  });
}
