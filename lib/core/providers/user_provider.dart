import 'package:greyfundr/shared/responsiveState/base_view_model.dart';

class UserProvider extends BaseNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void updateSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}