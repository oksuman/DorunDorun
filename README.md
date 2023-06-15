# Do run, Do run!

##메타버스 플랫폼 러닝 보조 어플리케이션

### #메타버스 #실시간 통신 #스포츠  

Team 오뚝
20183901 김상민
20180023 김승후
20181677 최현석 

##I. 서비스 소개 
두런 두런 (Do Run! Do Run!) 프로젝트의 목적은 다른 사람들과 함께 러닝(Running)을 즐길 수 있도록 실시간 통신 어플리케이션을 제공하는 데에 있다. 두런 두런은 사용자들의 러닝 기록을 측정하고 실시간 비교하여, 다른 공간에서 러닝을 즐기는 사용자와 함께 달리는 듯한 느낌을 제공한다. 

##II. 기획 배경
  다른 사람들과 함께 하는 러닝은 혼자서 하는 러닝과는 또 다른 즐거움을 준다. 많은 러너들은 다른 사람들과 함께 달릴 때 더욱 동기부여를 받으며, 끝까지 포기하지 않을 수 있다고 이야기한다.
  다른 사람들과 직접 만나서 함께 달리는 것이 가장 이상적이지만, 현실적으로 어려운 부분이 존재한다. 만나기에는 사는 지역이 멀거나 선호하는 운동 시간대가 다른 경우가 많기 때문이다. 우리는 이런 부분을 해소해줄 수 있는 러닝 보조 어플리케이션이 있으면 좋을 것 같다는 생각을 했다.
  기존의 러닝 어플리케이션은 기록 측정과 트레이닝 기능에 집중하고 있었고, 친구와의 소통을 지원하는 기능은 없거나, 매우 빈약했다. 우리는 친구와의 소통 기능에 보다 집중해, 함께 달리는 느낌을 제공해줄 수 있는 러닝 보조 어플리케이션을 개발하고자 한다. 이러한 러닝 보조 어플리케이션을 통해 친구와 함께 러닝을 한다면, 부담감 없이 러닝을 즐기며 동기부여도 받을 수 있을 것이다.   

##III. 사전 조사
 
현재 가장 많이 사용되는 러닝 보조 어플리케이션으로 NRC(나이키 런 클럽)와 런데이를 포함하여 표와 같이 5개를 뽑을 수 있다. 표는 해당 어플리케이션이 제공하는 기능들을 비교한 결과이다. 기록 및 트레이닝은 개인의 러닝을 보조하는 기능에 관한 것이며 커뮤니티 기능은 다른 사람과 함께 사용할 수 있는 어플리케이션의 기능을 뜻한다. 
이 밖에 운동에 메타버스 플랫폼을 활용한 것으로는 메타러닝이 있었다. 메타러닝은 러닝머신 위에서 달리는 사람의 모션을 캡처해 자세 교정을 도왔다. 이 때, 가상 트랙 속에서 다른 사람들과 함께 달리는 기능을 재미요소로 추가하기도 하였다.
  두런두런이 아바타와 가상 트랙을 통해 러닝에 재미 요소를 더한다는 점은 이와 유사하지만, 야외 러닝에서 친구와의 기록 공유와 실시간 소통을 돕는 것이 주 기능이라는 점에서 차별점이 있다. 두런두런은 러닝 기록과 소통을 메타버스 플랫폼을 통해 서로 다른 시공간에 존재하는 두 러너를 연결해준다. 

##IV. 구현    
• 러닝 기능 구현
1) GPS tracking 및 러닝 기록 측정
  Flutter의 Location Package와 LatLng2 Package를 이용해, GPS 데이터를 실시간으로 수집하고 GPS 좌표의 변화를 감지해 이동 거리를 누산하도록 하였다. 시간 별로 이동한 거리를 추적하여, 사용자에게 운동한 거리 및 현재 페이스를 보여주도록 하였다.
  또한, 러닝을 마치면 운동 결과 화면을 확인할 수 있도록 하였다. 결과 화면에선 GPS 좌표를 활용해 러닝한 트랙을 지도상에서 확인할 수 있도록 하였다. 

2) 러닝 기록 저장 및 저장된 기록과 달리기
  Firebase의 Firestore를 활용해 러닝 기록을 저장하도록 하였다. 실시간 러닝 기록은 Group Collection의 하위 Collection인 Log에 저장되도록 하였고, 운동을 마친 후 영구히 저장할 기록은 User Collection의 하위 Collection인 Log에 저장되도록 구현했다.
  영구히 저장된 기록은 사용자가 상시로 확인할 수 있도록 하였다. 이는, Firebase에 데이터를 불러오도록 요청하는 과정을 통해 수행된다. 불러온 기록을 Client에서 재현하는 과정을 통해, 이전 기록과 달리기 기능도 제공된다. 실시간으로 GPS tracking을 실시함과 동시에, 시간대별로 이전 기록을 하나씩 가져와 비교한다.
  저장된 기록 보기는 친구로 등록된 다른 사용자에게도 적용된다. Firebase에 저장된 친구의 유저 정보를 기반으로, 친구의 Log를 불러와 확인할 수 있다. 또한, 불러온 친구의 기록을 이용해 친구의 이전 기록과 달리기 기능을 구현하였다. 

