import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_hook/app_preferences.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class AuthTokenStore {
  FutureOr<void> write(AccessCredentials? credentials);
  FutureOr<AccessCredentials?> read();
  FutureOr<void> delete();
}

class PerferenceTokenStore extends AuthTokenStore {
  final String key = "access_credentials";

  @override
  FutureOr<void> delete() => Preferences.instance.remove(key);

  @override
  FutureOr<AccessCredentials?> read() {
    final accessCredentialsJson = Preferences.instance.getString(key);

    if (accessCredentialsJson != null) {
      return AccessCredentials.fromJson(json.decode(accessCredentialsJson));
    }

    return null;
  }

  @override
  FutureOr<void> write(AccessCredentials? credentials) {
    Preferences.instance.setString(key, json.encode(credentials));
  }
}

class User {
  final String name;
  final String firstName;
  final String lastName;
  final String picture;

  const User({
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.picture,
  });

  factory User.fromIdToken(String idToken) {
    final [_, encodedPayload, _] = idToken.split('.');

    final payload =
        json.decode(String.fromCharCodes(base64.decode(encodedPayload)))
            as Map<String, dynamic>;

    return User(
      name: payload["name"].toString(),
      firstName: payload["given_name"].toString(),
      lastName: payload["family_name"].toString(),
      picture: payload["picture"].toString(),
    );
  }
}

class Auth {
  final AuthTokenStore _tokenStore = PerferenceTokenStore();
  final StreamController<User?> _userStreamController = StreamController();
  late Stream<User?> _userStream;

  ClientId? _clientId;
  User? _currentUser;
  AutoRefreshingAuthClient? _currentClient;

  static final Auth instance = Auth._();

  Auth._() {
    _userStream = _userStreamController.stream.asBroadcastStream();
    _userStream.listen(
      (event) => _currentUser = event,
    );
    _restore();
  }

  AutoRefreshingAuthClient? get currentClient => _currentClient;
  User? get currentUser => _currentUser;
  Stream<User?> get userUpdate => _userStream;

  Future<void> signIn() async {
    final scopes = ["https://www.googleapis.com/auth/userinfo.profile"];

    final clientId = await _loadClientId();

    final authClient = await clientViaUserConsent(clientId, scopes, (uri) {
      launchUrl(Uri.parse(uri));
    });

    _tokenStore.write(authClient.credentials);
    _currentUser = User.fromIdToken(authClient.credentials.idToken!);
    _userStreamController.add(_currentUser);

    _setClient(authClient);
  }

  Future<void> singOut() async {
    _tokenStore.delete();
    _currentClient = null;
    _userStreamController.add(null);
  }

  Future<ClientId> _loadClientId() async {
    if (_clientId == null) {
      final clientSecretJson = await File("client_secret.json").readAsString();
      _clientId = ClientId.fromJson(json.decode(clientSecretJson));
    }

    return _clientId!;
  }

  Future<void> _restore() async {
    final clientId = await _loadClientId();
    final credentials = await _tokenStore.read();

    if (credentials != null) {
      final authClient = autoRefreshingClient(clientId, credentials, Client());

      _currentUser = User.fromIdToken(authClient.credentials.idToken!);
      _userStreamController.add(_currentUser);

      _setClient(authClient);
    }
  }

  void _setClient(AutoRefreshingAuthClient authClient) {
    authClient.credentialUpdates.listen((event) {
      _currentUser = User.fromIdToken(event.idToken!);
      _tokenStore.write(event);
    });

    _currentClient = authClient;
  }
}
