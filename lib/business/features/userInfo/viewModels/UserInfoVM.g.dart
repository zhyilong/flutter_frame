// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserInfoVM.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserInfoVM)
final userInfoVMProvider = UserInfoVMProvider._();

final class UserInfoVMProvider extends $NotifierProvider<UserInfoVM, User> {
  UserInfoVMProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userInfoVMProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userInfoVMHash();

  @$internal
  @override
  UserInfoVM create() => UserInfoVM();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(User value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<User>(value),
    );
  }
}

String _$userInfoVMHash() => r'c44868e24ef75f610717341a25a39d9a3c581f7b';

abstract class _$UserInfoVM extends $Notifier<User> {
  User build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<User, User>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<User, User>,
              User,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
