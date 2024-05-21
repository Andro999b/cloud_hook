import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/auth/auth.dart';
import 'package:cloud_hook/auth/auth_provider.dart';
import 'package:cloud_hook/collection/collection_sync.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
        return user != null ? _AuthUserMenu() : _renderLogin(ref);
      },
      orElse: () => _renderLogin(ref),
    );
  }
}

class _AuthUserMenu extends ConsumerStatefulWidget {
  const _AuthUserMenu();

  @override
  ConsumerState<_AuthUserMenu> createState() => _AuthUserMenuState();
}

class _AuthUserMenuState extends ConsumerState<_AuthUserMenu> {
  final MenuController _menuController = MenuController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).requireValue!;

    return MenuAnchor(
      controller: _menuController,
      builder: (context, controller, child) {
        return InkResponse(
          onTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
              _focusNode.requestFocus();
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
        BackButtonListener(
          onBackButtonPressed: () async {
            _menuController.close();
            return true;
          },
          child: FocusScope(
            child: Column(
              children: [
                MenuItemButton(
                  focusNode: _focusNode,
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
            ),
          ),
        ),
      ],
      consumeOutsideTap: true,
    );
  }
}
