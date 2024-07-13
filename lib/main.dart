import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  String title; // 宿題のタイトルを保持する変数
  DateTime dueDate; // 宿題の期限を保持する変数
  bool isCompleted; // 宿題が完了したかどうかを示す変数
  Proficiency proficiency; // 宿題の得意度を保持する変数

  Homework({
    required this.title, // タイトルは必須の引数
    required this.dueDate, // 期限は必須の引数
    this.isCompleted = false, // 完了チェックボックスはデフォルトでfalse
    this.proficiency = Proficiency.medium, // 得意度はデフォルトで「普通」
  });
}

class HomeworkOrganizerScreen extends StatefulWidget {
  const HomeworkOrganizerScreen({Key? key}) : super(key: key);

  @override
  _HomeworkOrganizerScreenState createState() =>
      _HomeworkOrganizerScreenState();
}

class _HomeworkOrganizerScreenState extends State<HomeworkOrganizerScreen> {
  final TextEditingController _titleController =
      TextEditingController(); // テキスト入力フィールドの内容を管理するためのコントローラ
  DateTime _selectedDateTime = DateTime.now(); // 日付と時間を保持するための変数。初期値は現在時刻
  Proficiency _selectedProficiency = Proficiency.medium; // 得意度の選択値を保持するための変数
  final List<Homework> _homeworkList = []; // 宿題オブジェクトを格納するリスト

  void _addHomework() {
    setState(() {
      // 入力されたタイトル、選択された日付、得意度で新しい宿題を作成する
      final homework = Homework(
        title: _titleController.text, // テキストフィールドの入力内容を取得
        dueDate: _selectedDateTime, // 日付選択ダイアログで選択された日付を設定
        proficiency: _selectedProficiency, // 選択された得意度を設定
      );
      _homeworkList.add(homework); // 宿題リストに新しい宿題を追加する
      _titleController.clear(); // 入力フィールドをクリアする
    });
  }

  void _toggleCompletion(int index) {
    setState(() {
      // 指定された宿題の完了チェックボックスのオンオフを反転
      _homeworkList[index].isCompleted = !_homeworkList[index].isCompleted;
    });
  }

  void _deleteHomework(int index) {
    setState(() {
      // 宿題リストから指定された宿題を削除する
      _homeworkList.removeAt(index);
    });
  }

  void _reorderHomework(int oldIndex, int newIndex) {
    setState(() {
      // 新しい位置が古い位置よりも後ろにある場合、インデックスを調整する
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      // 古い位置から宿題を取り出し、新しい位置に挿入することで並び替える
      final item = _homeworkList.removeAt(oldIndex);
      _homeworkList.insert(newIndex, item);
    });
  }

  void _sortHomeworkByDueDate() {
    setState(() {
      _homeworkList.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    });
  }

  void _sortHomeworkByProficiency() {
    setState(() {
      _homeworkList
          .sort((a, b) => a.proficiency.index.compareTo(b.proficiency.index));
    });
  }

  void _sortHomeworkByUnskilled() {
    setState(() {
      _homeworkList
          .sort((a, b) => b.proficiency.index.compareTo(a.proficiency.index));
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
                    controller: _titleController, // 上で定義したコントローラを指定
                    decoration: const InputDecoration(
                        labelText: '教科・内容をここに入力'), // 入力フィールドの装飾やラベルを設定
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today), // アイコンとしてカレンダーアイコンを指定
                  onPressed: () async {
                    // ボタンが押されたときの処理を設定（非同期）
                    final DateTime? pickedDateTime = await showDatePicker(
                      context:
                          context, // BuildContext を指定して、DatePicker を表示するためのコンテキストを提供
                      initialDate: _selectedDateTime, // 初期選択日付として現在の日付を指定
                      firstDate: DateTime(2024), // 最初の日付
                      lastDate: DateTime(2100), // 最後の日付
                    );

                    if (pickedDateTime != null) {
                      // 日付が選択された場合の処理
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                      );

                      if (pickedTime != null) {
                        // 時間が選択された場合の処理
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
                const Spacer(), // 可変スペースを追加して右端に追加ボタンを寄せる
                ElevatedButton(
                  onPressed: _addHomework,
                  child: const Text('宿題の追加'),
                ),
              ],
            ),
          ),

          // リストビューの作成
          // Expandedにより、残りのスクリーン領域をすべてリストビューが占有
          Expanded(
            // ユーザーが項目をドラッグして並べ替えできるリストビューを構築するためのウィジェット。builder メソッドを使用して、動的にリスト項目を作成
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              // リストビューに表示するアイテムの数を指定。ここでは _homeworkList の要素数を設定
              itemCount: _homeworkList.length,
              // 各リストアイテムのビルド方法を定義するコールバック関数。この中で、ListTile を使用して各宿題を表示
              itemBuilder: (context, index) {
                // _homeworkList リストから、指定された index に対応する宿題オブジェクトを取得
                final homework = _homeworkList[index];

                return ListTile(
                  key: ValueKey(index), // リスト項目を一意に識別するためのキー
                  // リスト項目の背景色を奇数・偶数で交互に設定。 '?'は三項演算子。true の場合には oddItemColor, false の場合には evenItemColor を選択
                  tileColor: _proficiencyToColor(homework.proficiency),
                  // ドラッグするためのウィジェット
                  leading: ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle), // ドラッグハンドルのアイコン
                  ),
                  title: Text(homework.title), // 宿題のタイトルを表示
                  subtitle: Text(
                    '${DateFormat.yMMMd().format(homework.dueDate)} ${DateFormat.Hm().format(homework.dueDate)} - ${_proficiencyToString(homework.proficiency)}',
                  ), // 宿題の期限と得意度を表示
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, // 子要素が必要な最小の幅で配置される
                    children: [
                      Checkbox(
                        value: homework.isCompleted, // チェックボックスの初期値に設定
                        onChanged: (value) {
                          // 上で定義
                          _toggleCompletion(index); // チェックボックスが押されたときの処理を設定
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete), // ゴミ箱のアイコンを表示
                        onPressed: () => _deleteHomework(index), // 削除処理を実行
                      ),
                    ],
                  ),
                );
              },
              // リスト項目が並び替えられたときに呼び出されるコールバック関数
              onReorder: _reorderHomework, // 上で定義
            ),
          ),
        ],
      ),
    );
  }
}
