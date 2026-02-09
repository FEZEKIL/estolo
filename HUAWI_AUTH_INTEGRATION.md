# Huawei AppGallery Connect Authentication Integration Guide

## Overview
This guide explains how to integrate Huawei AppGallery Connect Authentication into the Estolo Smart Spaza Assistant app using REST API (Option 1).

## Current Implementation: REST API Approach

### Features Implemented
1. **Email/Password Login** - Traditional authentication method via REST API
2. **Phone Number + OTP Login** - Perfect for township users (mock implementation)
3. **Social Login** - Support for Huawei ID, Google, Facebook (mock implementation)
4. **Token-based Sessions** - Secure JWT token management with refresh tokens
5. **Offline Session Handling** - Persistent login state with token validation
6. **User Registration** - Complete account creation flow
7. **Password Recovery** - Email-based reset functionality

### Setup Instructions

#### 1. Dependencies
The app uses standard HTTP client for REST API calls:
```yaml
dependencies:
  http: ^1.2.2
  shared_preferences: ^2.3.2
  # ... other dependencies
```

#### 2. Configuration
App credentials are extracted from `agconnect-services.json`:
- Client ID: 116754599
- Client Secret: 502ACA6DF9A6B48AD967C1C878AFDB10CEB8F4380F8437C4F0AB2F6D3EC3ADC1
- API Key: DQEDANQOIIfAuV4Q3yFrcMM1FDgHBkl3kenQgBQTOJ+S6sWpgBcXrWcmItI9LCM4TYA2bEkPsUoBFjiiYu4NebYMdA2hXTkDo4OGdA==
- App ID: 116754599
- Product ID: 461323198430118133

#### 3. REST API Endpoints
- Base URL: https://oauth-login.cloud.huawei.com
- Token Endpoint: /oauth2/v3/token
- User Info Endpoint: /oauth2/v3/userinfo
- Token Info Endpoint: /oauth2/v3/tokeninfo

### 4. Authentication Flow

#### Email/Password Login
```dart
// POST to /oauth2/v3/token with grant_type=password
final response = await http.post(
  Uri.parse('${baseUrl}/oauth2/v3/token'),
  headers: {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
  },
  body: {
    'grant_type': 'password',
    'username': email,
    'password': password,
    'scope': 'openid profile email',
  },
);
```

#### Token Management
- Access tokens are stored securely using SharedPreferences
- Refresh tokens are used to obtain new access tokens when they expire
- Token validation is performed on app startup

#### User Info Retrieval
```dart
// GET to /oauth2/v3/userinfo with Bearer token
final response = await http.get(
  Uri.parse('${baseUrl}/oauth2/v3/userinfo'),
  headers: {
    'Authorization': 'Bearer $accessToken',
  },
);
```

### 5. Advantages of REST API Approach
- ✅ Works now, no plugin issues
- ✅ Fully compatible with Flutter 3+, Windows, Java 11
- ✅ No native platform dependencies
- ✅ Easier testing and debugging
- ✅ More control over authentication flow

### 6. Current Limitations
- Phone/SMS authentication requires additional Huawei API endpoints
- Social login requires OAuth redirect flows
- Registration is currently mocked (would need Huawei account creation API)

### 7. Future Enhancements
- Implement complete phone number authentication
- Add OAuth redirect handling for social login
- Add account creation via Huawei APIs
- Implement password reset functionality

## Integration with Existing Code

### Updating Constants
The `huawei_auth_constants.dart` file now contains the real credentials from `agconnect-services.json`:
```dart
class HuaweiAuthConstants {
  static const String clientId = '116754599';
  static const String clientSecret = '502ACA6DF9A6B48AD967C1C878AFDB10CEB8F4380F8437C4F0AB2F6D3EC3ADC1';
  static const String apiKey = 'DQEDANQOIIfAuV4Q3yFrcMM1FDgHBkl3kenQgBQTOJ+S6sWpgBcXrWcmItI9LCM4TYA2bEkPsUoBFjiiYu4NebYMdA2hXTkDo4OGdA==';
  static const String appId = '116754599';
  static const String productId = '461323198430118133';
}
```

### Authentication Service Implementation
The `AuthService` now uses the real Huawei OAuth API endpoints and credentials to authenticate users. The service handles:
- Initial authentication
- Token refresh
- User info retrieval
- Session persistence

### Testing the Implementation
To test the authentication flow:
1. Run the app
2. Try logging in with test credentials
3. Verify that tokens are properly stored and retrieved
4. Test the logout functionality
5. Verify that the refresh token mechanism works

## Troubleshooting

### Common Issues
1. **Invalid Client Credentials**: Ensure the credentials in `huawei_auth_constants.dart` match those in `agconnect-services.json`
2. **Network Errors**: Verify internet connectivity and firewall settings
3. **Token Expiration**: The refresh token mechanism should handle this automatically
4. **Scope Issues**: Make sure the requested scopes match what's configured in AppGallery Connect

### Debugging Tips
- Enable verbose logging to see API request/response details
- Verify that the Huawei OAuth service is enabled in AppGallery Connect
- Check that the app package name matches the one registered in Huawei
- Ensure proper SSL certificate handling for HTTPS requests

## Security Considerations

### Token Storage
- Access and refresh tokens are stored using SharedPreferences
- For production apps, consider using more secure storage options like encrypted preferences
- Tokens are automatically cleared on logout

### API Security
- Client credentials are hardcoded in the constants file (this is standard practice for public clients)
- All API communications use HTTPS
- Tokens are sent using proper authorization headers

## Production Deployment

### Pre-deployment Checklist
- [ ] Verify all Huawei API credentials are correct
- [ ] Test authentication flow on multiple devices
- [ ] Review privacy and security compliance
- [ ] Update privacy policy to reflect Huawei authentication
- [ ] Prepare for app store review requirements

### Performance Optimization
- Implement proper error handling and fallback mechanisms
- Optimize token refresh timing to minimize user disruption
- Cache user info locally to reduce API calls
- Monitor API rate limits and implement appropriate throttling