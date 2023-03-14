import 'package:calculator/domain/media_file.dart';
import 'package:given_when_then_unit_test/given_when_then_unit_test.dart';
import 'package:shouldly/shouldly.dart';

void main() {
  given('MediaFileMappings', () {
    MediaFileMappings mediaFileMappings = MediaFileMappings();
    when("calling isNumber('a'.codeUnitAt(0))", () {
      var result = mediaFileMappings.isNumber('a'.codeUnitAt(0));
      then('should return false', () {
        result.should.be(false);
      });
    });
    when("calling isNumber(' '.codeUnitAt(0))", () {
      var result = mediaFileMappings.isNumber(' '.codeUnitAt(0));
      then('should return false', () {
        result.should.be(false);
      });
    });

    when("calling isNumber('-'.codeUnitAt(0))", () {
      var result = mediaFileMappings.isNumber('-'.codeUnitAt(0));
      then('should return false', () {
        result.should.be(false);
      });
    });

    when("calling isNumber('_'.codeUnitAt(0))", () {
      var result = mediaFileMappings.isNumber('_'.codeUnitAt(0));
      then('should return false', () {
        result.should.be(false);
      });
    });

    when("calling isNumber('0'.codeUnitAt(0))", () {
      var result = mediaFileMappings.isNumber('0'.codeUnitAt(0));
      then('should return true', () {
        result.should.be(true);
      });
    });

    when("calling isNumber('9'.codeUnitAt(0))", () {
      var result = mediaFileMappings.isNumber('9'.codeUnitAt(0));
      then('should return true', () {
        result.should.be(true);
      });
    });

    when("calling isLetter('0'.codeUnitAt(0))", () {
      var result = mediaFileMappings.isLetter('0'.codeUnitAt(0));
      then('should return false', () {
        result.should.be(false);
      });
    });

    when("calling isLetter(' '.codeUnitAt(0))", () {
      var result = mediaFileMappings.isLetter(' '.codeUnitAt(0));
      then('should return false', () {
        result.should.be(false);
      });
    });

    when("calling isLetter('-'.codeUnitAt(0))", () {
      var result = mediaFileMappings.isLetter('-'.codeUnitAt(0));
      then('should return false', () {
        result.should.be(false);
      });
    });

    when("calling isLetter('a'.codeUnitAt(0))", () {
      var result = mediaFileMappings.isLetter('a'.codeUnitAt(0));
      then('should return true', () {
        result.should.be(true);
      });
    });

    when("calling isLetter('z'.codeUnitAt(0))", () {
      var result = mediaFileMappings.isLetter('z'.codeUnitAt(0));
      then('should return true', () {
        result.should.be(true);
      });
    });

    when("calling fileNameWithoutExtension('C:\\Users\\user\\readMe.txt')", () {
      var result = mediaFileMappings
          .fileNameWithoutExtension('C:\\Users\\user\\readMe.txt');
      then("should return 'readMe'", () {
        result.should.be('readMe');
      });
    });

    when("calling fileExtension('C:\\Users\\user\\readMe.txt')", () {
      var result =
          mediaFileMappings.fileExtension('C:\\Users\\user\\readMe.txt');
      then("should return '.txt'", () {
        result.should.be('.txt');
      });
    });

    when("calling lettersToNumber('a')", () {
      var result = mediaFileMappings.lettersToNumber('a');
      then('return 1', () {
        result.should.be(1);
      });
    });

    when("calling lettersToNumber('z')", () {
      var result = mediaFileMappings.lettersToNumber('z');
      then('return 26', () {
        result.should.be(26);
      });
    });

    when("calling lettersToNumber('aa')", () {
      var result = mediaFileMappings.lettersToNumber('aa');
      then('return 27', () {
        result.should.be(27);
      });
    });

    when("calling lettersToNumber('az')", () {
      var result = mediaFileMappings.lettersToNumber('az');
      then('return 52', () {
        result.should.be(52);
      });
    });

    when("calling lettersToNumber('ba')", () {
      var result = mediaFileMappings.lettersToNumber('ba');
      then('return 53', () {
        result.should.be(53);
      });
    });

    when("calling convertToNumber('1234567890')", () {
      var result = mediaFileMappings.convertToNumber('1234567890');
      then("return '1234567890'", () {
        result.should.be('1234567890');
      });
    });

    when("calling convertToNumber('12345 67890')", () {
      var result = mediaFileMappings.convertToNumber('12345 67890');
      then("return '12345067890'", () {
        result.should.be('12345067890');
      });
    });

    when("calling convertToNumber('12345-67890')", () {
      var result = mediaFileMappings.convertToNumber('12345-67890');
      then("return '12345067890'", () {
        result.should.be('12345067890');
      });
    });

    when("calling convertToNumber('12345_67890')", () {
      var result = mediaFileMappings.convertToNumber('12345_67890');
      then("return '12345067890'", () {
        result.should.be('12345067890');
      });
    });

    when("calling convertToNumber('12345a67890')", () {
      var result = mediaFileMappings.convertToNumber('12345a67890');
      then("return '12345167890'", () {
        result.should.be('12345167890');
      });
    });

    when("calling convertToNumber('12345A67890')", () {
      var result = mediaFileMappings.convertToNumber('12345A67890');
      then("return '12345167890'", () {
        result.should.be('12345167890');
      });
    });

    when("calling convertToNumber('12345AA67890')", () {
      var result = mediaFileMappings.convertToNumber('12345AA67890');
      then("return '123452767890'", () {
        result.should.be('123452767890');
      });
    });
  });
}
