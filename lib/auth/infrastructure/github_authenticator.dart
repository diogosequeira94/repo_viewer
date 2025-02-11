import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:oauth2/oauth2.dart';
import 'package:repo_viewer_app/auth/domain/auth_failure.dart';
import 'package:repo_viewer_app/auth/infrastructure/credentials_storage/credentials_storage.dart';
import 'package:repo_viewer_app/auth/infrastructure/github_endpoints.dart';

class GithubAuthenticator {
  final CredentialsStorage _storage;

  const GithubAuthenticator(this._storage);

  static const _clientId = 'Ov23lihisi6Gi1AJnm0N';
  static const _clientSecret = 'ddfdd8bdfb9d9f9fc12d07ac11d9f78653952897';
  static const _scopes = ['read:user', 'repo'];

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

  AuthorizationCodeGrant createGrant() {
    return AuthorizationCodeGrant(
      _clientId,
      Uri.parse(GithubEndpoints.authorizationEndpoint),
      Uri.parse(GithubEndpoints.tokenEndpoint),
      secret: _clientSecret,
    );
  }

  Uri getAuthorizationUrl(AuthorizationCodeGrant grant) {
    return grant.getAuthorizationUrl(
      Uri.parse(GithubEndpoints.redirectUrl),
      scopes: _scopes,
    );
  }

  /// Unit is Dartz void
  Future<Either<AuthFailure, Unit>> handleAuthorizationResponse(
    AuthorizationCodeGrant grant,
    Map<String, String> queryParams,
  ) async {
    try {
      final httpClient = await grant.handleAuthorizationResponse(queryParams);
      await _storage.write(httpClient.credentials);
      return right(unit);
    } on FormatException {
      return left(const AuthFailure.server());
    } on AuthorizationException catch (e) {
      return left(AuthFailure.server('Error: ${e.error} ${e.description}'));
    } on PlatformException {
      return left(const AuthFailure.storage());
    }
  }
}
