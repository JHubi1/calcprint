// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i2;
import 'package:calcprint/main.dart' as _i1;
import 'package:flutter/foundation.dart' as _i3;

/// generated route for
/// [_i1.HomeScreen]
class HomeRoute extends _i2.PageRouteInfo<HomeRouteArgs> {
  HomeRoute({
    _i3.Key? key,
    String? printoutTitle,
    String? printoutFrom,
    String? printoutTo,
    bool? printoutKeepPrivate,
    String? models,
    List<_i2.PageRouteInfo>? children,
  }) : super(
         HomeRoute.name,
         args: HomeRouteArgs(
           key: key,
           printoutTitle: printoutTitle,
           printoutFrom: printoutFrom,
           printoutTo: printoutTo,
           printoutKeepPrivate: printoutKeepPrivate,
           models: models,
         ),
         rawQueryParams: {
           'printoutTitle': printoutTitle,
           'printoutFrom': printoutFrom,
           'printoutTo': printoutTo,
           'printoutKeepPrivate': printoutKeepPrivate,
           'models': models,
         },
         initialChildren: children,
       );

  static const String name = 'HomeRoute';

  static _i2.PageInfo page = _i2.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<HomeRouteArgs>(
        orElse:
            () => HomeRouteArgs(
              printoutTitle: queryParams.optString('printoutTitle'),
              printoutFrom: queryParams.optString('printoutFrom'),
              printoutTo: queryParams.optString('printoutTo'),
              printoutKeepPrivate: queryParams.optBool('printoutKeepPrivate'),
              models: queryParams.optString('models'),
            ),
      );
      return _i1.HomeScreen(
        key: args.key,
        printoutTitle: args.printoutTitle,
        printoutFrom: args.printoutFrom,
        printoutTo: args.printoutTo,
        printoutKeepPrivate: args.printoutKeepPrivate,
        models: args.models,
      );
    },
  );
}

class HomeRouteArgs {
  const HomeRouteArgs({
    this.key,
    this.printoutTitle,
    this.printoutFrom,
    this.printoutTo,
    this.printoutKeepPrivate,
    this.models,
  });

  final _i3.Key? key;

  final String? printoutTitle;

  final String? printoutFrom;

  final String? printoutTo;

  final bool? printoutKeepPrivate;

  final String? models;

  @override
  String toString() {
    return 'HomeRouteArgs{key: $key, printoutTitle: $printoutTitle, printoutFrom: $printoutFrom, printoutTo: $printoutTo, printoutKeepPrivate: $printoutKeepPrivate, models: $models}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HomeRouteArgs) return false;
    return key == other.key &&
        printoutTitle == other.printoutTitle &&
        printoutFrom == other.printoutFrom &&
        printoutTo == other.printoutTo &&
        printoutKeepPrivate == other.printoutKeepPrivate &&
        models == other.models;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      printoutTitle.hashCode ^
      printoutFrom.hashCode ^
      printoutTo.hashCode ^
      printoutKeepPrivate.hashCode ^
      models.hashCode;
}
