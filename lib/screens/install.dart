import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart' hide LaunchMode;

class InstallDialog extends StatelessWidget {
  const InstallDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Install CalcPrint"),
      icon: Icon(Icons.install_desktop),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Symbols.android),
            title: Text("Android"),
            subtitle: Text("Install the Android app from GitHub as an APK."),
            onTap:
                () => launchUrl(
                  Uri.parse(
                    "https://github.com/JHubi1/calcprint/releases/latest",
                  ),
                ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed:
              Navigator.of(context).canPop()
                  ? () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  }
                  : null,
          child: Text("Got it"),
        ),
      ],
      scrollable: true,
    );
  }
}

void showInstallDialog({required BuildContext context}) {
  showDialog(
    context: context,
    builder: (BuildContext context) => InstallDialog(),
  );
}
