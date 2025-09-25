import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider is used to share GlobalState across the whole app
import 'package:global_state/global_state.dart'; // Imports your custom global state file

void main() {
  runApp(
    // Provide GlobalState to the entire app so all widgets can access it
    ChangeNotifierProvider(
      create: (_) => GlobalState(),
      child: const MyEphemeralApp(),
    ),
  );
}

class MyEphemeralApp extends StatelessWidget {
  const MyEphemeralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Global Counter List')),
        body: const CounterListWidget(), // Displays the list of counters
        floatingActionButton: FloatingActionButton(
          // When pressed, add a new counter to the global state
          onPressed: () {
            Provider.of<GlobalState>(context, listen: false).addCounter();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class CounterListWidget extends StatelessWidget {
  const CounterListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen for changes in the global state and rebuild when counters update
    final counters = context.watch<GlobalState>().counters;

    // If no counters exist, show a message
    if (counters.isEmpty) {
      return const Center(child: Text('No counters. Tap + to add one.'));
    }

    // Otherwise, show a list of counters that can be reordered by dragging
    return ReorderableListView(
      onReorder: (oldIndex, newIndex) =>
          Provider.of<GlobalState>(context, listen: false).reorder(oldIndex, newIndex),
      children: [
        for (int i = 0; i < counters.length; i++)
          CounterTile(
            key: ValueKey(i), // Needed for proper list reordering
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
      color: counter.color, // Each counter has its own color
      child: ListTile(
        title: Text(counter.label), // Display the counter’s label
        subtitle: AnimatedSwitcher(
          // Smooth animation when the counter value changes
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Text(
            'Value: ${counter.value}', // Display the counter value
            key: ValueKey(counter.value), // Key so animation knows what changed
            style: const TextStyle(fontSize: 18),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decrement button
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => Provider.of<GlobalState>(context, listen: false).decrement(index),
            ),
            // Increment button
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Provider.of<GlobalState>(context, listen: false).increment(index),
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => Provider.of<GlobalState>(context, listen: false).removeCounter(index),
            ),
          ],
        ),
        // Tap the tile to edit label and color
        onTap: () async {
          await showDialog(
            context: context,
            builder: (context) {
              Color selectedColor = counter.color;
              TextEditingController labelController =
                  TextEditingController(text: counter.label);

              // Use StatefulBuilder so dialog can update color selection live
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Edit Counter'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Text field to edit the label
                        TextField(
                          controller: labelController,
                          decoration: const InputDecoration(labelText: 'Label'),
                        ),
                        const SizedBox(height: 10),
                        // Color picker (shows multiple selectable colors)
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
                                        // Highlight border if this color is selected
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
                      // Cancel button (closes dialog without saving)
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      // Save button (updates label and color in GlobalState)
                      TextButton(
                        onPressed: () {
                          Provider.of<GlobalState>(context, listen: false)
                              .changeLabel(index, labelController.text);
                          Provider.of<GlobalState>(context, listen: false)
                              .changeColor(index, selectedColor);
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
