import 'dart:convert';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:dynamic_system_colors/dynamic_system_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pwa_install/pwa_install.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_web/web.dart' as web;

import 'screens/about.dart';
import 'services/bookmark.dart';
import 'services/calculation.dart';
import 'services/display.dart';
import 'extensions.dart';
import 'screens/install.dart';
import 'l10n/app_localizations.dart';
import 'main.gr.dart';
import 'services/model.dart';
import 'widgets/toolbar.dart';
import 'widgets/widgets.dart';

const String authority = "calcprint.com";
final seed = Random().nextInt(10);

SharedPreferencesWithCache? prefs;
final mainAppKey = GlobalKey<_MainAppState>();
PackageInfo? packageInfo;
ThemeData? themeLight;
ThemeData? themeDark;

void main() {
  usePathUrlStrategy();
  PWAInstall().setup();

  runApp(MainApp(key: mainAppKey));

  PackageInfo.fromPlatform().then((value) => packageInfo = value);
}

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.material();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, path: "/", initial: true),
    RedirectRoute(path: "*", redirectTo: "/"),
  ];

  @override
  List<AutoRouteGuard> get guards => [];
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _appRouter = AppRouter();

  @override
  void initState() {
    SharedPreferences.setPrefix("calcprint.");
    SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(),
    ).then((value) {
      prefs = value;
      if (mounted) setState(() {});
    });

    super.initState();
    if (kIsWeb) {
      web.document.getElementById("loader")?.remove();
    }
  }

  ThemeData _themeModifier(ThemeData theme) {
    return theme.copyWith(
      progressIndicatorTheme: theme.progressIndicatorTheme.copyWith(
        year2023: true,
      ),
      sliderTheme: theme.sliderTheme.copyWith(year2023: true),
      iconTheme: theme.iconTheme.copyWith(weight: 600),
    );
  }

  void changeLocale(Locale locale) {
    if (prefs == null) return;
    if (!AppLocalizations.supportedLocales.contains(locale)) return;
    prefs!.setString("locale", locale.toString());
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("assets/data/icon.png"), context);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        themeLight = _themeModifier(
          ThemeData.from(
            colorScheme:
                lightDynamic ??
                ColorScheme.fromSeed(seedColor: Color(0xFF22A543)),
          ),
        );
        themeDark = _themeModifier(
          ThemeData.from(
            colorScheme:
                darkDynamic ??
                ColorScheme.fromSeed(
                  seedColor: Color(0xFF22A543),
                  brightness: Brightness.dark,
                ),
          ),
        );

        var localeCode = prefs?.getString("locale");
        Locale? locale;
        if (localeCode != null) {
          final parts = localeCode.split("_");
          if (parts.length == 1) {
            locale = Locale(parts[0]);
          } else if (parts.length == 2) {
            locale = Locale(parts[0], parts[1]);
          }

          if (!AppLocalizations.supportedLocales.contains(locale)) {
            prefs!.remove("locale");
            locale = null;
          }
        }

        return MaterialApp.router(
          onGenerateTitle: (context) {
            return data.printoutTitle == null
                ? AppLocalizations.of(context).appTitle
                : "${data.printoutTitle} – ${AppLocalizations.of(context).appTitle}";
          },
          routerConfig: _appRouter.config(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          themeMode: ThemeMode.system,
          theme: themeLight,
          darkTheme: themeDark,
        );
      },
    );
  }
}

@RoutePage()
class HomeScreen extends StatefulWidget {
  final String? printoutTitle;
  final String? printoutFrom;
  final String? printoutTo;
  final bool? printoutKeepPrivate;
  final String? models;
  final String? currency;

