import 'package:flutter/widgets.dart';
import 'package:phone_field_intel/src/model/intel_validate_number.dart';
import 'package:phone_field_intel/src/tools/countries.dart';

/// Exception thrown when a phone number is too long for the selected country.
class NumberTooLongException implements Exception {}

/// Exception thrown when a phone number is too short for the selected country.
class NumberTooShortException implements Exception {}

/// Exception thrown when a phone number contains invalid characters.
class InvalidCharactersException implements Exception {}

/// Represents a complete phone number with country information.
///
/// This class encapsulates all the components of an international phone number:
/// the country ISO code, the country dialing code, and the local phone number.
/// It provides methods for validation and formatting.
///
/// ## Properties
///
/// * [countryISOCode] - The ISO 3166-1 alpha-2 country code (e.g., 'US', 'IR')
/// * [countryCode] - The international dialing code with '+' prefix (e.g., '+1', '+98')
/// * [number] - The local phone number without country code
///
/// ## Example
///
/// ```dart
/// final phoneNumber = PhoneNumber(
///   countryISOCode: 'US',
///   countryCode: '+1',
///   number: '1234567890',
/// );
///
/// print(phoneNumber.completeNumber); // +11234567890
/// print(phoneNumber.isValidNumber()); // true or false
/// ```
class PhoneNumber {
  /// The ISO 3166-1 alpha-2 country code.
  ///
  /// A two-letter code that identifies the country (e.g., 'US', 'IR', 'GB').
  String countryISOCode;

  /// The international dialing code with '+' prefix.
  ///
  /// This includes the '+' symbol followed by the country's dialing code
  /// (e.g., '+1' for USA, '+98' for Iran).
  String countryCode;

  /// The local phone number without the country code.
  ///
  /// This is the phone number as it would be dialed within the country,
  /// without any international prefixes.
  String number;

  /// The flag of the country.
  ///
  /// This is the flag of the country, as a string.
  String flag;

  /// Creates a new [PhoneNumber] instance.
  ///
  /// All parameters are required:
  /// * [countryISOCode] - The ISO country code (e.g., 'US', 'IR')
  /// * [countryCode] - The international dialing code with '+' (e.g., '+1', '+98')
  /// * [number] - The local phone number without country code
  PhoneNumber({
    required this.countryISOCode,
    required this.countryCode,
    required this.number,
    required this.flag,
  });

  /// Creates a [PhoneNumber] from a complete international phone number string.
  ///
  /// Parses a complete phone number (with or without '+' prefix) and extracts
  /// the country code and local number components.
  ///
  /// [completeNumber] should be a string containing the full international
  /// phone number, such as '+11234567890' or '11234567890'.
  ///
  /// Returns a [PhoneNumber] with empty fields if parsing fails.
  ///
  /// Throws [InvalidCharactersException] if the number contains invalid characters.
  ///
  /// Example:
  /// ```dart
  /// final phone = PhoneNumber.fromCompleteNumber(
  ///   completeNumber: '+11234567890'
  /// );
  /// print(phone.countryISOCode); // 'US'
  /// print(phone.number); // '1234567890'
  /// ```
  factory PhoneNumber.fromCompleteNumber({required String completeNumber}) {
    if (completeNumber == "") {
      return PhoneNumber(
        countryISOCode: "",
        countryCode: "",
        number: "",
        flag: "",
      );
    }

    try {
      Country country = getCountry(completeNumber);
      String number;
      if (completeNumber.startsWith('+')) {
        number = completeNumber.substring(
          1 + country.dialCode.length + country.regionCode.length,
        );
      } else {
        number = completeNumber.substring(
          country.dialCode.length + country.regionCode.length,
        );
      }
      return PhoneNumber(
        countryISOCode: country.code,
        countryCode: country.dialCode + country.regionCode,
        number: number,
        flag: country.flag,
      );
    } on InvalidCharactersException {
      rethrow;
      // ignore: unused_catch_clause
    } on Exception catch (e) {
      return PhoneNumber(
        countryISOCode: "",
        countryCode: "",
        number: "",
        flag: "",
      );
    }
  }

  /// Validates the phone number against the country's length requirements.
  ///
  /// Checks if the phone number length is within the valid range for the
  /// selected country. Returns `true` if valid.
  ///
  /// Throws:
  /// * [NumberTooShortException] if the number is shorter than the minimum length
  /// * [NumberTooLongException] if the number is longer than the maximum length
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   bool isValid = phoneNumber.isValidNumber();
  ///   print('Phone number is valid: $isValid');
  /// } catch (e) {
  ///   print('Validation error: $e');
  /// }
  /// ```
  bool isValidNumber() {
    // Find the country that matches the current country ISO code
    Country country;
    try {
      country = countries.firstWhere((c) => c.code == countryISOCode);
    } catch (e) {
      // If country not found, try to get it from the complete number
      country = getCountry(completeNumber);
    }

    if (number.length < country.minLength) {
      throw NumberTooShortException();
    }

    if (number.length > country.maxLength) {
      throw NumberTooLongException();
    }
    return true;
  }

