import 'package:dusty_dust/model/status_model.dart';

import '../const/status_level.dart';
import '../model/stat_model.dart';

class DataUtils {
  static String getTimeFromDateTime({required DateTime dateTime}) {
    return '${dateTime.year}-${dateTime.month}-${dateTime.day} ${getTimeFormat(dateTime.hour)}:${getTimeFormat(dateTime.minute)}';
  }

  static String getTimeFormat(int number) {
    return number.toString().padLeft(2, '0');
  }

  static String getUnitFromDataType({
    required ItemCode itemCode,
  }) {
    switch (itemCode) {
      case ItemCode.PM10:
        return '㎍/㎥';
      case ItemCode.PM25:
        return '㎍/㎥';
      default:
        return 'ppm';
    }
  }

  static String getItemCodeKrString({
    required ItemCode itemCode,
  }) {
    switch (itemCode) {
      case ItemCode.PM10:
        return '미세먼지';
      case ItemCode.PM25:
        return '초미세먼지';
      case ItemCode.NO2:
        return '이산화질소';
      case ItemCode.O3:
        return '오존';
      case ItemCode.CO:
        return '일산화탄소';
      case ItemCode.SO2:
        return '아황산가스';
    }
  }

  static StatusModel getStatusFromItemCodeAndValue({
    required double value,
    required ItemCode itemCode,
  }) {
    try {
      return statusLevel.where((status) {
        if (itemCode == ItemCode.PM10) {
          //강의 버그 수정 -> 0.0일때 에러발생(No Element) 수정 (2022.9.16)
          if(value == 0) return status.minFineDust == value;
          return status.minFineDust < value;
        } else if (itemCode == ItemCode.PM25) {
          //강의 버그 수정 -> 0.0일때 에러발생(No Element) 수정 (2022.9.16)
          if(value == 0) return status.minUltraFineDust == value;
          return status.minUltraFineDust < value;
        } else if (itemCode == ItemCode.CO) {
          //강의 버그 수정 -> 0.0일때 에러발생(No Element) 수정 (2022.9.16)
          if(value == 0) return status.minCO == value;
          return status.minCO < value;
        } else if (itemCode == ItemCode.O3) {
          //강의 버그 수정 -> 0.0일때 에러발생(No Element) 수정 (2022.9.16)
          if(value == 0) return status.minO3 == value;
          return status.minO3 < value;
        } else if (itemCode == ItemCode.NO2) {
          //강의 버그 수정 -> 0.0일때 에러발생(No Element) 수정 (2022.9.16)
          if(value == 0) return status.minNO2 == value;
          return status.minNO2 < value;
        } else if (itemCode == ItemCode.SO2) {
          //강의 버그 수정 -> 0.0일때 에러발생(No Element) 수정 (2022.9.16)
          if(value == 0) return status.minSO2 == value;
          return status.minSO2 < value;
        } else {
          throw Exception('알수없는 ItemCode입니다.');
        }
      }).last;
    } catch (e) {
      print("<$itemCode> 에러 : $e");
      return statusLevel.last;
    }
  }
}
