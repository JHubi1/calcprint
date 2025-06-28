import 'package:flutter/material.dart';

class ListTileHeader extends StatelessWidget {
  final bool usePaddingTop;
  final Widget child;

  const ListTileHeader({
    super.key,
    this.usePaddingTop = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: usePaddingTop ? EdgeInsets.only(top: 8) : EdgeInsets.zero,
      child: ListTile(
        dense: true,
        title: DefaultTextStyle(
          style: (Theme.of(context).textTheme.titleSmall ??
                  DefaultTextStyle.of(context).style)
              .copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
          child: child,
        ),
      ),
    );
  }
}

class ListTilePadding extends StatelessWidget {
  final bool useSpecificationPadding;
  final bool usePaddingRight;
  final bool usePaddingTop;
  final bool usePaddingBottom;
  final Widget child;

  const ListTilePadding({
    super.key,
    this.useSpecificationPadding = false,
    this.usePaddingRight = true,
    this.usePaddingTop = true,
    this.usePaddingBottom = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    var padding = (Theme.of(context).listTileTheme.contentPadding ??
            (Theme.of(context).useMaterial3 && useSpecificationPadding
                ? EdgeInsetsDirectional.only(start: 16.0, end: 24.0)
                : EdgeInsets.symmetric(horizontal: 16.0)))
        .add(
          EdgeInsets.symmetric(
            vertical: 2 * (ListTileTheme.of(context).minVerticalPadding ?? 4),
          ),
        );
    if (!usePaddingRight) {
      padding = padding.subtract(
        EdgeInsets.only(
          right:
              Theme.of(context).listTileTheme.contentPadding?.horizontal ??
              ((Theme.of(context).useMaterial3 && useSpecificationPadding)
                  ? 24
                  : 16),
        ),
      );
    }
    if (!usePaddingTop) {
      padding = padding.subtract(
        EdgeInsets.only(
          top: 2 * (ListTileTheme.of(context).minVerticalPadding ?? 4),
        ),
      );
    }
    if (!usePaddingBottom) {
      padding = padding.subtract(
        EdgeInsets.only(
          bottom: 2 * (ListTileTheme.of(context).minVerticalPadding ?? 4),
        ),
      );
    }
    return Padding(padding: padding, child: child);
  }
}
