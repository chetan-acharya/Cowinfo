import 'dart:convert';
import 'package:translator/translator.dart';
import 'package:http/http.dart' as http;

mixin AppointmentAvailabilityDetail {
  List<AppointmentAvailabilityItem>? appointmentAvailabilityItemList;
  AppointmentAvailabilityCalendarItem? appointmentAvailabilityCalendarItem;

  Future<List<AppointmentAvailabilityItem>?>
      getAppointmentAvailabilityByLatLong(String lat, String long) async {
    appointmentAvailabilityItemList = [];
    var response = await fetchAppointmentAvailablityByLatLong(lat, long);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseJson = json.decode(response.body);
      int count = 0;
      for (var item in responseJson['centers']) {
        count++;
        if (count > 10) break;
        var locationItem = await GoogleTranslator().translate(
            item['name'] + "\n" + item['location'],
            from: 'en',
            to: 'hi');
        appointmentAvailabilityItemList?.add(AppointmentAvailabilityItem(
            name: item['name'],
            stateName: item['state_name'],
            centerId: item['center_id'],
            districtName: item['district_name'],
            location: locationItem.text,
            pincode: item['pincode']));
      }
    }
    return appointmentAvailabilityItemList;
  }

  Future<AppointmentAvailabilityCalendarItem?>
      getAppointmentAvailabilityCalendarByCenter(String centerId) async {
    appointmentAvailabilityCalendarItem = AppointmentAvailabilityCalendarItem();
    var response = await fetchAppointmentAvailablityCalendarByCenter(centerId);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseJson = json.decode(response.body);
      try {
        appointmentAvailabilityCalendarItem?.name = responseJson['centers']
                ['name'] +
            '\n' +
            responseJson['centers']['address'] +
            '\n' +
            responseJson['centers']['sessions'][0]['vaccine'];
      } catch (e) {
        appointmentAvailabilityCalendarItem?.name = "";
      }
    }
    return appointmentAvailabilityCalendarItem;
  }

  Future<http.Response> fetchAppointmentAvailablityByLatLong(
      String lat, String long) {
    final Map<String, String> _queryParameters = <String, String>{
      'lat': lat,
      'long': long,
    };
    return http.get(Uri.https('cdn-api.co-vin.in',
        'api/v2/appointment/centers/public/findByLatLong', _queryParameters));
  }

  Future<http.Response> fetchAppointmentAvailablityCalendarByCenter(
      String centerId) {
    String date = DateTime.now().day.toString().padLeft(2, '0') +
        '-' +
        DateTime.now().month.toString().padLeft(2, '0') +
        '-' +
        DateTime.now().year.toString();
    final Map<String, String> _queryParameters = <String, String>{
      'center_id': centerId,
      'date': date,
    };
    return http.get(Uri.https(
        'cdn-api.co-vin.in',
        'api/v2/appointment/sessions/public/calendarByCenter',
        _queryParameters));
  }
}

class AppointmentAvailabilityItem {
  String? name;
  String? districtName;
  String? stateName;
  String? location;
  String? pincode;
  int? centerId;

  AppointmentAvailabilityItem(
      {this.name,
      this.districtName,
      this.stateName,
      this.location,
      this.pincode,
      this.centerId});
}

class AppointmentAvailabilityCalendarItem {
  String? name;
  String? districtName;
  String? stateName;
  String? location;
  String? pincode;
  int? centerId;

  AppointmentAvailabilityCalendarItem(
      {this.name,
      this.districtName,
      this.stateName,
      this.location,
      this.pincode,
      this.centerId});
}
