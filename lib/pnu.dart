import 'package:flutter/services.dart' show rootBundle;

class JiBunItem {
  String text = "";
  List<JiBunItem> childs = [];
}

class PnuManager {
  Map<String, String> pnus = {};
  List<JiBunItem> gwangYeoks = [];

  void upsertRi(int index1, int index2, int index3, String ri) {
    bool hasIt = false;
    if (gwangYeoks[index1].childs[index2].childs[index3].childs.isNotEmpty) {
      for(int i=0;i<gwangYeoks[index1].childs[index2].childs[index3].childs.length;i++) {
        if (gwangYeoks[index1].childs[index2].childs[index3].childs[i].text == ri) {
          hasIt = true;
        }
      }
    }
    if (!hasIt) {
      JiBunItem newItem = JiBunItem();
      newItem.text = ri;
      gwangYeoks[index1].childs[index2].childs[index3].childs.add(newItem);
    }
  }

  void upsertUpMyeonDong(int index1, int index2, List<String> areas) {
    if (areas.isNotEmpty) {
      String front = areas[0];
      bool hasIt = false;
      if (gwangYeoks[index1].childs[index2].childs.isNotEmpty) {
        for(int i=0;i<gwangYeoks[index1].childs[index2].childs.length;i++) {
          if (gwangYeoks[index1].childs[index2].childs[i].text == front) {
            hasIt = true;
            if (areas.length > 1) {
              upsertRi(index1, index2, i, areas[1]);
            }
          }
        }
      }
      if (!hasIt) {
        JiBunItem newItem = JiBunItem();
        newItem.text = front;
        gwangYeoks[index1].childs[index2].childs.add(newItem);
        if (areas.length > 1) {
          upsertRi(
              index1, index2, gwangYeoks[index1].childs[index2].childs.length - 1, areas[1]);
        }
      }
    }
  }

  void upsertSiGunGu(int index, List<String> areas) {
    if (areas.isNotEmpty) {
      String front = areas[0];
      bool hasIt = false;
      if (gwangYeoks[index].childs.isNotEmpty) {
        for(int i=0;i<gwangYeoks[index].childs.length;i++) {
          if (gwangYeoks[index].childs[i].text == front) {
            hasIt = true;
            upsertUpMyeonDong(index, i, areas.sublist(1));
          }
        }
      }
      if (!hasIt) {
        JiBunItem newItem = JiBunItem();
        newItem.text = front;
        gwangYeoks[index].childs.add(newItem);
        upsertUpMyeonDong(index, gwangYeoks[index].childs.length-1, areas.sublist(1));
      }
    }
  }

  void upsertGwangYeok(List<String> areas) {
    if (areas.isNotEmpty) {
      String front = areas[0];
      bool hasIt = false;
      if (gwangYeoks.isNotEmpty) {
        for(int i=0;i<gwangYeoks.length;i++) {
          if (gwangYeoks[i].text == front) {
            hasIt = true;
            upsertSiGunGu(i, areas.sublist(1));
          }
        }
      }
      if (!hasIt) {
        JiBunItem newItem = JiBunItem();
        newItem.text = front;
        gwangYeoks.add(newItem);
        upsertSiGunGu(gwangYeoks.length-1, areas.sublist(1));
      }
    }
  }

  Future<void> loadData() async {
    pnus.clear();
    gwangYeoks.clear();
    String textFile = await rootBundle.loadString("assets/textfiles/pnus.txt");
    List<String> textLines = textFile.split("\n");
    for(String line in textLines) {
      List<String> item = line.split(" ");
      if (item.isNotEmpty) {
        if (item[item.length-1] == "존재") {
          String code = item[0];
          List<String> jibuns = item.sublist(1,item.length-1);
          pnus[jibuns.join(" ")] = code;
          upsertGwangYeok(jibuns);
        }
      }
    }
  }

  String? getFrontPnu(String jibun) {
    return pnus[jibun];
  }

  String makePnu(String front, bool isSan, String bon, String bu) {
    return front + (isSan ? "2" : "1") + bon.padLeft(4, "0") + bu.padLeft(4, "0");
  }
}