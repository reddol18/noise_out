import 'dart:io';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:path_provider/path_provider.dart';

import '../db/db_helper.dart';
import 'gov_service.dart';
import 'dart:io' as io;

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
  GlobalKey rpbKey = GlobalKey();
  late var _extDir;
  bool canCapture = false;
  bool hasGraphImage = false;
  bool _onPlay = false;
  AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    player.onPlayerComplete.listen((event) {
      setState(() {
        _onPlay = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<LogItem?> _getLogItem() async {
    _extDir = await getApplicationDocumentsDirectory();
    final String filename = _extDir.path + "/noise_out_" + widget.id.toString() +
        ".png";
    bool hasFile = await File(filename).exists();
    setState(() {
      canCapture = true;
      hasGraphImage = hasFile;
    });
    LogItem? item = await widget.dbHelper.getLogItem(widget.id);
    return item;
  }

  String getImageUri(int id) {
    final String filename = _extDir.path + "/noise_out_" + id.toString() +
        ".png";
    return filename;
  }

  Widget getImage() {
    return hasGraphImage ? Image.file(
      File(getImageUri(widget.id)),
    ) : SizedBox();
  }

  Widget _infoPanel() {
    return FutureBuilder<LogItem?>(
        future: _getLogItem(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            LogItem trg = snapshot.data!;
            String dtStr = "${trg.year}-${trg.month}-${trg.day} " +
                "${trg.hour}:${trg.minute}:${trg.second}";
            String decStr = (trg.use_average ? "평균 " : "최소값 ") + "${trg.noise.toStringAsFixed(2)} 데시벨" ;
            return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      image: DecorationImage(
                        colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.1), BlendMode.dstATop),
                        image: AssetImage("assets/favicon.png"),
                      ),
                      border: Border.all(
                        width: 1,
                        color: Colors.black26,
                      ),
                    ),
                    child:
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child:
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("측정주소 : " + snapshot.data!.jibun),
                            Text("측정일시 : " + dtStr),
                            Text("측정값 : " + decStr),
                            Text("좌표 : " + trg.lat.toString() + "," + trg.lng.toString()),
                            Text("이동거리 : " + trg.walks.toString() + " 보"),
                            Text("측정기간 : " + trg.duration.toString() + " 초"),
                            getImage(),
                          ],
                    )
                  )
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }

  Widget _saveBtnsPanel() {
    return ElevatedButton(
      child: Text("기록 인증서 저장", style: TextStyle(
        color: canCapture ? Colors.white : Colors.black12,
      )),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((state) {
            return state.contains(MaterialState.pressed) ? Colors.deepOrangeAccent : Colors.red;
          })
      ),
      onPressed: () async {
        if (canCapture) {
          final boundary = rpbKey.currentContext
              ?.findRenderObject() as RenderRepaintBoundary?;
          final image = await boundary?.toImage();
          final byteData = await image?.toByteData(format: ImageByteFormat.png);
          final imageBytes = byteData?.buffer.asUint8List();
          if (imageBytes != null) {
            final String filename = _extDir.path + "/noise_out_result" +
                widget.id.toString() +
                ".png";
            await File(filename).writeAsBytes(imageBytes);
            final params = SaveFileDialogParams(sourceFilePath: filename);
            await FlutterFileDialog.saveFile(params: params);
          }
        }
      },
    );
  }

  Widget _playBtnPanel() {
    return Padding(
        padding: const EdgeInsets.all(4.0),
        child:
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(child: Padding(
                  padding: EdgeInsets.all(10),
                  child: ElevatedButton.icon(
                      onPressed: () async {
                        if (_onPlay) {
                          await player.pause();
                          setState(() {
                            _onPlay = false;
                          });
                        } else {
                          final String destFile = _extDir.path + "/noise_out_audio${widget.id}.mp3";
                          await player.play(DeviceFileSource(destFile));
                          setState(() {
                            _onPlay = true;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        onPrimary: Colors.black,
                      ),
                      icon: Icon(
                        !_onPlay ? Icons.play_circle_outline : Icons.pause_circle_outline,
                        size: 16,
                      ),
                      label: Text("녹음파일", style: TextStyle(color: Colors.black)))
                ), flex: 5),
                Expanded(flex: 5,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: ElevatedButton(
                    child: Text("녹음파일 저장",
                        style: TextStyle(
                          color: canCapture ? Colors.white : Colors.black12,
                        )),
                    style: ButtonStyle(backgroundColor:
                        MaterialStateProperty.resolveWith((state) {
                      return state.contains(MaterialState.pressed)
                          ? Colors.deepOrangeAccent
                          : Colors.red;
                    })),
                    onPressed: () async {
                      if (canCapture) {
                        final String filename = _extDir.path +
                            "/noise_out_audio" +
                            widget.id.toString() +
                            ".mp3";
                        final params =
                            SaveFileDialogParams(sourceFilePath: filename);
                        await FlutterFileDialog.saveFile(params: params);
                      }
                    },
                )),)
              ],
            ),
    );
  }

  Widget _btnsPanel() {
    return ElevatedButton(
      child: Text("민원접수"),
      onPressed: () {
        Navigator.push(context, goGovService());
      },
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((state) {
            return state.contains(MaterialState.pressed) ? Colors.deepOrangeAccent : Colors.red;
          })
      ),
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
              RepaintBoundary(
                key: rpbKey,
                child: _infoPanel(),
              ),
              _playBtnPanel(),
              _saveBtnsPanel(),
              _btnsPanel(),
            ],
          ),
        ),
        isLoading: _nowSearch,
      ),
    );
  }
}