import 'package:flutter/material.dart';
import 'package:global_state/global_state.dart';

void main() {
  runApp(const MyEphemeralApp());
}

class MyEphemeralApp extends StatelessWidget {
  const MyEphemeralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Global Counter List')),
        body: const CounterListWidget(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            GlobalState.instance.addCounter();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class CounterListWidget extends StatefulWidget {
  const CounterListWidget({super.key});

  @override
  State<CounterListWidget> createState() => _CounterListWidgetState();
}

class _CounterListWidgetState extends State<CounterListWidget> {
  @override
  void initState() {
    super.initState();
    GlobalState.instance.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    GlobalState.instance.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final counters = GlobalState.instance.counters;
    if (counters.isEmpty) {
      return const Center(child: Text('No counters. Tap + to add one.'));
    }
    return ReorderableListView(
      onReorder: GlobalState.instance.reorder,
      children: [
        for (int i = 0; i < counters.length; i++)
          CounterTile(
            key: ValueKey(i),
            index: i,
            counter: counters[i],
          ),
      ],
    );
  }
}

class CounterTile extends StatelessWidget {
  final int index;
  final CounterData counter;

  const CounterTile({super.key, required this.index, required this.counter});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: counter.color,
      child: ListTile(
        title: Text(counter.label),
        subtitle: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Text(
            'Value: ${counter.value}',
            key: ValueKey(counter.value),
            style: const TextStyle(fontSize: 18),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => GlobalState.instance.decrement(index),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => GlobalState.instance.increment(index),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => GlobalState.instance.removeCounter(index),
            ),
          ],
        ),
        onTap: () async {
          await showDialog(
            context: context,
            builder: (context) {
              Color selectedColor = counter.color;
              TextEditingController labelController =
                  TextEditingController(text: counter.label);
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Edit Counter'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: labelController,
                          decoration: const InputDecoration(labelText: 'Label'),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: [
                            ...[
                              Colors.blue,
                              Colors.red,
                              Colors.green,
                              Colors.orange,
                              Colors.purple,
                              Colors.teal,
                            ].map((color) => GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedColor = color;
                                    });
                                  },
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: selectedColor == color
                                            ? Colors.black
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          GlobalState.instance.changeLabel(index, labelController.text);
                          GlobalState.instance.changeColor(index, selectedColor);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
