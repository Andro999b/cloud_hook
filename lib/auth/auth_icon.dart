import 'package:cloud_hook/auth/auth.dart';
import 'package:cloud_hook/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthIcon extends ConsumerWidget {
  const AuthIcon({super.key});

  Widget _renderUser(WidgetRef ref, User user) {
    return CircleAvatar(backgroundImage: NetworkImage(user.picture));
  }

  Widget _renderLogin(WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return IconButton.filledTonal(
      onPressed: () {
        auth.signIn();
      },
      icon: const Icon(Icons.login),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return user.maybeWhen(
      data: (user) {
        return user != null ? _renderUser(ref, user) : _renderLogin(ref);
      },
      orElse: () => _renderLogin(ref),
    );
  }
}
