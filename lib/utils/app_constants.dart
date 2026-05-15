class AppConstants {
  static const String baseUrl = 'https://sidi.mobilegear.co.in/';
  static const String registerUrl =
      '${baseUrl}api/mobileapp/auth/customer/register';
  static const String loginUrl = '${baseUrl}api/mobileapp/auth/customer/login';
  static const String verifyOtpUrl =
      '${baseUrl}api/mobileapp/auth/customer/verify-otp';
  static const String resendOtpUrl =
      '${baseUrl}api/mobileapp/auth/customer/resend-otp';
  static const String logout = '${baseUrl}api/mobileapp/auth/logout';
  static const String documentsVerify =
      '${baseUrl}api/mobileapp/auth/customer/upload-documents';
  static const String forgotpass =
      '${baseUrl}api/mobileapp/auth/forgot-password';
  static const String resetpass = '${baseUrl}api/mobileapp/auth/reset-password';
  static const String profile = '${baseUrl}api/mobileapp/user/profile';
  static const String availabilty = '${baseUrl}customer/availability';
  static const String earnings = '${baseUrl}customer/earnings';
  static const String appointments = '${baseUrl}customer/appointments';
  static const String appointmentDetails =
      '${baseUrl}customer/appointment-details';

  // Referral & Wallet
  static const String referralWallet =
      '${baseUrl}api/mobileapp/user/referral/wallet';
  static const String referralRedeem =
      '${baseUrl}api/mobileapp/user/referral/redeem';
}
