import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:advanced_navigator/advanced_navigator.dart';
import 'package:external_path/external_path.dart';
import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:location/location.dart';
import 'package:noise_out/views/gov_service.dart';
import 'package:noise_out/views/log_list.dart';
import 'package:noise_out/views/options.dart';
import 'package:noise_out/widgets/noise_chart.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart' as perm_handle;
import 'package:wakelock/wakelock.dart';
import 'package:wav/wav.dart';
import 'db/db_helper.dart';
import 'noise_log.dart';
import 'noise_meter.dart';
import 'dart:math' as _math;
import 'dart:math';
import 'package:convert/convert.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  ); // To turn off landscape mode
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MyHomePage(title: '건축소음 측정기'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _decValue = 0.0;
  bool _isRecording = false;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  NoiseLogs noiseLogs = NoiseLogs();
  late NoiseMeter _noiseMeter;
  double averageValue = 0.0;
  double maxValue = 30.0;
  int secondLength = 0;
  bool byAverage = false;
  bool byMin = false;
  int step = 0;
  late Timer _timer;
  late List<ChartData> chartData;
  bool _nowProgress = false;
  final DbHelper dbHelper = DbHelper();
  late BuildContext _gctx;
  Location location = new Location();
  bool _locEnabled = false;
  late PermissionStatus _perm;
  late LocationData _locData;
  GlobalKey<NoiseChartState> noiseChartCtrl = GlobalKey();
  late File tempWavFile;
  static FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  late DateTime second_on_start;
  List<List<int>> chunkToSave = [];

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    startLocation();
    startDb();
    chartData = [];
    _noiseMeter = new NoiseMeter(onError);
  }

  Future<void> startLocation() async {
    _locEnabled = await location.serviceEnabled();
    if (!_locEnabled) {
      _locEnabled = await location.requestService();
      if (!_locEnabled) {
        return;
      }
    }
    _perm = await location.hasPermission();
    if (_perm == PermissionStatus.denied) {
      _perm = await location.requestPermission();
      if (_perm != PermissionStatus.granted) {
        return;
      }
    }
  }

  Future<void> startDb() async {
    await dbHelper.openDb();
  }

  @override
  void dispose() {
    dbHelper.close();
    _noiseSubscription?.cancel();
    _timer?.cancel();
    Wakelock.disable();
    super.dispose();
  }

  void addChartData() {
    setState(() {
      maxValue =
          noiseLogs.latestValue > maxValue ? noiseLogs.latestValue : maxValue;
      if (chartData.length > noiseLogs.secondsRange) {
        chartData.removeAt(0);
      }
      try {
        DateTime current = DateTime.now();
        chartData.add(ChartData(
            current.difference(second_on_start).inSeconds,
            noiseLogs.latestValue));
      } catch(e) {
        print("chart data add error: " + e.toString());
      }
    });
  }

  void startRecord() async {
    setState(() {
      _nowProgress = true;
    });
    try {
      if (_locEnabled && _perm == PermissionStatus.granted) {
        _locData = await location.getLocation();
      }
      chunkToSave = [];
      setState(() {
        chartData = [];
      });
      final io.Directory extDir = await getApplicationDocumentsDirectory();
      final String destFile = extDir.path + "/temp.raw";
      tempWavFile = File(destFile);
      await tempWavFile.delete();
      await tempWavFile.create();

      noiseLogs.startLog();
      second_on_start = DateTime.now();
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
    } catch (exception) {
      print(exception);
    }
    _timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      if (_isRecording) {
        addChartData();
      }
    });
    setState(() {
      _nowProgress = false;
    });
  }

  String _put(int n, int l) {
    final _n = n.toRadixString(16);
    final __n = List<String>.filled(l * 2 - _n.length, "0").join() + _n;
    return String.fromCharCodes(hex.decode(__n)
        .reversed
        .toList());
  }

  Future<void> cutAudioFile(int length) async {
    try {
      int lengthToRest = length * 44100 * 2;
      int size = 0;
      int cutIndex = -1;
      for (int i=chunkToSave.length-1;i>=0;i--) {
        size += chunkToSave[i].length;
        if (size > lengthToRest) {
          cutIndex = i;
          break;
        }
      }
      for (int k=0;k<=cutIndex;k++) {
        chunkToSave.removeAt(0);
      }
    } catch(e) {
      print("Cut Error: " + e.toString());
    }
  }

  // TODO 시작 시간과 순간 소음값을 가지는 클래스 정의
  // TODO 연속기록을 저장하는 클래스 정의, 평균기준, 최소값 기준 두 개를 유지해야 함
  // TODO 그래프로 보여줘야 함
  // TODO 최근 5분의 데이터만 유지하는 함수
  // TODO 현재시각에 맞춰 5분 평균 데시벨 기준 체크, 옵션에 최소값 기준도 추가

  // TODO 현재 위치의 토지용도를 체크하는 API와 통신
  // TODO 토지 용도별 기준 반환 함수

  // TODO 소음 기준 초과시 서버로 정보 REST 통신
  // TODO 소음 기준 초과시 자치구로 신고 : 자동화 할 수 있으면 방법을 뚫어보고 안되면 안내팝업

  void onData(NoiseReading noiseReading) {
    List<int> temp1 = noiseReading.chunks;
    chunkToSave.add(temp1);
    this.setState(() {
      if (!_isRecording) {
        _isRecording = true;
      }
      _decValue = noiseReading.meanDecibel;
      noiseLogs.addLog(noiseReading.meanDecibel, noiseReading.maxDecibel);
      byAverage = noiseLogs.averageIsUp();
      averageValue = noiseLogs.average;
      byMin = noiseLogs.minIsUp();
      step = noiseLogs.sumOfWalk;
      secondLength = noiseLogs.secondLength;
      DateTime nowTime = DateTime.now();
      if (secondLength >= noiseLogs.secondsRange) {
        cutAudioFile(secondLength);
        if ((noiseLogs.use_average && byAverage )|| (!noiseLogs.use_average && byMin)) {
          LogItem trg = LogItem(
            id: 0,
            walks: step,
            year: nowTime.year,
            month: nowTime.month,
            day: nowTime.day,
            hour: nowTime.hour,
            minute: nowTime.minute,
            second: nowTime.second,
            noise: noiseLogs.average,
            use_average: noiseLogs.use_average,
            jibun: noiseLogs.jibun,
            is_lowlevel: noiseLogs.is_lowlevel,
            lat: _locData!.latitude!.toDouble(),
            lng: _locData!.longitude!.toDouble(),
            duration: secondLength,
          );
          stopRecorder();
          saveDataAndImageAndAudio(trg);

          showTextToast(text: "소음기준치 초과! 기록을 저장했습니다.", context: _gctx);

        }
      }
    });
  }

  Future<void> saveAudio(String id) async {
    try {
      final io.Directory extDir = await getApplicationDocumentsDirectory();
      final String srcFile = extDir.path + "/temp.raw";
      File file1 = File(srcFile);
      if (await file1.exists()) {
        List<int> temp = [];
        for(var chunk in chunkToSave) {
          temp = temp + chunk;
        }
        await file1.writeAsBytes(temp, mode: FileMode.writeOnlyAppend);
      }
      final String destFile = extDir.path + "/noise_out_audio" + id + ".mp3";
      File file2 = File(destFile);
      if (await file2.exists()) {
        file2.delete();
      }
      await _flutterFFmpeg.execute("-f s16be -ar 44100 -ac 1 -i ${srcFile} "
          + "-ar 44100 -ac 2 -b:a 320k -c:a libmp3lame ${destFile}");
    } catch(e) {
      print(e.toString());
    }
  }

  Future<void> saveDataAndImageAndAudio(LogItem item) async {
    LogItem ret = await dbHelper.add(item);
    await noiseChartCtrl.currentState?.saveAsImage(ret.id);
    await saveAudio(item.id.toString());
  }

  void onError(Object error) {
    print(error.toString());
    _isRecording = false;
  }

  List<Widget> getContent() => <Widget>[
        Expanded(
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(children: [
                Container(
                  height: 40,
                  child: Text(
                      _isRecording
                          ? _decValue.toStringAsFixed(2) + " db"
                          : "Mic: OFF",
                      style: TextStyle(fontSize: 25, color: Colors.redAccent)),
                  margin: EdgeInsets.only(top: 20),
                ),
                Container(
                  height: 15,
                  child: Text(averageValue.toStringAsFixed(2) + " db",
                      style: TextStyle(fontSize: 15, color: Colors.deepOrangeAccent)),
                  margin: EdgeInsets.only(top: 20),
                ),
                Container(
                  height: 30,
                  child: Text(byAverage ? "평균초과" : "평균미달",
                      style: TextStyle(fontSize: 18, color: Colors.black)),
                  margin: EdgeInsets.only(top: 10),
                ),
                Container(
                  height: 20,
                  child: Text(byMin ? "최소초과" : "최소미달",
                      style: TextStyle(fontSize: 15, color: Colors.black)),
                  margin: EdgeInsets.only(top: 20),
                ),
                Container(
                  height: 15,
                  child: Text(step.toString() + " 걸음",
                      style: TextStyle(fontSize: 13, color: Colors.black54)),
                  margin: EdgeInsets.only(top: 20),
                ),
                Container(
                  height: 15,
                  child: Text(secondLength.toString() + " s",
                      style: TextStyle(fontSize: 13, color: Colors.black54)),
                  margin: EdgeInsets.only(top: 10),
                ),
                Container(
                  height: 300,
                  child: NoiseChart(
                    key: noiseChartCtrl,
                    maxValue: maxValue,
                    values: chartData,
                    xInterval: chartData.length > 100 ? 30 : 5,
                    levelValue: noiseLogs.upperValue,
                  ),
                  margin: EdgeInsets.only(top: 10),
                ),
                _isRecording ? SizedBox() : Container(
                  child: _bottomButtons(),
                  margin: EdgeInsets.only(top: 10),
                ),
              ])),
        ),
      ];

  Widget _bottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          flex: 5,
          child: TextButton(
            child: Text("기준 데시벨 확인",
                style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => OptionPage()));
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith((state) {
                return state.contains(MaterialState.pressed) ? Colors.black12 : Colors.white;
              })
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: TextButton(
            child: Text("민원접수",
                style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => GovService()));
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((state) {
                  return state.contains(MaterialState.pressed) ? Colors.black12 : Colors.white;
                })
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: SizedBox(),
        ),
      ],
    );
  }

  Future<void> stopRecorder() async {
    try {
      setState(() {
        _isRecording = false;
        _nowProgress = true;
      });
      if (_noiseSubscription != null) {
        await _noiseSubscription!.cancel();
        _noiseSubscription = null;
      }
      noiseLogs.stopLog();
    } catch (err) {
      print('stopRecorder error: $err');
    } finally {
      setState(() {
        _nowProgress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _gctx = context;
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        backgroundColor: Colors.redAccent,
        actions: _isRecording ? [] : <Widget>[
          new IconButton(
            icon: new Icon(Icons.book_outlined),
            tooltip: "신고상황 발생 기록",
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LogList(dbHelper)));
            },
          ),
        ],
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
            children: getContent(),
          ),
        ),
        isLoading: _nowProgress,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _isRecording ? Colors.red : Colors.black,
        onPressed: _isRecording ? stopRecorder : startRecord,
        child: _isRecording ? Icon(Icons.stop) : Icon(Icons.mic),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
