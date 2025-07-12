import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:phone_field_intel/src/tools/countries.dart';
import 'package:phone_field_intel/src/tools/helpers.dart';

/// Style configuration for the country picker dialog
class CountryPickerStyle {
  /// Background color of the dialog
  final Color? backgroundColor;

  /// Text style for country dial codes
  final TextStyle? countryCodeStyle;

  /// Text style for country names
  final TextStyle? countryNameStyle;

  /// Custom divider widget between list items
  final Widget? listTileDivider;

  /// Padding for each list tile
  final EdgeInsets? listTilePadding;

  /// Overall padding for the dialog
  final EdgeInsets? padding;

  /// Cursor color for the search field
  final Color? searchFieldCursorColor;

  /// Input decoration for the search field
  final InputDecoration? searchFieldInputDecoration;

  /// Padding around the search field
  final EdgeInsets? searchFieldPadding;

  /// Text style for the search field
  final TextStyle? searchFieldTextStyle;

  /// Width of the dialog
  final double? width;

  const CountryPickerStyle({
    this.backgroundColor,
    this.countryCodeStyle,
    this.countryNameStyle,
    this.listTileDivider,
    this.listTilePadding,
    this.padding,
    this.searchFieldCursorColor,
    this.searchFieldInputDecoration,
    this.searchFieldPadding,
    this.searchFieldTextStyle,
    this.width,
  });
}

class CountryPickerDialog extends StatefulWidget {
  final List<Country> countryList;
  final Country selectedCountry;
  final ValueChanged<Country> onCountryChanged;
  final String searchText;
  final List<Country> filteredCountries;
  final CountryPickerStyle? style;
  final String languageCode;

  const CountryPickerDialog({
    super.key,
    required this.searchText,
    required this.languageCode,
    required this.countryList,
    required this.onCountryChanged,
    required this.selectedCountry,
    required this.filteredCountries,
    this.style,
  });

  @override
  _CountryPickerDialogState createState() => _CountryPickerDialogState();
}

class _CountryPickerDialogState extends State<CountryPickerDialog> {
  late List<Country> _filteredCountries;
  late Country _selectedCountry;

  @override
  void initState() {
    _selectedCountry = widget.selectedCountry;
    _filteredCountries = widget.filteredCountries.toList()
      ..sort(
        (a, b) => a
            .localizedName(widget.languageCode)
            .compareTo(b.localizedName(widget.languageCode)),
      );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = MediaQuery.of(context).size.width;
    final width = widget.style?.width ?? mediaWidth;
    const defaultHorizontalPadding = 40.0;
    const defaultVerticalPadding = 24.0;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        vertical: defaultVerticalPadding,
        horizontal: mediaWidth > (width + defaultHorizontalPadding * 2)
            ? (mediaWidth - width) / 2
            : defaultHorizontalPadding,
      ),
      backgroundColor: widget.style?.backgroundColor,
      child: Container(
        padding: widget.style?.padding ?? const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Padding(
              padding:
                  widget.style?.searchFieldPadding ?? const EdgeInsets.all(0),
              child: TextField(
                cursorColor: widget.style?.searchFieldCursorColor,
                style: widget.style?.searchFieldTextStyle,
                decoration:
                    widget.style?.searchFieldInputDecoration ??
                    InputDecoration(
                      suffixIcon: const Icon(Icons.search),
                      labelText: widget.searchText,
                    ),
                onChanged: (value) {
                  _filteredCountries = widget.countryList.stringSearch(value)
                    ..sort(
                      (a, b) => a
                          .localizedName(widget.languageCode)
                          .compareTo(b.localizedName(widget.languageCode)),
                    );
                  if (mounted) setState(() {});
                },
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredCountries.length,
                itemBuilder: (ctx, index) => Column(
                  children: <Widget>[
                    ListTile(
                      leading: _buildCountryFlag(_filteredCountries[index]),
                      contentPadding: widget.style?.listTilePadding,
                      title: Text(
                        _filteredCountries[index].localizedName(
                          widget.languageCode,
                        ),
                        style:
                            widget.style?.countryNameStyle ??
                            const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      trailing: Text(
                        '+${_filteredCountries[index].dialCode}',
                        style:
                            widget.style?.countryCodeStyle ??
                            const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      onTap: () {
                        _selectedCountry = _filteredCountries[index];
                        widget.onCountryChanged(_selectedCountry);
                        Navigator.of(context).pop();
                      },
                    ),
                    widget.style?.listTileDivider ??
                        const Divider(thickness: 1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the appropriate flag widget based on platform
  ///
  /// Uses PNG images for web and Windows platforms for better compatibility,
  /// and emoji flags for mobile platforms (Android/iOS) where emoji support is better.
  ///
  /// [country] The country for which to display the flag
  Widget _buildCountryFlag(Country country) {
    // Use PNG images for web and Windows for better flag display
    if (kIsWeb || Theme.of(context).platform == TargetPlatform.windows) {
      return Image.asset(
        'assets/flags/${country.code.toLowerCase()}.png',
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
                country.code,
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
      return Text(country.flag, style: const TextStyle(fontSize: 18));
    }
  }
}
