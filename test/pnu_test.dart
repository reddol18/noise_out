import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:noise_out/pnu.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  PnuManager pm = PnuManager();
  test('load test', () async {
    await pm.loadData();
    expect(pm.gwangYeoks.length > 0, true);
  });
  test('load front pnu', () async {
    await pm.loadData();
    String? ret = pm.getFrontPnu("서울특별시 중랑구 상봉동");
    expect(ret, "1126010200");
  });
  test('load full pnu', () async {
    await pm.loadData();
    String? front = pm.getFrontPnu("서울특별시 중랑구 상봉동");
    String ret = pm.makePnu(front!, false, "103", "9");
    expect(ret, "1126010200101030009");
  });
}