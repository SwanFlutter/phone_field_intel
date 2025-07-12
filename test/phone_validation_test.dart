import 'package:flutter_test/flutter_test.dart';
import 'package:phone_field_intel/phone_field_intel.dart';

void main() {
  group('Phone Number Validation Tests', () {
    test('Should validate Iranian phone numbers correctly', () {
      // Valid Iranian number
      final validIranNumber = PhoneNumber(
        countryISOCode: 'IR',
        countryCode: '+98',
        number: '9123456789',
        flag: '🇮🇷',
      );
      expect(validIranNumber.isValidLength(), true);

      // Invalid Iranian number (too short)
      final shortIranNumber = PhoneNumber(
        countryISOCode: 'IR',
        countryCode: '+98',
        number: '912345',
        flag: '🇮🇷',
      );
      expect(shortIranNumber.isValidLength(), false);

      // Invalid Iranian number (too long)
      final longIranNumber = PhoneNumber(
        countryISOCode: 'IR',
        countryCode: '+98',
        number: '912345678901234',
        flag: '🇮🇷',
      );
      expect(longIranNumber.isValidLength(), false);
    });

    test('Should validate US phone numbers correctly', () {
      // Valid US number
      final validUSNumber = PhoneNumber(
        countryISOCode: 'US',
        countryCode: '+1',
        number: '1234567890',
        flag: '🇺🇸',
      );
      expect(validUSNumber.isValidLength(), true);

      // Invalid US number (too short)
      final shortUSNumber = PhoneNumber(
        countryISOCode: 'US',
        countryCode: '+1',
        number: '123456',
        flag: '🇺🇸',
      );
      expect(shortUSNumber.isValidLength(), false);
    });

    test('Should detect country from complete phone number', () {
      // Iranian number
      final iranCountry = PhoneNumber.getCountry('+989123456789');
      expect(iranCountry.code, 'IR');
      expect(iranCountry.name, 'Iran, Islamic Republic of Persian Gulf');

      // US number
      final usCountry = PhoneNumber.getCountry('+11234567890');
      expect(usCountry.code, 'US');
      expect(usCountry.name, 'United States');

      // UK number
      final ukCountry = PhoneNumber.getCountry('+44123456789');
      expect(ukCountry.code, 'GB');
      expect(ukCountry.name, 'United Kingdom');
    });

    test('Should validate country matching', () {
      // Iranian number with Iranian country selected
      final iranNumber = PhoneNumber(
        countryISOCode: 'IR',
        countryCode: '+98',
        number: '9123456789',
        flag: '🇮🇷',
      );
      expect(iranNumber.isValidForSelectedCountry(), true);

      // Iranian number with US country selected (should be invalid)
      final iranNumberWithUSCountry = PhoneNumber(
        countryISOCode: 'US',
        countryCode: '+98',
        number: '9123456789',
        flag: '🇺🇸',
      );
      expect(iranNumberWithUSCountry.isValidForSelectedCountry(), false);
    });

    test('Should handle numeric validation', () {
      // Valid numeric number
      final validNumeric = PhoneNumber(
        countryISOCode: 'IR',
        countryCode: '+98',
        number: '9123456789',
        flag: '🇮🇷',
      );
      expect(RegExp(r'^[0-9]+$').hasMatch(validNumeric.number), true);

      // Invalid non-numeric number
      final invalidNumeric = PhoneNumber(
        countryISOCode: 'IR',
        countryCode: '+98',
        number: '912345678a',
        flag: '🇮🇷',
      );
      expect(RegExp(r'^[0-9]+$').hasMatch(invalidNumeric.number), false);
    });

    test('Should validate different country formats', () {
      // Test various countries with their specific formats
      final testCases = [
        {
          'country': 'IR',
          'validNumber': '9123456789',
          'invalidNumber': '123456789',
        },
        {
          'country': 'US',
          'validNumber': '1234567890',
          'invalidNumber': '123456789',
        },
        {
          'country': 'GB',
          'validNumber': '1234567890',
          'invalidNumber': '123456789',
        },
      ];

      for (final testCase in testCases) {
        final country = countries.firstWhere(
          (c) => c.code == testCase['country'],
        );

        // Test valid number
        final validPhone = PhoneNumber(
          countryISOCode: country.code,
          countryCode: '+${country.dialCode}',
          number: testCase['validNumber'] as String,
          flag: country.flag,
        );
        expect(validPhone.isValidLength(), true);

        // Test invalid number
        final invalidPhone = PhoneNumber(
          countryISOCode: country.code,
          countryCode: '+${country.dialCode}',
          number: testCase['invalidNumber'] as String,
          flag: country.flag,
        );
        expect(invalidPhone.isValidLength(), false);
      }
    });

    test('Should handle edge cases', () {
      // Empty number
      final emptyNumber = PhoneNumber(
        countryISOCode: 'IR',
        countryCode: '+98',
        number: '',
        flag: '🇮🇷',
      );
      expect(emptyNumber.isValidLength(), false);

      // Null number (should be handled gracefully)
      expect(() {
        PhoneNumber.getCountry('');
      }, throwsA(isA<NumberTooShortException>()));
    });
  });
}
