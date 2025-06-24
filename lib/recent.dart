import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

class Recent {
  static void updateUrl(String url) async {
    if (kIsWeb) {
      final composedUrl = Uri.parse(url);
      var newUrl = Uri.parse(
        web.window.location.href,
      ).removeFragment().replace(queryParameters: composedUrl.queryParameters);

      if (newUrl.queryParameters.isEmpty) {
        // no integrated function to remove query parameters
        newUrl = Uri(
          scheme: newUrl.scheme,
          userInfo: newUrl.userInfo,
          host: newUrl.host,
          port: newUrl.port,
          path: newUrl.path,
          query: null,
        );
      }

      web.window.history.replaceState(
        {"path": newUrl.toString()}.jsify(),
        "",
        newUrl.toString(),
      );
    } else {
      if (Platform.isAndroid) {
        await MethodChannel(
          "com.jhubi1.calcprint/recent",
        ).invokeMethod("updateRecent", {"url": url});
      }
    }
  }
}
