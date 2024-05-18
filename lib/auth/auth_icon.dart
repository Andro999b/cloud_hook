import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/auth/auth.dart';
import 'package:cloud_hook/auth/auth_provider.dart';
import 'package:cloud_hook/collection/collection_sync.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthIcon extends ConsumerWidget {
  const AuthIcon({super.key});

  Widget _renderUser(BuildContext context, WidgetRef ref, User user) {
    return MenuAnchor(
      builder: (context, controller, child) {
        return InkResponse(
          onTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          radius: 25,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Tooltip(
              message: user.name,
              child: CircleAvatar(
                radius: 20,
                backgroundImage:
                    user.picture != null ? NetworkImage(user.picture!) : null,
              ),
            ),
          ),
        );
      },
      style: const MenuStyle(alignment: Alignment.bottomLeft),
      menuChildren: [
        MenuItemButton(
          onPressed: () => CollectionSync.run(),
          leadingIcon: const Icon(Icons.refresh),
          child: Text(AppLocalizations.of(context)!.reload),
        ),
        MenuItemButton(
          onPressed: () {
            Auth.instance.singOut();
          },
          leadingIcon: const Icon(Icons.logout),
          child: Text(AppLocalizations.of(context)!.singOut),
        )
      ],
    );
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
        return user != null
            ? _renderUser(context, ref, user)
            : _renderLogin(ref);
      },
      orElse: () => _renderLogin(ref),
    );
  }
}
