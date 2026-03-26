import 'package:get_it/get_it.dart';
import 'package:greyfundr/core/api/auth_api/auth_api.dart';
import 'package:greyfundr/core/api/auth_api/auth_api_impl.dart';
import 'package:greyfundr/core/api/event_api/event_api.dart';
import 'package:greyfundr/core/api/event_api/event_api_impl.dart';
import 'package:greyfundr/core/api/splitbill_api/splitbill_api.dart';
import 'package:greyfundr/core/api/splitbill_api/splitbill_api_impl.dart';
import 'package:greyfundr/core/api/campaign_api/campaign_api.dart';
import 'package:greyfundr/core/api/campaign_api/campaign_api_impl.dart';
import 'package:greyfundr/core/api/user_api/user_api.dart' hide AuthApi;
import 'package:greyfundr/core/api/user_api/user_api_impl.dart';
import 'package:greyfundr/core/api/wallet_api/wallet_api.dart';
import 'package:greyfundr/core/api/wallet_api/wallet_api_impl.dart';

GetIt locator = GetIt.instance;
void setupLocator() {
  // locator.registerLazySingleton<API>(() => API());
  locator.registerLazySingleton<UserApi>(() => UserApiImpl());
  locator.registerLazySingleton<AuthApi>(() => AuthApiImpl());
  locator.registerLazySingleton<WalletApi>(() => WalletApiImpl());
  locator.registerLazySingleton<SplitBillApi>(() => SplitBillApiImpl());
  // Register CampaignApi so CampaignProvider can resolve it via locator
  locator.registerLazySingleton<CampaignApi>(() => CampaignApiImpl());
  locator.registerLazySingleton<EventApi>(() => EventApiImpl());

}
