import 'package:get_it/get_it.dart';

// Campaign API
import 'package:greyfundr/core/api/campaign_api/campaign_api.dart';
import 'package:greyfundr/core/api/campaign_api/campaign_api_impl.dart';

// SplitBill API – ADD THESE IMPORTS
import 'package:greyfundr/core/api/splitbill_api/splitbill_api.dart';
import 'package:greyfundr/core/api/splitbill_api/splitbill_api_impl.dart';

// Optional: Auth API (if you use locator<AuthApi>() anywhere)
import 'package:greyfundr/core/api/auth_api/auth_api.dart';
import 'package:greyfundr/core/api/auth_api/auth_api_impl.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Already registered (from previous fix)
  locator.registerLazySingleton<CampaignApi>(() => CampaignApiImpl());

  // NEW: Register SplitBillApi – this fixes "Failed to load users" in create_split_bill.dart
  locator.registerLazySingleton<SplitBillApi>(() => SplitBillApiImpl());

  // Optional: register AuthApi if you ever switch to locator<AuthApi>() instead of direct instantiation
  locator.registerLazySingleton<AuthApi>(() => AuthApiImpl());

  // Add more registrations here as your app grows
  // locator.registerLazySingleton<UserProvider>(() => UserProvider());
  // locator.registerLazySingleton<WalletProvider>(() => WalletProvider());
}