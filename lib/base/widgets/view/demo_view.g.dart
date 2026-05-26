// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'demo_view.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Demo 数据 Notifier（使用 @riverpod 注解）

@ProviderFor(DemoNotifier)
final demoProvider = DemoNotifierProvider._();

/// Demo 数据 Notifier（使用 @riverpod 注解）
final class DemoNotifierProvider
    extends $NotifierProvider<DemoNotifier, DemoData> {
  /// Demo 数据 Notifier（使用 @riverpod 注解）
  DemoNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'demoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$demoNotifierHash();

  @$internal
  @override
  DemoNotifier create() => DemoNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DemoData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DemoData>(value),
    );
  }
}

String _$demoNotifierHash() => r'7b587fb7e82a847a9b41b48d90b994ea3cc8e211';

/// Demo 数据 Notifier（使用 @riverpod 注解）

abstract class _$DemoNotifier extends $Notifier<DemoData> {
  DemoData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DemoData, DemoData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DemoData, DemoData>,
              DemoData,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
