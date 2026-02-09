class HuaweiAuthConstants {
  // Huawei OAuth Configuration
  static const String baseUrl = 'https://oauth-login.cloud.huawei.com';
  static const String tokenEndpoint = '/oauth2/v3/token';
  static const String userInfoEndpoint = '/oauth2/v3/userinfo';
  static const String tokenInfoEndpoint = '/oauth2/v3/tokeninfo';

  // App Credentials from agconnect-services.json
  static const String clientId = '116754599';
  static const String clientSecret =
      '502ACA6DF9A6B48AD967C1C878AFDB10CEB8F4380F8437C4F0AB2F6D3EC3ADC1';
  static const String apiKey =
      'DQEDANQOIIfAuV4Q3yFrcMM1FDgHBkl3kenQgBQTOJ+S6sWpgBcXrWcmItI9LCM4TYA2bEkPsUoBFjiiYu4NebYMdA2hXTkDo4OGdA==';
  static const String appId = '116754599';
  static const String productId = '461323198430118133';

  // Grant Types
  static const String grantTypePassword = 'password';
  static const String grantTypeRefreshToken = 'refresh_token';
  static const String grantTypeAuthorizationCode = 'authorization_code';

  // Scopes
  static const String scopeOpenId = 'openid';
  static const String scopeProfile = 'profile';
  static const String scopeEmail = 'email';

  // Timeouts (in milliseconds)
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
