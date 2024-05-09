import 'package:cloud_hook/auth/auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
Auth auth(Ref ref) {
  return Auth.instance;
}

@riverpod
Stream<User?> user(Ref ref) {
  return ref.read(authProvider).userUpdate;
}
