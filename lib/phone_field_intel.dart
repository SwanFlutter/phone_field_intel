/// A customized Flutter TextFormField to input international phone numbers
/// along with country code.
///
/// This library provides a comprehensive solution for international phone number
/// input with country selection, validation, and formatting.
library;

import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone_field_intel/src/country_picker_dialog.dart';
import 'package:phone_field_intel/src/icon_position.dart';
import 'package:phone_field_intel/src/model/phone_number.dart';
import 'package:phone_field_intel/src/tools/countries.dart';
import 'package:phone_field_intel/src/tools/helpers.dart';

// Export public APIs
export 'package:phone_field_intel/src/country_picker_dialog.dart';
export 'package:phone_field_intel/src/icon_position.dart';
export 'package:phone_field_intel/src/model/phone_number.dart';
export 'package:phone_field_intel/src/tools/countries.dart';

/// A customizable international phone number input field widget.
///
/// This widget provides a text field for entering phone numbers with
/// automatic country code detection and validation. It includes a
/// country picker dialog and supports various styling options.
///
/// ## Features
///
/// * **Country Selection**: Tap on the country flag/code to open a searchable country picker
/// * **Auto-formatting**: Automatically formats phone numbers based on country rules
/// * **Validation**: Built-in validation for phone number length and format
/// * **Localization**: Supports multiple languages for country names
/// * **Cross-platform**: Works on iOS, Android, Web, and Desktop with appropriate flag display
/// * **Customizable**: Extensive styling options for both the input field and country picker
///
/// ## Basic Usage
///
/// ```dart
/// IntlPhoneField(
///   decoration: InputDecoration(
///     labelText: 'Phone Number',
///     border: OutlineInputBorder(),
///   ),
///   initialCountryCode: 'US',
///   onChanged: (phone) {
///     print(phone.completeNumber);
///   },
/// )
/// ```
///
/// ## Advanced Usage with Custom Styling
///
/// ```dart
/// IntlPhoneField(
///   decoration: InputDecoration(
///     labelText: 'Phone Number',
///     border: OutlineInputBorder(),
///   ),
///   initialCountryCode: 'IR',
///   languageCode: 'fa',
///   pickerDialogStyle: CountryPickerStyle(
///     backgroundColor: Colors.white,
///     searchFieldTextStyle: TextStyle(fontSize: 16),
///     countryNameStyle: TextStyle(fontWeight: FontWeight.w500),
///     countryCodeStyle: TextStyle(color: Colors.blue),
///   ),
///   onChanged: (phone) {
///     // Handle phone number changes
///   },
///   onCountryChanged: (country) {
///     // Handle country selection changes
///   },
/// )
/// ```
class IntlPhoneField extends StatefulWidget {
  /// Whether to hide the text being edited (e.g., for passwords).
  ///
  /// Defaults to `false`.
  final bool obscureText;

  /// How the text should be aligned horizontally.
  ///
  /// Defaults to [TextAlign.left].
  final TextAlign textAlign;

  /// How the text should be aligned vertically.
  ///
  /// If null, defaults to [TextAlignVertical.center].
  final TextAlignVertical? textAlignVertical;

  /// Called when the user taps on the text field.
  ///
  /// Can be used to show custom dialogs or perform other actions.
  final VoidCallback? onTap;

  /// Whether the text field is read-only.
  ///
  /// When true, the text field cannot be edited but can still be focused
  /// and the country picker can still be used.
  ///
  /// Defaults to `false`.
  final bool readOnly;

  /// Called when the form is saved.
  ///
  /// The callback receives a [PhoneNumber] object containing the complete
  /// phone number information.
  final FormFieldSetter<PhoneNumber>? onSaved;

  /// Called whenever the phone number changes.
  ///
  /// The callback receives a [PhoneNumber] object containing:
  /// * `countryISOCode`: The ISO country code (e.g., 'US', 'IR')
  /// * `countryCode`: The country dial code (e.g., '+1', '+98')
  /// * `number`: The phone number without country code
  /// * `completeNumber`: The full phone number including country code
  ///
  /// This is called every time the user types in the text field or
  /// changes the country selection.
  ///
  /// Example:
  /// ```dart
  /// onChanged: (phone) {
  ///   print('Country: ${phone.countryISOCode}');
  ///   print('Full number: ${phone.completeNumber}');
  /// }
  /// ```
  final ValueChanged<PhoneNumber>? onChanged;

