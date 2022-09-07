import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nock/nock.dart';
import 'package:noise_out/land_use.dart';

void main() async {
  setUpAll(nock.init);

  setUp(() {
    nock.cleanAll();
  });
  TestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  test('land use by pnu', () async {
    final httpMock = nock("http://apis.data.go.kr/1611000/nsdi/LandUseService/attr").
      get("/getLandUseAttr?serviceKey=SWREtbqXkGVKg0pX4289T8Nu8wRfYExVLL6IjU2Py73b3XcgFpVjmZKkoK%2B2WwVibJsya4rcznYmW7JUojHj8Q%3D%3D&pnu=1126010200101030009&format=json")
      ..headers({HttpHeaders.contentTypeHeader: "application/json; charset=UTF-8"})
      ..reply(200,{"landUses":{"field":[{"regstrSeCode":"1","pnu":"1126010200101030009","lastUpdtDt":"2022-07-14","manageNo":"15000001126020000000UQA01X0001001","ldCode":"1126010200","ldCodeNm":"서울특별시 중랑구 상봉동","mnnmSlno":"103-9","regstrSeCodeNm":"토지대장","cnflcAt":"1","cnflcAtNm":"포함","prposAreaDstrcCode":"UQA01X","prposAreaDstrcCodeNm":"도시지역","registDt":"2017-09-05"},{"regstrSeCode":"1","pnu":"1126010200101030009","lastUpdtDt":"2022-07-14","manageNo":"15000001126020000000UQA1300006006","ldCode":"1126010200","ldCodeNm":"서울특별시 중랑구 상봉동","mnnmSlno":"103-9","regstrSeCodeNm":"토지대장","cnflcAt":"1","cnflcAtNm":"포함","prposAreaDstrcCode":"UQA130","prposAreaDstrcCodeNm":"준주거지역","registDt":"2017-09-05"},{"regstrSeCode":"1","pnu":"1126010200101030009","lastUpdtDt":"2022-07-14","manageNo":"15000001126020090001UBA1000001001","ldCode":"1126010200","ldCodeNm":"서울특별시 중랑구 상봉동","mnnmSlno":"103-9","regstrSeCodeNm":"토지대장","cnflcAt":"1","cnflcAtNm":"포함","prposAreaDstrcCode":"UBA100","prposAreaDstrcCodeNm":"과밀억제권역","registDt":"2017-09-05"},{"regstrSeCode":"1","pnu":"1126010200101030009","lastUpdtDt":"2022-07-14","manageNo":"15800001126020192019UNE2000001003","ldCode":"1126010200","ldCodeNm":"서울특별시 중랑구 상봉동","mnnmSlno":"103-9","regstrSeCodeNm":"토지대장","cnflcAt":"1","cnflcAtNm":"포함","prposAreaDstrcCode":"UNE200","prposAreaDstrcCodeNm":"대공방어협조구역","registDt":"2019-07-01"},{"regstrSeCode":"1","pnu":"1126010200101030009","lastUpdtDt":"2022-07-14","manageNo":"30600001126020110009UMZ1000001001","ldCode":"1126010200","ldCodeNm":"서울특별시 중랑구 상봉동","mnnmSlno":"103-9","regstrSeCodeNm":"토지대장","cnflcAt":"1","cnflcAtNm":"포함","prposAreaDstrcCode":"UMZ100","prposAreaDstrcCodeNm":"가축사육제한구역","registDt":"2017-09-05"},{"regstrSeCode":"1","pnu":"1126010200101030009","lastUpdtDt":"2022-07-14","manageNo":"61100001126020170174UDA1000001003","ldCode":"1126010200","ldCodeNm":"서울특별시 중랑구 상봉동","mnnmSlno":"103-9","regstrSeCodeNm":"토지대장","cnflcAt":"1","cnflcAtNm":"포함","prposAreaDstrcCode":"UDA100","prposAreaDstrcCodeNm":"재정비촉진지구","registDt":"2017-09-05"},{"regstrSeCode":"1","pnu":"1126010200101030009","lastUpdtDt":"2022-07-14","manageNo":"61100001126020170402UDA1000001001","ldCode":"1126010200","ldCodeNm":"서울특별시 중랑구 상봉동","mnnmSlno":"103-9","regstrSeCodeNm":"토지대장","cnflcAt":"1","cnflcAtNm":"포함","prposAreaDstrcCode":"UDA100","prposAreaDstrcCodeNm":"재정비촉진지구","registDt":"2017-12-06"},{"regstrSeCode":"1","pnu":"1126010200101030009","lastUpdtDt":"2022-07-14","manageNo":"61100001126020170402UQQ3000001001","ldCode":"1126010200","ldCodeNm":"서울특별시 중랑구 상봉동","mnnmSlno":"103-9","regstrSeCodeNm":"토지대장","cnflcAt":"1","cnflcAtNm":"포함","prposAreaDstrcCode":"UQQ300","prposAreaDstrcCodeNm":"지구단위계획구역","registDt":"2017-12-06"}],"totalCount":"8","numOfRows":"10","pageNo":"1","resultCode":null,"resultMsg":null}});
    landUse temp = landUse();
    landUseResult lur = await temp.getLandUse('1126010200101030009');
    expect(httpMock.isDone, true);

  });
}