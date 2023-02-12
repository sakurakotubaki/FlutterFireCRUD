import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:counter/repository/data_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeList(),
    );
  }
}

class HomeList extends StatelessWidget {
  const HomeList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // リポジトリクラスをインスタンス化する.
    final DataRepository repository = DataRepository();
    // Formの値を保存するTextEditingController.
    TextEditingController title = TextEditingController();
    TextEditingController description = TextEditingController();

    return Scaffold(
        appBar: AppBar(
          title: Text('お菓子アプリ'),
        ),
        body: Center(
            child: Column(
          children: [
            TextField(
              controller: title,
            ),
            TextField(
              controller: description,
            ),
            ElevatedButton(
                onPressed: () async {
                  repository.addItem(title.text, description.text);
                },
                child: Text('アイテムを追加')),
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
              stream: repository.getStream(),// メソッドでデータを全て取得.
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');// エラー処理.
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();// ローディング処理.
                }

                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    return ListTile(
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () async {
                                  // 編集用Modal
                                  showModalBottomSheet<void>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SizedBox(
                                        height: 800,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              const Text('アイテムを編集'),
                                              TextFormField(
                                                controller: title,
                                                decoration:
                                                    const InputDecoration(
                                                  border:
                                                      UnderlineInputBorder(),
                                                  labelText: 'アイテムを入力',
                                                ),
                                              ),
                                              TextFormField(
                                                controller: description,
                                                decoration:
                                                    const InputDecoration(
                                                  border:
                                                      UnderlineInputBorder(),
                                                  labelText: '解説を入力してください',
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                              ElevatedButton(
                                                  onPressed: () async {
                                                    // ドキュメントidを取得する変数.
                                                    final id =
                                                        document.reference.id;
                                                    repository.updateItem(
                                                        id,
                                                        title.text,
                                                        description.text);
                                                  },
                                                  child: Text('編集')),
                                              SizedBox(height: 20),
                                              ElevatedButton(
                                                child: const Text('閉じる'),
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.blueAccent,
                                )),
                            // 削除ボタン.
                            IconButton(
                              onPressed: () async {
                                // ドキュメントidを取得する変数.
                                final id = document.reference.id;
                                repository.deleteItem(id);
                              },
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ),
                      title: Text(data['title']),// タイトルを表示.
                      subtitle: Text(data['description']),// 解説を表示.
                    );
                  }).toList(),
                );
              },
            )),
          ],
        )));
  }
}
