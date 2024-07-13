import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeworkOrganizerScreen(),
    );
  }
}

class Homework {
  String title;
  DateTime dueDate;
  bool isCompleted;

  Homework(
      {required this.title, required this.dueDate, this.isCompleted = false});
}

class HomeworkOrganizerScreen extends StatefulWidget {
  const HomeworkOrganizerScreen({super.key});

  @override
  _HomeworkOrganizerScreenState createState() =>
      _HomeworkOrganizerScreenState();
}

class _HomeworkOrganizerScreenState extends State<HomeworkOrganizerScreen> {
  final TextEditingController _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final List<Homework> _homeworkList = [];
  bool _isReordering = false;
  int? _reorderIndex;

  void _addHomework() {
    setState(() {
      final homework = Homework(
        title: _titleController.text,
        dueDate: _selectedDate,
      );
      _homeworkList.add(homework);
      _titleController.clear();
    });
  }

  void _toggleCompletion(int index) {
    setState(() {
      _homeworkList[index].isCompleted = !_homeworkList[index].isCompleted;
    });
  }

  void _deleteHomework(int index) {
    setState(() {
      _homeworkList.removeAt(index);
    });
  }

  void _reorderHomework(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _homeworkList.removeAt(oldIndex);
      _homeworkList.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('宿題'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: '教科・内容を入力'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    }
                  },
                ),
                ElevatedButton(
                  onPressed: _addHomework,
                  child: const Text('追加'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Listener(
              onPointerDown: (event) {
                setState(() {
                  _isReordering = true;
                });
              },
              onPointerUp: (event) {
                setState(() {
                  _isReordering = false;
                  _reorderIndex = null;
                });
              },
              child: ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                itemCount: _homeworkList.length,
                itemBuilder: (context, index) {
                  final homework = _homeworkList[index];
                  final ColorScheme colorScheme = Theme.of(context).colorScheme;
                  final Color oddItemColor =
                      colorScheme.primary.withOpacity(0.05);
                  final Color evenItemColor =
                      colorScheme.primary.withOpacity(0.15);
                  return ListTile(
                    key: ValueKey(homework),
                    tileColor: index.isOdd ? oddItemColor : evenItemColor,
                    leading: IconButton(
                      icon: const Icon(Icons.drag_handle),
                      onPressed: () {
                        setState(() {
                          _reorderIndex = index;
                        });
                      },
                    ),
                    title: Text(homework.title),
                    subtitle: Text(DateFormat.yMMMd().format(homework.dueDate)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: homework.isCompleted,
                          onChanged: (value) {
                            _toggleCompletion(index);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteHomework(index),
                        ),
                      ],
                    ),
                  );
                },
                onReorder: (oldIndex, newIndex) {
                  if (_reorderIndex != null && _isReordering) {
                    _reorderHomework(oldIndex, newIndex);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
