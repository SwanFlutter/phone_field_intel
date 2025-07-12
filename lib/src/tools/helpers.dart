/// Helper functions and extensions for phone field intel package.
///
/// This file contains utility functions for string manipulation, validation,
/// and country searching functionality.
library;

import 'package:phone_field_intel/src/tools/countries.dart';

/// Checks if a string represents a numeric value.
///
/// Returns `true` if the string is not empty and can be parsed as an integer
/// after removing any '+' characters.
///
/// This is used to determine if a search query is a phone number (numeric)
/// or a country name (alphabetic).
///
/// Example:
/// ```dart
/// print(isNumeric('123')); // true
/// print(isNumeric('+1')); // true
/// print(isNumeric('USA')); // false
/// print(isNumeric('')); // false
/// ```
bool isNumeric(String s) =>
    s.isNotEmpty && int.tryParse(s.replaceAll("+", "")) != null;

/// Removes diacritical marks (accents) from a string.
///
/// This function normalizes text by replacing accented characters with their
/// base equivalents. This is useful for search functionality to match text
/// regardless of accent marks.
///
/// For example, 'café' becomes 'cafe', 'naïve' becomes 'naive'.
///
/// [str] The input string that may contain diacritical marks.
///
/// Returns the string with diacritical marks removed.
///
/// Example:
/// ```dart
/// print(removeDiacritics('café')); // 'cafe'
/// print(removeDiacritics('naïve')); // 'naive'
/// print(removeDiacritics('Zürich')); // 'Zurich'
/// ```
String removeDiacritics(String str) {
  var withDia =
      'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
  var withoutDia =
      'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';

  for (int i = 0; i < withDia.length; i++) {
    str = str.replaceAll(withDia[i], withoutDia[i]);
  }

  return str;
}

/// Extension methods for [List<Country>] to add search functionality.
extension CountryExtensions on List<Country> {
  /// Searches for countries based on a search query.
  ///
  /// This method provides intelligent search functionality that can handle:
  /// * Numeric searches (dial codes): Searches in country dial codes
  /// * Text searches (country names): Searches in country names and translations
  /// * Diacritic-insensitive search: Matches regardless of accent marks
  /// * Case-insensitive search: Matches regardless of letter case
  ///
  /// [search] The search query string. Can be:
  /// * A dial code (e.g., '1', '+98', '44')
  /// * A country name (e.g., 'United States', 'Iran', 'ایران')
  /// * Part of a country name (e.g., 'Unit' matches 'United States')
  ///
  /// Returns a filtered list of countries that match the search criteria.
  ///
  /// Example:
  /// ```dart
  /// // Search by dial code
  /// var results = countries.stringSearch('1');
  /// // Returns USA, Canada, etc.
  ///
  /// // Search by country name
  /// var results = countries.stringSearch('Iran');
  /// // Returns Iran
  ///
  /// // Search by localized name
  /// var results = countries.stringSearch('ایران');
  /// // Returns Iran
  ///
  /// // Partial search
  /// var results = countries.stringSearch('Unit');
  /// // Returns United States, United Kingdom, etc.
  /// ```
  List<Country> stringSearch(String search) {
    search = removeDiacritics(search.toLowerCase());
    return where(
      (country) => isNumeric(search) || search.startsWith("+")
          ? country.dialCode.contains(search)
          : removeDiacritics(
                  country.name.replaceAll("+", "").toLowerCase(),
                ).contains(search) ||
                country.nameTranslations.values.any(
                  (element) =>
                      removeDiacritics(element.toLowerCase()).contains(search),
                ),
    ).toList();
  }
}
