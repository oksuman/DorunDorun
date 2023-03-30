# DorunDorun
두런두런 걸어봅시다. 

- 적용법
1) 플러터 프로젝트에 해당 폴더 설치
2) 유니티 22.1.71f 버전 설치
3) 해당 프로젝트 실행 후 Assets > Import Package > Custom Package 에서 FlutterUnityPackage.unitypackage file을 클릭 후 import
4) import 후 상단 메뉴 중 Flutter > Export Android Debug or Export Android Release 실행
5) 빌드 성공 메세지 출력 시 unityLibrary/build.gradle file로 이동 후
commandLineArgs.add("--enable-debugger") 
commandLineArgs.add("--profiler-report") 
commandLineArgs.add("--profiler-output-file=" + workingDir + "/build/il2cpp_"+ abi + "_" + configuration + "/il2cpp_conv.traceevents") 를 제거
6) terminal에서 flutter run 입력

참고) https://pub.dev/packages/flutter_unity_widget
