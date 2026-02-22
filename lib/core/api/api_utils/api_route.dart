import 'package:greyfundr/shared/environment.dart';

class ApiRoute {
  
static final String baseUrl = env.host;

// Auth Routes
static final String signupRoute = "$baseUrl/auth/signup";
static final String loginRoute = "$baseUrl/auth/login";
static final String refreshTokenRoute = "$baseUrl/auth/refresh";
static final String verifyOtpRoute = "$baseUrl/auth/verify-otp";
static final String resendOtpRoute = "$baseUrl/auth/resend-otp";
static final String forgotPasswordRoute = "$baseUrl/auth/forgot-password";
static final String createPasswordRoute = "$baseUrl/auth/create-password";
static final String submitBasicInfoRoute = "$baseUrl/auth/submit-basic-info";
static final String completeKycRoute = "$baseUrl/auth/complete-kyc";
static final String loginPinRoute = "$baseUrl/auth/login-pin";
static final String setPinRoute = "$baseUrl/auth/set-pin";

// Two Factor Authentication Routes
static final String generateTwoFactorRoute = "$baseUrl/auth/generate";
static final String verifyTwoFactorRoute = "$baseUrl/auth/verify";
static final String validateTwoFactorRoute = "$baseUrl/auth/validate";
static final String disableTwoFactorRoute = "$baseUrl/auth/disable";

// Settings Routes
static final String getSettingsRoute = "$baseUrl/settings";
static final String updateSettingsRoute = "$baseUrl/settings/update";

// User Routes
static final String userProfileRoute = "$baseUrl/users/profile";

// Wallet Routes
static final String walletRoute = "$baseUrl/wallet";
static final String walletBalanceRoute = "$baseUrl/wallet/balance";
static final String provisionVirtualAccountRoute = "$baseUrl/wallet/provision-virtual-account";
static final String fundingAccountRoute = "$baseUrl/wallet/funding-account";
static final String fundInitiateRoute = "$baseUrl/wallet/fund/initiate";
static final String fundVerifyRoute = "$baseUrl/wallet/fund/verify";
static final String bankAccountsRoute = "$baseUrl/wallet/bank-accounts";
static final String withdrawRoute = "$baseUrl/wallet/withdraw";

}