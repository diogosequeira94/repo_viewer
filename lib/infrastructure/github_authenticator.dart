import 'package:flutter/services.dart';
import 'package:oauth2/oauth2.dart';
import 'package:repo_viewer_app/infrastructure/credentials_storage/credentials_storage.dart';

class GithubAuthenticator {
  final CredentialsStorage _storage;

  const GithubAuthenticator(this._storage);

  /// Returns [Credentials] in case the user is signedIn
  /// Returns null if user it NOT signedIn
  Future<Credentials?> getSignedInCredentials() async {
    try {
      final storedCredentials = await _storage.read();
      if (storedCredentials != null) {
        if (storedCredentials.canRefresh && storedCredentials.isExpired) {
          ///ToDo: Refresh the credentials (in GitHub the token never expires but in other APIs it will)
        }
      }
      return storedCredentials;
    } on PlatformException {
      return null;
    }
  }

  /// Helper method that checks if its SignedIn
  Future<bool> isSignedIn() =>
      getSignedInCredentials().then((credentials) => credentials != null);
}
