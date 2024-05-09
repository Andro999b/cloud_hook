import 'package:cloud_hook/utils/logger.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ErrorProviderObserver extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    logger.e("Provider $provider fails", error: error, stackTrace: stackTrace);
  }
}
