import 'package:flutter/material.dart';

Future<double?> showNumberSliderDialog(
    BuildContext context, {
      required String title,
      required int min,
      required int max,
    }) async {
  double value = min.toDouble();
  final result = await showDialog<double>(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: Text(title),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value.toInt().toString()),
                Slider(
                  value: value,
                  min: min.toDouble(),
                  max: max.toDouble(),
                  divisions: max - min,
                  label: value.toInt().toString(),
                  onChanged: (v) => setState(() => value = v),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Отмена"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, value),
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
  return result;
}