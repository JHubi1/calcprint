import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:share_plus/share_plus.dart';

import 'bookmark.dart';
import 'display.dart';
import 'main.dart';
import 'model.dart';

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
        DataStore.newInstanceWith();
        widget.onUpdate();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            width: Display.from(context).isPhone ? null : 288,
            content: Text("Form data has been cleared."),
            action: SnackBarAction(
              label: "Undo",
              onPressed: () {
                if (!data.isModified && mounted) {
                  setState(() {
                    final tmp = jsonDecode(oldModels) as Map<String, dynamic>;
                    DataStore.newInstanceWith(
                      printoutTitle: tmp["printoutTitle"] as String?,
                      printoutFrom: tmp["printoutFrom"] as String?,
                      printoutTo: tmp["printoutTo"] as String?,
                      printoutKeepPrivate: tmp["printoutKeepPrivate"] as bool?,
                      models: jsonEncode(tmp["models"]),
                    );
                    widget.onUpdate();
                  });
                }
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
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

        final image = QrImage(
          QrCode.fromData(
            data: data.url.toString(),
            errorCorrectLevel: QrErrorCorrectLevel.M,
          ),
        );
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
                    onLongPress: () async {
                      SharePlus.instance.share(
                        ShareParams(
                          files: [
                            XFile.fromData(
                              (await image.toImageAsBytes(
                                size: 512,
                                decoration: PrettyQrDecoration(
                                  shape: PrettyQrSmoothSymbol(
                                    color: themeLight!.colorScheme.primary,
                                  ),
                                  quietZone: const PrettyQrModulesQuietZone(4),
                                  background: themeLight!.colorScheme.surface,
                                ),
                              ))!.buffer.asUint8List(),
                              mimeType: "image/png",
                              name: "calcprintProjectQrcode.png",
                            ),
                          ],
                        ),
                      );
                    },
                    child: PrettyQrView(
                      qrImage: image,
                      decoration: PrettyQrDecoration(
                        shape: PrettyQrSmoothSymbol(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        );
      },
      icon: Transform.flip(flipX: true, child: Icon(Symbols.reply)),
    );
  }
}
