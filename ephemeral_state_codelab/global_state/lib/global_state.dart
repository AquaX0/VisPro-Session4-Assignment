import 'package:flutter/material.dart';

/// Model class that represents a single counter.
/// Each counter has a value, a color, and a label.
class CounterData {
  int value;   // current count value
  Color color; // background color of the counter card
  String label; // display label for the counter

  CounterData({
    this.value = 0,          // default starting value is 0
    required this.color,     // color must be provided
    required this.label,     // label must be provided
  });
}

/// Global state manager for all counters in the app.
/// Extends ChangeNotifier so widgets can rebuild when state changes.
class GlobalState extends ChangeNotifier {
  // Internal list that stores all counters
  final List<CounterData> _counters = [];

  /// Read-only access to the counters list.
  List<CounterData> get counters => List.unmodifiable(_counters);

  /// Add a new counter with optional [color] and [label].
  /// Defaults to blue color and auto-generated label if not provided.
  void addCounter({Color? color, String? label}) {
    _counters.add(CounterData(
      color: color ?? Colors.blue,
      label: label ?? 'Counter ${_counters.length + 1}',
    ));
    notifyListeners(); // notify widgets to rebuild
  }

  /// Remove the counter at the given [index].
  void removeCounter(int index) {
    if (index >= 0 && index < _counters.length) {
      _counters.removeAt(index);
      notifyListeners();
    }
  }

  /// Increment the value of the counter at [index].
  void increment(int index) {
    if (index >= 0 && index < _counters.length) {
      _counters[index].value++;
      notifyListeners();
    }
  }

  /// Decrement the value of the counter at [index].
  /// Value cannot go below 0.
  void decrement(int index) {
    if (index >= 0 && index < _counters.length && _counters[index].value > 0) {
      _counters[index].value--;
      notifyListeners();
    }
  }

  /// Change the [color] of the counter at [index].
  void changeColor(int index, Color color) {
    if (index >= 0 && index < _counters.length) {
      _counters[index].color = color;
      notifyListeners();
    }
  }

  /// Change the [label] of the counter at [index].
  void changeLabel(int index, String label) {
    if (index >= 0 && index < _counters.length) {
      _counters[index].label = label;
      notifyListeners();
    }
  }

  /// Reorder the counters list after drag-and-drop.
  /// [oldIndex] is the previous position, [newIndex] is the new position.
  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1; // adjust index if moving downwards
    }
    final item = _counters.removeAt(oldIndex);
    _counters.insert(newIndex, item);
    notifyListeners();
  }
}
