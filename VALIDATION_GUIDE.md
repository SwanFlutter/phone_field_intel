# راهنمای Validation خودکار Phone Field Intel

این راهنما توضیح می‌دهد که چطور از سیستم validation خودکار پکیج `phone_field_intel` استفاده کنید.

## ویژگی‌های جدید

### 🚀 Validation خودکار برای همه کشورها
- سیستم validation هوشمند که قوانین مخصوص هر کشور را اعمال می‌کند
- نیازی به نوشتن validation سفارشی نیست
- پیام‌های خطای محلی‌سازی شده

### 🔧 فیلتر کشورها
- امکان محدود کردن کشورهای قابل انتخاب
- مفید برای اپلیکیشن‌هایی که فقط در مناطق خاص فعالیت می‌کنند

### 🌍 قوانین مخصوص کشورها
- ایران: شماره موبایل باید با 9 شروع شود
- آمریکا/کانادا: نباید با 0 یا 1 شروع شود
- انگلیس: در فرمت بین‌المللی نباید با 0 شروع شود
- آلمان: در فرمت بین‌المللی نباید با 0 شروع شود
- هند: شماره موبایل باید با 6، 7، 8 یا 9 شروع شود
- و قوانین مخصوص سایر کشورها...

## نحوه استفاده

### مثال ساده

```dart
IntlPhoneField(
  decoration: InputDecoration(
    labelText: 'شماره تلفن',
    border: OutlineInputBorder(),
  ),
  initialCountryCode: 'IR',
  languageCode: 'fa',
  autovalidateMode: AutovalidateMode.onUserInteraction,
  validator: (phone) {
    if (phone == null || phone.number.isEmpty) {
      return 'لطفاً شماره تلفن را وارد کنید';
    }
    
    // بررسی فرمت عددی
    if (!RegExp(r'^[0-9]+$').hasMatch(phone.number)) {
      return 'شماره تلفن باید فقط شامل اعداد باشد';
    }
    
    // بررسی طول
    if (!phone.isValidLength()) {
      return 'طول شماره تلفن نامعتبر است';
    }
    
    // بررسی تطبیق کشور
    try {
      final detectedCountry = PhoneNumber.getCountry(phone.completeNumber);
      final selectedCountry = countries.firstWhere(
        (c) => c.code == phone.countryISOCode,
      );
      
      if (detectedCountry.code != selectedCountry.code) {
        return 'این شماره متعلق به کشور ${detectedCountry.localizedName('fa')} است';
      }
    } catch (e) {
      // اگر تشخیص کشور ناموفق بود، کد کشور را بررسی کن
      final selectedCountry = countries.firstWhere(
        (c) => c.code == phone.countryISOCode,
      );
      final cleanNumber = phone.completeNumber.replaceFirst('+', '');
      final expectedDialCode = selectedCountry.dialCode + selectedCountry.regionCode;
      
      if (!cleanNumber.startsWith(expectedDialCode)) {
        return 'شماره باید با کد کشور ${selectedCountry.localizedName('fa')} شروع شود';
      }
    }
    
    return null;
  },
  onChanged: (phone) {
    print('شماره تغییر کرد: ${phone.completeNumber}');
  },
  onCountryChanged: (country) {
    print('کشور انتخاب شد: ${country.localizedName('fa')}');
  },
)
```

### مثال پیشرفته با مدیریت State

