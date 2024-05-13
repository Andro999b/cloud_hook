import 'package:cloud_hook/auth/auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
Auth auth(Ref ref) {
  return Auth.instance;
}

@Riverpod(keepAlive: true)
Stream<User?> user(Ref ref) {
  return Auth.instance.userUpdate;
}
