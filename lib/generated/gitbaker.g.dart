// GitBaker v0.0.6 <https://pub.dev/packages/gitbaker>

// This is an automatically generated file by GitBaker. Do not modify manually.
// To regenerate this file, please rerun the command 'dart run gitbaker'

// ignore_for_file: unnecessary_nullable_for_final_variable_declarations

library;

enum RemoteType { fetch, push }

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
      r"A tool for calculating the printing cost of 3D print items.";

  static final Set<Remote> remotes = {
    Remote._(
      name: r"origin",
      url: Uri.parse(r"https://github.com/JHubi1/calcprint.git"),
      type: RemoteType.fetch,
    ),
    Remote._(
      name: r"origin",
      url: Uri.parse(r"https://github.com/JHubi1/calcprint.git"),
      type: RemoteType.push,
    ),
  };

  static final Set<User> contributors = {
    User._(name: r"JHubi1", email: r"me@jhubi1.com"),
  };

  static final Branch defaultBranch = branches.singleWhere(
    (e) => e.name == r"main",
  );
  static final Branch currentBranch = branches.singleWhere(
    (e) => e.name == r"main",
  );

  static final Set<Branch> branches = {
    Branch._(
      r"0d00a202da3821d3b4f7ad4fb1757f4328f84544",
      name: r"main",
      commits: [
        Commit._(
          r"1b61ee8833719887b04f61a4633992457b7cad34",
          message: r"Initial commit",
          date: DateTime.fromMillisecondsSinceEpoch(
            1750776599000,
          ), // 2025-06-24T14:49:59.000Z
          signed: true,
          branch: r"main",
          author: r"me@jhubi1.com",
        ),
        Commit._(
          r"4f43dfa1a6f44b1b581f5f75c6eb10f8e3be7465",
          message: r"Update wrangler.json",
          date: DateTime.fromMillisecondsSinceEpoch(
            1750776838000,
          ), // 2025-06-24T14:53:58.000Z
          signed: true,
          branch: r"main",
          author: r"me@jhubi1.com",
        ),
        Commit._(
          r"50c349ea76851200950fb1b0e28719a4e5ae603a",
          message: r"Update wrangler.json",
          date: DateTime.fromMillisecondsSinceEpoch(
            1750776973000,
          ), // 2025-06-24T14:56:13.000Z
          signed: true,
          branch: r"main",
          author: r"me@jhubi1.com",
        ),
        Commit._(
          r"016a3ca529ff3f956a0f1b6963b9817600c16f37",
          message: r"Update wrangler.json",
          date: DateTime.fromMillisecondsSinceEpoch(
            1750782978000,
          ), // 2025-06-24T16:36:18.000Z
          signed: true,
          branch: r"main",
          author: r"me@jhubi1.com",
        ),
        Commit._(
          r"305200415d5d48fee1399ad976a8212265bfb827",
          message: r"Update wrangler.json",
          date: DateTime.fromMillisecondsSinceEpoch(
            1750783077000,
          ), // 2025-06-24T16:37:57.000Z
          signed: true,
          branch: r"main",
          author: r"me@jhubi1.com",
        ),
        Commit._(
          r"991611264a15da16a118f01f295352265f7f2c95",
          message: r"Update wrangler.json",
          date: DateTime.fromMillisecondsSinceEpoch(
            1750784510000,
          ), // 2025-06-24T17:01:50.000Z
          signed: true,
          branch: r"main",
          author: r"me@jhubi1.com",
        ),
        Commit._(
          r"23ea4aa48b35757d3f779b7d5ca1e782ccb0f3b4",
          message: r"GH Actions Test",
          date: DateTime.fromMillisecondsSinceEpoch(
            1751040845000,
          ), // 2025-06-27T16:14:05.000Z
          signed: true,
          branch: r"main",
          author: r"me@jhubi1.com",
        ),
        Commit._(
          r"b39891b29b8f717d07e10dfc63c2c89ce23c0928",
          message: r"Version Update",
          date: DateTime.fromMillisecondsSinceEpoch(
            1751040943000,
          ), // 2025-06-27T16:15:43.000Z
          signed: true,
          branch: r"main",
          author: r"me@jhubi1.com",
        ),
        Commit._(
          r"6b891af3d547aab580a77fcfd4442ec7046077b6",
          message: r"Some improvements; NOTICE file",
          date: DateTime.fromMillisecondsSinceEpoch(
            1751061990000,
          ), // 2025-06-27T22:06:30.000Z
          signed: true,
          branch: r"main",
          author: r"me@jhubi1.com",
        ),
        Commit._(
          r"375fccb6e64b98c7013294dc421543f2bf5cae2d",
          message: r"Better animations, other tweaks",
          date: DateTime.fromMillisecondsSinceEpoch(
            1751124466000,
          ), // 2025-06-28T15:27:46.000Z
          signed: true,
          branch: r"main",
          author: r"me@jhubi1.com",
        ),
        Commit._(
          r"253952753d98c2d83bc553dca5877d5942809773",
          message: r"Changed build script",
          date: DateTime.fromMillisecondsSinceEpoch(
            1751125475000,
          ), // 2025-06-28T15:44:35.000Z
          signed: true,
          branch: r"main",
          author: r"me@jhubi1.com",
        ),
        Commit._(
          r"0d00a202da3821d3b4f7ad4fb1757f4328f84544",
          message: r"`CalculationTable` Improvements",
          date: DateTime.fromMillisecondsSinceEpoch(
            1751146421000,
          ), // 2025-06-28T21:33:41.000Z
          signed: true,
          branch: r"main",
          author: r"me@jhubi1.com",
        ),
      ],
    ),
  };

  static final Set<Tag> tags = {};
}
