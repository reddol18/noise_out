import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../land_use.dart';
import '../pnu.dart';

class OptionPage extends StatefulWidget {
  const OptionPage({Key? key}) : super(key: key);

  @override
  State<OptionPage> createState() => _OptionPage();
}

class _OptionPage extends State<OptionPage> {
  JiBunItem? _selectedGwangYeok = null;
  JiBunItem? _selectedSigungu = null;
  JiBunItem? _selectedUpMyeonDong = null;
  String _selectedRi = "";
  bool _isSan = false;
  String _addr1 = "";
  String _addr2 = "";
  bool _hasRi = false;
  String _info = "";
  int _level1 = 65;
  int _level2 = 70;
  int _level3 = 55;
  int _wait_second = 300;
  int _max_walks = 100;
  bool _useAverage = true;
  late dynamic prefs;
  PnuManager pm = PnuManager();
  List<JiBunItem> gwangYeoks = [];
  bool _nowSearch = true;

  late TextEditingController tc1 =
      TextEditingController(text: _level1.toString());
  late TextEditingController tc2 =
      TextEditingController(text: _level2.toString());
  late TextEditingController tc3 =
      TextEditingController(text: _level3.toString());
  late TextEditingController tc4 =
  TextEditingController(text: _wait_second.toString());
  late TextEditingController tc5 =
  TextEditingController(text: _max_walks.toString());
  late TextEditingController tcad1 =
    TextEditingController(text: "");
  late TextEditingController tcad2 =
    TextEditingController(text: "");

  Future<void> _selectGwangYeok(JiBunItem? value) async {
    await prefs.setString("selected_gw", value!.text);
    setState(() {
      _selectedGwangYeok = value!;
    });
  }

