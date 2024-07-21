import 'package:oauth2/oauth2.dart';

abstract class CredentialsStorage {
  Future<Credentials?> read();
  Future<void> write(Credentials credentials);
  Future<void> clear();
}
