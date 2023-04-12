import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

/*
    @param date : 년/월/일/시/분/초 정보가 있는 Datetime 자료형
    @return formatDate : 형식이 맞춰진 날짜 string

    datetime을 받아 보기 좋은 형식의 날짜 String으로 반환한다.
    형식은 추후에 변경 가능
*/
class DateFormating{
  static  String dateFormating(DateTime date){
    var formatDate = DateFormat('yy년, MMM dd, ' 'a h:mm').format(date);
    return formatDate;
  }
}

/*
    LatLng 타입의 변수를
    firestore에서 사용하는 geopoint 형식으로 변환
 */
class LatLngFormating{
  static List<LatLng> toLatLng(List<Map<String, double>> geoPoints){
    List<LatLng> pathMoved = List<LatLng>.empty(growable: true);
    geoPoints.forEach((gp) {
      pathMoved.add(LatLng(gp['latitude']!, gp['longitude']!));
    });
    return pathMoved;
  }

  static List<Map<String, double>> fromLatLng(List<LatLng> pathMoved){
    List<Map<String, double>> geoPoints = List<Map<String, double>>.empty(growable : true);
    pathMoved.forEach((ll) {
      geoPoints.add({
        "latitude" : ll.latitude,
        "longitude" : ll.longitude,
      });
    });
    return geoPoints;
  }
}

class TimeFormating{
  static timeFormating({required int timeInSecond}) {
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute : $second";
  }
}

