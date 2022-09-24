import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class landUseNoiseLevel {
  List<String> reason1 = [];
  List<String> reason2 = [];
  final landUseResult result;
  bool isLowLevel;
  landUseNoiseLevel({required this.result, required this.isLowLevel,
    required this.reason1, required this.reason2});
  bool checkIt(List<String> checkable) {
    for(dynamic field in result.fields) {
      if (checkable.contains(field['prposAreaDstrcCode'])) {
        return true;
      }
    }
    return false;
  }

  bool get isLivingArea {
    List<String> checkable = ["UQA100", "UQA110", "UQA111", "UQA112",
      "UQA120", "UQA121", "UQA122", "UQA123", "UQA130"];
    return checkIt(checkable);
  }

  bool get isGreenArea {
    List<String> checkable = ["UQA400", "UQA410", "UQA420", "UQA430"];
    return checkIt(checkable);
  }

  bool get isManageArea {
    List<String> checkable = ["UQB001", "UQA100", "UQA200", "UQA300",
      "UQA999"];
    return checkIt(checkable);
  }

  bool get isChwiRak {
    List<String> checkable = ["UQM100", "UQM110", "UQM120", "UQM999"];
    return checkIt(checkable);
  }

  bool get isLivingDev {
    List<String> checkable = ["UQM100", "UQM110", "UQM120", "UQM999"];
    return checkIt(checkable);
  }

  bool get isTravelDev {
    List<String> checkable = ["UQN110"];
    return checkIt(checkable);
  }

  bool get isPreserve {
    List<String> checkable = ["UQN140"];
    return checkIt(checkable);
  }

  bool get isSchool {
    List<String> checkable = ["UQV300", "UQV310", "UQV320", "UQV330",
      "UQV340", "UQV350", "UQV390"];
    return checkIt(checkable);
  }

  bool get isHospital {
    List<String> checkable = ["UQX510"];
    return checkIt(checkable);
  }

  bool get isLibrary {
    List<String> checkable = ["UQV410"];
    return checkIt(checkable);
  }

  double getDecibel(DateTime nowTime) {
    bool check1 = false;
    bool check2 = false;
    if (this.isLivingArea) {
      check1 = true;
      this.reason1.add("주거지역");
    }
    if (this.isGreenArea) {
      check1 = true;
      this.reason1.add("녹지지역");
    }
    if (this.isManageArea) {
      check1 = true;
      this.reason1.add("관리지역");
    }
    if (check1) {
      if (this.isChwiRak) {
        check2 = true;
        this.reason2.add("취락지구");
      }
      if (this.isLivingDev) {
        check2 = true;
        this.reason2.add("주거개발진흥지구");
      }
      if (this.isTravelDev) {
        check2 = true;
        this.reason2.add("관광-휴양개발진흥지구");
      }
      if (this.isPreserve) {
        check2 = true;
        this.reason2.add("자연환경보전지역");
      }
      if (this.isSchool) {
        check2 = true;
        this.reason2.add("학교");
      }
      if (this.isHospital) {
        check2 = true;
        this.reason2.add("종합병원");
      }
      if (this.isLibrary) {
        check2 = true;
        this.reason2.add("공공도서관");
      }
    }
    this.isLowLevel = check2;
    if ((nowTime.hour >= 5 && nowTime.hour < 7) || (nowTime.hour >= 18 && nowTime.hour < 22)) {
      return this.isLowLevel ? 60.0 : 65.0;
    } else if (nowTime.hour >= 7 && nowTime.hour < 18) {
      return this.isLowLevel ? 65.0 : 70.0;
    }
    return this.isLowLevel ? 50.0 : 55.0;
  }
}

class landUseResult {
  final List<dynamic> fields;
  landUseResult({required this.fields});

  factory landUseResult.fromJson(Map<String, dynamic> json) {
    return landUseResult(
        fields: json['landUses']['field']
    );
  }
}

class landUse {
  // 주거지역, 녹지지역, 관리지역 중
  // 취락지구, 주거개발진흥지구 및 관광 휴양개발진흥지구, 자연환경보전지역, 학교, 종합병원, 공공도서관
  final String key = "";
  final String url = "http://apis.data.go.kr/1611000/nsdi/LandUseService/attr/getLandUseAttr";


  Future<landUseResult> getLandUse(String pnu) async {
    Map<String, String> prms = {
      'serviceKey': key,
      'pnu': pnu,
      'format': 'json',
    };
    Map<String, String> header = {
      HttpHeaders.contentTypeHeader: "application/json; charset=UTF-8",
    };
    Uri finalUri = Uri.parse(url).replace(queryParameters: prms);
    Response response = await http.get(finalUri, headers: header);
    if (response.statusCode == 200) {
      String respString = utf8.decode(response.bodyBytes);
      return landUseResult.fromJson(json.decode(respString));
    } else {
      throw Exception('failed to load land use');
    }
  }
}
