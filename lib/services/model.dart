import 'dart:convert';

import 'package:flutter/material.dart';

import '../extensions.dart';
import '../main.dart';
import 'recent.dart';

DataStore get data => DataStore.instance;

final List<String> dataStoreCurrenciesDefault = ["€", r"$", "£", "¥"];
final String dataStoreCurrencyDefault = dataStoreCurrenciesDefault.elementAt(1);

class DataStore extends ChangeNotifier {
  final TextEditingController printoutTitleController;
  String? get printoutTitle => printoutTitleController.text.orNull;

  final TextEditingController printoutFromController;
  String? get printoutFrom => printoutFromController.text.orNull;

  final TextEditingController printoutToController;
  String? get printoutTo => printoutToController.text.orNull;

  bool printoutKeepPrivateRaw;
  bool? get printoutKeepPrivate => printoutKeepPrivateRaw.orNullOnFalse;

  final TextEditingController currency;
  String? get currencyText =>
      currency.text.orNullOnDefault(dataStoreCurrencyDefault);
  String get currencyTextOrDefault => currency.text;

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
        isModelsModified ||
        currency.text != dataStoreCurrencyDefault;
  }

  DataStore._({
    required this.printoutTitleController,
    required this.printoutFromController,
    required this.printoutToController,
    required this.printoutKeepPrivateRaw,
    required this.models,
    required this.currency,
  }) {
    printoutTitleController.addListener(notifyListeners);
    printoutFromController.addListener(notifyListeners);
    printoutToController.addListener(notifyListeners);
    currency.addListener(notifyListeners);
  }

  static DataStore get _default => DataStore._(
    printoutTitleController: TextEditingController(),
    printoutFromController: TextEditingController(),
    printoutToController: TextEditingController(),
    printoutKeepPrivateRaw: false,
    models: [ModelControllers()],
    currency: TextEditingController(text: dataStoreCurrencyDefault),
  );

  static DataStore? _instance;
  static DataStore get instance {
    _instance ??= _default;
    return _instance!;
  }

  static void resetInstanceWith({
    String? printoutTitle,
    String? printoutFrom,
    String? printoutTo,
    bool? printoutKeepPrivate,
    String? models,
    String? currency,
  }) {
    final fallback = _default;

    instance.printoutTitleController.text =
        printoutTitle ?? fallback.printoutTitleController.text;
    instance.printoutFromController.text =
        printoutFrom ?? fallback.printoutFromController.text;
    instance.printoutToController.text =
        printoutTo ?? fallback.printoutToController.text;
    instance.printoutKeepPrivateRaw =
        printoutKeepPrivate ?? fallback.printoutKeepPrivateRaw;
    instance.models = tryWithFallback(() {
      return (jsonDecode(models!) as List)
          .map((m) => ModelControllers.fromJson(m))
          .toList();
    }, fallback: fallback.models);
    instance.currency.text = currency ?? dataStoreCurrencyDefault;

    instance.reportUrlToPlatform();
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
      "currency": currencyText,
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
      "currency": currencyText,
    }..removeNullValues()).orNull,
  );
}

// MODEL

class Filament {}

class ModelFilamentControllers extends ChangeNotifier {
  final TextEditingController weight;
  final TextEditingController filament;

  ModelFilamentControllers()
    : weight = TextEditingController(),
      filament = TextEditingController() {
    weight.addListener(notifyListeners);
    filament.addListener(notifyListeners);
  }

  ModelFilamentControllers.fromJson(Map<String, dynamic> json)
    : weight = TextEditingController(text: json["weight"]?.toString()),
      filament = TextEditingController(text: json["filament"]?.toString()) {
    weight.addListener(notifyListeners);
    filament.addListener(notifyListeners);
  }

  @override
  String toString() {
    return jsonEncode(
      {"weight": int.tryParse(weight.text), "filament": filament.text.orNull}
        ..removeNullValues(),
    );
  }
}

class ModelAdditionControllers extends ChangeNotifier {
  final TextEditingController name;
  final TextEditingController description;
  final TextEditingController quantity;
  final TextEditingController fixPrice;

  ModelAdditionControllers()
    : name = TextEditingController(),
      description = TextEditingController(),
      quantity = TextEditingController(),
      fixPrice = TextEditingController() {
    name.addListener(notifyListeners);
    description.addListener(notifyListeners);
    quantity.addListener(notifyListeners);
    fixPrice.addListener(notifyListeners);
  }

  ModelAdditionControllers.fromJson(Map<String, dynamic> json)
    : name = TextEditingController(text: json["name"]?.toString()),
      description = TextEditingController(
        text: json["description"]?.toString(),
      ),
      quantity = TextEditingController(
        text: (json["quantity"] ?? modelControllerQuantityDefault).toString(),
      ),
      fixPrice = TextEditingController(text: json["fixPrice"]?.toString()) {
    name.addListener(notifyListeners);
    description.addListener(notifyListeners);
    quantity.addListener(notifyListeners);
    fixPrice.addListener(notifyListeners);
  }

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

String get modelControllerQuantityDefault => "1";

class ModelControllers extends ChangeNotifier {
  final GlobalKey<FormState> formKey;

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
    return name.text.isNotEmpty ||
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
       fixPrice = TextEditingController(text: fixPrice) {
    this.name.addListener(notifyListeners);
    this.quantity.addListener(notifyListeners);
    this.description.addListener(notifyListeners);
    this.time.addListener(notifyListeners);
    this.hourlyRate.addListener(notifyListeners);
    this.margin.addListener(notifyListeners);
    this.fixPrice.addListener(notifyListeners);
  }

  ModelControllers.fromJson(Map<String, dynamic> json)
    : formKey = GlobalKey<FormState>(),

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
      fixPrice = TextEditingController(text: json["fixPrice"]?.toString()) {
    name.addListener(notifyListeners);
    quantity.addListener(notifyListeners);
    description.addListener(notifyListeners);
    time.addListener(notifyListeners);
    hourlyRate.addListener(notifyListeners);
    margin.addListener(notifyListeners);
    fixPrice.addListener(notifyListeners);
  }

  @override
  String toString() {
    return jsonEncode(
      {
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
