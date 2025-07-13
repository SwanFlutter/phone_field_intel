import 'package:flutter/material.dart';
import 'package:phone_field_intel/phone_field_intel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phone Field Intel Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PhoneFieldDemo(),
    );
  }
}

class PhoneFieldDemo extends StatefulWidget {
  const PhoneFieldDemo({super.key});

  @override
  State<PhoneFieldDemo> createState() => _PhoneFieldDemoState();
}

class _PhoneFieldDemoState extends State<PhoneFieldDemo> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _phoneController = TextEditingController();
  PhoneNumber? _phoneNumber;
  String? _selectedCountryCode;
  Country? _selectedCountry;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// Validates if the phone number matches the selected country
  String? _validatePhoneNumber(PhoneNumber? phone) {
    if (phone == null || phone.number.isEmpty) {
      return 'لطفاً شماره تلفن را وارد کنید';
    }

    // Check if the number is numeric
    if (!RegExp(r'^[0-9]+$').hasMatch(phone.number)) {
      return 'شماره تلفن باید فقط شامل اعداد باشد';
    }

    // Check length validation
    if (!phone.isValidLength()) {
      return 'طول شماره تلفن باید بین ${_selectedCountry?.minLength ?? 0} تا ${_selectedCountry?.maxLength ?? 0} رقم باشد';
    }

    // Check if the number belongs to the selected country
    if (_selectedCountry != null) {
      try {
        // Try to detect the country from the complete number
        final detectedCountry = PhoneNumber.getCountry(phone.completeNumber);

        // If the detected country is different from the selected country
        if (detectedCountry.code != _selectedCountry!.code) {
          return 'این شماره تلفن متعلق به کشور ${detectedCountry.localizedName('fa')} است. لطفاً کشور را تغییر دهید یا شماره صحیح وارد کنید.';
        }
      } catch (e) {
        // If country detection fails, check if the number starts with the selected country's dial code
        final cleanNumber = phone.completeNumber.replaceFirst('+', '');
        final expectedDialCode =
            _selectedCountry!.dialCode + _selectedCountry!.regionCode;

        if (!cleanNumber.startsWith(expectedDialCode)) {
          return 'شماره تلفن باید با کد کشور ${_selectedCountry!.localizedName('fa')} شروع شود';
        }
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Phone Field Intel Demo'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'نمونه استفاده از Phone Field Intel',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Basic Phone Field with Enhanced Validation
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'فیلد شماره تلفن با validation پیشرفته:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      IntlPhoneField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'شماره تلفن (با validation خودکار)',
                          border: OutlineInputBorder(),
                          helperText:
                              'validation خودکار برای همه کشورها فعال است',
                        ),
                        initialCountryCode: 'IR',
                        languageCode: 'fa',
                        enableAutoValidation:
                            true, // فعال کردن validation خودکار
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: (phone) {
                          setState(() {
                            _phoneNumber = phone;
                          });
                          debugPrint('Phone: ${phone.toDisplayString()}');
                          debugPrint(
                            'Is valid length: ${phone.isValidLength()}',
                          );
                        },
                        onCountryChanged: (country) {
                          setState(() {
                            _selectedCountryCode = country.code;
                            _selectedCountry = country;
                          });
                          debugPrint(
                            'Selected country: ${country.localizedName('fa')}',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Styled Phone Field with Enhanced Validation
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'فیلد شماره تلفن با استایل سفارشی و validation:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      IntlPhoneField(
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                          helperText:
                              'Enter a valid phone number for the selected country',
                        ),
                        initialCountryCode: 'US',
                        languageCode: 'en',
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (phone) {
                          if (phone == null || phone.number.isEmpty) {
                            return 'Please enter a phone number';
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(phone.number)) {
                            return 'Phone number should only contain digits';
                          }
                          if (!phone.isValidLength()) {
                            return 'Invalid phone number length';
                          }
                          if (!phone.isValidForSelectedCountry(
                            _selectedCountry?.code ?? '',
                            phone.completeNumber,
                          )) {
                            return 'Invalid phone number for selected country';
                          }
                          // Check if number belongs to selected country
                          try {
                            final detectedCountry = PhoneNumber.getCountry(
                              phone.completeNumber,
                            );
                            final selectedCountry = countries.firstWhere(
                              (c) => c.code == phone.countryISOCode,
                            );

                            if (detectedCountry.code != selectedCountry.code) {
                              return 'This number belongs to ${detectedCountry.name}. Please change country or enter correct number.';
                            }
                          } catch (e) {
                            // If detection fails, check dial code
                            final selectedCountry = countries.firstWhere(
                              (c) => c.code == phone.countryISOCode,
                            );
                            final cleanNumber = phone.completeNumber
                                .replaceFirst('+', '');
                            final expectedDialCode =
                                selectedCountry.dialCode +
                                selectedCountry.regionCode;

                            if (!cleanNumber.startsWith(expectedDialCode)) {
                              return 'Phone number should start with ${selectedCountry.name} dial code';
                            }
                          }

                          return null;
                        },
                        dropdownTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                        pickerDialogStyle: const CountryPickerStyle(
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
                          debugPrint('Phone changed: ${phone.completeNumber}');
                          if (phone.isValidForSelectedCountry(
                            _selectedCountry?.code ?? '',
                            phone.completeNumber,
                          )) {
                            setState(() {
                              _phoneNumber = phone;
                              _selectedCountryCode = phone.countryISOCode;
                            });
                          } else {}
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Filtered Countries Phone Field
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'فیلد با فیلتر کشورها (فقط ایران، آمریکا، انگلیس):',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      IntlPhoneField(
                        decoration: const InputDecoration(
                          labelText: 'Phone Number (Filtered)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.filter_list),
                          helperText: 'Only Iran, US, and UK are available',
                        ),
                        initialCountryCode: 'IR',
                        languageCode: 'en',
                        enableAutoValidation: true,
                        allowedCountries: const [
                          'IR',
                          'US',
                          'GB',
                        ], // فیلتر کشورها
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: (phone) {
                          debugPrint(
                            'Filtered phone: ${phone.toDisplayString()}',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Display current phone number info
              if (_phoneNumber != null) ...[
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'اطلاعات شماره تلفن:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text('کد کشور: ${_phoneNumber!.countryISOCode}'),
                        Text('پرچم کشور: ${_phoneNumber!.flagString}'),
                        Text('کد تلفن: ${_phoneNumber!.countryCode}'),
                        Text('شماره: ${_phoneNumber!.number}'),
                        Text('شماره کامل: ${_phoneNumber!.completeNumber}'),
                        if (_selectedCountryCode != null)
                          Text('کشور انتخاب شده: $_selectedCountryCode'),
                        if (_selectedCountry != null) ...[
                          Text(
                            'نام کشور: ${_selectedCountry!.localizedName('fa')}',
                          ),
                          Text(
                            'طول مجاز: ${_selectedCountry!.minLength} تا ${_selectedCountry!.maxLength} رقم',
                          ),
                        ],
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _validatePhoneNumber(_phoneNumber) == null
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _validatePhoneNumber(_phoneNumber) ??
                                'شماره تلفن معتبر است',
                            style: TextStyle(
                              color: _validatePhoneNumber(_phoneNumber) == null
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _phoneNumber != null
                              ? 'شماره تلفن معتبر: ${_phoneNumber!.completeNumber}'
                              : 'لطفاً شماره تلفن را وارد کنید',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('لطفاً خطاهای موجود را برطرف کنید'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('تایید شماره تلفن'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
