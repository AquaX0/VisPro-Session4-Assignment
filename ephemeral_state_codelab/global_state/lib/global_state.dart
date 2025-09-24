import 'package:flutter/material.dart';

class CounterData {
  int value;
  Color color;
  String label;

  CounterData({
    this.value = 0,
    required this.color,
    required this.label,
  });
}

class GlobalState extends ChangeNotifier {
  static final GlobalState instance = GlobalState._internal();
  GlobalState._internal();

  final List<CounterData> _counters = [];

  List<CounterData> get counters => List.unmodifiable(_counters);

  void addCounter({Color? color, String? label}) {
    _counters.add(CounterData(
      color: color ?? Colors.blue,
      label: label ?? 'Counter ${_counters.length + 1}',
    ));
    notifyListeners();
  }

  void removeCounter(int index) {
    if (index >= 0 && index < _counters.length) {
      _counters.removeAt(index);
      notifyListeners();
    }
  }

  void increment(int index) {
    if (index >= 0 && index < _counters.length) {
      _counters[index].value++;
      notifyListeners();
    }
  }

  void decrement(int index) {
    if (index >= 0 && index < _counters.length && _counters[index].value > 0) {
      _counters[index].value--;
      notifyListeners();
    }
  }

  void changeColor(int index, Color color) {
    if (index >= 0 && index < _counters.length) {
      _counters[index].color = color;
      notifyListeners();
    }
  }

  void changeLabel(int index, String label) {
    if (index >= 0 && index < _counters.length) {
      _counters[index].label = label;
      notifyListeners();
    }
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _counters.removeAt(oldIndex);
    _counters.insert(newIndex, item);
    notifyListeners();
  }
}