// GitBaker v0.0.6 <https://pub.dev/packages/gitbaker>

// This is an automatically generated file by GitBaker. Do not modify manually.
// To regenerate this file, please rerun the command 'dart run gitbaker'

// ignore_for_file: unnecessary_nullable_for_final_variable_declarations

library;

enum RemoteType { fetch, push, unknown }

final class Remote {
  final String name;
  final Uri url;
  final RemoteType type;

  Remote._({required this.name, required this.url, required this.type});
}

final class User {
  final String name;
  final String email;

  User._({required this.name, required this.email});
}

final class Commit {
  final String hash;
  final String message;
  final DateTime date;

  /// Whether the commit has been signed.
  /// Careful: not whether the signature is valid!
  final bool signed;

  final String _branch;
  Branch get branch => GitBaker.branches.singleWhere((e) => e.name == _branch);

  final String _author;
  User get author =>
      GitBaker.contributors.singleWhere((e) => e.email == _author);

  Commit._(
    this.hash, {
    required this.message,
    required this.date,
    required this.signed,
    required String branch,
    required String author,
  }) : _branch = branch,
       _author = author;
}

final class Branch {
  final String hash;
  final String name;
  final List<Commit> commits;

  bool get isCurrent => this == GitBaker.currentBranch;
  bool get isDefault => this == GitBaker.defaultBranch;

  Branch._(this.hash, {required this.name, required this.commits});
}

final class Tag {
  final String hash;
  final String name;
  final String description;

  Tag._(this.hash, {required this.name, required this.description});
}

final class GitBaker {
  static final String? description =
      "A tool for calculating the printing cost of 3D print items.";

  static Remote get remote => remotes.firstWhere(
    (r) => r.name == 'origin' && r.type == RemoteType.fetch,
    orElse: () => remotes.firstWhere(
      (r) => r.type == RemoteType.fetch,
      orElse: () => remotes.first,
    ),
  );
  static final Set<Remote> remotes = {
    Remote._(
      name: "origin",
      url: Uri.parse("https://github.com/JHubi1/calcprint.git"),
      type: RemoteType.fetch,
    ),
    Remote._(
      name: "origin",
      url: Uri.parse("https://github.com/JHubi1/calcprint.git"),
      type: RemoteType.push,
    ),
  };

  static final Set<User> contributors = {
    User._(name: "JHubi1", email: "me@jhubi1.com"),
  };

  static final Branch defaultBranch = branches.singleWhere(
    (e) => e.name == "main",
  );
  static final Branch currentBranch = branches.singleWhere(
    (e) => e.name == "main",
  );

