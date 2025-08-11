import 'dart:math';

import 'package:cash/cash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:strgad/strgad.dart';

import '../extensions.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../widgets/draggable_perspective_widget.dart';
import '../widgets/widgets.dart';
import 'display.dart';
import 'model.dart';

final _regexTime = RegExp(r"^(?:(?<h>\d+)\:)?(?<m>\d+)$");
final _regexTimePerfect = RegExp(r"^(?<h>\d{2,})\:(?<m>\d{2})$");

String _decimalSeparator(BuildContext context) =>
    NumberFormat.decimalPattern(
      AppLocalizations.of(context).localeName,
    ).symbols.DECIMAL_SEP;

NumberFormat _numFormatCurrency(BuildContext context) => NumberFormat.currency(
  locale: AppLocalizations.of(context).localeName,
  name: data.currencyOrDefault.code,
  symbol: data.currencyOrDefault.symbol,
);
double? _numParseWithDecimalFromLocale(
  String text,
  BuildContext context, {
  double? fallback = 0,
}) {
  if (text.isEmpty) return fallback;
  return double.tryParse(text.replaceAll(_decimalSeparator(context), ".")) ?? 0;
}

class CalculationTableDivider extends StatelessWidget {
  const CalculationTableDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Divider(height: 0),
    );
  }
}

class CalculationModelEvaluationContainer {
  final int quantity;

  final String? timeSpent;
  final Cash? timePrice;

  final String? marginPercent;
  final Cash? marginPrice;

  final Cash? fixPrice;

  final Cash priceSingle;
  final Cash price;

  CalculationModelEvaluationContainer({
    required this.quantity,
    required this.timeSpent,
    required this.timePrice,
    required this.marginPercent,
    required this.marginPrice,
    required this.fixPrice,
    required this.priceSingle,
    required this.price,
  });
}

class CalculationModel extends StatelessWidget {
  final ModelControllers model;
  final bool paddingTop;
  final bool paddingBottom;

  const CalculationModel({
    super.key,
    required this.model,
    required this.paddingTop,
    required this.paddingBottom,
  });

