# TODO: Fix Registration Flow to Redirect to Login Screen

## Tasks
- [x] Modify `lib/core/services/auth_service.dart` to not auto-login after registration (remove setting _isLoggedIn and AuthState.authenticated)
- [x] Modify `lib/features/auth/auth_controller.dart` to not set auth state to authenticated after registration
- [x] Ensure registration does not save user data locally as if logged in
- [x] Test the flow: Register -> Redirect to Login -> Login with registered credentials
