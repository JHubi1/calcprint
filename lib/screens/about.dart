import 'dart:math';

import 'package:country_flags/country_flags.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:strgad/strgad.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/gitbaker.g.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import 'notice.dart';

final Uri localizationUrl = Uri.parse("");

class AppDialog extends StatefulWidget {
  const AppDialog({super.key});

  @override
  State<AppDialog> createState() => _AppDialogState();
}

class _AppDialogState extends State<AppDialog> {
  PackageInfo get data =>
      packageInfo ??
      PackageInfo(
        appName: "–",
        packageName: "–",
        version: "–",
        buildNumber: "",
      );

  @override
  Widget build(BuildContext context) {
    final currentLocale =
        prefs!.getString("locale") ?? AppLocalizations.of(context).localeName;
    return AboutDialog(
      applicationName: AppLocalizations.of(context).appTitle,
      applicationVersion:
          "v${data.version}${data.buildNumber.isNotEmpty ? "+" : ""}${data.buildNumber}"
          "\n(${GitBaker.currentBranch.commits.last.hash.substring(0, 7)}@${GitBaker.currentBranch.name})",
      applicationIcon: Image.asset(
        "assets/data/icon.png",
        width: 96,
        height: 96,
      ),
      applicationLegalese: "Copyright 2025 JHubi1",
      children: [
        SizedBox(height: 8),
        ListTile(
          dense: true,
          leading: Icon(Symbols.favorite, fill: 1),
          title: Text(
            "Built with love, for the 3D Printing Community as an Open Source project.",
          ),
        ),
        ListTile(
          dense: true,
          leading: ImageIcon(AssetImage("assets/data/github.png")),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("GitHub Repository"),
              Transform.translate(
                offset: Offset(4, -1),
                child: Icon(Symbols.open_in_new, size: 16),
              ),
            ],
          ),
          subtitle: Text(
            "Report issues, snoop around, and get the source code.",
          ),
          onTap:
              () => launchUrl(Uri.parse("https://github.com/JHubi1/calcprint")),
          onLongPress: () => showNoticeDialog(context, doNavigatorPop: true),
        ),
        kIsWeb
            ? SearchAnchor(
              textInputAction: TextInputAction.search,
              viewHintText: "Select a language",
              viewLeading: IconButton(
                style: const ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Symbols.close),
              ),
              viewTrailing: [
                // IconButton(
                //   tooltip: "Help translate",
                //   onPressed: () => launchUrl(Uri.parse("")),
                //   icon: Icon(Symbols.crowdsource),
                // ),
              ],
              viewConstraints: const BoxConstraints(maxHeight: 250),
              suggestionsBuilder: (context, controller) async {
                final locales = <String, String>{};
                for (var locale in AppLocalizations.supportedLocales) {
                  locales[locale.languageCode] =
                      (await AppLocalizations.delegate.load(
                        locale,
                      )).languageName;
                }

                final input = controller.text.toLowerCase();
                locales.removeWhere(
                  (key, value) =>
                      !(key.toLowerCase().contains(input) ||
                          value.toLowerCase().contains(input)) &&
                      !(value.toLowerCase().levenshteinDistance(input) <=
                          max(value.length * 0.2, 2)),
                );

                if (locales.isEmpty) {
                  return [
                    ListTile(
                      title: Text("No languages found"),
                      subtitle: Text("Try a different search term."),
                    ),
                  ];
                }

                final widgets = <ListTile>[];
                for (var code in locales.keys.toList()..sort()) {
                  final selected = code == currentLocale;
                  widgets.add(
                    ListTile(
                      selected: selected,
                      leading: _FlagLeading(locale: code, isSelected: selected),
                      title: Text(locales[code]!),
                      onTap: () {
                        mainAppKey.currentState?.changeLocale(Locale(code));
                        controller.closeView(null);
                      },
                    ),
                  );
                }

                return widgets;
              },
              builder:
                  (context, controller) => ListTile(
                    dense: true,
                    leading: AnimatedSwitcher(
                      duration: Duration(milliseconds: 250),
                      switchInCurve: Curves.fastEaseInToSlowEaseOut,
                      child: _FlagLeading(
                        key: ValueKey(currentLocale),
                        locale: currentLocale,
                      ),
                    ),
                    title: Text(AppLocalizations.of(context).languageName),

                    subtitle: Text(
                      "Language used in this app. Click to change.",
                    ),
                    onTap: () => controller.openView(),
                  ),
            )
            // : ListTile(
            //   leading: Icon(Symbols.crowdsource),
            //   title: Text("Help translate"),
            //   subtitle: Text("Help translate this app to your language."),
            //   onTap: () => launchUrl(Uri.parse("")),
            // ),
            : SizedBox.shrink(),
      ],
    );
  }
}

class _FlagLeading extends StatelessWidget {
  final String locale;
  final bool isSelected;

  const _FlagLeading({
    super.key,
    required this.locale,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      child: AspectRatio(
        aspectRatio: 1,
        child: Badge(
          isLabelVisible: isSelected,
          backgroundColor: Theme.of(context).colorScheme.primary,
          label: Transform.scale(
            scale: 1.2,
            child: Icon(
              Symbols.check,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 8,
            ),
          ),
          child: CountryFlag.fromLanguageCode(locale, shape: Circle()),
        ),
      ),
    );
  }
}

void showAppDialog({required BuildContext context}) {
  showDialog(context: context, builder: (_) => AppDialog());
}