3)  실시간 함께 달리기
  실시간 함께 달리기는 Firebase에 기반한 실시간 통신을 이용하여 구현하였다. 함께 달리고자 하는 사용자들은 Client에서 각자 GPS tracking을 통해 이동한 거리를 측정한다. 사용자들은 GPS 정보를 갱신할 때마다 이를 Firebase의 Group Collection에 업로드한다. Group Collection은 함께 달리고자 하는 사용자들의 정보를 모은 Collection을 의미한다. 
  사용자들은 Firebase의 Group Log가 실시간으로 업데이트되는 것을 구독하여, 다른 사용자의 최신 정보를 지속적으로 받아온다. 이를 통해, Client에서 자신과 다른 사용자 간의 거리를 비교할 수 있도록 구현하였다.  

• 친구 관련 기능
1) 친구 추가 및 관리
파이어베이스를 통해 유저이름을 검색한 다음, 다른 유저에게 친구 초대를 보낼 수 있게 하였고, 초대를 받은 친구는 친구를 수락할 수도 거절 할 수도 있다. 사용자는 수락한 친구들을 리스트 형식으로 확인하고 원하지 않는 친구를 삭제할 수 있다.
다른 유저와 친구를 맺으면 초대장을 전송하여 함께 러닝 컨텐츠들을 즐길 수 있으며, 그 밖의 TTS 응원 전송과 수락된 친구들의 이전 러닝 기록을 확인하고 도전이 가능하다.

2) TTS 음성안내 및 친구 응원
  Flutter의 flutter_tts Package를 사용해, TTS 음성안내 기능을 구현하였다. 각 모드 별로 특정 이벤트가 발생하였을 때, 미리 준비된 대사를 TTS를 통해 읽어주도록 구현하였다.
또한, 운동 중에 친구가 보낸 메시지 정보를 파이어베이스를 통해 전달 받으며, 동시에 메시지를 수신하는 경우를 대비하여 큐 형식으로 메시지를 저장했다가 하나 씩 읽어주도록 구현하였다.

3) 러닝 방 생성
앱 메인 화면에서 달리기 모양의 버튼을 누르면 방을 생성하거나, 이미 소속된 방으로 접속한다. 방에는 총 4명까지 접속이 가능하며, 1명의 방장이 존재한다. 방장은 러닝의 목표나 모드를 설정할 수 있으며, 원치 않는 유저를 강제 퇴장 시키는 것이 가능하다. 유저들을 자신들의 친구들에게 초대장을 전송할 수 있으며, 초대 받은 사용자는 메시지 함을 통해서 접속이 가능하다. 유저 전원이 하단의 ‘준비’ 버튼을 눌러 준비된 상태에서 방장이 달리기 버튼을 누르면 러닝이 시작된다. 이 모든 과정은 동기화되어 실시간으로 확인 가능하다.

• 업적기능
  달리기 완주 횟수에 따라 업적이 차례대로 오픈 되도록 구현하였다. 각 카테고리 별로 5간계가 있으며, 업적 클릭 시 현재 진척도와 업적 문구를 확인할 수 있다. 현재는 달리기 완주 횟수 카테고리만 구현되어 있는 상태이고, 추후 커스터마이징 기능과 연계하여 업적 달성 시 추가 코스튬이 오픈 되도록 확장 가능하다.

• 3D 모델링
  Unity를 활용해서 3D 모델링을 구현했다. Asset 들은 스토어에서 적당한 것을 골라 구매해서 사용했다. 맵 같은 경우는 직접 타일들과 돌, 풀, 나무 Asset을 조합해 만들었다. 앱 상에서 구현할 화면은 쓰임에 따라 서로 다른 Scene을 구성해 앱에서 특정 동작이 있을 때마다 Scene change가 일어나는 방식으로 화면 전환을 구현했다. 
  Flutter와 Unity를 연결하기 위해서 flutter_unity_widget을 사용했다. 해당 패키지는 Unity 프로젝트를 Flutter의 widget과 같은 형식으로 써서 앱 내에서 구동할 수 있도록 구현되어 있었다. Flutter에서 함수를 실행하면, Unity의 특정 함수에게 message를 보내는 방식으로 통신을 구현했다. 

