import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../db/db_helper.dart';
import 'gov_service.dart';

Route goGovService() {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => GovService(),
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


class LogDetail extends StatefulWidget {
  final DbHelper dbHelper;
  final int id;
  const LogDetail(this.dbHelper, this.id);

  @override
  State<LogDetail> createState() => _LogDetail();
}

class _LogDetail extends State<LogDetail> {
  bool _nowSearch = false;
  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  Future<LogItem?> _getLogItem() async {
    LogItem? item = await widget.dbHelper.getLogItem(widget.id);
    return item;
  }

  Widget _infoPanel() {
    return FutureBuilder<LogItem?>(
        future: _getLogItem(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            LogItem trg = snapshot.data!;
            String dtStr = "${trg.year}-${trg.month}-${trg.hour} " +
                "${trg.hour}:${trg.minute}:${trg.second}";
            String decStr = (trg.use_average ? "평균 " : "최소값 ") + "${trg.noise.toStringAsFixed(2)} 데시벨" ;
            return Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("측정주소 : " + snapshot.data!.jibun),
                  Text("측정일시 : " + dtStr),
                  Text("측정값 : " + decStr),
                  Text("좌표 : " + trg.lng.toString() + "," + trg.lng.toString()),
                  Text("이동거리 : " + trg.walks.toString() + " 보"),
                  Text("측정기간 : " + trg.duration.toString() + " 초"),
                ],
              )
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }

  Widget _btnsPanel() {
    return TextButton(
      child: Text("민원접수"),
      onPressed: () {
        Navigator.push(context, goGovService());
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("소음측정치 초과 기록 상세정보"),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _infoPanel(),
              _btnsPanel(),
            ],
          ),
        ),
        isLoading: _nowSearch,
      ),
    );
  }
}