import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:state_tutorial/model/note_model.dart';
import 'package:state_tutorial/theme/my_color.dart';
import 'package:state_tutorial/ui/create_note.dart';
import 'package:state_tutorial/utils/note_repository.dart';

class NotePage extends StatelessWidget {
  const NotePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final noteRepository = NoteRepository();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColor.myColor,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const CreateNote(),
                fullscreenDialog: true,
              ));
            },
            icon: const Icon(Icons.add),
            color: MyColor.myFontColor,
          )
        ],
        title: Text('note', style: TextStyle(color: MyColor.myFontColor)),
      ),
      body: StreamBuilder<QuerySnapshot<NoteModel>>(
        // クラスを型として使う.
        stream: notesRef.snapshots(), // withConverterのデータをstreamで流す.
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.requireData;

          return ListView.builder(
            // ListView.builderで画面に描画する.
            itemCount: data.size,
            itemBuilder: (context, index) {
              // ListView.builderのListTileを
              // Slidableでラップする.
              // ここからSlidable.
              return Slidable(
                  key: const ValueKey(0),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    // childrenの中にボタンを書く.
                    children: [
                      // 種類ボタン.
                      SlidableAction(
                        onPressed: (value) {},
                        backgroundColor: Colors.green,
                        icon: Icons.category,
                        label: '種類',
                      ),
                      // 編集ボタン.
                      SlidableAction(
                        onPressed: (value) {},
                        backgroundColor: Colors.blue,
                        icon: Icons.edit,
                        label: '編集',
                      ),
                      // 削除ボタン
                      SlidableAction(
                        onPressed: (value) {
                          final id = data.docs[index].reference.id;

                          noteRepository.deleteItem(id);
                        },
                        backgroundColor: Colors.red,
                        icon: Icons.delete,
                        label: '削除',
                      ),
                    ],
                  ),
                  // ここからListTileを書く.
                  child: ListTile(
                    title: Text(data.docs[index]
                        .data()
                        .title), // Movieクラスのtitleプロパティを使う.
                    subtitle: Row(
                      children: [
                        Text(data.docs[index].data().description),
                        const SizedBox(width: 20),
                        // .toStringだと変な文字になるので、.toDate()の後に
                        // .と入力してString型に変換するコードを選ぶ.
                        Text(data.docs[index]
                            .data()
                            .createdAt
                            .toDate()
                            .toUtc()
                            .toIso8601String())
                      ],
                    ), // Movieクラスのgenreプロパティを使う.
                  ));
              // ここまでSlidable.
            },
          );
        },
      ),
    );
  }
}