1) 메인 화면
메인 화면에서는 자신의 계정에 저장된 아바타 ID를 받아 본인이 커스텀 한 캐릭터의 모습을 보여준다. 또한 화면 하단의 커스텀 기능을 활용해서 모자, 피부색, 상의를 바꿀 수 있다. 처음 로그인 시 Flutter 상에서 자신의 계정에 저장된 초기 정보를 받아오는데, 그중 아바타 ID 정보를 유니티 프로젝트에게 넘겨준다. 아바타 id는 세자리로 구성되어 있으며, 각 자릿수가 각각 모자, 피부색, 상의를 의미한다. Unity에서는 모델 출력 함수가 호출될 때마다 해당 아바타 id와 동일한 이름의 prefab을 모델링한다. 앱 상의 커스텀 버튼을 누르면 해당하는 자릿수의 숫자를 + 혹은 – 해서 다른 prefab을 출력하는 방식으로 커스텀 기능을 구현했다.

2) 달리기 화면
 방 만들기 화면에서 달리기 화면으로 넘어갈 때, Unity는 Flutter로부터 그룹 내 몇 명이 있는 지와 각 플레이어의 아바타 id를 받는다. 이를 바탕으로 화면에 각자의 캐릭터를 모델링한다. 그리고 Flutter가 Firebase로부터 그룹 내 인원들의 현재 위치 및 속도 데이터를 받을 때마다, 바로 유니티에도 전달해서 각 플레이어의 모델들의 위치 및 속도가 빠르게 업데이트 될 수 있도록 구현했다. 모델의 애니메이션에 속도 변수를 추가해서 빨리 달릴수록 애니메이션도 빠르게 재생될 수 있도록 구현했다. 
2.1) 기본 모드
 기본 모드에서는 단순히 각 플레이어들이 정해진 맵 위에서 달리는 장면을 구현했다. 만약 다른 플레이어가 뒤에 있어 화면에 보이지 않거나, 너무 앞에 있어 모델이 깨질 정도로 작게 보이면 UI를 활용해 내 모델과 얼마나 거리가 있는지 직관적으로 알 수 있도록 구현했다. 
2.2) 협력 모드
 협력 모드는 다른 모드들과 달리 시점을 180도 돌려서 보스 몬스터가 플레이어들을 쫓아오도록 구현했다. 또한 보스와의 거리가 일정 수치 미만이 되는 순간 해당 플레이어의 모델이 사라지는 로직을 구현했다. 
2.3) 경쟁 모드
 경쟁 모드에서는 만약 목표 거리를 설정하고 뛴다면, 미니맵이 화면에 생성되어 목표까지 얼마나 남았는지, 상대 플레이어와의 거리는 어떠한 지 한눈에 알아볼 수 있도록 구현했다.
2.4) 다른 기록과 함께 달리기 
 다른 기록과 함께 달리기에서는 기록의 주인 정보에서 아바타 ID를 받아와 모델링 한 후 기본 모드에서 2명이 달리는 것과 같은 화면을 구현했다. 

##V. 기능 소개
1) 로그인 및 계정 생성 기능
앱을 새로 시작하면 사용자가 계정을 로그인하거나 새로 계정을 생성할 수 있다. 로그인이나 계정 생성 시, 기본적인 형식에 맞는지 확인하는 validation이 적용되어 있으며, 계정을 생성 시 운동 피드백을 위해 사용자 개인정보를 제공 할지 설정할 수 있다. 그 과정에서 개인정보보호법과 함께 사용자의 동의를 구하도록 구현하였다.
한번 계정을 생성한 다음 로그인을 할 경우, Flutter secured storage 패키지를 통해 캐시 메모리에 로그인 정보가 저장되며, 다음부터 로그인 할 경우 자동 로그인이 되어 사용자의 편의성을 높였다.

2) 홈 화면 및 아바타 꾸미기
  로그인이 되면 보게 될 첫 화면이다. 현재 자신의 캐릭터를 확인할 수 있으며, 커스터마이징이 가능하다. 왼쪽에서 스와이프해서 열 수 있는 Drawer에는 초대장을 확인할 수 있는 메시지함과 설정창 그리고 로그아웃 항목을 확인할 수 있다.

3) 친구 기능
다음은 현재 자신의 친구 목록을 확인 및 관리할 수 있는 화면과 새로 친구를 추가할 수 있는 화면이다. 현재 생성된 친구들을 리스트 형식으로 확인하고, 친구들의 러닝로그를 확인하거나 응원 메시지를 전송할 수 있다.
우칙 상단 아이콘을 누르면 친구 추가 창으로 넘어가며, 유저 아이디를 검색하여 친구를 신청할 수 있다. 친구 신청을 받으면 친구 대기 리스트에서 수락할지 선택할 수 있다.

