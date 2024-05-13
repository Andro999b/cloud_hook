import 'dart:async';
import 'dart:convert';

import 'package:cloud_hook/app_preferences.dart';
import 'package:firebase_dart/firebase_dart.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart' show rootBundle;

abstract class AuthTokenStore {
  FutureOr<void> write(AccessCredentials? credentials);
  FutureOr<AccessCredentials?> read();
  FutureOr<void> delete();
}

class PerferenceTokenStore extends AuthTokenStore {
  final String key = "access_credentials";

  @override
  FutureOr<void> delete() => AppPreferences.instance.remove(key);

  @override
  FutureOr<AccessCredentials?> read() {
    final accessCredentialsJson = AppPreferences.instance.getString(key);

    if (accessCredentialsJson != null) {
      return AccessCredentials.fromJson(json.decode(accessCredentialsJson));
    }

    return null;
  }

  @override
  FutureOr<void> write(AccessCredentials? credentials) {
    AppPreferences.instance.setString(key, json.encode(credentials));
  }
}

class User {
  final String id;
  final String? name;
  final String? picture;

  const User({
    required this.id,
    required this.name,
    required this.picture,
  });

  factory User.fromIdToken(String idToken) {
    final [_, encodedPayload, _] = idToken.split('.');

    final payload =
        json.decode(String.fromCharCodes(base64.decode(encodedPayload)))
            as Map<String, dynamic>;

    return User(
      id: payload["sub"].toString(),
      name: payload["name"].toString(),
      picture: payload["picture"].toString(),
    );
  }
}

class Auth {
  final AuthTokenStore _tokenStore = PerferenceTokenStore();
  final StreamController<User?> _userStreamController = StreamController();
  late Stream<User?> _userStream;

  static ClientId? clientId;
  User? _currentUser;

  static final Auth instance = Auth._();

  Auth._() {
    _userStream = _userStreamController.stream.asBroadcastStream();

    FirebaseAuth.instance.userChanges().listen((event) {
      if (event != null) {
        _currentUser = User(
          id: event.uid,
          name: event.displayName,
          picture: event.photoURL,
        );
        _userStreamController.add(_currentUser);
      } else {
        _currentUser = null;
      }
    });

    restore();
  }

  User? get currentUser => _currentUser;
  Stream<User?> get userUpdate => _userStream;

  Future<void> signIn() async {
    final scopes = [
      "https://www.googleapis.com/auth/userinfo.profile",
      "https://www.googleapis.com/auth/userinfo.email"
    ];

    final clientId = await loadClientId();

    final credentials = await obtainAccessCredentialsViaUserConsent(
      clientId,
      scopes,
      Client(),
      (uri) {
        launchUrl(Uri.parse(uri));
      },
    );

    _setCredentials(credentials);
  }

  Future<void> singOut() async {
    _tokenStore.delete();
    _currentUser = null;
    _userStreamController.add(null);
  }

  static Future<ClientId> loadClientId() async {
    if (clientId == null) {
      final clientSecretJson =
          await rootBundle.loadString("client_secret.json");
      clientId = ClientId.fromJson(json.decode(clientSecretJson));
    }

    return clientId!;
  }

  Future<void> restore() async {
    final clientId = await loadClientId();
    var credentials = await _tokenStore.read();

    if (credentials != null) {
      if (credentials.accessToken.hasExpired) {
        credentials = await refreshCredentials(clientId, credentials, Client());
      }
      _setCredentials(credentials);
    }
  }

  void _setCredentials(AccessCredentials credentials) {
    FirebaseAuth.instance.signInWithCredential(
      GoogleAuthProvider.credential(
        accessToken: credentials.accessToken.data,
        idToken: credentials.idToken,
      ),
    );
  }
}