  const HomeScreen({
    super.key,
    @queryParam this.printoutTitle,
    @queryParam this.printoutFrom,
    @queryParam this.printoutTo,
    @queryParam this.printoutKeepPrivate,
    @queryParam this.models,
    @queryParam this.currency,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    DataStore.resetInstanceWith(
      printoutTitle: widget.printoutTitle,
      printoutFrom: widget.printoutFrom,
      printoutTo: widget.printoutTo,
      printoutKeepPrivate: widget.printoutKeepPrivate,
      models: widget.models,
      currency: widget.currency,
    );
    data.addListener(_dataListener);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    data.removeListener(_dataListener);
  }

  void _dataListener() {
    data.reportUrlToPlatform();
    if (mounted) setState(() {});
  }

  List<Widget> get _formFields => [
    SizedBox(height: 8),
    ListTilePadding(
      child: Text(
        "Welcome to CalcPrint!\nYou can use this tool to calculate the costs of your 3D prints based on a variety of factors. ${Display.from(context).isPhone ? "Press the button below to view and share your result." : "Simply fill out the fields below, and the calculations will be displayed in the table on the left."}",
      ),
    ),

    ListTileHeader(child: Text("Printout")),
    ListTilePadding(
      child: TextFormField(
        controller: data.printoutTitleController,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          label: Text("Title"),
          border: OutlineInputBorder(),
          helperText:
              "The title shown on the printout. Should be related to the print.",
          hintText:
              [
                "Banana Phone Holder",
                "Miniature Viking Duck",
                "Toothpaste Squeezer 3000",
                "Catapult for Office Wars",
                "Emergency Pizza Cutter",
                "Tiny Desk Cactus",
                "Rocket-Powered Paperclip",
                "Unicorn Horn for Cats",
                "Spaghetti Measuring Tool",
                "Wobbly Chess Knight",
              ][seed],
        ),
        autovalidateMode: AutovalidateMode.always,
        validator: (value) {
          if (value?.isEmpty ?? true) return null;
          if (value!.length < 3) {
            return "Must be at least 3 characters long.";
          }
          return null;
        },
      ),
    ),
    ListTilePadding(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: TextFormField(
              controller: data.printoutFromController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                label: Text("From"),
                border: OutlineInputBorder(),
                helperText: "The person printing the print.",
                hintText: "You",
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: data.printoutToController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                label: Text("To"),
                border: OutlineInputBorder(),
                helperText: "The recipient of the printout.",
                hintText: "The Boss",
              ),
            ),
          ),
        ],
      ),
    ),
    SwitchListTile(
      value: data.printoutKeepPrivateRaw,
      onChanged:
          (v) => setState(() {
            data.printoutKeepPrivateRaw = v;
            data.reportUrlToPlatform();
          }),
      title: Text("Keep calculations private"),
      subtitle: Text(
        "If enabled, the calculations will not be shown on the printout.",
      ),
      thumbIcon: WidgetStateProperty<Icon?>.fromMap({
        WidgetState.selected: Icon(Symbols.check),
      }),
    ),

    ListTileHeader(child: Text("Models")),
    ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              setState(() {
                data.models.add(ModelControllers());
                data.reportUrlToPlatform();
              });
            },
            label: Text("Add model"),
            icon: Icon(Symbols.add),
          ),
          SizedBox(width: 8),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 250),
            switchInCurve: Curves.fastEaseInToSlowEaseOut,
            switchOutCurve: Curves.fastEaseInToSlowEaseOut.flipped,
            child:
                !data.isModelsModified
                    ? null
                    : TextButton.icon(
                      onPressed: () {
                        final oldModels = List<ModelControllers>.from(
                          data.models,
                        );
                        setState(() {
                          data.models = [ModelControllers()];
                          data.reportUrlToPlatform();
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            width: Display.from(context).isPhone ? null : 288,
                            content: Text("All models have been reset."),
                            action: SnackBarAction(
                              label: "Undo",
                              onPressed: () {
                                if (!data.isModelsModified) {
                                  setState(() {
                                    data.models = oldModels;
                                    _dataListener();
                                  });
                                }
                                ScaffoldMessenger.of(
                                  context,
                                ).hideCurrentSnackBar();
                              },
                            ),
                          ),
                        );
                      },
                      label: Text("Reset models"),
                      icon: Icon(Symbols.delete_sweep),
                    ),
          ),
        ],
      ),
    ),

    SizedBox(height: 4),
    AnimatedSize(
      duration: Duration(milliseconds: 250),
      curve: Curves.fastEaseInToSlowEaseOut,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:
            data.models
                .map(
                  (model) => ModelForm(
                    model: model,
                    onRender: _dataListener,
                    onRemove:
                        (data.models.length == 1)
                            ? null
                            : () => setState(() {
                              data.models.remove(model);
                              data.reportUrlToPlatform();
                            }),
                  ),
                )
                .toList(),
      ),
    ),
    SizedBox(height: 4),

    SizedBox(height: kIsWeb ? 12 : 16),
  ];

  @override
  Widget build(BuildContext context) {
    final appBarDesktop =
        Display.from(context).isPhone ||
        (MediaQuery.sizeOf(context).width >= 1250);
    final appBar = AppBar(
      automaticallyImplyLeading: false,
      title: Text(AppLocalizations.of(context).appTitle),
      backgroundColor: appBarDesktop ? Colors.transparent : null,
      scrolledUnderElevation: appBarDesktop ? 0 : null,
      actions: [
        kIsWeb && InstallDialog.isBrowser
            ? Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                onPressed: () => showInstallDialog(context: context),
                icon: Icon(Symbols.install_desktop),
              ),
            )
            : SizedBox.shrink(),
        IconButton(
          tooltip: "Bookmarks",
          onPressed: () {
            _scaffoldKey.currentState?.openEndDrawer();
          },
          icon: Icon(Symbols.bookmarks),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            tooltip: "About CalcPrint",
            onPressed: () async {
              showAppDialog(context: context);
            },
            icon: Icon(Symbols.info),
          ),
        ),
      ],
    );

    final cardContent = Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        if (Display.from(context).moreEqualTablet) ...[
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(
                      context,
                    ).copyWith(scrollbars: false),
                    child: SingleChildScrollView(child: CalculationTable()),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ClipRRect(
                        child: AnimatedSlide(
                          offset: Offset(data.isModified ? 0 : 1, 0),
                          duration: Duration(milliseconds: 250),
                          curve: Curves.fastEaseInToSlowEaseOut,
                          child: Card.filled(
                            color: Theme.of(context).colorScheme.surface,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ToolbarButtonBookmark(),
                                  ToolbarButtonReset(
                                    onUpdate: () => setState(() {}),
                                  ),
                                  ToolbarButtonShare(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          VerticalDivider(width: 1),
        ],

        Expanded(
          child: Form(
            key: _formKey,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  if (Display.from(context).isPhone) appBar,
                  ..._formFields,
                ],
              ),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: appBarDesktop,
      appBar:
          Display.from(context).moreEqualTablet
              ? appBar
              // this is a pretty hacky workaround, but AnnotatedRegion doesn't
              // seem to do anything and otherwise the icons are always white in
              // the status bar (on android at least)
              : AppBar(
                toolbarHeight: 0,
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                systemOverlayStyle:
                    Theme.of(context).colorScheme.brightness == Brightness.dark
                        ? SystemUiOverlayStyle.light
                        : SystemUiOverlayStyle.dark,
              ),
      body: Center(
        child: ConstrainedBox(
          constraints:
              Display.from(context).moreEqualTablet
                  ? BoxConstraints(maxWidth: 1024, maxHeight: 768)
                  : BoxConstraints(),
          child:
              Display.from(context).moreEqualTablet
                  ? Card.outlined(child: cardContent)
                  : cardContent,
        ),
      ),
      endDrawerEnableOpenDragGesture: false,
      endDrawer: _HomeScreenDrawer(
        scaffoldKey: _scaffoldKey,
        onUpdate: () {
          if (mounted) setState(() {});
        },
      ),
      bottomNavigationBar:
          Display.from(context).isPhone
              ? Container(
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: AnimatedSize(
                  duration: Duration(milliseconds: 250),
                  curve:
                      data.isModified
                          ? Curves.fastEaseInToSlowEaseOut
                          : Curves.fastEaseInToSlowEaseOut.flipped,
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: data.isModified ? null : 0,
                    padding:
                        data.isModified
                            ? null
                            : EdgeInsets.only(top: 8, bottom: 8),
                    child: BottomAppBar(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ToolbarButtonBookmark(),
                          ToolbarButtonReset(onUpdate: () => setState(() {})),
                          ToolbarButtonShare(),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      floatingActionButton:
          Display.from(context).isPhone && data.isModified
              ? _HomeScreenFab(
                calculationTable: CalculationTable(),
                url: data.url,
              )
              : null,
    );
  }
}

class _HomeScreenDrawer extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final void Function() onUpdate;

  const _HomeScreenDrawer({required this.scaffoldKey, required this.onUpdate});

  @override
  State<_HomeScreenDrawer> createState() => _HomeScreenDrawerState();
}

class _HomeScreenDrawerState extends State<_HomeScreenDrawer> {
  final Bookmarks _bookmarks = Bookmarks();

  @override
  void initState() {
    super.initState();
    _bookmarks.addListener(_bookmarkListener);
  }

  @override
  void dispose() {
    _bookmarks.removeListener(_bookmarkListener);
    super.dispose();
  }

  void _bookmarkListener() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView(
          children: [
            ListTileHeader(child: Text("Bookmarks")),

            AnimatedSwitcher(
              duration: Duration(milliseconds: 250),
              switchInCurve: Curves.fastEaseInToSlowEaseOut,
              child:
                  (_bookmarks.getBookmarkCount() == 0)
                      ? ListTile(
                        style: ListTileStyle.drawer,
                        title: Text(
                          "No stored bookmarks.",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      )
                      : null,
            ),
            ...List.generate(_bookmarks.getBookmarkCount(), (index) {
              final bookmark =
                  _bookmarks.getBookmarkAt(index) ?? bookmarkRecordEmpty;
              final bookmarkParsed = jsonDecode(bookmark.array);
              return Dismissible(
                key: UniqueKey(),
                onDismissed: (_) {
                  _bookmarks.removeBookmark(bookmark.array);
                  widget.onUpdate();
                },
                direction: DismissDirection.startToEnd,
                child: ListTile(
                  style: ListTileStyle.drawer,
                  isThreeLine: true,
                  title: Text(
                    bookmarkParsed["printoutTitle"] ?? "Untitled Project",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle:
                      (bookmarkParsed["printoutFrom"] != null ||
                              bookmarkParsed["printoutTo"] != null ||
                              bookmarkParsed["models"] != null)
                          ? Builder(
                            builder: (context) {
                              var tmp = "";
                              final parts = [];
                              if (bookmarkParsed["printoutFrom"] != null) {
                                parts.add(
                                  "From: ${bookmarkParsed["printoutFrom"]}",
                                );
                              }
                              if (bookmarkParsed["printoutTo"] != null) {
                                parts.add(
                                  "To: ${bookmarkParsed["printoutTo"]}",
                                );
                              }
                              tmp += parts.join(" – ");

                              if (bookmarkParsed["models"] != null) {
                                tmp +=
                                    "\nModels: ${List<Map>.from(bookmarkParsed["models"]).map((e) => "“${e["name"] ?? "Untitled"}”").join(", ")}";
                              }

                              return Text(
                                tmp.trim(),
                                softWrap: true,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          )
                          : null,
                  trailing: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 64),
                    child: Text(
                      GetTimeAgo.parse(
                        bookmark.date,
                        locale: AppLocalizations.of(context).localeName,
                      ),
                      textAlign: TextAlign.end,
                      softWrap: true,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  onTap: () {
                    DataStore.resetInstanceWith(
                      printoutTitle: bookmarkParsed["printoutTitle"],
                      printoutFrom: bookmarkParsed["printoutFrom"],
                      printoutTo: bookmarkParsed["printoutTo"],
                      printoutKeepPrivate:
                          bookmarkParsed["printoutKeepPrivate"],
                      models: jsonEncode(
                        bookmarkParsed["models"] ?? [],
                      ).orNullOnDefault("[]"),
                    );
                    widget.onUpdate();
                    widget.scaffoldKey.currentState?.closeEndDrawer();
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _HomeScreenFab extends StatelessWidget {
  final CalculationTable calculationTable;
  final Uri url;

  const _HomeScreenFab({required this.calculationTable, required this.url});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: data.isModified ? 0 : null,
      onPressed:
          () => showModalBottomSheet(
            context: context,
            builder:
                (context) => Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  child: Center(
                    heightFactor: 1,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [calculationTable],
                    ),
                  ),
                ),
          ),
      child: Icon(Symbols.publish),
    );
  }
}
