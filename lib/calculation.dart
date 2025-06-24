import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'extensions.dart';
import 'main.dart';
import 'model.dart';
import 'widgets.dart';

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

  const CalculationModel({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(model.name.text.orNull ?? "Untitled Model", maxLines: 1),
          subtitle: ListTile(
            contentPadding: EdgeInsets.zero,
            minTileHeight: 0,
            minVerticalPadding: 0,
            title:
                (model.description.text.orNull != null)
                    ? Text(
                      model.description.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    )
                    : null,
            subtitle: Text("data"),
          ),
          titleAlignment: ListTileTitleAlignment.top,
          trailing: DefaultTextStyle(
            style: TextStyle(),
            child: Padding(
              padding: EdgeInsets.only(
                top: 2 * (ListTileTheme.of(context).minVerticalPadding ?? 4),
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
                          "${model.currency.text.orNull ?? modelControllerCurrencyDefault}${calculatePrice(model).toStringAsFixed(2)}",
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
        ),
      ],
    );
  }

  static double calculatePrice(ModelControllers model) {
    // TODO: implement this
    return (int.tryParse(model.quantity.text) ?? 1) *
        (double.tryParse(model.fixPrice.text) ?? 0);
  }
}

class CalculationTable extends StatelessWidget {
  const CalculationTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(64),
      child: AnimatedSize(
        duration: Duration(milliseconds: 250),
        curve: Curves.fastEaseInToSlowEaseOut,
        child: Card.filled(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTileHeader(
                usePaddingTop:
                    (data.printoutFrom == null && data.printoutTo == null),
                child: Text(
                  data.printoutTitle ?? "Untitled Project",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (data.printoutFrom != null || data.printoutTo != null)
                ListTilePadding(
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

              CalculationTableDivider(),
              ...data.models.map((e) => CalculationModel(model: e)),
              CalculationTableDivider(),

              ListTile(
                title: Text("Total"),
                trailing: DefaultTextStyle(
                  style: TextStyle(),
                  child: Builder(
                    builder: (context) {
                      double totalPrice = 0;

                      for (final model in data.models) {
                        totalPrice += CalculationModel.calculatePrice(model);
                      }

                      return Text(
                        "$modelControllerCurrencyDefault${totalPrice.toStringAsFixed(2)}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
  final _regexTime = RegExp(r"^(?:(?<h>\d+)\:)?(?<m>\d+)$");
  final _regexTimePerfect = RegExp(r"^(?<h>\d{2,})\:(?<m>\d{2})$");

  Widget currencyPicker({bool enabled = true}) => Container(
    width: 96,
    padding: const EdgeInsets.only(left: 12),
    child: DropdownMenu(
      enabled: enabled,
      enableSearch: true,
      controller: widget.model.currency,
      textAlign: TextAlign.right,
      textStyle: TextStyle(
        color: enabled ? null : Theme.of(context).disabledColor,
      ),
      inputDecorationTheme: InputDecorationTheme(border: InputBorder.none),
      dropdownMenuEntries:
          modelControllerCurrenciesDefault
              .map((e) => DropdownMenuEntry(value: e, label: e))
              .toList(),
    ),
  );

  void render(_) {
    widget.model.formKey.currentState?.validate();
    widget.onRender();
    setState(() {});
  }

  @override
  void initState() {
    widget.model.currency.addListener(() => render(null));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    widget.model.currency.removeListener(() => render(null));
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
                                onChanged: render,
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
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return "Required.";
                                  }
                                  if (int.tryParse(value ?? "") == null) {
                                    return "Must be Int.";
                                  } else if (int.parse(value!) < 1) {
                                    return "At least 1.";
                                  }
                                  return null;
                                },
                                onChanged: render,
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
                          ),
                          onChanged: render,
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
                          validator: (value) {
                            if (value?.isEmpty ?? true) return null;
                            if (!_regexTime.hasMatch(value!)) {
                              return "Must be in HH:MM or MM format.";
                            }
                            return null;
                          },
                          onChanged: render,
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
                            hintText: "0.00",
                            suffixIcon: currencyPicker(
                              enabled: widget.model.fixPrice.text.isEmpty,
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return null;
                            if (double.tryParse(value ?? "") == null) {
                              return "Must be a valid number.";
                            } else if (double.parse(value!) < 0) {
                              return "Must be positive.";
                            }
                            return null;
                          },
                          onChanged: render,
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
                            validator: (value) {
                              if (value?.isEmpty ?? true) return null;
                              if (int.tryParse(value ?? "") == null) {
                                return "Must be a valid number.";
                              } else if (int.parse(value!) < 0) {
                                return "Must be positive.";
                              }
                              return null;
                            },
                            onChanged: render,
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
                            hintText: "0.00",
                            helperText:
                                "If this option is set, hourly rate, filament costs, and the price margin will get ignored.",
                            helperMaxLines: 2,
                            suffixIcon: currencyPicker(),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return null;
                            if (double.tryParse(value ?? "") == null) {
                              return "Must be a valid number.";
                            } else if (double.parse(value!) < 0) {
                              return "Must be positive.";
                            }
                            return null;
                          },
                          onChanged: render,
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
