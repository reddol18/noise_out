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
        title: "???????????????",
        subtitle: "????????? ???????????? ???????????????.",
        url: "https://eungdapso.seoul.go.kr/login/loginForm.jsp?writeYN=Y",
      ),
      GovPhoto(
        assetName: 'gov_photos/busan.png',
        title: "???????????????",
        subtitle: "????????????120?????? ???????????????.",
        url: "https://www.busan.go.kr/minwon/myminwon",
      ),
      GovPhoto(
        assetName: 'gov_photos/daegu.png',
        title: "???????????????",
        subtitle: "??????????????? ???????????????.",
        url: "https://dudeuriso.daegu.go.kr/vocRqr/rqs/step01.do",
      ),
      GovPhoto(
        assetName: 'gov_photos/incheon.png',
        title: "???????????????",
        subtitle: "??????????????? ?????????????????? ???????????????.",
        url: "https://www.incheon.go.kr/IC030201",
      ),
      GovPhoto(
        assetName: 'gov_photos/gwangju.jpg',
        title: "???????????????",
        subtitle: "????????????1?????? ??????????????? 365?????????????????? ???????????????.",
        url:
            "https://baroeungdap.gwangju.go.kr/contentsView.do?menuId=baroeungda0210101000",
      ),
      GovPhoto(
        assetName: 'gov_photos/daejeon.png',
        title: "???????????????",
        subtitle: "??????????????? ??????????????? ?????????????????? ?????????????????? ???????????????.",
        url:
            "https://www.daejeon.go.kr/drh/DrhContentsHtmlView.do?menuSeq=4776",
      ),
      GovPhoto(
        assetName: 'gov_photos/ulsan.png',
        title: "???????????????",
        subtitle: "??????????????? ??????????????? ?????????????????? ?????????????????? ???????????????.",
        url:
            "https://www.ulsan.go.kr/u/rep/contents.ulsan?mId=001001007006000000",
      ),
      GovPhoto(
        assetName: 'gov_photos/sejong.png',
        title: "?????????????????????",
        subtitle: "????????????????????? ??????????????? ???????????? ???????????????.",
        url: "https://www.sejong.go.kr/prog/bbs/1/citizen/sub01_03/write.do",
      ),
      GovPhoto(
        assetName: 'gov_photos/gyunggi.jpg',
        title: "?????????",
        subtitle: "????????? ??????????????? ?????????????????? ???????????????.",
        url:
            "https://www.epeople.go.kr/nep/crtf/userLogn.npaid?returnUrl=%2Fnep%2Fpttn%2FgnrlPttn%2FPttnRqstWrtnInfo.paid",
      ),
      GovPhoto(
        assetName: 'gov_photos/gangwon.png',
        title: "?????????",
        subtitle: "????????? ??????????????? ???????????????????????? ???????????????.",
        url: "http://www.provin.gangwon.kr/gw/portal/sub01_04",
      ),
      GovPhoto(
        assetName: 'gov_photos/chungbuk.png',
        title: "????????????",
        subtitle: "???????????? ??????????????? ??????????????????????????? ???????????????.",
        url: "https://www.chungbuk.go.kr/www/contents.do?key=331",
      ),
      GovPhoto(
        assetName: 'gov_photos/chungnam.png',
        title: "????????????",
        subtitle: "???????????? ??????????????? ??????????????? ????????? ???????????? ???????????????.",
        url: "http://www.chungnam.go.kr/cnnet/content.do?mnu_cd=CNNMENU00072",
      ),
      GovPhoto(
        assetName: 'gov_photos/jeonbuk.png',
        title: "????????????",
        subtitle: "???????????? ??????????????? ??????????????? ???????????? ???????????????.",
        url:
            "https://www.jeonbuk.go.kr/index.jeonbuk?menuCd=DOM_000000102003001000",
      ),
      GovPhoto(
        assetName: 'gov_photos/jeonnam.png',
        title: "????????????",
        subtitle: "???????????? ??????????????? ???????????? ??????????????? ???????????????.",
        url:
            "https://www.jeonnam.go.kr/contentsView.do?menuId=jeonnam0407010000",
      ),
      GovPhoto(
        assetName: 'gov_photos/gyungbuk.png',
        title: "????????????",
        subtitle: "???????????? ??????????????? ??????????????? ???????????? ???????????????.",
        url:
            "https://www.gb.go.kr/Main/page.do?mnu_uid=6668&LARGE_CODE=720&MEDIUM_CODE=10&SMALL_CODE=40&SMALL_CODE2=10&",
      ),
      GovPhoto(
        assetName: 'gov_photos/gyungnam.png',
        title: "????????????",
        subtitle: "???????????? ??????????????? ?????????????????? ???????????????.",
        url:
            "https://www.gyeongnam.go.kr/index.gyeong?menuCd=DOM_000000102005001004&cpath=",
      ),
      GovPhoto(
        assetName: 'gov_photos/jeju.jpg',
        title: "?????????????????????",
        subtitle: "????????????????????? ??????????????? ??????????????????????????? ???????????????.",
        url: "https://www.jeju.go.kr/open/minwon/online/my.htm",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("??????????????? ???????????????"),
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
