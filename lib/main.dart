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
  String title; // 宿題のタイトルを保持する変数
  DateTime dueDate; // 宿題の期限を保持する変数
  bool isCompleted; // 宿題が完了したかどうかを示す変数

  Homework(
      {required this.title, // タイトルは必須の引数
      required this.dueDate, // 期限は必須の引数
      this.isCompleted = false // 完了チェックボックスはデフォルトでfalse
      });
}

// StatefulWidgetを継承
class HomeworkOrganizerScreen extends StatefulWidget {
  const HomeworkOrganizerScreen({super.key});

  @override
  _HomeworkOrganizerScreenState createState() =>
      _HomeworkOrganizerScreenState();
}

class _HomeworkOrganizerScreenState extends State<HomeworkOrganizerScreen> {
  // テキスト入力フィールド (TextField) の内容を管理するためのコントローラ
  final TextEditingController _titleController = TextEditingController();
  // 日付選択ダイアログから選択された日付を保持するための変数
  DateTime _selectedDate = DateTime.now(); // 初期値として現在の日時を入れる
  // オブジェクトを格納するリスト。アプリで追加された宿題の情報を管理し、表示するためのデータ構造
  final List<Homework> _homeworkList = []; // 初期値として空のリスト

  void _addHomework() {
    setState(() {
      // 入力されたタイトルと選択された日付で新しい宿題を作成する
      final homework = Homework(
        title: _titleController.text, // テキストフィールドの入力内容を取得
        dueDate: _selectedDate, // 日付選択ダイアログで選択された日付を設定
      );
      // 宿題リストに新しい宿題を追加する
      _homeworkList.add(homework);
      // 入力フィールドをクリアする
      _titleController.clear();
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
      // 宿題リストの削除
      _homeworkList.removeAt(index);
    });
  }

  void _reorderHomework(int oldIndex, int newIndex) {
    // 並び替え時のロジックは公式にも記載があり、あまり考える必要はない。
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('宿題リスト'),
        backgroundColor: Colors.blue.withOpacity(0.5),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController, // 上で定義した
                    decoration: const InputDecoration(
                        labelText: '教科・内容をここに入力'), // 入力フィールドの装飾やラベルを設定
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today), // アイコンとしてカレンダーアイコンを指定
                  onPressed: () async {
                    // ボタンが押されたときの処理を設定（非同期）
                    final DateTime? pickedDate = await showDatePicker(
                      context:
                          context, // BuildContext を指定して、DatePicker を表示するためのコンテキストを提供
                      initialDate: DateTime.now(), // 初期選択日付として現在の日付を指定
                      firstDate: DateTime(2024), // 最初の日付
                      lastDate: DateTime(2100), // 最後の日付
                    );

                    if (pickedDate != null) {
                      // 日付が選択された場合の処理
                      setState(() {
                        _selectedDate = pickedDate; // 上で定義した変数を更新
                      });
                    }
                  },
                ),
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
            //  ユーザーが項目をドラッグして並べ替えできるリストビューを構築するためのウィジェット。builder メソッドを使用して、動的にリスト項目を作成
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              // リストビューに表示するアイテムの数を指定。ここでは _homeworkList の要素数を設定
              itemCount: _homeworkList.length,
              // 各リストアイテムのビルド方法を定義するコールバック関数。この中で、ListTile を使用して各宿題を表示
              itemBuilder: (context, index) {
                // _homeworkList リストから、指定された index に対応する宿題オブジェクトを取得
                final homework = _homeworkList[index];
                // 宿題リストに付ける色を設定
                final Color oddItemColor = Colors.blue.withOpacity(0.05);
                final Color evenItemColor = Colors.blue.withOpacity(0.15);

                return ListTile(
                  key: ValueKey(homework), // リスト項目を一意に識別するためのキー
                  // リスト項目の背景色を奇数・偶数で交互に設定。 '?'は三項演算子。true の場合には oddItemColor, false の場合には evenItemColor を選択
                  tileColor: index.isOdd ? oddItemColor : evenItemColor,
                  // ドラッグするためのウィジェット
                  leading: ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle), // ドラッグハンドルのアイコン
                  ),
                  title: Text(homework.title), // 宿題のタイトルを表示
                  subtitle: Text(DateFormat.yMMMd()
                      .format(homework.dueDate)), // 宿題の期限を表示（日付をフォーマットして表示）
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, // 子要素が必要な最小の幅で配置される
                    children: [
                      Checkbox(
                        value: homework.isCompleted, // チェックボックスの初期値に設定
                        onChanged: (value) {
                          // 上で定義
                          _toggleCompletion(
                              index); // チェックボックスの状態が変更されたときの処理を呼び出す
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete), // 削除アイコンボタン
                        onPressed: () =>
                            _deleteHomework(index), // 削除アイコンボタンが押されたときの処理
                      ),
                    ],
                  ),
                );
              },
              onReorder: _reorderHomework, // 項目の並べ替えが行われたときの処理を指定
            ),
          ),
        ],
      ),
    );
  }
}