  /// Simple validation that only checks length without throwing exceptions.
  ///
  /// Returns `true` if the phone number length is valid for the selected country,
  /// `false` otherwise. This is safer than [isValidNumber] as it doesn't throw exceptions.
  ///
  /// Example:
  /// ```dart
  /// bool isValid = phoneNumber.isValidLength();
  /// print('Phone number length is valid: $isValid');
  /// ```
  bool isValidLength() {
    try {
      Country country = countries.firstWhere((c) => c.code == countryISOCode);
      return number.length >= country.minLength &&
          number.length <= country.maxLength;
    } catch (e) {
      return false;
    }
  }

  /// Validates if the phone number matches the selected country.
  ///
  /// This method checks if the phone number's country code matches
  /// the currently selected country. This prevents users from entering
  /// a phone number from one country while having another country selected.
  ///
  /// Returns `true` if the phone number matches the selected country,
  /// `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// bool isValid = phoneNumber.isValidForSelectedCountry('US', '+11234567890');
  /// print('Phone number is valid for selected country: $isValid');
  /// ```
  bool isValidForSelectedCountry(String countryISOCode, String completeNumber) {
    try {
      // دریافت کشور انتخابی از کد ISO کشور
      CountryInvalidate selectedCountry = CountryInvalidate.countries
          .firstWhere(
            (country) => country.code == countryISOCode,
            orElse: () => throw Exception('Country not found'),
          );

      // پاک کردن شماره از کاراکترهای غیرضروری
      String cleanNumber = completeNumber.replaceAll(RegExp(r'[^0-9]'), '');

      // حذف + از ابتدای شماره اگر وجود داشته باشد
      if (completeNumber.startsWith('+')) {
        cleanNumber = completeNumber
            .substring(1)
            .replaceAll(RegExp(r'[^0-9]'), '');
      }

      // بررسی اینکه آیا شماره کامل با یکی از پیش‌شماره‌های کشور انتخابی شروع می‌شود
      bool isValid = selectedCountry.dialCodes.any((dialCode) {
        return cleanNumber.startsWith(dialCode);
      });

      // اگر معتبر نیست، لاگ کن تا دیباگ کنید
      if (!isValid) {
        debugPrint('Invalid number: $cleanNumber for country: $countryISOCode');
        debugPrint('Expected dial codes: ${selectedCountry.dialCodes}');
      }

      return isValid;
    } catch (e) {
      debugPrint('Error validating phone number: $e');
      return false;
    }
  }

  /// Returns the complete international phone number.
  ///
  /// Combines the [countryCode] and [number] to form the complete
  /// international phone number string.
  ///
  /// Example:
  /// ```dart
  /// final phone = PhoneNumber(
  ///   countryISOCode: 'US',
  ///   countryCode: '+1',
  ///   number: '1234567890',
  /// );
  /// print(phone.completeNumber); // '+11234567890'
  /// ```
  String get completeNumber {
    return countryCode + number;
  }

  /// Determines the country for a given phone number string.
  ///
  /// Analyzes the phone number to identify which country it belongs to
  /// based on the dialing code prefix.
  ///
  /// [phoneNumber] should be a complete international phone number string,
  /// with or without the '+' prefix.
  ///
  /// Returns the [Country] object that matches the phone number's prefix.
  ///
  /// Throws:
  /// * [NumberTooShortException] if the phone number is empty
  /// * [InvalidCharactersException] if the phone number contains invalid characters
  ///
  /// Example:
  /// ```dart
  /// Country usa = PhoneNumber.getCountry('+11234567890');
  /// print(usa.name); // 'United States'
  ///
  /// Country iran = PhoneNumber.getCountry('989123456789');
  /// print(iran.name); // 'Iran'
  /// ```
  static Country getCountry(String phoneNumber) {
    if (phoneNumber == "") {
      throw NumberTooShortException();
    }

    final validPhoneNumber = RegExp(r'^[+0-9]*[0-9]*$');

    if (!validPhoneNumber.hasMatch(phoneNumber)) {
      throw InvalidCharactersException();
    }

    if (phoneNumber.startsWith('+')) {
      return countries.firstWhere(
        (country) => phoneNumber
            .substring(1)
            .startsWith(country.dialCode + country.regionCode),
      );
    }
    return countries.firstWhere(
      (country) =>
          phoneNumber.startsWith(country.dialCode + country.regionCode),
    );
  }

  /// Returns a string representation of this phone number.
  ///
  /// Useful for debugging and logging purposes.
  ///
  /// Example output: 'PhoneNumber(countryISOCode: US, countryCode: +1, number: 1234567890, flag: 🇺🇸)'
  @override
  String toString() =>
      'PhoneNumber(countryISOCode: $countryISOCode, countryCode: $countryCode, number: $number, flag: $flag)';

  /// Returns a formatted string representation for display purposes.
  ///
  /// This method returns the flag as a regular string that can be displayed
  /// in UI components without emoji rendering issues.
  ///
  /// Example output: 'US +1 1234567890 🇺🇸'
  String toDisplayString() => '$countryISOCode $countryCode $number $flag';

  /// Returns just the flag as a string.
  ///
  /// This is useful when you need to display the country flag separately.
  String get flagString => flag;
}
