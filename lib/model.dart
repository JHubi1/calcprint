import 'dart:convert';

import 'package:flutter/material.dart';

import 'extensions.dart';
import 'main.dart';
import 'recent.dart';

DataStore get data => DataStore.instance;

class DataStore {
  final TextEditingController printoutTitleController;
  String? get printoutTitle => printoutTitleController.text.orNull;

  final TextEditingController printoutFromController;
  String? get printoutFrom => printoutFromController.text.orNull;

  final TextEditingController printoutToController;
  String? get printoutTo => printoutToController.text.orNull;

  bool printoutKeepPrivateRaw;
  bool? get printoutKeepPrivate => printoutKeepPrivateRaw.orNullOnFalse;

  List<ModelControllers> models;
  String get modelsJson {
    return jsonEncode(models.map((m) => jsonDecode(m.toString())).toList());
  }

  bool get isModelsModified => models.length != 1 || models[0].isModified;

  bool get isModified {
    return printoutTitleController.text.isNotEmpty ||
        printoutFromController.text.isNotEmpty ||
        printoutToController.text.isNotEmpty ||
        printoutKeepPrivateRaw != false ||
        isModelsModified;
  }

  DataStore._({
    required this.printoutTitleController,
    required this.printoutFromController,
    required this.printoutToController,
    required this.printoutKeepPrivateRaw,
    required this.models,
  });

  static DataStore get _default => DataStore._(
    printoutTitleController: TextEditingController(),
    printoutFromController: TextEditingController(),
    printoutToController: TextEditingController(),
    printoutKeepPrivateRaw: false,
    models: [ModelControllers()],
  );

  static DataStore? _instance;
  static DataStore get instance {
    _instance ??= _default;
    return _instance!;
  }

  static DataStore newInstanceWith({
    String? printoutTitle,
    String? printoutFrom,
    String? printoutTo,
    bool? printoutKeepPrivate,
    String? models,
  }) {
    final fallback = _default;
    _instance = DataStore._(
      printoutTitleController: TextEditingController(
        text: printoutTitle ?? fallback.printoutTitleController.text,
      ),
      printoutFromController: TextEditingController(
        text: printoutFrom ?? fallback.printoutFromController.text,
      ),
      printoutToController: TextEditingController(
        text: printoutTo ?? fallback.printoutToController.text,
      ),
      printoutKeepPrivateRaw:
          printoutKeepPrivate ?? fallback.printoutKeepPrivateRaw,
      models: tryWithFallback(() {
        if (models == null) {
          return fallback.models;
        }
        return (jsonDecode(models) as List)
            .map((m) => ModelControllers.fromJson(m))
            .toList();
      }, fallback: fallback.models),
    );
    return _instance!;
  }

  void reportUrlToPlatform() {
    Recent.updateUrl(url.toString());
  }

  String toJson() => jsonEncode(
    {
      "printoutTitle": printoutTitle,
      "printoutFrom": printoutFrom,
      "printoutTo": printoutTo,
      "printoutKeepPrivate": printoutKeepPrivate,
      "models":
          (models.length != 1 || models[0].isModified)
              ? jsonDecode(modelsJson)
              : null,
    }..removeNullValues(),
  );

  Uri get url => Uri.https(
    authority,
    "/",
    ({
      "printoutTitle": printoutTitle,
      "printoutFrom": printoutFrom,
      "printoutTo": printoutTo,
      "printoutKeepPrivate": printoutKeepPrivate.toStringOrNull(),
      "models":
          (models.length != 1 || models[0].isModified) ? modelsJson : null,
    }..removeNullValues()).orNull,
  );
}

// MODEL

class Filament {}

class ModelFilamentControllers {
  final TextEditingController weight;
  final TextEditingController filament;

  ModelFilamentControllers()
    : weight = TextEditingController(),
      filament = TextEditingController();

  ModelFilamentControllers.fromJson(Map<String, dynamic> json)
    : weight = TextEditingController(text: json["weight"]?.toString()),
      filament = TextEditingController(text: json["filament"]?.toString());

  @override
  String toString() {
    return jsonEncode(
      {"weight": int.tryParse(weight.text), "filament": filament.text.orNull}
        ..removeNullValues(),
    );
  }
}

class ModelAdditionControllers {
  final TextEditingController name;
  final TextEditingController description;
  final TextEditingController quantity;
  final TextEditingController fixPrice;

  ModelAdditionControllers()
    : name = TextEditingController(),
      description = TextEditingController(),
      quantity = TextEditingController(),
      fixPrice = TextEditingController();

