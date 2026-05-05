// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reference_data_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allDiseasesHash() => r'b86490551017567acbc187a2daebdfd30d0b13ae';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [allDiseases].
@ProviderFor(allDiseases)
const allDiseasesProvider = AllDiseasesFamily();

/// See also [allDiseases].
class AllDiseasesFamily extends Family<AsyncValue<List<Disease>>> {
  /// See also [allDiseases].
  const AllDiseasesFamily();

  /// See also [allDiseases].
  AllDiseasesProvider call({required String gender}) {
    return AllDiseasesProvider(gender: gender);
  }

  @override
  AllDiseasesProvider getProviderOverride(
    covariant AllDiseasesProvider provider,
  ) {
    return call(gender: provider.gender);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'allDiseasesProvider';
}

/// See also [allDiseases].
class AllDiseasesProvider extends FutureProvider<List<Disease>> {
  /// See also [allDiseases].
  AllDiseasesProvider({required String gender})
    : this._internal(
        (ref) => allDiseases(ref as AllDiseasesRef, gender: gender),
        from: allDiseasesProvider,
        name: r'allDiseasesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$allDiseasesHash,
        dependencies: AllDiseasesFamily._dependencies,
        allTransitiveDependencies: AllDiseasesFamily._allTransitiveDependencies,
        gender: gender,
      );

  AllDiseasesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gender,
  }) : super.internal();

  final String gender;

  @override
  Override overrideWith(
    FutureOr<List<Disease>> Function(AllDiseasesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AllDiseasesProvider._internal(
        (ref) => create(ref as AllDiseasesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gender: gender,
      ),
    );
  }

  @override
  FutureProviderElement<List<Disease>> createElement() {
    return _AllDiseasesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AllDiseasesProvider && other.gender == gender;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gender.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AllDiseasesRef on FutureProviderRef<List<Disease>> {
  /// The parameter `gender` of this provider.
  String get gender;
}

class _AllDiseasesProviderElement extends FutureProviderElement<List<Disease>>
    with AllDiseasesRef {
  _AllDiseasesProviderElement(super.provider);

  @override
  String get gender => (origin as AllDiseasesProvider).gender;
}

String _$allTraumasHash() => r'fe09eab82c2bf94f327ba79c59dd2a0015fdb060';

/// See also [allTraumas].
@ProviderFor(allTraumas)
final allTraumasProvider = FutureProvider<List<Map<String, dynamic>>>.internal(
  allTraumas,
  name: r'allTraumasProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allTraumasHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllTraumasRef = FutureProviderRef<List<Map<String, dynamic>>>;
String _$allActivitiesHash() => r'0ebaba1039d6b49749711eab282ca8034a5448ec';

/// See also [allActivities].
@ProviderFor(allActivities)
final allActivitiesProvider =
    FutureProvider<List<Map<String, dynamic>>>.internal(
      allActivities,
      name: r'allActivitiesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allActivitiesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllActivitiesRef = FutureProviderRef<List<Map<String, dynamic>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
