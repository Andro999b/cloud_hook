import 'package:strumok/app_localizations.dart';
import 'package:strumok/auth/auth.dart';
import 'package:strumok/auth/auth_provider.dart';
import 'package:strumok/collection/collection_sync.dart';
import 'package:strumok/utils/visual.dart';
import 'package:strumok/widgets/dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AuthIcon extends ConsumerWidget {
  const AuthIcon({super.key});

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
        return user != null ? _AuthUserMenu(user: user) : _renderLogin(ref);
      },
      orElse: () => _renderLogin(ref),
    );
  }
}

class _AuthUserMenu extends ConsumerWidget {
  final User user;

  const _AuthUserMenu({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dropdown(
      anchorBuilder: (context, onPressed, child) => InkResponse(
        onTap: onPressed,
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
      ),
      style: MenuStyle(
        alignment:
            isMobile(context) ? Alignment.topCenter : Alignment.bottomLeft,
      ),
      menuChildrenBulder: (focusNode) => [
        MenuItemButton(
          focusNode: focusNode,
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
        ),
      ],
    );
  }
}