  // 광역시도 선택사항 표출
  Widget _getGwanyeokOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          flex: 3,
          child: Text("광역시도 선택"),
        ),
        Expanded(
          flex: 7,
          child: gwangYeoks.length > 0
              ? DropdownButton<JiBunItem>(
                  value: _selectedGwangYeok,
                  items: gwangYeoks.map((v) {
                    return DropdownMenuItem<JiBunItem>(
                        value: v, child: Text(v.text));
                  }).toList(),
                  onChanged: _selectGwangYeok)
              : SizedBox(),
        ),
      ],
    );
  }

  Future<void> _selectSigungu(JiBunItem? value) async {
    await prefs.setString("selected_sgg", value!.text);
    setState(() {
      _selectedSigungu = value!;
    });
  }

  // 시군구 선택사항 표출
  Widget _getSigunguOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          flex: 3,
          child: Text("시군구 선택"),
        ),
        Expanded(
          flex: 7,
          child: _selectedGwangYeok != null
              ? DropdownButton<JiBunItem>(
                  value: _selectedSigungu,
                  items: _selectedGwangYeok!.childs.map((v) {
                    return DropdownMenuItem<JiBunItem>(
                        value: v, child: Text(v.text));
                  }).toList(),
                  onChanged: _selectSigungu)
              : SizedBox(),
        ),
      ],
    );
  }

  Future<void> _selectUpMyeonDong(JiBunItem? value) async {
    await prefs.setString("selected_umd", value!.text);
    setState(() {
      _selectedUpMyeonDong = value!;
      _hasRi = value.childs.isNotEmpty;
    });
  }

  // 읍면동 선택사항 표출
  Widget _getUpMyeonDongOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          flex: 3,
          child: Text("읍면동 선택"),
        ),
        Expanded(
          flex: 7,
          child: _selectedSigungu != null
              ? DropdownButton<JiBunItem>(
                  value: _selectedUpMyeonDong,
                  items: _selectedSigungu!.childs.map((v) {
                    return DropdownMenuItem<JiBunItem>(
                        value: v, child: Text(v.text));
                  }).toList(),
                  onChanged: _selectUpMyeonDong)
              : SizedBox(),
        ),
      ],
    );
  }

  Future<void> _selectRi(String? value) async {
    await prefs.setString("selected_ri", value);
    setState(() {
      _selectedRi = value!;
    });
  }

  // 리 선택사항 표출
  Widget _getRiOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          flex: 3,
          child: Text("리 선택"),
        ),
        Expanded(
          flex: 7,
          child: _selectedUpMyeonDong != null
              ? DropdownButton(
                  value: _selectedRi,
                  items: _selectedUpMyeonDong!.childs.map((v) {
                    return DropdownMenuItem(value: v.text, child: Text(v.text));
                  }).toList(),
                  onChanged: _selectRi)
              : SizedBox(),
        ),
      ],
    );
  }

  // 추가 주소 입력창 표출
  Widget _getAnothers() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          flex: 1,
          child: Checkbox(
            value: _isSan,
            onChanged: (value) async {
              await prefs.setBool("is_san", value);
              setState(() {
                _isSan = value!;
              });
            },
          ),
        ),
        Expanded(flex: 1, child: Text("산")),
        Expanded(
          flex: 4,
          child: new TextField(
            controller: tcad1,
            onChanged: (value) async {
              await prefs.setString("addr1", value);
              setState(() {
                _addr1 = value;
              });
            },
            decoration: new InputDecoration(labelText: "본주소 입력"),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ], // Only numbers can be entered
          ),
        ),
        Expanded(
          flex: 4,
          child: new TextField(
            controller: tcad2,
            onChanged: (value) async {
              await prefs.setString("addr2", value);
              setState(() {
                _addr2 = value;
              });
            },
            decoration: new InputDecoration(labelText: "부주소 입력"),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ], // Only numbers can be entered
          ),
        )
      ],
    );
  }

  // 입력된 수조를 바탕으로 데시벨 기준을 구한다
  Future<void> _getLevelByApi() async {
    setState(() {
      _nowSearch = true;
    });
    String? front = pm.getFrontPnu(_selectedGwangYeok!.text +
        " " +
        _selectedSigungu!.text +
        " " +
        _selectedUpMyeonDong!.text +
        (_hasRi ? " " + _selectedRi : ""));
    String pnu = pm.makePnu(front!, _isSan, _addr1, _addr2);
    landUse temp = landUse();
    bool isLowLevel = false;
    String reason1 = "";
    String reason2 = "";
    bool noResult = false;
    try {
      landUseResult lur = await temp.getLandUse(pnu);
      landUseNoiseLevel lunl = landUseNoiseLevel(
          result: lur, isLowLevel: false, reason1: [], reason2: []);
      lunl.getDecibel(DateTime.now());
      isLowLevel = lunl.isLowLevel;
      reason1 = lunl.reason1.join(",");
      reason2 = lunl.reason2.join(",");
    } catch (e) {
      noResult = true;
    }
    setState(() {
      if (isLowLevel) {
        _info = "해당 주소지는 " +
            reason1 +
            "에 해당하며 " +
            reason2 +
            "에 해당합니다. 아래와 같은 기준으로 소음측정 해주세요.";
        _level1 = 60;
        _level2 = 65;
        _level3 = 50;
      } else if (!noResult) {
        _info = "아래와 같은 기준으로 소음측정 해주세요.";
        _level1 = 65;
        _level2 = 70;
        _level3 = 55;
      } else {
        _info = "주소입력이 잘못된것 같아요. 정확하게 입력해주세요.";
        _level1 = 65;
        _level2 = 70;
        _level3 = 55;
      }
      tc1.text = _level1.toString();
      tc2.text = _level2.toString();
      tc3.text = _level3.toString();
      _nowSearch = false;
    });
    await prefs.setInt("level1", _level1);
    await prefs.setInt("level2", _level2);
    await prefs.setInt("level3", _level3);
  }

  // 데시벨 기준이 된 근거를 표시
  Widget _getInfos() {
    return Text(_info);
  }

  // 수동으로 데시벨 기준을 설정하는 입력창 표출
  Widget _getSetLevels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          flex: 3,
          child: new TextField(
            controller: tc1,
            onChanged: (value) async {
              int intVal = int.parse(value);
              await prefs.setInt("level1", intVal);
              setState(() {
                _level1 = intVal;
              });
            },
            decoration: new InputDecoration(labelText: "5~7,18~22시"),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ], // Only numbers can be entered
          ),
        ),
        Expanded(
          flex: 3,
          child: new TextField(
            controller: tc2,
            onChanged: (value) async {
              int intVal = int.parse(value);
              await prefs.setInt("level2", intVal);
              setState(() {
                _level2 = intVal;
              });
            },
            decoration: new InputDecoration(labelText: "7~18시"),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ], // Only numbers can be entered
          ),
        ),
        Expanded(
          flex: 3,
          child: new TextField(
            controller: tc3,
            onChanged: (value) async {
              int intVal = int.parse(value);
              await prefs.setInt("level3", intVal);
              setState(() {
                _level3 = intVal;
              });
            },
            decoration: new InputDecoration(labelText: "22~5시"),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ], // Only numbers can be entered
          ),
        )
      ],
    );
  }

  // 대기시간과 허용최대 이동보행수 설정
  Widget _getWaitAndWalks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          flex: 5,
          child: new TextField(
            controller: tc4,
            onChanged: (value) async {
              int intVal = int.parse(value);
              await prefs.setInt("wait_second", intVal);
              setState(() {
                _wait_second = intVal;
              });
            },
            decoration: new InputDecoration(labelText: "측정시간(초)"),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ], // Only numbers can be entered
          ),
        ),
        Expanded(
          flex: 5,
          child: new TextField(
            controller: tc5,
            onChanged: (value) async {
              int intVal = int.parse(value);
              await prefs.setInt("max_walks", intVal);
              setState(() {
                _max_walks = intVal;
              });
            },
            decoration: new InputDecoration(labelText: "허용 보행수"),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ], // Only numbers can be entered
          ),
        ),
      ],
    );
  }


  // 평균값을 이용할지, 최소값을 이용할지 설정창
  Widget _getAverageOrMinSet() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Expanded(
        flex: 1,
        child: Checkbox(
          value: _useAverage,
          onChanged: (value) async {
            await prefs.setBool("useAverage", value);
            setState(() {
              _useAverage = value!;
            });
          },
        ),
      ),
      Expanded(flex: 9, child: Text("평균값 이용(해제시 최소값 이용)")),
    ]);
  }

  bool get canSearch {
    return _selectedGwangYeok != null &&
        _selectedSigungu != null &&
        _selectedUpMyeonDong != null &&
        (_hasRi ? _selectedRi.isNotEmpty : true) &&
        _addr1.isNotEmpty;
  }

  List<Widget> getContent() => <Widget>[
        Container(
            margin: EdgeInsets.all(25),
            child: Column(children: [
              Container(
                child: _getGwanyeokOptions(),
                margin: EdgeInsets.only(top: 8),
              ),
              Container(
                child: _getSigunguOptions(),
                margin: EdgeInsets.only(top: 8),
              ),
              Container(
                child: _getUpMyeonDongOptions(),
                margin: EdgeInsets.only(top: 8),
              ),
              Container(
                child: _hasRi ? _getRiOptions() : SizedBox(),
                margin: EdgeInsets.only(top: 8),
              ),
              Container(
                child: _getAnothers(),
                margin: EdgeInsets.only(top: 8),
              ),
              Container(
                child: canSearch
                    ? TextButton(
                        child: Text("주소지 기준 데시벨 구하기"),
                        onPressed: () {
                          _getLevelByApi();
                        },
                      )
                    : Text("주소지 기준 데시벨 구하기",
                        style: TextStyle(color: Colors.black12)),
                margin: EdgeInsets.only(top: 8),
              ),
              Container(
                child: _getInfos(),
                margin: EdgeInsets.only(top: 8),
              ),
              Container(
                child: _getSetLevels(),
                margin: EdgeInsets.only(top: 8),
              ),
              Container(
                child: _getWaitAndWalks(),
                margin: EdgeInsets.only(top: 8),
              ),
              Container(
                child: _getAverageOrMinSet(),
                margin: EdgeInsets.only(top: 8),
              ),
            ]))
      ];

  Future<void> loadPm() async {
    prefs = await SharedPreferences.getInstance();
    await pm.loadData();
    String gw = prefs.getString("selected_gw") ?? "";
    String sgg = prefs.getString("selected_sgg") ?? "";
    String umd = prefs.getString("selected_umd") ?? "";
    String ri = prefs.getString("selected_ri") ?? "";
    bool is_san = prefs.getBool("is_san") ?? false;
    String ad1 = prefs.getString("addr1") ?? "";
    String ad2 = prefs.getString("addr2") ?? "";
    setState(() {
      gwangYeoks = pm.gwangYeoks;
      if (gw.isNotEmpty) {
        // 광역시도 자동 고르기
        int index = gwangYeoks
            .lastIndexWhere((JiBunItem element) => element.text == gw);
        if (index != -1) {
          _selectedGwangYeok = gwangYeoks[index];
          if (sgg.isNotEmpty) {
            // 시군구 자동 고르기
            int index = _selectedGwangYeok!.childs
                .lastIndexWhere((JiBunItem element) => element.text == sgg);
            if (index != -1) {
              _selectedSigungu = _selectedGwangYeok!.childs[index];
              if (umd.isNotEmpty) {
                // 읍면동 자동 고르기
                int index = _selectedSigungu!.childs
                  .lastIndexWhere((JiBunItem element) => element.text == umd);
                if (index != -1) {
                  _selectedUpMyeonDong = _selectedSigungu!.childs[index];
                  if (_selectedUpMyeonDong!.childs.isNotEmpty && ri.isNotEmpty) {
                    _hasRi = true;
                    // 리 자동고르기
                    int index = _selectedUpMyeonDong!.childs
                      .lastIndexWhere((JiBunItem element) => element.text == ri);
                    if (index != -1) {
                      _selectedRi = _selectedUpMyeonDong!.childs[index].text;
                    }
                  }
                }
              }
            }
          }
        }
      }
      _isSan = is_san;
      _addr1 = ad1;
      tcad1.text = ad1;
      _addr2 = ad2;
      tcad2.text = ad2;
      _level1 = prefs.getInt("level1") ?? 65;
      tc1.text = _level1.toString();
      _level2 = prefs.getInt("level2") ?? 70;
      tc2.text = _level2.toString();
      _level3 = prefs.getInt("level3") ?? 55;
      tc3.text = _level3.toString();
      _wait_second = prefs.getInt("wait_second") ?? 300;
      tc4.text = _wait_second.toString();
      _max_walks = prefs.getInt("max_walks") ?? 100;
      tc5.text = _max_walks.toString();
      _useAverage = prefs.getBool("useAverage") ?? true;
      _nowSearch = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadPm();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("설정화면"),
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
        isLoading: _nowSearch,
      ),
    );
  }
}