  ModelAdditionControllers.fromJson(Map<String, dynamic> json)
    : name = TextEditingController(text: json["name"]?.toString()),
      description = TextEditingController(
        text: json["description"]?.toString(),
      ),
      quantity = TextEditingController(
        text: (json["quantity"] ?? modelControllerQuantityDefault).toString(),
      ),
      fixPrice = TextEditingController(text: json["fixPrice"]?.toString());

  @override
  String toString() {
    return jsonEncode(
      {
        "name": name.text.orNull,
        "description": description.text.orNull,
        "quantity": int.tryParse(quantity.text.orNullOnDefault("1") ?? ""),
        "fixPrice": double.tryParse(fixPrice.text),
      }..removeNullValues(),
    );
  }
}

String get modelControllerCurrencyDefault => r"$";
final List<String> modelControllerCurrenciesDefault = ["€", r"$", "£", "¥"];
String get modelControllerQuantityDefault => "1";

class ModelControllers {
  final GlobalKey<FormState> formKey;
  final TextEditingController currency;

  final TextEditingController name;
  final TextEditingController quantity;
  final TextEditingController description;

  final List<ModelFilamentControllers> filaments;
  final List<ModelAdditionControllers> additions;

  final TextEditingController time;
  final TextEditingController hourlyRate;

  final TextEditingController margin;
  final TextEditingController fixPrice;

  bool get isModified {
    return currency.text != modelControllerCurrencyDefault ||
        name.text.isNotEmpty ||
        quantity.text != modelControllerQuantityDefault ||
        description.text.isNotEmpty ||
        filaments.isNotEmpty ||
        additions.isNotEmpty ||
        time.text.isNotEmpty ||
        hourlyRate.text.isNotEmpty ||
        margin.text.isNotEmpty ||
        fixPrice.text.isNotEmpty;
  }

  ModelControllers({
    String? currency,
    String? name,
    String? quantity,
    String? description,
    String? time,
    String? hourlyRate,
    String? margin,
    String? fixPrice,
  }) : formKey = GlobalKey<FormState>(),
       currency = TextEditingController(
         text: currency ?? modelControllerCurrencyDefault,
       ),

       name = TextEditingController(text: name),
       quantity = TextEditingController(
         text: quantity ?? modelControllerQuantityDefault,
       ),
       description = TextEditingController(text: description),

       filaments = [],
       additions = [],

       time = TextEditingController(text: time),
       hourlyRate = TextEditingController(text: hourlyRate),

       margin = TextEditingController(text: margin),
       fixPrice = TextEditingController(text: fixPrice);

  ModelControllers.fromJson(Map<String, dynamic> json)
    : formKey = GlobalKey<FormState>(),
      currency = TextEditingController(
        text: json["currency"]?.toString() ?? modelControllerCurrencyDefault,
      ),
      name = TextEditingController(text: json["name"]?.toString()),
      quantity = TextEditingController(
        text: (json["quantity"] ?? modelControllerQuantityDefault).toString(),
      ),
      description = TextEditingController(
        text: json["description"]?.toString(),
      ),

      filaments =
          (json["filaments"] as List?)
              ?.map((f) => ModelFilamentControllers.fromJson(f))
              .toList() ??
          [],

      additions =
          (json["additions"] as List?)
              ?.map((a) => ModelAdditionControllers.fromJson(a))
              .toList() ??
          [],

      time = TextEditingController(text: json["time"]?.toString()),
      hourlyRate = TextEditingController(text: json["hourlyRate"]?.toString()),

      margin = TextEditingController(text: json["margin"]?.toString()),
      fixPrice = TextEditingController(text: json["fixPrice"]?.toString());

  @override
  String toString() {
    return jsonEncode(
      {
        "currency": currency.text.orNullOnDefault(
          modelControllerCurrencyDefault,
        ),
        "name": name.text.orNull,
        "quantity": int.tryParse(
          quantity.text.orNullOnDefault(modelControllerQuantityDefault) ?? "",
        ),
        "description": description.text.orNull,
        "filaments": filaments.map((f) => f.toString()).toList().orNull,
        "additions": additions.map((a) => a.toString()).toList().orNull,
        "time": time.text.orNull,
        "hourlyRate": double.tryParse(hourlyRate.text),
        "margin": int.tryParse(margin.text),
        "fixPrice": double.tryParse(fixPrice.text),
      }..removeNullValues(),
    );
  }
}
