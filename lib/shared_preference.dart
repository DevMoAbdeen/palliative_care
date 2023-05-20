import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static late SharedPreferences _prefs;

  static initSharedPreference() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static saveToken(String token) async {
    await _prefs.setString('myToken', token);
  }

  static String? getMyToken() {
    return _prefs.getString('myToken');
  }

  static removeToken() async {
    await _prefs.remove('myToken');
  }

}
