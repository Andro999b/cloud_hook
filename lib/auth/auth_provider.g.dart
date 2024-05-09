// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authHash() => r'9a12133dad8c394f93636e7013724bf66dc25819';

/// See also [auth].
@ProviderFor(auth)
final authProvider = AutoDisposeProvider<Auth>.internal(
  auth,
  name: r'authProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthRef = AutoDisposeProviderRef<Auth>;
String _$userHash() => r'b798a76a0d8a63bd2e090e5146c752d1f013f9a9';

/// See also [user].
@ProviderFor(user)
final userProvider = AutoDisposeStreamProvider<User?>.internal(
  user,
  name: r'userProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UserRef = AutoDisposeStreamProviderRef<User?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
