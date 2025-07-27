import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../extensions.dart';
import '../main.dart';
import '../widgets/widgets.dart';
import 'model.dart';

final _regexTime = RegExp(r"^(?:(?<h>\d+)\:)?(?<m>\d+)$");
final _regexTimePerfect = RegExp(r"^(?<h>\d{2,})\:(?<m>\d{2})$");

final _numFormatCurrency = NumberFormat.currency(
  symbol: data.currencyTextOrDefault,
);

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
    bool strikethroughValues = false;

    if (model.time.text.isNotEmpty) {
      final parsed = calculatePartTime(
        model.time.text,
        hourlyRate: model.hourlyRate.text,
      );
      if (parsed.valid) {
        fields.addAll({
          "Spend Time (${parsed.time})": _numFormatCurrency.format(
            parsed.price,
          ),
        });
      }
    }
    if (model.margin.text.isNotEmpty) {
      final parsed = calculatePartMargin(
        model.margin.text,
        calculatePrice(
          model,
          quantityOne: true,
          ignoreMargin: true,
          ignoreFixPrice: true,
        ),
      );
      if (parsed.valid) {
        fields.addAll({
          "Price Margin (${parsed.percent})": _numFormatCurrency.format(
            parsed.marginAmount,
          ),
        });
      }
    }

    if (model.fixPrice.text.isNotEmpty) {
      final fixPrice = double.tryParse(
        model.fixPrice.text.replaceAll(
          NumberFormat.decimalPattern().symbols.DECIMAL_SEP,
          ".",
        ),
      );
      if (fixPrice != null && fixPrice > 0) {
        strikethroughValues = true;
        separators.add(fields.length);
        fields.addAll({"Fix Price": _numFormatCurrency.format(fixPrice)});
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        top: paddingTop ? 8 : 0,
        bottom: paddingBottom ? 8 : 0,
      ),
      child: ListTile(
        minTileHeight:
            model.description.text.isEmpty && fields.isEmpty ? 0 : null,
        minVerticalPadding:
            model.description.text.isEmpty && fields.isEmpty ? 0 : null,
        title: Text(model.name.text.orNull ?? "Untitled Model", maxLines: 1),
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
                      (data.printoutKeepPrivate ?? false)
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
                        "${model.quantity.text.orNull ?? modelControllerQuantityDefault}x",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      _numFormatCurrency.format(
                        calculatePrice(model, quantityOne: true),
                      ),
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

  static ({bool valid, double price, String time}) calculatePartTime(
    String source, {
    required String hourlyRate,
  }) {
    final matches = _regexTime.allMatches(source);
    if (matches.length == 1) {
      final totalMinutes =
          (int.tryParse(matches.first.namedGroup("m")!) ?? 0) +
          (int.tryParse(matches.first.namedGroup("h") ?? "0") ?? 0) * 60;
      final minutes = totalMinutes % Duration.minutesPerHour;
      final hours = (totalMinutes - minutes) ~/ Duration.minutesPerHour;

      final relativeHours = (totalMinutes / Duration.minutesPerHour);
      final rate =
          double.tryParse(
            hourlyRate.replaceAll(
              NumberFormat.decimalPattern().symbols.DECIMAL_SEP,
              ".",
            ),
          ) ??
          0;

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
  calculatePartMargin(String source, double other) {
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

  static double calculatePrice(
    ModelControllers model, {
    bool quantityOne = false,
    bool ignoreMargin = false,
    bool ignoreFixPrice = false,
  }) {
    double price = 0;

    final fixedPrice = double.tryParse(
      model.fixPrice.text.replaceAll(
        NumberFormat.decimalPattern().symbols.DECIMAL_SEP,
        ".",
      ),
    );
    if (model.fixPrice.text.isNotEmpty &&
        fixedPrice != null &&
        !ignoreFixPrice) {
      price = fixedPrice;
    } else {
      if (model.hourlyRate.text.isNotEmpty) {
        final parsed = calculatePartTime(
          model.time.text,
          hourlyRate: model.hourlyRate.text,
        );
        if (parsed.valid) {
          price += parsed.price;
        }
      }

      if (model.margin.text.isNotEmpty && !ignoreMargin) {
        final parsed = calculatePartMargin(model.margin.text, price);
        if (parsed.valid) {
          price += parsed.marginAmount;
        }
      }
    }

    final quantity = quantityOne ? 1 : (int.tryParse(model.quantity.text) ?? 1);
    return price * quantity;
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
          child: AnimatedSize(
            duration: Duration(milliseconds: 250),
            curve: Curves.fastEaseInToSlowEaseOut,
            alignment: Alignment.topCenter,
            child: Card.filled(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.translate(
                    offset:
                        (data.printoutFrom != null || data.printoutTo != null)
                            ? Offset(0, -4)
                            : Offset(0, 4),
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
                        2 * (ListTileTheme.of(context).minVerticalPadding ?? 4),
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
                        double totalPrice = 0;

                        for (final model in data.models) {
                          totalPrice += CalculationModel.calculatePrice(model);
                        }

                        return Text(
                          NumberFormat.currency(
                            symbol: data.currencyTextOrDefault,
                          ).format(totalPrice),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                ],
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
  Widget currencyPicker({bool enabled = true}) => Container(
    width: 96,
    padding: const EdgeInsets.only(left: 12),
    child: DropdownMenu(
      enabled: enabled,
      enableSearch: true,
      controller: data.currency,
      textAlign: TextAlign.right,
      textStyle: TextStyle(
        color: enabled ? null : Theme.of(context).disabledColor,
      ),
      inputDecorationTheme: InputDecorationTheme(border: InputBorder.none),
      dropdownMenuEntries:
          dataStoreCurrenciesDefault
              .map((e) => DropdownMenuEntry(value: e, label: e))
              .toList(),
    ),
  );

  void render() {
    data.reportUrlToPlatform();
    widget.onRender();
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    data.currency.addListener(render);
    widget.model.addListener(render);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    data.currency.removeListener(render);
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
                                decoration: InputDecoration(
                                  label: Text("Quantity"),
                                  border: OutlineInputBorder(),
                                  hintText: "1",
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
                          decoration: InputDecoration(
                            label: Text("Spend Time"),
                            border: OutlineInputBorder(),
                            hintText: "00:00",
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
                          enabled: widget.model.fixPrice.text.isEmpty,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            label: Text("Hourly Rate"),
                            border: OutlineInputBorder(),
                            hintText:
                                "0${NumberFormat.decimalPattern().symbols.DECIMAL_SEP}00",
                            suffixIcon: currencyPicker(
                              enabled: widget.model.fixPrice.text.isEmpty,
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return null;
                            value = value!.replaceAll(
                              NumberFormat.decimalPattern().symbols.DECIMAL_SEP,
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
                            enabled: widget.model.fixPrice.text.isEmpty,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              label: Text("Price Margin"),
                              border: OutlineInputBorder(),
                              hintText: "0",
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
                          decoration: InputDecoration(
                            label: Text("Fix Price"),
                            border: OutlineInputBorder(),
                            hintText:
                                "0${NumberFormat.decimalPattern().symbols.DECIMAL_SEP}00",
                            helperText:
                                "If this option is set, hourly rate, filament costs, and the price margin will get ignored.",
                            helperMaxLines: 2,
                            suffixIcon: currencyPicker(),
                          ),
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return null;
                            value = value!.replaceAll(
                              NumberFormat.decimalPattern().symbols.DECIMAL_SEP,
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
