
import 'package:intl/intl.dart';

/// Class of validation functions that the app will use
///   - This class should be used as a mixin using the `with` keyword
mixin Validators {
  String password = "";
  String pin = "";

  final RegExp bvnRegex = RegExp(r'^[0-9]+$');

  final phoneNumberRegExp = RegExp(r'^(?:(?:\+|00)234)?(0[789][01]\d{8})$');
  final emailRegExp =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  final zipCodeRegExp = RegExp(r'^[0-9]{5}(?:-[0-9]{4})?$');

  String? validateEmail(String value) {
    if (value.isEmpty) {
      return null;
    }
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Invalid email';
    }
    return null;
  }

  String? validateEmailOrPhoneNumber(String value) {
    if (value.isEmpty) {
      return 'Field cannot be empty';
    }

    // Regular expression to validate an email
    final emailRegExp = RegExp(
      r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$',
      caseSensitive: false,
    );

    // Regular expression to validate a phone number (simple example)
    final phoneRegExp = RegExp(r'^[0-9-]+$');

    if (!emailRegExp.hasMatch(value.trim()) &&
        !phoneRegExp.hasMatch(value.trim())) {
      return 'Invalid email or phone number';
    }

    return null;
  }

  String? validateRetailEmail(String value) {
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Invalid email';
    }
    return null;
  }

  String? validateAddress(String value) {
    if (value.isEmpty) {
      return 'Address field cannot be empty';
    }
    return null;
  }

  String? validateAmount(String value) {
    if (value.isEmpty) {
      return 'Field cannot be empty';
    }
    // if (value.length < 3) {
    //   return 'Amount too small';
    // }
    if (value.length > 10) {
      return 'Amount too large';
    }
    return null;
  }

  String? validateName(String value) {
     if (value.length < 3) {
      return 'Name is too short';
    }
    if (value.isEmpty) {
      return 'Name field cannot be empty';
    }
    if (value.contains(RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]')) ||
        value.contains("’") ||
        value.contains('"') ||
        value.contains("_") ||
        value.contains("-")) {
      return 'Name cannot contain special characters or numbers';
    }
    if (value.contains(' ')) {
      return 'Name cannot contain spaces';
    }
    if (value.contains(RegExp(
        r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}]',
        unicode: true))) {
      return 'Name cannot contain emojis';
    }
    return null;
  }

  String? validate(String value) {
    if (value.length < 3) {
      return 'Name is too short';
    }
    if (value.isEmpty) {
      return 'Name field cannot be empty';
    }
    if (value.contains(RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]'))) {
      return 'Name cannot contain special characters or numbers';
    }
    if (value.contains(' ')) {
      return 'Name cannot contain spaces';
    }
    if (value.contains(RegExp(
        r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}]',
        unicode: true))) {
      return 'Name cannot contain emojis';
    }
    return null;
  }

  String? validatePhoneNumber(String value) {
    if (value.length < 11) {
      return 'Invalid phone number';
    }
    if (!phoneNumberRegExp.hasMatch(value.trim())) {
      return 'Invalid phone number';
    }
    return null;
  }

  String? validateWalletAddress(String value) {
    if (value.length < 38) {
      return 'Invalid wallet address';
    }
    if (value.isEmpty) {
      return 'Wallet address cannot be empty';
    }
    return null;
  }

  String? validateAccountNumber(String value) {
    if (value.isEmpty) return "Field cannot be empty";

    if (value.length < 10) {
      return 'Invalid account number';
    }

    return null;
  }

  String? validateBVN(String value) {
    if (value.isEmpty) return "Provide a valid BVN";

    if (value.length < 11) {
      return 'Invalid BVN format';
    }
    if (value.length > 11) {
      return 'Invalid BVN format';
    }
    if (!bvnRegex.hasMatch(value.trim())) {
      return 'Invalid BVN format';
    }
    return null;
  }

  String? validateComment(String value) {
    if (value.isEmpty) return "Field cannot be empty";
    return null;
  }

  String? validateReferral(String value) {
    if (value.length > 6) return "Invalid entry";
    return null;
  }

  String? validateZip(String value) {
    if (!zipCodeRegExp.hasMatch(value.trim())) {
      return 'Invalid zip code';
    }
    return null;
  }

  String? validatePassword(String value) {
    if (value.trim().isEmpty) {
      return 'Password field cannot be empty';
    } else if (value.length < 8) {
      return 'Password is too short';
    }
    password = value;
    return null;
  }

  String? confirmPassword(String confirmPassword) {
    if (confirmPassword != password) {
      return 'Passwords do not match';
    } else if (confirmPassword.isEmpty) {
      return 'Confirm password field cannot be empty';
    }
    return null;
  }

  String? confirmPin(String confirmPassword) {
    if (confirmPassword != pin) {
      return 'PINs do not match';
    } else if (confirmPassword.isEmpty) {
      return 'Confirm PIN field cannot be empty';
    }

    return null;
  }

  String? validatePin(String value) {
    if (value.trim().isEmpty) {
      return 'PIN field cannot be empty';
    } else if (value.length != 4) {
      return 'PIN must be 4 numbers';
    }
    pin = value;

    return null;
  }

  String? validatePin1(String value) {
    if (value.trim().isEmpty) {
      return 'PIN field cannot be empty';
    } else if (value.length != 4) {
      return 'PIN must be 4 numbers';
    }

    return null;
  }

  bool isValidDate(String input) {
    // print(input);
    String editInput = input.replaceAll(RegExp('/'), '');
    try {
      final date = DateFormat("dd/MM/yyyy").parse(input);
      final originalFormatString = toOriginalFormatString(date);
      // print(editInput);
      // print(originalFormatString);
      return editInput == originalFormatString;
    } catch (e) {
      return false;
    }
  }

  String toOriginalFormatString(DateTime dateTime) {
    final y = dateTime.year.toString().padLeft(4, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    return "$d$m$y";
  }

  // String? valdateDate(String value) {
  //   bool isdate = isValidDate(value);
  //   DateTime date;
  //   DateTime now = DateTime.now();
  //   DateTime beg = DateFormat("dd/MM/yyyy").parse('01/01/1800');
  //   DateTime end = DateFormat("dd/MM/yyyy").parse('01/01/3000');

  //   try {
  //     date = DateFormat("dd/MM/yyyy").parse(value);
  //     //isdate = true;
  //   } catch (e) {
  //     isdate = false;
  //     print('Note a correct date');
  //   }

  //   if (value.trim().isEmpty) {
  //     return 'Date cannot be empty';
  //   } else if (!isdate) {
  //     return 'Enter a correct date';
  //   } else if (date.isAfter(beg) && date.isBefore(end)) {
  //     return null;
  //   } else {
  //     return 'Date out of range';
  //   }

  // }

  String? validateCard(String input) {
    if (input.isEmpty) {
      return "Please enter a credit card number";
    }

    // input = getCleanedNumber(input);

    if (input.length < 8) {
      // No need to even proceed with the validation if it's less than 8 characters
      return "Not a valid credit card number";
    }

    int sum = 0;
    int length = input.length;
    for (var i = 0; i < length; i++) {
      // get digits in reverse order
      int digit = int.parse(input[length - i - 1]);

      // every 2nd number multiply with 2
      if (i % 2 == 1) {
        digit *= 2;
      }
      sum += digit > 9 ? (digit - 9) : digit;
    }

    if (sum % 10 == 0) {
      return null;
    }

    return "You entered an invalid credit card number";
  }
}
