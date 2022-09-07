import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GovPhoto {
  final String assetName;
  final String title;
  final String subtitle;
  final String url;

  GovPhoto({
    required this.assetName,
    required this.title,
    required this.subtitle,
    required this.url,
  });
}

class TitleText extends StatelessWidget {
  final String text;

  const TitleText(this.text);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: Text(text),
    );
  }
}

class GridPhotoItem extends StatelessWidget {
  final GovPhoto photo;

  const GridPhotoItem({
    required this.photo,
  });

  Future<void> openNewBrowser(String url) async {
    final Uri _url = Uri.parse(url);
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $_url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget image = Semantics(
      label: '${photo.title} ${photo.subtitle}',
      child: Material(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          "assets/" + photo.assetName,
          fit: BoxFit.fitWidth,
          alignment: Alignment.topCenter,
        ),
      ),
    );
    return GestureDetector(
        onTap: () {openNewBrowser(photo.url);},
        child: GridTile(
          footer: Material(
            color: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
            ),
            clipBehavior: Clip.antiAlias,
            child: GridTileBar(
              backgroundColor: Colors.black45,
              title: TitleText(photo.title),
              subtitle: TitleText(photo.subtitle),
            ),
          ),
          child: image,
    ));
  }
}

class GovService extends StatelessWidget {
  const GovService({super.key});

  List<GovPhoto> govs(BuildContext context) {
    return [
      GovPhoto(
        assetName: 'gov_photos/seoul.png',
        title: "서울특별시",
        subtitle: "응답소 사이트로 연결됩니다.",
        url: "https://eungdapso.seoul.go.kr/login/loginForm.jsp?writeYN=Y",
      ),
      GovPhoto(
        assetName: 'gov_photos/busan.png',
        title: "부산광역시",
        subtitle: "부산민원120으로 연결됩니다.",
        url: "https://www.busan.go.kr/minwon/myminwon",
      ),
      GovPhoto(
        assetName: 'gov_photos/daegu.png',
        title: "대구광역시",
        subtitle: "두드리소로 연결됩니다.",
        url: "https://dudeuriso.daegu.go.kr/vocRqr/rqs/step01.do",
      ),
      GovPhoto(
        assetName: 'gov_photos/incheon.png',
        title: "인천광역시",
        subtitle: "시청사이트 민원상담으로 연결됩니다.",
        url: "https://www.incheon.go.kr/IC030201",
      ),
      GovPhoto(
        assetName: 'gov_photos/gwangju.jpg',
        title: "광주광역시",
        subtitle: "광주행복1번가 바로응답의 365생활민원으로 연결됩니다.",
        url:
            "https://baroeungdap.gwangju.go.kr/contentsView.do?menuId=baroeungda0210101000",
      ),
      GovPhoto(
        assetName: 'gov_photos/daejeon.png',
        title: "대전광역시",
        subtitle: "대전광역시 사이트내의 국민신문고의 환경신문고로 연결됩니다.",
        url:
            "https://www.daejeon.go.kr/drh/DrhContentsHtmlView.do?menuSeq=4776",
      ),
      GovPhoto(
        assetName: 'gov_photos/ulsan.png',
        title: "울산광역시",
        subtitle: "울산광역시 사이트내의 국민신문고의 환경신문고로 연결됩니다.",
        url:
            "https://www.ulsan.go.kr/u/rep/contents.ulsan?mId=001001007006000000",
      ),
      GovPhoto(
        assetName: 'gov_photos/sejong.png',
        title: "세종특별자치시",
        subtitle: "세종특별자치시 민원글쓰기 사이트로 연결됩니다.",
        url: "https://www.sejong.go.kr/prog/bbs/1/citizen/sub01_03/write.do",
      ),
      GovPhoto(
        assetName: 'gov_photos/gyunggi.jpg',
        title: "경기도",
        subtitle: "경기도 사이트내의 국민신문고로 연결됩니다.",
        url:
            "https://www.epeople.go.kr/nep/crtf/userLogn.npaid?returnUrl=%2Fnep%2Fpttn%2FgnrlPttn%2FPttnRqstWrtnInfo.paid",
      ),
      GovPhoto(
        assetName: 'gov_photos/gangwon.png',
        title: "강원도",
        subtitle: "강원도 사이트내의 민원상담신청으로 연결됩니다.",
        url: "http://www.provin.gangwon.kr/gw/portal/sub01_04",
      ),
      GovPhoto(
        assetName: 'gov_photos/chungbuk.png',
        title: "충청북도",
        subtitle: "충청북도 사이트내의 통합전자상담창구로 연결됩니다.",
        url: "https://www.chungbuk.go.kr/www/contents.do?key=331",
      ),
      GovPhoto(
        assetName: 'gov_photos/chungnam.png',
        title: "충청남도",
        subtitle: "충청남도 사이트내의 충청남도에 바란다 글쓰기로 연결됩니다.",
        url: "http://www.chungnam.go.kr/cnnet/content.do?mnu_cd=CNNMENU00072",
      ),
      GovPhoto(
        assetName: 'gov_photos/jeonbuk.png',
        title: "전라북도",
        subtitle: "전라북도 사이트내의 민원서비스 페이지로 연결됩니다.",
        url:
            "https://www.jeonbuk.go.kr/index.jeonbuk?menuCd=DOM_000000102003001000",
      ),
      GovPhoto(
        assetName: 'gov_photos/jeonnam.png',
        title: "전라남도",
        subtitle: "전라남도 사이트내의 민원상담 신청하기로 연결됩니다.",
        url:
            "https://www.jeonnam.go.kr/contentsView.do?menuId=jeonnam0407010000",
      ),
      GovPhoto(
        assetName: 'gov_photos/gyungbuk.png',
        title: "경상북도",
        subtitle: "경상북도 사이트내의 국민신문고 페이지로 연결됩니다.",
        url:
            "https://www.gb.go.kr/Main/page.do?mnu_uid=6668&LARGE_CODE=720&MEDIUM_CODE=10&SMALL_CODE=40&SMALL_CODE2=10&",
      ),
      GovPhoto(
        assetName: 'gov_photos/gyungnam.png',
        title: "경상남도",
        subtitle: "경상남도 사이트내의 민원신청으로 연결됩니다.",
        url:
            "https://www.gyeongnam.go.kr/index.gyeong?menuCd=DOM_000000102005001004&cpath=",
      ),
      GovPhoto(
        assetName: 'gov_photos/jeju.jpg',
        title: "제주특별자치도",
        subtitle: "제주특별자치도 사이트내의 온라인민원상담으로 연결됩니다.",
        url: "https://www.jeju.go.kr/open/minwon/online/my.htm",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("광역시도별 민원접수처"),
        ),
        body: GridView.count(
          restorationId: 'gov_service_offset',
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: const EdgeInsets.all(8),
          childAspectRatio: 1,
          children: govs(context).map<Widget>((photo) {
            return GridPhotoItem(photo: photo);
          }).toList(),
        ));
  }
}
