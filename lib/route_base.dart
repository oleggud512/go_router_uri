import 'package:get_it/get_it.dart';

final _routeStore = GetIt.asNewInstance();

class AppSubPath<Self extends AppSubPath<Self>> {
  final AppSubPath? parent;
  final String? segment;

  AppSubPath(this.parent, {this.segment});

  Self get br => _routeStore(param1: null);

  T route<T extends AppSubPath<T>>(String segment) {
    return _routeStore<T>(param1: AppSubPath<Self>(this, segment: segment));
  }

  AppSubPathParam<T> param<T extends AppSubPath<T>>(String paramName) {
    return AppSubPathParam<T>(this, paramName: paramName);
  }

  AppSubPath<Self> leafRoute(String segment) =>
      AppSubPath(this, segment: segment);

  AppSubPathParam<LeafSubPath> leafParam(String paramName) {
    return AppSubPathParam<LeafSubPath>(this, paramName: paramName);
  }

  Uri get uri => Uri.parse(path);

  String get path {
    final segments = <String>[];

    AppSubPath? cursor = this;

    while (cursor != null) {
      final segment = cursor.segment;
      if (segment != null) {
        segments.insert(0, segment);
      }
      cursor = cursor.parent;
    }

    final res = segments.join('/');
    if (res.isEmpty) return '/';

    return res;
  }

  @override
  String toString() {
    return 'AppSubPath(segment=$segment)';
  }
}

class AppSubPathParam<T extends AppSubPath<T>> extends AppSubPath<T> {
  final String paramName;

  AppSubPathParam(super.parent, {required this.paramName})
    : super(segment: ':$paramName');

  T call([String? value]) => _routeStore<T>(
    param1: value != null ? AppSubPath<T>(parent, segment: value) : this,
  );
}

class LeafSubPath extends AppSubPath<LeafSubPath> {
  LeafSubPath(super.parent);
}

class RootSubPath extends AppSubPath<RootSubPath> {
  RootSubPath() : super(null, segment: '');

  void register<T extends AppSubPath<T>>(
    T Function(AppSubPath? parent) create,
  ) {
    _routeStore.registerFactoryParam<T, dynamic, AppSubPath?>(
      (p1, _) => create(p1),
    );
  }
}