  static final Set<Branch> branches = {
    Branch._(
      "e264a93d8f6d247212e3ee8c07e75ba2030d28cd",
      name: "main",
      commits: [
        Commit._(
          "1b61ee8833719887b04f61a4633992457b7cad34",
          message: "Initial commit",
          date: DateTime.fromMillisecondsSinceEpoch(
            1750776599000,
            isUtc: true,
          ), // 2025-06-24T14:49:59.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "4f43dfa1a6f44b1b581f5f75c6eb10f8e3be7465",
          message: "Update wrangler.json",
          date: DateTime.fromMillisecondsSinceEpoch(
            1750776838000,
            isUtc: true,
          ), // 2025-06-24T14:53:58.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "50c349ea76851200950fb1b0e28719a4e5ae603a",
          message: "Update wrangler.json",
          date: DateTime.fromMillisecondsSinceEpoch(
            1750776973000,
            isUtc: true,
          ), // 2025-06-24T14:56:13.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "016a3ca529ff3f956a0f1b6963b9817600c16f37",
          message: "Update wrangler.json",
          date: DateTime.fromMillisecondsSinceEpoch(
            1750782978000,
            isUtc: true,
          ), // 2025-06-24T16:36:18.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "305200415d5d48fee1399ad976a8212265bfb827",
          message: "Update wrangler.json",
          date: DateTime.fromMillisecondsSinceEpoch(
            1750783077000,
            isUtc: true,
          ), // 2025-06-24T16:37:57.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "991611264a15da16a118f01f295352265f7f2c95",
          message: "Update wrangler.json",
          date: DateTime.fromMillisecondsSinceEpoch(
            1750784510000,
            isUtc: true,
          ), // 2025-06-24T17:01:50.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "23ea4aa48b35757d3f779b7d5ca1e782ccb0f3b4",
          message: "GH Actions Test",
          date: DateTime.fromMillisecondsSinceEpoch(
            1751040845000,
            isUtc: true,
          ), // 2025-06-27T16:14:05.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "b39891b29b8f717d07e10dfc63c2c89ce23c0928",
          message: "Version Update",
          date: DateTime.fromMillisecondsSinceEpoch(
            1751040943000,
            isUtc: true,
          ), // 2025-06-27T16:15:43.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "6b891af3d547aab580a77fcfd4442ec7046077b6",
          message: "Some improvements; NOTICE file",
          date: DateTime.fromMillisecondsSinceEpoch(
            1751061990000,
            isUtc: true,
          ), // 2025-06-27T22:06:30.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "375fccb6e64b98c7013294dc421543f2bf5cae2d",
          message: "Better animations, other tweaks",
          date: DateTime.fromMillisecondsSinceEpoch(
            1751124466000,
            isUtc: true,
          ), // 2025-06-28T15:27:46.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "253952753d98c2d83bc553dca5877d5942809773",
          message: "Changed build script",
          date: DateTime.fromMillisecondsSinceEpoch(
            1751125475000,
            isUtc: true,
          ), // 2025-06-28T15:44:35.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "0d00a202da3821d3b4f7ad4fb1757f4328f84544",
          message: "`CalculationTable` Improvements",
          date: DateTime.fromMillisecondsSinceEpoch(
            1751146421000,
            isUtc: true,
          ), // 2025-06-28T21:33:41.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "c3c56af6a801fb5be6b301516c86fb8f56fd90ce",
          message: "Commit hash in info screen",
          date: DateTime.fromMillisecondsSinceEpoch(
            1751191951000,
            isUtc: true,
          ), // 2025-06-29T10:12:31.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "a2591c6e228d081d8cef6bad4a387cd87cbaeeb3",
          message: "Version display modifications",
          date: DateTime.fromMillisecondsSinceEpoch(
            1751206236000,
            isUtc: true,
          ), // 2025-06-29T14:10:36.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "2db84445cdf87b4c2a37af455a45ce0f838a78e3",
          message: "Various fixes",
          date: DateTime.fromMillisecondsSinceEpoch(
            1753202531000,
            isUtc: true,
          ), // 2025-07-22T16:42:11.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "699a1240dfe4e8d87bf20bb698ad113a17627cff",
          message: "Localization",
          date: DateTime.fromMillisecondsSinceEpoch(
            1753553777000,
            isUtc: true,
          ), // 2025-07-26T18:16:17.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "f3ac063a3fdb9fce0a5ba23709208d0270e0166e",
          message: "PWA and Android install link",
          date: DateTime.fromMillisecondsSinceEpoch(
            1753604580000,
            isUtc: true,
          ), // 2025-07-27T08:23:00.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "15f7b1e30c3d8a1a6b4477a7db81a8d612a3a534",
          message: "Updated dependency",
          date: DateTime.fromMillisecondsSinceEpoch(
            1753605403000,
            isUtc: true,
          ), // 2025-07-27T08:36:43.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "8f4f7af597b413179ee697ccc71f933375298722",
          message: "PWA Updates",
          date: DateTime.fromMillisecondsSinceEpoch(
            1753608348000,
            isUtc: true,
          ), // 2025-07-27T09:25:48.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "746f142ae55bd334610603ab7132a0208ad1f2b6",
          message: "Reorganization, fixed theme color",
          date: DateTime.fromMillisecondsSinceEpoch(
            1753613964000,
            isUtc: true,
          ), // 2025-07-27T10:59:24.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "b9d590d649f85704cf0744dc4bfde644cf349aee",
          message: "Consistent QR code",
          date: DateTime.fromMillisecondsSinceEpoch(
            1753619462000,
            isUtc: true,
          ), // 2025-07-27T12:31:02.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "dabd7b21ae8799cfdadd3bf8b8e518a2872099d7",
          message: "Removed PWA install, added about route",
          date: DateTime.fromMillisecondsSinceEpoch(
            1753996894000,
            isUtc: true,
          ), // 2025-07-31T21:21:34.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "d5fe40520d95a45d3966ca65e7f73f4301dee5f3",
          message: "Restore `wrangler.json`",
          date: DateTime.fromMillisecondsSinceEpoch(
            1753997513000,
            isUtc: true,
          ), // 2025-07-31T21:31:53.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "0107ff7e98bcabf221cef42ee52588f0c3150af9",
          message: "Revert \"Restore `wrangler.json`\"",
          date: DateTime.fromMillisecondsSinceEpoch(
            1753999135000,
            isUtc: true,
          ), // 2025-07-31T21:58:55.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "fceb4add071c1734d373a8968ad0f8225e286636",
          message: "Copy index to 404 in build workflow",
          date: DateTime.fromMillisecondsSinceEpoch(
            1753999202000,
            isUtc: true,
          ), // 2025-07-31T22:00:02.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "522c304d8a94d0ff9dc5141a151efedab58b650c",
          message: "Update makefile",
          date: DateTime.fromMillisecondsSinceEpoch(
            1754000535000,
            isUtc: true,
          ), // 2025-07-31T22:22:15.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "ac045fa5374038d70e483c2d4e68f1754e3e0bf5",
          message: "`cash` package, `DraggablePerspectiveWidget`",
          date: DateTime.fromMillisecondsSinceEpoch(
            1754923847000,
            isUtc: true,
          ), // 2025-08-11T14:50:47.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
        Commit._(
          "e264a93d8f6d247212e3ee8c07e75ba2030d28cd",
          message: "Updated dependency for correct calculation",
          date: DateTime.fromMillisecondsSinceEpoch(
            1754934514000,
            isUtc: true,
          ), // 2025-08-11T17:48:34.000Z
          signed: true,
          branch: "main",
          author: "me@jhubi1.com",
        ),
      ],
    ),
  };

  static final Set<Tag> tags = {};
}