4) 방 생성
  메인화면에서 러닝 버튼을 누르면 방을 새로 생성하거나 이미 접속한 방으로 넘어간다. 방에는 총 4명까지 접속이 가능하며, 1명의 방장이 존재한다. 방장은 러닝의 목표나 모드를 설정할 수 있으며, 원치 않는 유저를 강제 퇴장 시키는 것이 가능하다. 유저들을 자신들의 친구들에게 초대장을 전송할 수 있으며, 초대 받은 사용자는 메시지 함을 통해서 접속이 가능하다. 유저 전원이 하단의 ‘준비’ 버튼을 눌러 준비된 상태에서 방장이 달리기 버튼을 누르면 러닝이 시작된다. 이 모든 과정은 동기화되어 실시간으로 확인 가능하다.
방은 총 기본모드, 협동모드, 경쟁모드가 존재하며, 각 모드별로 기본모드는 목표거리, 목표시간, 랩타임 측정 중 하나를 선택할 수 있고, 협동모드는 단계 설정, 경쟁모드는 목표거리, 최저페이스 중 하나를 설정할 수 있다.

5) 실시간 러닝 기능
러닝을 시작하게 되면 3초의 카운트 다운 이후 러닝이 시작된다. 상단에는 타이머가 표시되며 아래 버튼으로 타이머를 멈출 수 있다. 타이머 밑에 총 이동거리와 평균페이스를 확인할 수 있으며, 또한 현재 러닝 정보가 반영되어 3D 모델링이 된 트랙 위 아바타로 확인할 수 있다.
우측 하단 버튼을 누르면 러닝을 중단할 수 있고, 러닝 종료와 함께 운동한 경로, 총 이동거리, 운동 시간, 평균 페이스 등의 정보를 제공한다. 해당 정보는 저장할 지 선택할 수 있다.

6) 업적 기능
각 카테고리 별로 5간계가 있으며, 업적 클릭 시 현재 진척도와 업적 문구를 확인할 수 있다. 현재는 달리기 완주 횟수 카테고리만 구현되어 있는 상태이고, 추후 커스터마이징 기능과 연계하여 업적 달성 시 추가 코스튬이 오픈 되도록 확장 가능하다.

7) 이전 기록과 뛰기 기능
  자신의 이전 러닝기록이나 친구의 이전 러닝기록을 확인할 수 있다. 이 때 과거의 기록과 다시 뛰는 것이 가능하며, 러닝을 완주하고 댓글로 코멘트를 남기는 것이 가능하다.

##VI. 역할 분담

김상민    Firebase 연결 담당    Flutter와 Firebase를 연결하여, 러닝 방 생성, 친구 관리, TTS 메시지 전송 등의 기능 구현
김승후    Flutter 개발 담당     GPS기반 거리를 측정하고, 사용자간 통신을 구현. 
최현석    3D 모델링 담당    유니티를 활용해 캐릭터 커스텀 기능, 달리기 화면 등을 구현
 
 
##VII. 결론
엔데믹이 다가오며 러닝의 인기는 나날이 상승 중이다. 이와 함께 러닝 크루의 수 또한 많이 생기는 추세인데, 이는 다른 사람과 함께 뛸 때 동기부여가 되어 즐겁기 때문이다. 하지만 각자 지역적인 한계와 시간이 맞지 않아 서로 모일 여건이 되지 않는 경우가 많았다. 이런 상황 속에서 ‘두런두런’은 사람들의 시간적 공간적 한계를 뛰어넘어 서로 함께 뛰는 듯한 체감을 줄 수 있다. 또한 단순히 사용자들을 연결만 시켜주는 것이 아닌 자신의 개성을 아바타로 표현해주는 커스터마이징 기능, 단순 러닝 뿐만 아닌 ‘협동모드’, ‘경쟁모드’와 같은 다양한 컨텐츠, 업적 컨텐츠 등을 통해 남녀 노소 쉽게 러닝에 접근할 수 있게 한다. 이렇듯 두런두런은 높아지는 러닝의 인기 속에서 사용자들이 누구나 쉽게 러닝에 입문하고, 서로 시공간을 초월하여 연결 시켜주는 효과를 가져다 줄 수 있다.
향후 두런두런은 다양한 아바타 및 러닝트랙 에셋을 제공하고, 부분유료화를 통한 사업모델을 구축할 계획이다. 또한 업적 컨텐츠와 커스터마이징을 연동시켜 사용자의 동기를 고취시키고, 더욱 다양한 사용자를 확보하기 위하여 실내 러닝머신에 어플리케이션을 적용 시킬  방안을 생각 중에 있다. 만약 여건이 된다면 모두 반영하여 두런두런을 개선시킬 예정이다.
