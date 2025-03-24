import '../../../utils/platform_utils.dart';
import 'auth0_service.dart'; // Your existing native implementation
import 'auth_service_web.dart';

class AuthServiceFactory {
  static Object create() {
    if (PlatformUtils.isWeb) {
      return AuthServiceWeb();
    } else {
      return Auth0Service(); // Your existing implementation for mobile
    }
  }
}