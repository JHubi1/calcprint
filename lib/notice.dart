import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'extensions.dart';

final _report = Uri.parse("https://github.com/JHubi1/calcprint/issues/new");
final _replacementText = """CalcPrint
Copyright 2025 JHubi1

The app us unable to retrieve the NOTICE file. This is likely due to it being
removed. Removing the NOTICE file is not permitted by the Apache License 2.0,
which is the license under which this app is distributed.
Removing the NOTICE file is a violation of the license and by that also a
violation of copyright law. Contact the developer and ask them to restore the
NOTICE file. If no action is taken, you're kindly asked to report this under
the following URL:

> ${_report.toString()}""";

void showNoticeDialog(
  BuildContext context, {
  bool doNavigatorPop = false,
}) async {
  String noticeText;
  bool reportError = false;

  try {
    noticeText = (await rootBundle.loadString("NOTICE")).trim();
  } catch (_) {
    noticeText = _replacementText;
    reportError = true;
  }
  if (!context.mounted) return;
  if (doNavigatorPop) Navigator.of(context).pop();

  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text("Notice"),
          content: Stack(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText(
                  noticeText,
                  style: TextStyle(fontFamily: "NotoSansMono"),
                ),
              ),
              Container(
                alignment: Alignment.topRight,
                width: double.infinity,
                child: Transform.translate(
                  offset: Offset(8, -8),
                  child: IconButton(
                    onPressed:
                        () =>
                            Clipboard.setData(ClipboardData(text: noticeText)),
                    icon: Icon(Symbols.content_copy),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            if (reportError)
              FilledButton.icon(
                onPressed: () => launchUrl(_report),
                label: Text("Report"),
                icon: Icon(Symbols.flag, fill: 1),
                style: FilledButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Close"),
            ),
          ],
          scrollable: true,
        ),
  );
}
