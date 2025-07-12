import 'package:flutter_test/flutter_test.dart';
import 'package:phone_field_intel/phone_field_intel.dart';

void main() {
  group('Phone Field Intel Tests', () {
    test('Country class should have required properties', () {
      const country = Country(
        name: 'United States',
        flag: '🇺🇸',
        code: 'US',
        dialCode: '1',
        nameTranslations: {'en': 'United States'},
        minLength: 10,
        maxLength: 10,
      );

      expect(country.name, 'United States');
      expect(country.flag, '🇺🇸');
      expect(country.code, 'US');
      expect(country.dialCode, '1');
      expect(country.minLength, 10);
      expect(country.maxLength, 10);
    });

    test('Country localizedName should return correct translation', () {
      const country = Country(
        name: 'United States',
        flag: '🇺🇸',
        code: 'US',
        dialCode: '1',
        nameTranslations: {'en': 'United States', 'fa': 'ایالات متحده آمریکا'},
        minLength: 10,
        maxLength: 10,
      );

      expect(country.localizedName('en'), 'United States');
      expect(country.localizedName('fa'), 'ایالات متحده آمریکا');
      expect(country.localizedName('de'), 'United States'); // fallback to name
    });

    test('PhoneNumber should format correctly', () {
      final phoneNumber = PhoneNumber(
        countryISOCode: 'US',
        countryCode: '+1',
        number: '1234567890',
        flag: '🇺🇸',
      );

      expect(phoneNumber.countryISOCode, 'US');
      expect(phoneNumber.countryCode, '+1');
      expect(phoneNumber.number, '1234567890');
      expect(phoneNumber.flag, '🇺🇸');
      expect(phoneNumber.completeNumber, '+11234567890');
    });

    test('PhoneNumber validation should work correctly', () {
      // Valid US number
      final validUSNumber = PhoneNumber(
        countryISOCode: 'US',
        countryCode: '+1',
        number: '1234567890',
        flag: '🇺🇸',
      );
      expect(validUSNumber.isValidLength(), true);

      // Valid Iranian number
      final validIranNumber = PhoneNumber(
        countryISOCode: 'IR',
        countryCode: '+98',
        number: '9123456789',
        flag: '🇮🇷',
      );
      expect(validIranNumber.isValidLength(), true);

      // Invalid: too short number
      final shortNumber = PhoneNumber(
        countryISOCode: 'US',
        countryCode: '+1',
        number: '123',
        flag: '🇺🇸',
      );
      expect(shortNumber.isValidLength(), false);
    });

    test('PhoneNumber string methods should work correctly', () {
      final phoneNumber = PhoneNumber(
        countryISOCode: 'IR',
        countryCode: '+98',
        number: '9123456789',
        flag: '🇮🇷',
      );

      expect(phoneNumber.flagString, '🇮🇷');
      expect(phoneNumber.toDisplayString(), 'IR +98 9123456789 🇮🇷');
      expect(phoneNumber.toString().contains('flag: 🇮🇷'), true);
    });
  });
}
