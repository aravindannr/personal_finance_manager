import 'package:get_storage/get_storage.dart';
import 'package:personal_finance_manager/app/constants/app_constants.dart';

class StorageService {
  late final GetStorage _box;

  Future<StorageService> init() async {
    await GetStorage.init();
    _box = GetStorage();
    return this;
  }

  // Theme Mode
  bool get isDarkMode => _box.read(AppConstants.keyThemeMode) ?? false;

  Future<void> setFirstTime(bool value) async {
    await _box.write(AppConstants.keyFirstTime, value);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _box.erase();
  }
}