  /// Called when the user selects a different country.
  ///
  /// The callback receives a [Country] object containing information
  /// about the selected country including name, flag, dial code, etc.
  ///
  /// This is useful for updating UI elements based on the selected country
  /// or performing country-specific validations.
  ///
  /// Example:
  /// ```dart
  /// onCountryChanged: (country) {
  ///   print('Selected country: ${country.name}');
  ///   print('Dial code: +${country.dialCode}');
  /// }
  /// ```
  final ValueChanged<Country>? onCountryChanged;

  /// An optional method that validates an input. Returns an error string to display if the input is invalid, or null otherwise.
  ///
  /// A [PhoneNumber] is passed to the validator as argument.
  /// The validator can handle asynchronous validation when declared as a [Future].
  /// Or run synchronously when declared as a [Function].
  ///
  /// By default, the validator checks whether the input number length is between selected country's phone numbers min and max length.
  /// If `disableLengthCheck` is not set to `true`, your validator returned value will be overwritten by the default validator.
  /// But, if `disableLengthCheck` is set to `true`, your validator will have to check phone number length itself.
  final FutureOr<String?> Function(PhoneNumber?)? validator;

  /// {@macro flutter.widgets.editableText.keyboardType}
  final TextInputType keyboardType;

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController].
  final TextEditingController? controller;

  /// Defines the keyboard focus for this widget.
  ///
  /// The [focusNode] is a long-lived object that's typically managed by a
  /// [StatefulWidget] parent. See [FocusNode] for more information.
  ///
  /// To give the keyboard focus to this widget, provide a [focusNode] and then
  /// use the current [FocusScope] to request the focus:
  ///
  /// ```dart
  /// FocusScope.of(context).requestFocus(myFocusNode);
  /// ```
  ///
  /// This happens automatically when the widget is tapped.
  ///
  /// To be notified when the widget gains or loses the focus, add a listener
  /// to the [focusNode]:
  ///
  /// ```dart
  /// focusNode.addListener(() { print(myFocusNode.hasFocus); });
  /// ```
  ///
  /// If null, this widget will create its own [FocusNode].
  ///
  /// ## Keyboard
  ///
  /// Requesting the focus will typically cause the keyboard to be shown
  /// if it's not showing already.
  ///
  /// On Android, the user can hide the keyboard - without changing the focus -
  /// with the system back button. They can restore the keyboard's visibility
  /// by tapping on a text field.  The user might hide the keyboard and
  /// switch to a physical keyboard, or they might just need to get it
  /// out of the way for a moment, to expose something it's
  /// obscuring. In this case requesting the focus again will not
  /// cause the focus to change, and will not make the keyboard visible.
  ///
  /// This widget builds an [EditableText] and will ensure that the keyboard is
  /// showing when it is tapped by calling [EditableTextState.requestKeyboard()].
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.editableText.onSubmitted}
  ///
  /// See also:
  ///
  ///  * [EditableText.onSubmitted] for an example of how to handle moving to
  ///    the next/previous field when using [TextInputAction.next] and
  ///    [TextInputAction.previous] for [textInputAction].
  final void Function(String)? onSubmitted;

  /// If false the widget is "disabled": it ignores taps, the [TextFormField]'s
  /// [decoration] is rendered in grey,
  /// [decoration]'s [InputDecoration.counterText] is set to `""`,
  /// and the drop down icon is hidden no matter [showDropdownIcon] value.
  ///
  /// If non-null this property overrides the [decoration]'s
  /// [Decoration.enabled] property.
  final bool enabled;

  /// The appearance of the keyboard.
  ///
  /// This setting is only honored on iOS devices.
  ///
  /// If unset, defaults to the brightness of [ThemeData.brightness].
  final Brightness? keyboardAppearance;

  /// Initial Value for the field.
  /// This property can be used to pre-fill the field.
  final String? initialValue;

  final String languageCode;

  /// 2 letter ISO Code or country dial code.
  ///
  /// ```dart
  /// initialCountryCode: 'IN', // India
  /// initialCountryCode: '+225', // Côte d'Ivoire
  /// ```
  final String? initialCountryCode;

  /// List of Country to display see countries.dart for format
  final List<Country>? countries;

  /// The decoration to show around the text field.
  ///
  /// By default, draws a horizontal line under the text field but can be
  /// configured to show an icon, label, hint text, and error text.
  ///
  /// Specify null to remove the decoration entirely (including the
  /// extra padding introduced by the decoration to save space for the labels).
  final InputDecoration decoration;

  /// The style to use for the text being edited.
  ///
  /// This text style is also used as the base style for the [decoration].
  ///
  /// If null, defaults to the `subtitle1` text style from the current [Theme].
  final TextStyle? style;

  /// Disable view Min/Max Length check
  final bool disableLengthCheck;

  /// Whether to enable automatic validation for all countries
  ///
  /// When enabled, the field will automatically validate phone numbers
  /// according to each country's specific rules without requiring custom validators.
  ///
  /// Defaults to `true`.
  final bool enableAutoValidation;

  /// List of country codes to show in the country picker
  ///
  /// If provided, only countries with these codes will be shown in the picker.
  /// Use ISO 3166-1 alpha-2 country codes (e.g., ['US', 'IR', 'GB']).
  ///
  /// If null or empty, all countries will be shown.
  ///
  /// Example:
  /// ```dart
  /// allowedCountries: ['US', 'IR', 'GB', 'DE', 'FR']
  /// ```
  final List<String>? allowedCountries;

  /// Won't work if [enabled] is set to `false`.
  final bool showDropdownIcon;

  final BoxDecoration dropdownDecoration;

  /// The style use for the country dial code.
  final TextStyle? dropdownTextStyle;

  /// {@macro flutter.widgets.editableText.inputFormatters}
  final List<TextInputFormatter>? inputFormatters;

  /// The text that describes the search input field.
  ///
  /// When the input field is empty and unfocused, the label is displayed on top of the input field (i.e., at the same location on the screen where text may be entered in the input field).
  /// When the input field receives focus (or if the field is non-empty), the label moves above (i.e., vertically adjacent to) the input field.
  final String searchText;

  /// Position of an icon [leading, trailing]
  final IconPosition dropdownIconPosition;

  /// Icon of the drop down button.
  ///
  /// Default is [Icon(Icons.arrow_drop_down)]
  final Icon dropdownIcon;

  /// Whether this text field should focus itself if nothing else is already focused.
  final bool autofocus;

  /// Autovalidate mode for text form field.
  ///
  /// If [AutovalidateMode.onUserInteraction], this FormField will only auto-validate after its content changes.
  /// If [AutovalidateMode.always], it will auto-validate even without user interaction.
  /// If [AutovalidateMode.disabled], auto-validation will be disabled.
  ///
  /// Defaults to [AutovalidateMode.onUserInteraction].
  final AutovalidateMode? autovalidateMode;

  /// Whether to show or hide country flag.
  ///
  /// Default value is `true`.
  final bool showCountryFlag;

  /// Message to be displayed on autoValidate error
  ///
  /// Default value is `Invalid Mobile Number`.
  final String? invalidNumberMessage;

  /// The color of the cursor.
  final Color? cursorColor;

  /// How tall the cursor will be.
  final double? cursorHeight;

  /// How rounded the corners of the cursor should be.
  final Radius? cursorRadius;

  /// How thick the cursor will be.
  final double cursorWidth;

  /// Whether to show cursor.
  final bool? showCursor;

  /// The padding of the Flags Button.
  ///
  /// The amount of insets that are applied to the Flags Button.
  ///
  /// If unset, defaults to [EdgeInsets.zero].
  final EdgeInsetsGeometry flagsButtonPadding;

  /// The type of action button to use for the keyboard.
  final TextInputAction? textInputAction;

  /// Optional set of styles to allow for customizing the country search
  /// & pick dialog
  final CountryPickerStyle? pickerDialogStyle;

  /// The margin of the country selector button.
  ///
  /// The amount of space to surround the country selector button.
  ///
  /// If unset, defaults to [EdgeInsets.zero].
  final EdgeInsets flagsButtonMargin;

  //enable the autofill hint for phone number
  final bool disableAutoFillHints;

  const IntlPhoneField({
    super.key,
    this.initialCountryCode,
    this.languageCode = 'en',
    this.disableAutoFillHints = false,
    this.obscureText = false,
    this.textAlign = TextAlign.left,
    this.textAlignVertical,
    this.onTap,
    this.readOnly = false,
    this.initialValue,
    this.keyboardType = TextInputType.phone,
    this.controller,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.style,
    this.dropdownTextStyle,
    this.onSubmitted,
    this.validator,
    this.onChanged,
    this.countries,
    this.onCountryChanged,
    this.onSaved,
    this.showDropdownIcon = true,
    this.dropdownDecoration = const BoxDecoration(),
    this.inputFormatters,
    this.enabled = true,
    this.keyboardAppearance,
    @Deprecated('Use searchFieldInputDecoration of PickerDialogStyle instead')
    this.searchText = 'Search country',
    this.dropdownIconPosition = IconPosition.leading,
    this.dropdownIcon = const Icon(Icons.arrow_drop_down),
    this.autofocus = false,
    this.textInputAction,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.showCountryFlag = true,
    this.cursorColor,
    this.disableLengthCheck = false,
    this.enableAutoValidation = true,
    this.allowedCountries,
    this.flagsButtonPadding = EdgeInsets.zero,
    this.invalidNumberMessage = 'Invalid Mobile Number',
    this.cursorHeight,
    this.cursorRadius = Radius.zero,
    this.cursorWidth = 2.0,
    this.showCursor = true,
    this.pickerDialogStyle,
    this.flagsButtonMargin = EdgeInsets.zero,
  });

  @override
  _IntlPhoneFieldState createState() => _IntlPhoneFieldState();
}

