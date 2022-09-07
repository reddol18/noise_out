import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoiseLogItem {
  DateTime atTime;
  double meanValue;
  double maxValue;
  int diffWalk;
  NoiseLogItem(
    {
      required this.atTime,
      required this.meanValue,
      required this.maxValue,
      required this.diffWalk
    }
  );
}

class NoiseLogs {
  List<NoiseLogItem> items = [];
  int secondsRange = 300;
  int level1 = 0;
  int level2 = 0;
  int level3 = 0;
  int upperStep = 100;
  int beforeStepCount = 0;
  Pedo pedo = Pedo();
  double latestValue = 0.0;
  String jibun = "";
  bool use_average = true;
  bool is_lowlevel = false;
  double get average {
    double ret = 0.0;
    if (items.isEmpty) return ret;
    for(NoiseLogItem item in items) {
      ret += item.meanValue;
    }
    return ret / items.length;
  }

  int get upperValue {
    DateTime nowTime = DateTime.now();
    if ((nowTime.hour >= 5 && nowTime.hour < 7) || (nowTime.hour >= 18 && nowTime.hour < 22)) {
      return level1;
    } else if (nowTime.hour >= 7 && nowTime.hour < 18) {
      return level2;
    }
    return level3;
  }

  int get sumOfWalk {
    int ret = 0;
    for(NoiseLogItem item in items) {
      ret += item.diffWalk;
    }
    return ret;
  }

  int get secondLength {
    if (items.isEmpty) return 0;
    return items[items.length-1].atTime.difference(items[0].atTime).inSeconds;
  }

  void clear() {
    items.clear();
    beforeStepCount = 0;
  }

  // 최근 N분이 아닌 값을 없앤다
  void deleteBefore() {
    if (items.isEmpty) return;
    DateTime now = DateTime.now();
    while(!items.isEmpty) {
      if (now.difference(items[0].atTime).inSeconds > secondsRange) {
        items.removeAt(0);
      } else {
        return;
      }
    }
  }
  // 평균 값이 기준 값을 넘는지 체크
  bool averageIsUp() {
    // 최근 N분이 아닌 값을 없앤다
    deleteBefore();
    // 평균값을 구해서 기준값이 넘는지 리턴
    return this.average >= upperValue && this.sumOfWalk <= upperStep;
  }
  // 최소 값이 모두 기준 값을 넘는지 체크
  bool minIsUp() {
    // 최근 N분이 아닌 값을 없앤다
    deleteBefore();
    // 모든 값을 순회해서 기준 값보다 넘는지 체크
    for(NoiseLogItem item in items) {
      if (item.meanValue < upperValue) {
        return false;
      }
    }
    return this.sumOfWalk <= upperStep;
  }

  void addLog(double meanValue, double maxValue) {
    latestValue = meanValue;
    items.add(NoiseLogItem(atTime: DateTime.now(), meanValue: meanValue, maxValue: maxValue, diffWalk: pedo.stepCounter - beforeStepCount));
    beforeStepCount = pedo.stepCounter;
  }

  Future<void> startLog() async {
    // 기준값을 sp에서 구해온다
    var prefs = await SharedPreferences.getInstance();
    level1 = await prefs.getInt("level1") ?? 65;
    level2 = await prefs.getInt("level2") ?? 70;
    level3 = await prefs.getInt("level3") ?? 55;

    secondsRange = await prefs.getInt("wait_second") ?? 300;
    upperStep = await prefs.getInt("max_walks") ?? 100;

    String gw = prefs.getString("selected_gw") ?? "";
    String sgg = prefs.getString("selected_sgg") ?? "";
    String umd = prefs.getString("selected_umd") ?? "";
    String ri = prefs.getString("selected_ri") ?? "";
    bool is_san = prefs.getBool("is_san") ?? false;
    String ad1 = prefs.getString("addr1") ?? "";
    String ad2 = prefs.getString("addr2") ?? "";

    jibun = gw + " " + sgg + " " + umd +
        (ri.isNotEmpty ? ri + " " : "") + (is_san ? "산 " : "") +
        ad1 + " " + ad2;
    jibun = jibun.trim();

    use_average = prefs.getBool("useAverage") ?? true;
    is_lowlevel = level2 <= 70;

    pedo.actionState = true;
    pedo.firstStepDone = false;
  }

  void stopLog() {
    clear();
    pedo.stepCounter = 0;
    pedo.actionState = false;
    pedo.firstStepDone = false;
  }
}

class Pedo {
  int stepCounter = 0;
  int beforeStepCount = 0;
  int fullStepCount = 0;
  bool firstStepDone = false;
  bool actionState = false;
  late Stream<StepCount> stepCountStream;
  Pedo() {
    stepCountStream = Pedometer.stepCountStream;
    stepCountStream.listen(onData).onError(onError);
  }
  void onData(StepCount event) {
      if (!firstStepDone) {
        fullStepCount = event.steps;
        firstStepDone = true;
      }
      int diff = event.steps - fullStepCount;
      // 직전 시각과 현재 시각을 비교해서 날짜가 지났으면 초기화
      if (actionState) {
        stepCounter += diff;
      }
      fullStepCount = event.steps;

  }

  void onError(err) {
    print("Step Error: $err");
  }
}