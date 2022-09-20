# 건축소음 측정기

- 현재 위치의 지번주소를 입력하여, 소음진동에 관한 법률에 근거하여 소음기준치를 확인할 수 있습니다.
- 소음기준치를 근거로 특정시간 동안의 평균 소음을 측정하고, 이 기록을 토대로 각 지방자치단체의 민원접수처에 소음관련 민원을 접수할 수 있도록 연결을 지원합니다.
- 개발버전을 실행하려면 https://www.data.go.kr/tcs/dss/selectApiDataDetailView.do?publicDataPk=15056930 에서 apikey를 받아서 land_use.dart 파일의 코드에 수정해야 합니다.
  - https://github.com/reddol18/noise_out/blob/1090ca6a72794eb324526c22487e918957bffac6/lib/land_use.dart#L145

## 사용방법

- 첫 화면
  - ![KakaoTalk_20220909_012202109](https://user-images.githubusercontent.com/15623847/189176266-ce04fef3-71ba-4725-b16c-0bf5139d3cba.jpg)
  - 버튼 설명
    - 1 : 소음측정 기록보기
    - 2 기준 데시벨 확인 : 소음기준치 및 기록방식 옵션 지정
    - 3 민원접수 : 각 지자체별 민원접수용 게시판으로 연결됩니다
    - 4 : 소음측정하기 (측정중에는 중단버튼으로 변경됩니다)
- 먼저 2. 소음기준치 및 기록방식 옵션 지정을 하기 위해서 "기준 데시벨 확인" 버튼을 터치해주세요. 그러면 아래와 같은 화면이 나타납니다.
  - ![KakaoTalk_20220909_012202109_01](https://user-images.githubusercontent.com/15623847/189176799-d0d47143-d644-4510-a5a2-fc4a3fb430d2.jpg)
  - 지번주소를 이용해야 법에 근거한 기준치를 가져올 수 있습니다. 광역시도부터 부주소까지 입력을 완료한 후에 "주소지 기준 데시벨 구하기" 버튼을 터치해주세요.
  - 이때 부주소가 없는 주소일 경우에는 공란으로 두어도 됩니다.
  - 주소가 정확히 입력되었다면 시간대별 소음기준치 값이 자동으로 지정됩니다. 수동 지정도 가능합니다.
  - 측정시간은 얼마나 측정할지를 지정하는 값 입니다. 보통 5분(300초)로 지정합니다.
  - 허용 보행수는 측정시에 얼마나 움직였는지를 나타냅니다. 너무 많이 움직였다면 측정값의 신뢰도가 떨어지기 때문에 허용보행수 이하로 움직이셔야 기록이 남습니다.
- 위에서 측정에 필요한 값을 지정했다면, 소음현장 근처로 가서 4 소음측정하기 버튼을 터치해주세요. 아래처럼 측정이 시작됩니다.
  - ![KakaoTalk_20220909_012202109_02](https://user-images.githubusercontent.com/15623847/189177603-8b8368d9-eebc-45be-a747-3ca830f16e56.jpg)
  - 측정을 중단하고 싶으면 중단버튼을 터치하면 됩니다.
  - 측정시간 동안 평균값(혹은 최소값)이 측정기준치를 초과했다면 팝업이 뜨고 자동으로 기록이 남습니다.
- 기록확인은 1. 소음측정 기록보기 버튼을 터치하면 됩니다. 그러면 아래처럼 기록 리스트가 나타납니다.
  - ![KakaoTalk_20220909_012202109_03](https://user-images.githubusercontent.com/15623847/189177789-f95ee604-d1fa-4e15-afe3-870a5e2cdf58.jpg)
  - 그 중 하나를 터치해봅시다.
- 아래와 같은 기록상세 화면이 나타나면 해당화면을 캡쳐한 후에 민원접수처에 첨부하시면 됩니다.
  - ![KakaoTalk_20220909_012202109_04](https://user-images.githubusercontent.com/15623847/189177938-f9861ea4-69ba-4a94-9f01-e64c4a96647b.jpg)



