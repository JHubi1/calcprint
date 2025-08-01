import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:share_plus/share_plus.dart';

import '../main.dart';
import '../services/bookmark.dart';
import '../services/display.dart';
import '../services/model.dart';

class ToolbarButtonBookmark extends StatefulWidget {
  const ToolbarButtonBookmark({super.key});

  @override
  State<ToolbarButtonBookmark> createState() => _ToolbarButtonBookmarkState();
}

class _ToolbarButtonBookmarkState extends State<ToolbarButtonBookmark> {
  final Bookmarks _bookmarks = Bookmarks();
  double offsetX = 0;

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

  void _animateOffset() async {
    offsetX = -0.3;
    if (mounted) setState(() {});
    await Future.delayed(const Duration(milliseconds: 150));
    offsetX = 0;
    if (mounted) setState(() {});
  }

  bool get isBookmarked {
    return _bookmarks.getBookmark() != null;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: isBookmarked ? "Remove bookmark" : "Add bookmark",
      onPressed: () {
        if (!data.isModified) return;
        if (isBookmarked) {
          _bookmarks.removeBookmark();
        } else {
          _bookmarks.addBookmark();
          _animateOffset();
        }
      },
      icon: AnimatedSlide(
        offset: Offset(0, offsetX),
        curve: Curves.fastEaseInToSlowEaseOut,
        duration: const Duration(milliseconds: 100),
        child: Icon(
          isBookmarked ? Symbols.bookmark : Symbols.bookmark_add,
          fill: isBookmarked ? 1 : 0,
        ),
      ),
    );
  }
}

class ToolbarButtonReset extends StatefulWidget {
  final void Function() onUpdate;

  const ToolbarButtonReset({super.key, required this.onUpdate});

  @override
  State<ToolbarButtonReset> createState() => _ToolbarButtonResetState();
}

class _ToolbarButtonResetState extends State<ToolbarButtonReset> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: "Clear form data",
      onPressed: () {
        if (!data.isModified) return;

        final oldModels = data.toJson();
        DataStore.resetInstanceWith();
        widget.onUpdate();

        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            width: Display.from(context).isPhone ? null : 288,
            content: Text("Form data has been cleared."),
            action: SnackBarAction(
              label: "Undo",
              onPressed: () {
                if (!data.isModified) {
                  final tmp = jsonDecode(oldModels) as Map<String, dynamic>;
                  DataStore.resetInstanceWith(
                    printoutTitle: tmp["printoutTitle"] as String?,
                    printoutFrom: tmp["printoutFrom"] as String?,
                    printoutTo: tmp["printoutTo"] as String?,
                    printoutKeepPrivate: tmp["printoutKeepPrivate"] as bool?,
                    models: jsonEncode(tmp["models"]),
                  );
                  widget.onUpdate();
                  if (mounted) setState(() {});
                }
                messenger.hideCurrentSnackBar();
              },
            ),
          ),
        );
      },
      icon: Icon(Symbols.restart_alt),
    );
  }
}

class ToolbarButtonShare extends StatelessWidget {
  const ToolbarButtonShare({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: "Share project",
      onPressed: () {
        if (!data.isModified) return;
        SharePlus.instance.share(ShareParams(uri: data.url));
      },
      onLongPress: () {
        if (!data.isModified) return;

        QrImage? image;
        bool tooBig = false;
        try {
          image = QrImage(
            QrCode.fromData(
              data: data.url.toString(),
              errorCorrectLevel: QrErrorCorrectLevel.M,
            ),
          );
        } on InputTooLongException catch (_) {
          tooBig = true;
        }
        final emblem = AssetImage("assets/data/emblem.png");
        final colorScheme = Theme.of(context).colorScheme;

        showModalBottomSheet(
          context: context,
          builder:
              (context) => Container(
                width: double.infinity,
                padding: EdgeInsets.all(64),
                child: Center(
                  heightFactor: 1,
                  child: InkWell(
                    hoverColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    onLongPress:
                        (image != null)
                            ? () async {
                              final colorScheme = ColorScheme.fromSeed(
                                seedColor: fallbackColor,
                              );
                              SharePlus.instance.share(
                                ShareParams(
                                  files: [
                                    XFile.fromData(
                                      (await image!.toImageAsBytes(
                                        size: 512,
                                        decoration: PrettyQrDecoration(
                                          image: PrettyQrDecorationImage(
                                            image: emblem,
                                            filterQuality: FilterQuality.medium,
                                            colorFilter: ColorFilter.mode(
                                              colorScheme.primary,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          shape: PrettyQrSmoothSymbol(
                                            color: colorScheme.primary,
                                          ),
                                          quietZone:
                                              const PrettyQrModulesQuietZone(4),
                                          background: colorScheme.surface,
                                        ),
                                      ))!.buffer.asUint8List(),
                                      mimeType: "image/png",
                                      name:
                                          "calcprintProjectQrcode${data.printoutTitle != null ? "-${data.printoutTitle!.replaceAll(" ", "_")}" : ""}.png",
                                    ),
                                  ],
                                  downloadFallbackEnabled: false,
                                ),
                              );
                            }
                            : null,
                    child:
                        (image != null)
                            ? PrettyQrView(
                              qrImage: image,
                              decoration: PrettyQrDecoration(
                                image: PrettyQrDecorationImage(
                                  image: emblem,
                                  filterQuality: FilterQuality.medium,
                                  colorFilter: ColorFilter.mode(
                                    colorScheme.primary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                shape: PrettyQrSmoothSymbol(
                                  color: colorScheme.primary,
                                ),
                              ),
                            )
                            : tooBig
                            ? Text("Input too long to generate QR code.")
                            : Text("Unable to generate QR code."),
                  ),
                ),
              ),
        );
      },
      icon: Transform.flip(flipX: true, child: Icon(Symbols.reply)),
    );
  }
}
