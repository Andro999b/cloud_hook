import 'package:strumok/auth/auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
Auth auth(AuthRef ref) {
  return Auth.instance;
}

@Riverpod(keepAlive: true)
Stream<User?> user(UserRef ref) {
  return Auth.instance.userUpdate;
}
