# Phone Field Intel

A customized Flutter TextFormField to input international phone numbers along with country code.

[![pub package](https://img.shields.io/pub/v/phone_field_intel.svg)](https://pub.dev/packages/phone_field_intel)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

🌍 **International Support**: Support for 240+ countries with localized country names
📱 **Cross-Platform**: Works seamlessly on iOS, Android, Web, and Desktop
🎨 **Highly Customizable**: Extensive styling options for both input field and country picker
🔍 **Smart Search**: Intelligent country search by name, dial code, or localized names
✅ **Auto Validation**: Built-in validation for all countries with country-specific rules
🏳️ **Flag Display**: Beautiful flag display with fallback support for all platforms
🌐 **RTL Support**: Full support for right-to-left languages like Arabic and Persian
🎯 **Type Safe**: Full null safety support with comprehensive type definitions
🔧 **Country Filtering**: Filter available countries by providing a list of country codes
🚀 **Zero Configuration**: Works out of the box with automatic validation for all countries

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  phone_field_intel: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:phone_field_intel/phone_field_intel.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Phone Field Intel Demo')),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: IntlPhoneField(
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
            ),
            initialCountryCode: 'US',
            onChanged: (phone) {
              print(phone.completeNumber);
            },
          ),
        ),
      ),
    );
  }
}
```

## Advanced Usage

### Custom Styling

```dart
IntlPhoneField(
  decoration: InputDecoration(
    labelText: 'Phone Number',
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.phone),
  ),
  initialCountryCode: 'IR',
  languageCode: 'fa', // Persian language
  dropdownTextStyle: TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  ),
  pickerDialogStyle: CountryPickerStyle(
    backgroundColor: Colors.white,
    searchFieldTextStyle: TextStyle(
      fontSize: 16,
      color: Colors.black87,
    ),
    countryNameStyle: TextStyle(
      fontWeight: FontWeight.w500,
    ),
    countryCodeStyle: TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.blue,
    ),
  ),
  onChanged: (phone) {
    print('Country: ${phone.countryISOCode}');
    print('Full number: ${phone.completeNumber}');
  },
  onCountryChanged: (country) {
    print('Selected country: ${country.name}');
  },
)
```

### Auto Validation and Country Filtering

```dart
IntlPhoneField(
  decoration: InputDecoration(
    labelText: 'Phone Number',
    border: OutlineInputBorder(),
  ),
  initialCountryCode: 'IR',
  languageCode: 'fa',
  enableAutoValidation: true, // Automatic validation for all countries
  allowedCountries: ['IR', 'US', 'GB', 'DE'], // Only show these countries
  autovalidateMode: AutovalidateMode.onUserInteraction,
  onChanged: (phone) {
    print('Country: ${phone.countryISOCode}');
    print('Full number: ${phone.completeNumber}');
    print('Flag: ${phone.flagString}');
  },
)
```

### Form Validation

```dart
Form(
  key: _formKey,
  child: Column(
    children: [
      IntlPhoneField(
        decoration: InputDecoration(
          labelText: 'Phone Number',
          border: OutlineInputBorder(),
        ),
        initialCountryCode: 'US',
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (phone) {
          if (phone == null || phone.number.isEmpty) {
            return 'Please enter a phone number';
          }
          if (!phone.isValidLength()) {
            return 'Invalid phone number length';
          }
          return null;
        },
        onChanged: (phone) {
          // Handle phone number changes
          print('Valid length: ${phone.isValidLength()}');
          print('Flag: ${phone.flagString}');
        },
      ),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Form is valid
          }
        },
        child: Text('Submit'),
      ),
    ],
  ),
)
```

## Customization Options

### IntlPhoneField Properties

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `initialCountryCode` | `String?` | Initial country code (e.g., 'US', 'IR') | 'US' |
| `languageCode` | `String` | Language code for country names | 'en' |
| `countries` | `List<Country>?` | Custom list of countries | All countries |
| `allowedCountries` | `List<String>?` | Filter countries by ISO codes | null |
| `enableAutoValidation` | `bool` | Enable automatic validation for all countries | true |
| `onChanged` | `ValueChanged<PhoneNumber>?` | Called when phone number changes | null |
| `onCountryChanged` | `ValueChanged<Country>?` | Called when country changes | null |
| `pickerDialogStyle` | `CountryPickerStyle?` | Custom styling for country picker | null |
| `showCountryFlag` | `bool` | Whether to show country flag | true |
| `showDropdownIcon` | `bool` | Whether to show dropdown icon | true |
| `dropdownTextStyle` | `TextStyle?` | Style for country code text | null |
| `disableLengthCheck` | `bool` | Disable automatic length validation | false |

### CountryPickerStyle Properties

| Property | Type | Description |
|----------|------|-------------|
| `backgroundColor` | `Color?` | Background color of the picker dialog |
| `searchFieldTextStyle` | `TextStyle?` | Text style for the search field |
| `countryNameStyle` | `TextStyle?` | Text style for country names |
| `countryCodeStyle` | `TextStyle?` | Text style for country codes |
| `listTilePadding` | `EdgeInsets?` | Padding for each country list item |
| `searchFieldPadding` | `EdgeInsets?` | Padding around the search field |

## Supported Languages

The package supports localized country names in the following languages:

- English (en) - Persian/Farsi (fa) - Arabic (ar) - German (de) - French (fr)
- Spanish (es) - Italian (it) - Dutch (nl) - Portuguese (pt_BR) - Chinese (zh)
- Japanese (ja) - Korean (ko) - Russian (ru) - And many more...

## Platform-Specific Features

### Flag Display
- **Mobile (iOS/Android)**: Uses emoji flags for better performance
- **Web**: Uses PNG flag images for consistent display
- **Desktop (Windows/macOS/Linux)**: Uses PNG flag images with fallback to country codes

## API Reference

### PhoneNumber Class

```dart
class PhoneNumber {
  String countryISOCode;  // e.g., 'US'
  String countryCode;     // e.g., '+1'
  String number;          // e.g., '1234567890'
  String flag;            // e.g., '🇺🇸'

  String get completeNumber;     // e.g., '+11234567890'
  String get flagString;         // Returns flag as string
  String toDisplayString();      // e.g., 'US +1 1234567890 🇺🇸'
  bool isValidNumber();          // Throws exceptions
  bool isValidLength();          // Safe validation
  bool isValidForSelectedCountry(); // Country matching
}
```

### Country Class

```dart
class Country {
  String name;                          // English name
  Map<String, String> nameTranslations; // Localized names
  String flag;                          // Emoji flag
  String code;                          // ISO country code
  String dialCode;                      // International dial code
  int minLength;                        // Min phone number length
  int maxLength;                        // Max phone number length

  String localizedName(String languageCode);
  String get fullCountryCode;
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you find this package helpful, please give it a ⭐ on GitHub and a 👍 on pub.dev!
