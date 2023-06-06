import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

/*
    @param date : 년/월/일/시/분/초 정보가 있는 Datetime 자료형
    @return formatDate : 형식이 맞춰진 날짜 string

    datetime을 받아 보기 좋은 형식의 날짜 String으로 반환한다.
    형식은 추후에 변경 가능
*/
class DateFormatting{
  static String dateFormatting(DateTime date){
    var formatDate = DateFormat('yy.MM.dd - HH시 mm분').format(date);
    return formatDate;
  }
}

/*
    LatLng 타입의 변수를
    firestore에서 사용하는 geopoint 형식으로 변환
 */
class LatLngFormatting{
  static List<LatLng> toLatLng(List<dynamic> geoPoints){
    List<LatLng> pathMoved = List<LatLng>.empty(growable: true);
    geoPoints.forEach((gp) {
      pathMoved.add(LatLng(gp['latitude']!, gp['longitude']!));
    });
    return pathMoved;
  }

  static List<dynamic> fromLatLng(List<LatLng> pathMoved){
    List<dynamic> geoPoints = List<dynamic>.empty(growable : true);
    pathMoved.forEach((ll) {
      geoPoints.add({
        "latitude" : ll.latitude,
        "longitude" : ll.longitude,
      });
    });
    return geoPoints;
  }

  // 경로 압축해서 formatting
  static List<dynamic> fromLatLngCompact(List<LatLng> pathMoved, int factoring){
    List<dynamic> geoPoints = List<dynamic>.empty(growable : true);
    var indexGrow = pathMoved.length ~/ factoring;
    for(int i=0; i<pathMoved.length; i+= indexGrow){
      geoPoints.add({
        "latitude" : pathMoved[i].latitude,
        "longitude" : pathMoved[i].longitude,
      });
    }
    return geoPoints;
  }
}

class TimeFormatting{
  static String timeWriteFormatting({required int timeInSecond}) {
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute : $second";
  }

  static String timeVoiceFormatting({required int timeInSecond}) {
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute분 $second초";
  }
}

