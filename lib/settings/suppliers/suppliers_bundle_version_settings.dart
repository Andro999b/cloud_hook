import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/content_suppliers/ffi_supplier_bundle_info.dart';
import 'package:cloud_hook/settings/suppliers/suppliers_bundle_version_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SuppliersBundleVersionSettings extends ConsumerWidget {
  const SuppliersBundleVersionSettings({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installedBundle = ref.watch(installedSupplierBundleInfoProvider);

    return installedBundle.maybeWhen(
      data: (installed) => installed == null
          ? const _SuppliersBundleInstall()
          : _SuppliersBundleUpdate(installedBundle: installed),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _SuppliersBundleInstall extends ConsumerWidget {
  const _SuppliersBundleInstall();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestBundle = ref.watch(latestSupplierBundleInfoProvider);

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        latestBundle.when(
          data: (info) => SuppliersBundleDownload(
            info: info,
            lable: const Text("Встановити"),
          ),
          loading: () => const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator.adaptive(),
          ),
          error: (Object error, StackTrace stackTrace) =>
              Text(error.toString()),
        ),
      ],
    );
  }
}

class _SuppliersBundleUpdate extends ConsumerWidget {
  final FFISupplierBundleInfo installedBundle;

  const _SuppliersBundleUpdate({required this.installedBundle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestBundle = ref.watch(latestSupplierBundleInfoProvider);

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(installedBundle.version),
        const Spacer(),
        latestBundle.when(
          data: (data) => renderUpdateButton(
            context,
            ref,
            data,
            installedBundle.version != data.version,
          ),
          loading: () => FilledButton.tonalIcon(
            icon: const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator.adaptive(),
            ),
            onPressed: null,
            label: Text(AppLocalizations.of(context)!.settingsCheckForUpdate),
          ),
          error: (error, stackTrace) => Text(error.toString()),
        )
      ],
    );
  }

  Widget renderUpdateButton(
    BuildContext context,
    WidgetRef ref,
    FFISupplierBundleInfo lattestInfo,
    bool hasNewVersion,
  ) {
    if (hasNewVersion) {
      return SuppliersBundleDownload(
        info: lattestInfo,
        lable: Text(AppLocalizations.of(context)!
            .settingsDownloadUpdate(lattestInfo.version)),
      );
    }

    return FilledButton.tonal(
      onPressed: () => ref.refresh(latestSupplierBundleInfoProvider),
      child: Text(AppLocalizations.of(context)!.settingsCheckForUpdate),
    );
  }
}

class SuppliersBundleDownload extends ConsumerWidget {
  final FFISupplierBundleInfo info;
  final Widget lable;

  const SuppliersBundleDownload({
    super.key,
    required this.info,
    required this.lable,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = suppliersBundleDownloadProvider(info);
    final state = ref.watch(provider);

    return state.downloading
        ? FilledButton.tonalIcon(
            icon: SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator.adaptive(
                value: state.progress == 0 ? null : state.progress,
              ),
            ),
            onPressed: null,
            label: lable,
          )
        : FilledButton(
            onPressed: () {
              ref.read(provider.notifier).download();
            },
            child: lable,
          );
  }
}
