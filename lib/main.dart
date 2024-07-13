import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeworkOrganizerScreen(),
    );
  }
}

enum Proficiency { high, medium, low }

class Homework {
  String title;
  DateTime dueDate;
  bool isCompleted;
  Proficiency proficiency;

  Homework({
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
    this.proficiency = Proficiency.medium,
  });

  // Homework オブジェクトから Map を作成するメソッド
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dueDate': dueDate.millisecondsSinceEpoch, // DateTime をエポック秒に変換
      'isCompleted': isCompleted,
      'proficiency': proficiency.index,
    };
  }

  // Map から Homework オブジェクトを作成するファクトリメソッド
  factory Homework.fromMap(Map<String, dynamic> map) {
    return Homework(
      title: map['title'],
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate']),
      isCompleted: map['isCompleted'],
      proficiency: Proficiency.values[map['proficiency']],
    );
  }
}

class HomeworkOrganizerScreen extends StatefulWidget {
  const HomeworkOrganizerScreen({Key? key}) : super(key: key);

  @override
  _HomeworkOrganizerScreenState createState() =>
      _HomeworkOrganizerScreenState();
}

class _HomeworkOrganizerScreenState extends State<HomeworkOrganizerScreen> {
  final TextEditingController _titleController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  Proficiency _selectedProficiency = Proficiency.medium;
  List<Homework> _homeworkList = [];

  @override
  void initState() {
    super.initState();
    _loadHomeworkList(); // アプリ起動時に宿題リストを読み込む
  }

  // 宿題リストの読み込み
  void _loadHomeworkList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? stringList = prefs.getStringList('homeworkList');
    if (stringList != null) {
      setState(() {
        _homeworkList = stringList
            .map((item) =>
                Homework.fromMap(Map<String, dynamic>.from(json.decode(item))))
            .toList();
      });
    }
  }

  // 宿題リストの保存
  void _saveHomeworkList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> stringList =
        _homeworkList.map((homework) => json.encode(homework.toMap())).toList();
    prefs.setStringList('homeworkList', stringList);
  }

  void _addHomework() {
    setState(() {
      final homework = Homework(
        title: _titleController.text,
        dueDate: _selectedDateTime,
        proficiency: _selectedProficiency,
      );
      _homeworkList.add(homework);
      _titleController.clear();
      _saveHomeworkList(); // 宿題が追加されたら保存する
    });
  }

  void _toggleCompletion(int index) {
    setState(() {
      _homeworkList[index].isCompleted = !_homeworkList[index].isCompleted;
      _saveHomeworkList(); // 完了状態が変更されたら保存する
    });
  }

  void _deleteHomework(int index) {
    setState(() {
      _homeworkList.removeAt(index);
      _saveHomeworkList(); // 宿題が削除されたら保存する
    });
  }

  void _reorderHomework(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _homeworkList.removeAt(oldIndex);
      _homeworkList.insert(newIndex, item);
      _saveHomeworkList(); // 宿題が並び替えられたら保存する
    });
  }

  void _sortHomeworkByDueDate() {
    setState(() {
      _homeworkList.sort((a, b) {
        int dateComparison = a.dueDate.compareTo(b.dueDate);
        if (dateComparison != 0) {
          return dateComparison;
        }
        return a.proficiency.index.compareTo(b.proficiency.index);
      });
      _saveHomeworkList(); // 並び替え後に保存する
    });
  }

  void _sortHomeworkByProficiency() {
    setState(() {
      _homeworkList.sort((a, b) {
        int proficiencyComparison =
            a.proficiency.index.compareTo(b.proficiency.index);
        if (proficiencyComparison != 0) {
          return proficiencyComparison;
        }
        return a.dueDate.compareTo(b.dueDate);
      });
      _saveHomeworkList(); // 並び替え後に保存する
    });
  }

  void _sortHomeworkByUnskilled() {
    setState(() {
      _homeworkList.sort((a, b) {
        int unskilledComparison =
            b.proficiency.index.compareTo(a.proficiency.index);
        if (unskilledComparison != 0) {
          return unskilledComparison;
        }
        return a.dueDate.compareTo(b.dueDate);
      });
      _saveHomeworkList(); // 並び替え後に保存する
    });
  }

  String _proficiencyToString(Proficiency proficiency) {
    switch (proficiency) {
      case Proficiency.high:
        return "得意";
      case Proficiency.medium:
        return "普通";
      case Proficiency.low:
        return "苦手";
    }
  }

  Color _proficiencyToColor(Proficiency proficiency) {
    switch (proficiency) {
      case Proficiency.high:
        return Colors.green.withOpacity(0.3);
      case Proficiency.medium:
        return Colors.orange.withOpacity(0.3);
      case Proficiency.low:
        return Colors.red.withOpacity(0.3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('宿題リスト'),
        backgroundColor: Colors.blue.withOpacity(0.5),
        actions: [
          TextButton(
            onPressed: _sortHomeworkByDueDate,
            child: const Text('期限順'),
          ),
          TextButton(
            onPressed: _sortHomeworkByProficiency,
            child: const Text('得意順'),
          ),
          TextButton(
            onPressed: _sortHomeworkByUnskilled,
            child: const Text('苦手順'),
          ),
        ],
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
                    decoration: const InputDecoration(labelText: '教科・内容をここに入力'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final DateTime? pickedDateTime = await showDatePicker(
                      context: context,
                      initialDate: _selectedDateTime,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDateTime != null) {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                      );

                      if (pickedTime != null) {
                        setState(() {
                          _selectedDateTime = DateTime(
                            pickedDateTime.year,
                            pickedDateTime.month,
                            pickedDateTime.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                const Text('得意度:'),
                const SizedBox(width: 10),
                DropdownButton<Proficiency>(
                  value: _selectedProficiency,
                  onChanged: (Proficiency? newValue) {
                    setState(() {
                      _selectedProficiency = newValue!;
                    });
                  },
                  items: Proficiency.values.map((Proficiency proficiency) {
                    return DropdownMenuItem<Proficiency>(
                      value: proficiency,
                      child: Text(_proficiencyToString(proficiency)),
                    );
                  }).toList(),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _addHomework,
                  child: const Text('宿題の追加'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              itemCount: _homeworkList.length,
              itemBuilder: (context, index) {
                final homework = _homeworkList[index];

                return ListTile(
                  key: ValueKey(index),
                  tileColor: _proficiencyToColor(homework.proficiency),
                  leading: ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle),
                  ),
                  title: Text(homework.title),
                  subtitle: Text(
                    '${DateFormat.yMMMd().format(homework.dueDate)} ${DateFormat.Hm().format(homework.dueDate)} - ${_proficiencyToString(homework.proficiency)}',
                  ),
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
              onReorder: _reorderHomework,
            ),
          ),
        ],
      ),
    );
  }
}