```dart
class PhoneFieldDemo extends StatefulWidget {
  @override
  _PhoneFieldDemoState createState() => _PhoneFieldDemoState();
}

class _PhoneFieldDemoState extends State<PhoneFieldDemo> {
  Country? _selectedCountry;
  PhoneNumber? _phoneNumber;

  String? _validatePhoneNumber(PhoneNumber? phone) {
    if (phone == null || phone.number.isEmpty) {
      return 'لطفاً شماره تلفن را وارد کنید';
    }

    // بررسی فرمت عددی
    if (!RegExp(r'^[0-9]+$').hasMatch(phone.number)) {
      return 'شماره تلفن باید فقط شامل اعداد باشد';
    }

    // بررسی طول
    if (!phone.isValidLength()) {
      return 'طول شماره تلفن باید بین ${_selectedCountry?.minLength ?? 0} تا ${_selectedCountry?.maxLength ?? 0} رقم باشد';
    }

    // بررسی تطبیق کشور
    if (_selectedCountry != null) {
      try {
        final detectedCountry = PhoneNumber.getCountry(phone.completeNumber);
        
        if (detectedCountry.code != _selectedCountry!.code) {
          return 'این شماره تلفن متعلق به کشور ${detectedCountry.localizedName('fa')} است. لطفاً کشور را تغییر دهید یا شماره صحیح وارد کنید.';
        }
      } catch (e) {
        final cleanNumber = phone.completeNumber.replaceFirst('+', '');
        final expectedDialCode = _selectedCountry!.dialCode + _selectedCountry!.regionCode;
        
        if (!cleanNumber.startsWith(expectedDialCode)) {
          return 'شماره تلفن باید با کد کشور ${_selectedCountry!.localizedName('fa')} شروع شود';
        }
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      decoration: InputDecoration(
        labelText: 'شماره تلفن',
        border: OutlineInputBorder(),
      ),
      initialCountryCode: 'IR',
      languageCode: 'fa',
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: _validatePhoneNumber,
      onChanged: (phone) {
        setState(() {
          _phoneNumber = phone;
        });
      },
      onCountryChanged: (country) {
        setState(() {
          _selectedCountry = country;
        });
      },
    );
  }
}
```

## پیام‌های خطا

### پیام‌های فارسی
- `لطفاً شماره تلفن را وارد کنید` - شماره خالی است
- `شماره تلفن باید فقط شامل اعداد باشد` - کاراکتر غیرمجاز
- `طول شماره تلفن نامعتبر است` - طول خارج از محدوده
- `این شماره متعلق به کشور [نام کشور] است` - شماره متعلق به کشور دیگری است
- `شماره باید با کد کشور [نام کشور] شروع شود` - کد کشور اشتباه

### پیام‌های انگلیسی
- `Please enter a phone number` - شماره خالی است
- `Phone number should only contain digits` - کاراکتر غیرمجاز
- `Invalid phone number length` - طول خارج از محدوده
- `This number belongs to [Country Name]` - شماره متعلق به کشور دیگری است
- `Phone number should start with [Country Name] dial code` - کد کشور اشتباه

## تست Validation

برای تست validation می‌توانید از فایل تست استفاده کنید:

```bash
flutter test test/phone_validation_test.dart
```

## نکات مهم

1. **Validation خودکار**: با تنظیم `autovalidateMode` روی `AutovalidateMode.onUserInteraction`، validation به صورت خودکار اجرا می‌شود.

2. **مدیریت خطا**: همیشه خطاها را به صورت graceful handle کنید تا تجربه کاربری بهتری داشته باشید.

3. **پیام‌های محلی**: از `localizedName` برای نمایش نام کشورها به زبان محلی استفاده کنید.

4. **Performance**: Validation در `onChanged` اجرا می‌شود، پس سعی کنید کد validation را بهینه کنید.

## مثال‌های کاربردی

### Validation برای ایران
```dart
validator: (phone) {
  if (phone?.countryISOCode == 'IR') {
    // بررسی شماره ایران
    if (phone!.number.length != 10) {
      return 'شماره ایران باید 10 رقم باشد';
    }
    if (!phone.number.startsWith('9')) {
      return 'شماره ایران باید با 9 شروع شود';
    }
  }
  return null;
}
```

### Validation برای آمریکا
```dart
validator: (phone) {
  if (phone?.countryISOCode == 'US') {
    // بررسی شماره آمریکا
    if (phone!.number.length != 10) {
      return 'شماره آمریکا باید 10 رقم باشد';
    }
  }
  return null;
}
```

این راهنما به شما کمک می‌کند تا validation پیشرفته و کاربردی برای شماره‌های تلفن پیاده‌سازی کنید. 