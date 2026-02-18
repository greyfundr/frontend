

import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/features/auth/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class AppProviders {
  static final providers = <SingleChildWidget>[
    ListenableProvider(create: (_) => UserProvider()),
    ListenableProvider(create: (_) => AuthProvider()),

  ];}