class _IntlPhoneFieldState extends State<IntlPhoneField> {
  late List<Country> _countryList;
  late Country _selectedCountry;
  late List<Country> filteredCountries;
  late String number;

  String? validatorMessage;

  @override
  void initState() {
    super.initState();
    _countryList = widget.countries ?? countries;

    // Apply country filter if allowedCountries is provided
    if (widget.allowedCountries != null &&
        widget.allowedCountries!.isNotEmpty) {
      _countryList = _countryList
          .where((country) => widget.allowedCountries!.contains(country.code))
          .toList();
    }

    filteredCountries = _countryList;
    number = widget.initialValue ?? '';
    if (widget.initialCountryCode == null && number.startsWith('+')) {
      number = number.substring(1);
      // parse initial value
      _selectedCountry = countries.firstWhere(
        (country) => number.startsWith(country.fullCountryCode),
        orElse: () => _countryList.first,
      );

      // remove country code from the initial number value
      number = number.replaceFirst(
        RegExp("^${_selectedCountry.fullCountryCode}"),
        "",
      );
    } else {
      _selectedCountry = _countryList.firstWhere(
        (item) => item.code == (widget.initialCountryCode ?? 'US'),
        orElse: () => _countryList.first,
      );

      // remove country code from the initial number value
      if (number.startsWith('+')) {
        number = number.replaceFirst(
          RegExp("^\\+${_selectedCountry.fullCountryCode}"),
          "",
        );
      } else {
        number = number.replaceFirst(
          RegExp("^${_selectedCountry.fullCountryCode}"),
          "",
        );
      }
    }

    if (widget.autovalidateMode == AutovalidateMode.always) {
      final initialPhoneNumber = PhoneNumber(
        countryISOCode: _selectedCountry.code,
        countryCode: '+${_selectedCountry.dialCode}',
        number: widget.initialValue ?? '',
        flag: _selectedCountry.flag,
      );

      final value = widget.validator?.call(initialPhoneNumber);

      if (value is String) {
        validatorMessage = value;
      } else {
        (value as Future).then((msg) {
          validatorMessage = msg;
        });
      }
    }
  }

