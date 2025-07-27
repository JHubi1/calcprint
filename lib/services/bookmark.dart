import 'package:flutter/widgets.dart';

import '../main.dart';
import 'model.dart';

typedef BookmarkRecord = ({DateTime date, String array});
final BookmarkRecord bookmarkRecordEmpty = (
  date: DateTime.fromMillisecondsSinceEpoch(0),
  array: "{}",
);

class Bookmarks extends ChangeNotifier {
  String get _key => "bookmarks";

  int getBookmarkCount() {
    return prefs?.getStringList(_key)?.length ?? 0;
  }

  BookmarkRecord? getBookmark([String? array]) {
    final bookmarks = prefs?.getStringList(_key) ?? [];
    array ??= data.toJson();

    try {
      final res = bookmarks
          .singleWhere((e) => e.split(";").first == array)
          .split(";");
      return (
        date: DateTime.fromMillisecondsSinceEpoch(int.parse(res[1])),
        array: res[0],
      );
    } catch (_) {
      return null;
    }
  }

  BookmarkRecord? getBookmarkAt(int index) {
    final bookmarks = prefs?.getStringList(_key) ?? [];
    if (index < 0 || index >= bookmarks.length) return null;

    final res = bookmarks[index].split(";");
    return (
      date: DateTime.fromMillisecondsSinceEpoch(int.parse(res[1])),
      array: res[0],
    );
  }

  void addBookmark([String? array]) {
    final bookmarks = prefs?.getStringList(_key) ?? [];
    array ??= data.toJson();

    bookmarks.removeWhere((e) => e.split(";").first == array);
    bookmarks.insert(0, "$array;${DateTime.now().millisecondsSinceEpoch}");

    prefs?.setStringList(_key, bookmarks);
    notifyListeners();
  }

  void removeBookmark([String? array]) {
    final bookmarks = prefs?.getStringList(_key) ?? [];
    array ??= data.toJson();

    bookmarks.removeWhere((e) => e.split(";").first == array);
    prefs?.setStringList(_key, bookmarks);
    notifyListeners();
  }
}
