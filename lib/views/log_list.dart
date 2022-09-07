import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../db/db_helper.dart';
import 'log_detail.dart';

Route goLogDetail(DbHelper dbHelper, int id) {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => LogDetail(dbHelper, id),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      });
}


class LogList extends StatefulWidget {
  final DbHelper dbHelper;
  const LogList(this.dbHelper);

  @override
  State<LogList> createState() => _LogList();
}

class _LogList extends State<LogList> {
  bool _nowSearch = false;
  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  Widget _listItem(LogItem trg) {
    String dtStr = "${trg.year}-${trg.month}-${trg.hour} " +
        "${trg.hour}:${trg.minute}:${trg.second}";
    String decStr = (trg.use_average ? "평균 " : "최소값 ") + "${trg.noise.toStringAsFixed(2)} 데시벨" ;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
            flex: 4,
            child: Text(
                dtStr
            )
        ),
        Expanded(
            flex: 4,
            child: Text(
                decStr
            )
        ),
        Expanded(
          flex:2,
          child: TextButton(
            onPressed: () async {
              Navigator.push(context, goLogDetail(widget.dbHelper, trg.id));
            },
            child: Text("상세정보"),
          ),
        )
      ],
    );
  }

  Future<List<LogItem>> _getLogItems() async {
    List<LogItem> logItems = await widget.dbHelper.getLogItems();
    return logItems;
  }

  Widget _makeListView() {
    return FutureBuilder<List<LogItem>>(
        future: _getLogItems(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.length > 0) {
              return ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, index) {
                    return _listItem(snapshot.data![index]);
                  });
            } else {
              return SizedBox();
            }
          } else {
            return CircularProgressIndicator();
          }
        });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("소음측정치 초과 기록"),
      ),
      body: LoadingOverlay(
        child: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: _makeListView()
                )
              ),
            ],
          ),
        ),
        isLoading: _nowSearch,
      ),
    );
  }
}