  Future<void> _changeCountry() async {
    filteredCountries = _countryList;
    await showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setState) => CountryPickerDialog(
          languageCode: widget.languageCode.toLowerCase(),
          style: widget.pickerDialogStyle,
          filteredCountries: filteredCountries,
          searchText: widget.searchText,
          countryList: _countryList,
          selectedCountry: _selectedCountry,
          onCountryChanged: (Country country) {
            _selectedCountry = country;
            widget.onCountryChanged?.call(country);
            setState(() {});
          },
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: (widget.controller == null) ? number : null,
      autofillHints: widget.disableAutoFillHints
          ? null
          : [AutofillHints.telephoneNumberNational],
      readOnly: widget.readOnly,
      obscureText: widget.obscureText,
      textAlign: widget.textAlign,
      textAlignVertical: widget.textAlignVertical,
      cursorColor: widget.cursorColor,
      onTap: widget.onTap,
      controller: widget.controller,
      focusNode: widget.focusNode,
      cursorHeight: widget.cursorHeight,
      cursorRadius: widget.cursorRadius,
      cursorWidth: widget.cursorWidth,
      showCursor: widget.showCursor,
      onFieldSubmitted: widget.onSubmitted,
      decoration: widget.decoration.copyWith(
        prefixIcon: _buildFlagsButton(),
        counterText: !widget.enabled ? '' : null,
      ),
      style: widget.style,
      onSaved: (value) {
        widget.onSaved?.call(
          PhoneNumber(
            countryISOCode: _selectedCountry.code,
            countryCode:
                '+${_selectedCountry.dialCode}${_selectedCountry.regionCode}',
            number: value!,
            flag: _selectedCountry.flag,
          ),
        );
      },
      onChanged: (value) async {
        final phoneNumber = PhoneNumber(
          countryISOCode: _selectedCountry.code,
          countryCode: '+${_selectedCountry.fullCountryCode}',
          number: value,
          flag: _selectedCountry.flag,
        );

        if (widget.autovalidateMode != AutovalidateMode.disabled) {
          validatorMessage = await widget.validator?.call(phoneNumber);
        }

        widget.onChanged?.call(phoneNumber);
      },
      validator: (value) {
        if (value == null || !isNumeric(value)) return validatorMessage;

        // If auto validation is enabled and length check is not disabled
        if (widget.enableAutoValidation && !widget.disableLengthCheck) {
          return _validatePhoneNumber(value);
        }

        // Legacy validation for backward compatibility
        if (!widget.disableLengthCheck) {
          if (value.length < _selectedCountry.minLength ||
              value.length > _selectedCountry.maxLength) {
            return widget.invalidNumberMessage ??
                'شماره تلفن باید بین ${_selectedCountry.minLength} تا ${_selectedCountry.maxLength} رقم باشد';
          }
        }

        return validatorMessage;
      },
      maxLength: widget.disableLengthCheck ? null : _selectedCountry.maxLength,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled,
      keyboardAppearance: widget.keyboardAppearance,
      autofocus: widget.autofocus,
      textInputAction: widget.textInputAction,
      autovalidateMode: widget.autovalidateMode,
    );
  }

  Container _buildFlagsButton() {
    return Container(
      margin: widget.flagsButtonMargin,
      child: DecoratedBox(
        decoration: widget.dropdownDecoration,
        child: InkWell(
          borderRadius: widget.dropdownDecoration.borderRadius as BorderRadius?,
          onTap: widget.enabled ? _changeCountry : null,
          child: Padding(
            padding: widget.flagsButtonPadding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(width: 4),
                if (widget.enabled &&
                    widget.showDropdownIcon &&
                    widget.dropdownIconPosition == IconPosition.leading) ...[
                  widget.dropdownIcon,
                  const SizedBox(width: 4),
                ],
                if (widget.showCountryFlag) ...[
                  _buildCountryFlag(),
                  const SizedBox(width: 8),
                ],
                FittedBox(
                  child: Text(
                    '+${_selectedCountry.dialCode}',
                    style: widget.dropdownTextStyle,
                  ),
                ),
                if (widget.enabled &&
                    widget.showDropdownIcon &&
                    widget.dropdownIconPosition == IconPosition.trailing) ...[
                  const SizedBox(width: 4),
                  widget.dropdownIcon,
                ],
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Validates phone number with advanced country-specific rules
  ///
  /// This method provides comprehensive validation for phone numbers
  /// based on the selected country's specific formatting and length rules.
  String? _validatePhoneNumber(String value) {
    if (value.isEmpty) {
      return widget.languageCode == 'fa'
          ? 'لطفاً شماره تلفن را وارد کنید'
          : 'Please enter a phone number';
    }

    // Basic length validation
    if (value.length < _selectedCountry.minLength) {
      return widget.languageCode == 'fa'
          ? 'شماره تلفن کوتاه است (حداقل ${_selectedCountry.minLength} رقم)'
          : 'Phone number is too short (minimum ${_selectedCountry.minLength} digits)';
    }

    if (value.length > _selectedCountry.maxLength) {
      return widget.languageCode == 'fa'
          ? 'شماره تلفن طولانی است (حداکثر ${_selectedCountry.maxLength} رقم)'
          : 'Phone number is too long (maximum ${_selectedCountry.maxLength} digits)';
    }

    // Country-specific validation rules
    String? countrySpecificError = _validateCountrySpecificRules(value);
    if (countrySpecificError != null) {
      return countrySpecificError;
    }

    return null; // Valid
  }

  /// Validates country-specific phone number rules
  ///
  /// This method contains specific validation rules for different countries
  /// to ensure phone numbers follow the correct format for each country.
  String? _validateCountrySpecificRules(String value) {
    switch (_selectedCountry.code) {
      case 'IR': // Iran
        if (!value.startsWith('9')) {
          return widget.languageCode == 'fa'
              ? 'شماره موبایل ایران باید با 9 شروع شود'
              : 'Iranian mobile numbers must start with 9';
        }
        break;

      case 'US': // United States
      case 'CA': // Canada
        // US/Canada numbers should not start with 0 or 1
        if (value.startsWith('0') || value.startsWith('1')) {
          return widget.languageCode == 'fa'
              ? 'شماره تلفن آمریکا/کانادا نباید با 0 یا 1 شروع شود'
              : 'US/Canada numbers cannot start with 0 or 1';
        }
        break;

      case 'GB': // United Kingdom
        if (value.startsWith('0')) {
          return widget.languageCode == 'fa'
              ? 'شماره تلفن انگلیس نباید با 0 شروع شود'
              : 'UK numbers should not start with 0 in international format';
        }
        break;

      case 'DE': // Germany
        if (value.startsWith('0')) {
          return widget.languageCode == 'fa'
              ? 'شماره تلفن آلمان نباید با 0 شروع شود'
              : 'German numbers should not start with 0 in international format';
        }
        break;

      case 'FR': // France
        if (value.startsWith('0')) {
          return widget.languageCode == 'fa'
              ? 'شماره تلفن فرانسه نباید با 0 شروع شود'
              : 'French numbers should not start with 0 in international format';
        }
        break;

      case 'IN': // India
        if (!RegExp(r'^[6-9]').hasMatch(value)) {
          return widget.languageCode == 'fa'
              ? 'شماره موبایل هند باید با 6، 7، 8 یا 9 شروع شود'
              : 'Indian mobile numbers must start with 6, 7, 8, or 9';
        }
        break;

      case 'AU': // Australia
        if (!RegExp(r'^[2-9]').hasMatch(value)) {
          return widget.languageCode == 'fa'
              ? 'شماره تلفن استرالیا نباید با 0 یا 1 شروع شود'
              : 'Australian numbers cannot start with 0 or 1';
        }
        break;

      case 'JP': // Japan
        if (value.startsWith('0')) {
          return widget.languageCode == 'fa'
              ? 'شماره تلفن ژاپن نباید با 0 شروع شود'
              : 'Japanese numbers should not start with 0 in international format';
        }
        break;

      case 'BR': // Brazil
        if (!RegExp(r'^[1-9]').hasMatch(value)) {
          return widget.languageCode == 'fa'
              ? 'شماره تلفن برزیل نباید با 0 شروع شود'
              : 'Brazilian numbers cannot start with 0';
        }
        break;

      case 'RU': // Russia
        if (value.startsWith('0') || value.startsWith('8')) {
          return widget.languageCode == 'fa'
              ? 'شماره تلفن روسیه نباید با 0 یا 8 شروع شود'
              : 'Russian numbers should not start with 0 or 8 in international format';
        }
        break;
    }

    return null; // No country-specific errors
  }

  /// Builds the appropriate flag widget based on platform
  ///
  /// Uses PNG images for web and Windows platforms for better compatibility,
  /// and emoji flags for mobile platforms (Android/iOS) where emoji support is better.
  Widget _buildCountryFlag() {
    // Use PNG images for web and Windows for better flag display
    if (kIsWeb || Theme.of(context).platform == TargetPlatform.windows) {
      return Image.asset(
        'assets/flags/${_selectedCountry.code.toLowerCase()}.png',
        package: 'phone_field_intel',
        width: 32,
        height: 24,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to country code if image fails to load
          return Container(
            width: 32,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Center(
              child: Text(
                _selectedCountry.code,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          );
        },
      );
    } else {
      // For mobile platforms (Android/iOS), use emoji flags
      return Text(_selectedCountry.flag, style: const TextStyle(fontSize: 18));
    }
  }
}