  @override
  Widget build(BuildContext context) {
    final contentTextStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    final fields = <String, String>{};
    final separators = <int>{};
    final bool printoutKeepPrivate = data.printoutKeepPrivate ?? false;
    bool strikethroughValues = false;

    final calculation = calculatePrice(model, context: context);
    if (calculation.timePrice != null) {
      fields.addAll({
        "Spend Time (${calculation.timeSpent})": _numFormatCurrency(
          context,
        ).format(calculation.timePrice!.value),
      });
    }
    if (calculation.marginPercent != null) {
      fields.addAll({
        "Price Margin (${calculation.marginPercent})": _numFormatCurrency(
          context,
        ).format(calculation.marginPrice!.value),
      });
    }
    if (calculation.fixPrice != null) {
      strikethroughValues = true;
      separators.add(fields.length);
      fields.addAll({
        "Fix Price": _numFormatCurrency(
          context,
        ).format(calculation.fixPrice!.value),
      });
    }

    return Padding(
      padding: EdgeInsets.only(
        top: paddingTop ? 8 : 0,
        bottom: paddingBottom ? 8 : 0,
      ),
      child: ListTile(
        minTileHeight:
            model.description.text.isEmpty &&
                    (fields.isEmpty || printoutKeepPrivate)
                ? 0
                : null,
        minVerticalPadding:
            model.description.text.isEmpty &&
                    (fields.isEmpty || printoutKeepPrivate)
                ? 0
                : null,
        title: Text(
          model.name.text.orNull ?? "Untitled Model",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle:
            (model.description.text.isNotEmpty || fields.isNotEmpty)
                ? ListTile(
                  contentPadding: EdgeInsets.zero,
                  minTileHeight: 0,
                  minVerticalPadding: 0,
                  title:
                      (model.description.text.orNull != null)
                          ? Text(
                            model.description.text,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: contentTextStyle,
                          )
                          : null,
                  subtitle:
                      printoutKeepPrivate
                          ? null
                          : Builder(
                            builder: (context) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(fields.length, (index) {
                                  final pair = fields.entries.elementAt(index);
                                  final titleMain =
                                      pair.key.split("(").first.trim();
                                  final titleSub =
                                      pair.key.split("(").length > 1
                                          ? pair.key.split("(").last.trim()
                                          : null;

                                  return ListTile(
                                    contentPadding: EdgeInsets.only(
                                      top:
                                          ((index == 0 &&
                                                      model
                                                          .description
                                                          .text
                                                          .isNotEmpty) ||
                                                  separators.contains(index))
                                              ? 4
                                              : 0,
                                    ),
                                    minTileHeight: 0,
                                    minVerticalPadding: 0,
                                    title: Text.rich(
                                      TextSpan(
                                        text: "$titleMain ",
                                        style: contentTextStyle,
                                        children:
                                            titleSub != null
                                                ? [
                                                  TextSpan(
                                                    text: "($titleSub",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelSmall!
                                                        .copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurfaceVariant,
                                                        ),
                                                  ),
                                                ]
                                                : null,
                                      ),
                                    ),
                                    trailing: Text(
                                      pair.value,
                                      style:
                                          (strikethroughValues &&
                                                  index != fields.length - 1)
                                              ? Theme.of(
                                                context,
                                              ).textTheme.labelSmall!.copyWith(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).disabledColor,
                                                fontStyle: FontStyle.italic,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                decorationColor:
                                                    Theme.of(
                                                      context,
                                                    ).disabledColor,
                                                decorationThickness: 2,
                                              )
                                              : null,
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                )
                : null,
        titleAlignment: ListTileTitleAlignment.top,
        trailing: Padding(
          padding: EdgeInsets.only(
            top: ListTileTheme.of(context).minVerticalPadding ?? 4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        "${model.quantity.text.orNull ?? modelControllerQuantityDefault} ×",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      _numFormatCurrency(
                        context,
                      ).format(calculation.priceSingle.value),
                      style: TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static ({bool valid, double price, String time}) _calculatePartTime(
    String source, {
    required BuildContext context,
    required String hourlyRate,
  }) {
    if (source.isEmpty || hourlyRate.isEmpty) {
      return (valid: false, price: 0, time: "");
    }

    final matches = _regexTime.allMatches(source);
    if (matches.length == 1) {
      final totalMinutes =
          (int.tryParse(matches.first.namedGroup("m")!) ?? 0) +
          (int.tryParse(matches.first.namedGroup("h") ?? "0") ?? 0) * 60;
      final minutes = totalMinutes % Duration.minutesPerHour;
      final hours = (totalMinutes - minutes) ~/ Duration.minutesPerHour;

      final relativeHours = (totalMinutes / Duration.minutesPerHour);
      final rate = _numParseWithDecimalFromLocale(hourlyRate, context)!;

      return (
        valid: true,
        price: relativeHours * rate,
        time:
            "${hours.toString().padLeft(2, "0")}:${minutes.toString().padLeft(2, "0")}",
      );
    }
    return (valid: false, price: 0, time: "");
  }

  static ({bool valid, double marginAmount, String percent})
  _calculatePartMargin(String source, double other) {
    final margin = int.tryParse(source);
    if (margin != null && margin >= 0) {
      return (
        valid: true,
        marginAmount: (margin / 100) * other,
        percent: "${margin.toString()}%",
      );
    }
    return (valid: false, marginAmount: 0, percent: "");
  }

  static CalculationModelEvaluationContainer calculatePrice(
    ModelControllers model, {
    required BuildContext context,
  }) {
    Cash zero = Cash(0, data.currencyOrDefault);
    Cash tmp = Cash(0, data.currencyOrDefault);

    final int quantity = int.tryParse(model.quantity.text) ?? 1;

    final timeCalc = _calculatePartTime(
      model.time.text,
      context: context,
      hourlyRate: model.hourlyRate.text,
    );
    final String? timeSpent = timeCalc.valid ? timeCalc.time : null;
    final Cash? timePrice =
        timeCalc.valid ? Cash(timeCalc.price, data.currencyOrDefault) : null;
    if (timePrice != null) tmp += timePrice;

    final marginCalc = _calculatePartMargin(model.margin.text, tmp.value);
    final String? marginPercent = marginCalc.valid ? marginCalc.percent : null;
    final Cash? marginPrice =
        marginCalc.valid
            ? Cash(marginCalc.marginAmount, data.currencyOrDefault)
            : null;

    final fixPriceCalc = _numParseWithDecimalFromLocale(
      model.fixPrice.text,
      context,
      fallback: null,
    );
    final Cash? fixPrice =
        (fixPriceCalc != null && fixPriceCalc > 0)
            ? Cash(fixPriceCalc, data.currencyOrDefault)
            : null;

    final Cash priceSingle =
        (fixPrice != null)
            ? fixPrice
            : onNull(timePrice, orElse: zero) +
                onNull(marginPrice, orElse: zero);
    final Cash price = priceSingle * quantity;

    return CalculationModelEvaluationContainer(
      quantity: quantity,
      timeSpent: timeSpent,
      timePrice: timePrice,
      marginPercent: marginPercent,
      marginPrice: marginPrice,
      fixPrice: fixPrice,
      priceSingle: priceSingle,
      price: price,
    );
  }
}

class CalculationTable extends StatelessWidget {
  const CalculationTable({super.key});

  @override
  Widget build(BuildContext context) {
    int modelCount = 0;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.all(constraints.maxWidth >= 500 ? 64 : 32),
          child: DraggablePerspectiveWidget(
            enabled: Display.from(context).moreEqualTablet,
            child: Card.filled(
              child: AnimatedSize(
                duration: Duration(milliseconds: 250),
                curve: Curves.fastEaseInToSlowEaseOut,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (data.printoutFrom != null || data.printoutTo != null)
                      SizedBox(height: 8),
                    Transform.translate(
                      offset:
                          (data.printoutFrom != null || data.printoutTo != null)
                              ? Offset(0, -4)
                              : Offset(0, 6),
                      child: ListTileHeader(
                        usePaddingTop:
                            (data.printoutFrom != null ||
                                data.printoutTo != null),
                        child: Text(
                          data.printoutTitle ?? "Untitled Project",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (data.printoutFrom != null || data.printoutTo != null)
                      Transform.translate(
                        offset: Offset(
                          0,
                          (ListTileTheme.of(context).minVerticalPadding ?? 4) *
                                  -2 -
                              4,
                        ),
                        child: ListTilePadding(
                          usePaddingTop: false,
                          usePaddingBottom: false,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (data.printoutFrom != null)
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 32),
                                      child: Text("Printer:"),
                                    ),
                                    Expanded(
                                      child: Text(
                                        data.printoutFrom!,
                                        textAlign: TextAlign.end,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              if (data.printoutTo != null)
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 32),
                                      child: Text("Client:"),
                                    ),
                                    Expanded(
                                      child: Text(
                                        data.printoutTo!,
                                        textAlign: TextAlign.end,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(
                      height:
                          2 *
                          (ListTileTheme.of(context).minVerticalPadding ?? 4),
                    ),

                    CalculationTableDivider(),
                    ...data.models.map((e) {
                      modelCount++;
                      return CalculationModel(
                        model: e,
                        paddingTop: modelCount == 1,
                        paddingBottom: modelCount == data.models.length,
                      );
                    }),
                    CalculationTableDivider(),

                    ListTile(
                      title: Text("Total"),
                      trailing: Builder(
                        builder: (context) {
                          Cash totalPrice = Cash(0, data.currencyOrDefault);

                          for (final model in data.models) {
                            totalPrice +=
                                CalculationModel.calculatePrice(
                                  model,
                                  context: context,
                                ).price;
                          }

                          return Text(
                            _numFormatCurrency(
                              context,
                            ).format(totalPrice.value),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ModelForm extends StatefulWidget {
  final ModelControllers model;
  final void Function() onRender;
  final void Function()? onRemove;

  const ModelForm({
    super.key,
    required this.model,
    required this.onRender,
    required this.onRemove,
  });

  @override
  State<ModelForm> createState() => _ModelFormState();
}

class _ModelFormState extends State<ModelForm> {
  void render() {
    widget.onRender();
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    data.currencyRaw.addListener(render);
    widget.model.addListener(render);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    data.currencyRaw.removeListener(render);
    widget.model.removeListener(render);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.model.formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Card.filled(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTilePadding(
                        usePaddingRight: false,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: widget.model.name,
                                textInputAction: TextInputAction.next,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                decoration: InputDecoration(
                                  label: Text("Name"),
                                  border: OutlineInputBorder(),
                                  hintText:
                                      [
                                        "bananaPhoneHolder",
                                        "miniatureVikingDuck",
                                        "toothpasteSqueezer3000",
                                        "officeWarCatapult",
                                        "emergencyPizzaCutter",
                                        "tinyDeskCactus",
                                        "rocketPoweredPaperclip",
                                        "catUnicornHorn",
                                        "spaghettiMeasuringTool",
                                        "wobblyChessKnight",
                                      ][seed],
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            SizedBox(
                              width: 96,
                              child: TextFormField(
                                controller: widget.model.quantity,
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: false,
                                ),
                                textInputAction: TextInputAction.next,
                                textAlign: TextAlign.end,
                                maxLength: 5,
                                decoration: InputDecoration(
                                  label: Text("Quantity"),
                                  border: OutlineInputBorder(),
                                  hintText: "1",
                                  counterText: "",
                                ),
                                autovalidateMode: AutovalidateMode.always,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) return null;
                                  if (int.tryParse(value ?? "") == null) {
                                    return "Must be Int.";
                                  } else if (int.parse(value!) < 1) {
                                    return "At least 1.";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListTilePadding(
                        usePaddingRight: false,
                        child: TextFormField(
                          controller: widget.model.description,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.sentences,
                          minLines: 1,
                          maxLines: 3,
                          decoration: InputDecoration(
                            label: Text("Description"),
                            border: OutlineInputBorder(),
                            hintText:
                                [
                                  "Banana-shaped phone holder",
                                  "Mini Viking duck",
                                  "Toothpaste squeezer",
                                  "Office war catapult",
                                  "Pizza cutter for emergencies",
                                  "Tiny desk cactus",
                                  "Rocket-powered paperclip",
                                  "Unicorn horn for CAT",
                                  "Spaghetti measuring tool",
                                  "Wobbly chess knight",
                                ][seed],
                            hintMaxLines: 1,
                          ),
                        ),
                      ),

                      // TODO: add filaments
                      ListTileHeader(child: Text("Time Calculation")),
                      ListTilePadding(
                        usePaddingRight: false,
                        child: TextFormField(
                          controller: widget.model.time,
                          keyboardType: TextInputType.datetime,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => setState(() {}),
                          maxLength: 5,
                          decoration: InputDecoration(
                            label: Text("Spend Time"),
                            border: OutlineInputBorder(),
                            hintText: "00:00",
                            counterText: "",
                            suffixText: () {
                              final time = widget.model.time.text;
                              final match = _regexTime.firstMatch(time);
                              if (time.isEmpty || match == null) {
                                return null;
                              }

                              final hoursOut = int.tryParse(
                                match.namedGroup("h") ?? "0",
                              );
                              final minutesOut = int.tryParse(
                                match.namedGroup("m")!,
                              );
                              if (hoursOut == null || minutesOut == null) {
                                return null;
                              }

                              final minutesCalc =
                                  minutesOut +
                                  hoursOut * Duration.minutesPerHour;

                              final hours =
                                  minutesCalc ~/ Duration.minutesPerHour;
                              final minutes =
                                  minutesCalc % Duration.minutesPerHour;

                              if (hours != hoursOut ||
                                  minutes != minutesOut ||
                                  !_regexTimePerfect.hasMatch(time)) {
                                return "= ${hours.toString().padLeft(2, "0")}:${minutes.toString().padLeft(2, "0")}";
                              }
                            }(),
                          ),
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return null;
                            if (!_regexTime.hasMatch(value!)) {
                              return "Must be in HH:MM or MM format.";
                            }
                            return null;
                          },
                        ),
                      ),
                      ListTilePadding(
                        usePaddingRight: false,
                        child: TextFormField(
                          controller: widget.model.hourlyRate,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          maxLength: 5,
                          decoration: InputDecoration(
                            label: Text("Hourly Rate"),
                            border: OutlineInputBorder(),
                            hintText: "0${_decimalSeparator(context)}00",
                            counterText: "",
                            suffixIcon: ModelFormCurrency(),
                          ),
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return null;
                            value = value!.replaceAll(
                              _decimalSeparator(context),
                              ".",
                            );
                            if (double.tryParse(value) == null) {
                              return "Must be a valid number.";
                            } else if (double.parse(value) < 0) {
                              return "Must be positive.";
                            }
                            return null;
                          },
                        ),
                      ),

                      ListTileHeader(child: Text("Price Adjustments")),
                      AnimatedSize(
                        duration: Duration(milliseconds: 250),
                        curve: Curves.fastEaseInToSlowEaseOut,
                        alignment: Alignment.topCenter,
                        child: ListTilePadding(
                          usePaddingRight: false,
                          child: TextFormField(
                            controller: widget.model.margin,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            maxLength: 5,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              label: Text("Price Margin"),
                              border: OutlineInputBorder(),
                              hintText: "0",
                              counterText: "",
                              helperText:
                                  ((int.tryParse(widget.model.margin.text) ??
                                              0) >
                                          100)
                                      ? "r/foundSatan"
                                      : null,
                              suffixText: "%",
                            ),
                            autovalidateMode: AutovalidateMode.always,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return null;
                              if (int.tryParse(value ?? "") == null) {
                                return "Must be a valid number.";
                              } else if (int.parse(value!) < 0) {
                                return "Must be positive.";
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      ListTilePadding(
                        usePaddingRight: false,
                        child: TextFormField(
                          controller: widget.model.fixPrice,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          maxLength: 7,
                          decoration: InputDecoration(
                            label: Text("Fix Price"),
                            border: OutlineInputBorder(),
                            hintText: "0${_decimalSeparator(context)}00",
                            counterText: "",
                            helperText:
                                "If this option is set, hourly rate, filament costs, and the price margin will get ignored.",
                            helperMaxLines: 2,
                            suffixIcon: ModelFormCurrency(),
                          ),
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return null;
                            value = value!.replaceAll(
                              _decimalSeparator(context),
                              ".",
                            );
                            if (double.tryParse(value) == null) {
                              return "Must be a valid number.";
                            } else if (double.parse(value) < 0) {
                              return "Must be positive.";
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: IconButton(
                  onPressed: widget.onRemove,
                  icon: Icon(Symbols.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModelFormCurrency extends StatelessWidget {
  const ModelFormCurrency({super.key});

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      textInputAction: TextInputAction.search,
      viewHintText: "Currencies",
      viewLeading: IconButton(
        style: const ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(Symbols.close),
      ),
      viewTrailing: [
        // IconButton(
        //   tooltip: "Submit new currency",
        //   onPressed: () => launchUrl(Uri.parse("")),
        //   icon: Icon(Symbols.approval),
        // ),
      ],
      viewConstraints: const BoxConstraints(
        maxHeight: 250,
        minWidth: 300,
        maxWidth: 300,
      ),
      builder:
          (context, controller) => InkWell(
            onTap: () => controller.openView(),
            hoverColor: Colors.transparent,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    data.currencyOrDefault.symbol ??
                        data.currencyOrDefault.code,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Symbols.arrow_drop_down),
                ),
              ],
            ),
          ),
      suggestionsBuilder: (context, controller) async {
        final currencies = <Currency, CurrencyLocalization>{};
        for (var currency in Currency.currencies) {
          final tmp =
              CurrencyLocalizationContainer.resolveLocaleFallback(
                AppLocalizations.of(context).localeName,
              )[currency.code];
          if (tmp != null) currencies[currency] = tmp;
        }

        final input = controller.text.toLowerCase();
        currencies.removeWhere((key, value) {
          return !((key.symbol?.toLowerCase().contains(input) ?? false) ||
                  key.code.toLowerCase().contains(input) ||
                  value.displayName.toLowerCase().contains(input)) &&
              !(value.displayName.toLowerCase().levenshteinDistance(input) <=
                  max(value.displayName.length * 0.2, 2));
        });

        if (currencies.isEmpty) {
          return [
            ListTile(
              title: Text("No currency found"),
              subtitle: Text("Try a different search term."),
            ),
          ];
        }

        final widgets = <ListTile>[];
        for (var currency
            in currencies.keys.toList()
              ..sort((a, b) => a.code.compareTo(b.code))) {
          final selected = currency == data.currencyOrDefault;
          widgets.add(
            ListTile(
              selected: selected,
              // leading: SizedBox(
              //   width: 22,
              //   child: AspectRatio(
              //     aspectRatio: 1,
              //     child: Badge(
              //       isLabelVisible: selected,
              //       backgroundColor: Theme.of(context).colorScheme.primary,
              //       label: Transform.scale(
              //         scale: 1.2,
              //         child: Icon(
              //           Symbols.check,
              //           color: Theme.of(context).colorScheme.onPrimary,
              //           size: 8,
              //         ),
              //       ),

              //       child: CircleAvatar(
              //         child: Text(
              //           (currency.symbol ?? currency.code).trim(),
              //           textAlign: TextAlign.center,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              title: Text(currencies[currency]!.displayName),
              onTap: () {
                data.currencyRaw.value = currency;
                controller.closeView(null);
                Future.delayed(
                  Durations.medium1,
                ).then((_) => controller.clear());
              },
              trailing: Text(currency.symbol ?? currency.code),
            ),
          );
        }

        return widgets;
      },
    );
  }
}
