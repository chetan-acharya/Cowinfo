import 'dart:convert';
import 'package:translator/translator.dart';
import 'package:http/http.dart' as http;

mixin AppointmentAvailabilityDetail {
  List<AppointmentAvailabilityItem> appointmentAvailabilityItemList = [];
  AppointmentAvailabilityCalendarItem appointmentAvailabilityCalendarItem =
      AppointmentAvailabilityCalendarItem();

  Future<List<AppointmentAvailabilityItem>> getAppointmentAvailabilityByLatLong(
      String lat, String long, bool isHindi) async {
    appointmentAvailabilityItemList = [];
    var response = await fetchAppointmentAvailablityByLatLong(lat, long);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseJson = json.decode(response.body);
      int count = 0;
      for (var item in responseJson['centers']) {
        count++;
        if (count > 10) break;
        AppointmentAvailabilityCalendarItem calendarAvailabilityItem =
            new AppointmentAvailabilityCalendarItem();
        var calendarAvailabilityResponse =
            await getAppointmentAvailabilityCalendarByCenter(
                item['center_id'].toString());

        if (isHindi) {
          var locationItem = await GoogleTranslator().translate(
              item['name'] + "\n" + item['location'],
              from: 'en',
              to: 'hi');
          var appointmentAvailabilityItem = AppointmentAvailabilityItem(
              name: item['name'],
              stateName: item['state_name'],
              centerId: item['center_id'],
              districtName: item['district_name'],
              location: locationItem.text,
              pincode: item['pincode']);
          appointmentAvailabilityItem.calendarAvailabilityDetail =
              calendarAvailabilityResponse;
          appointmentAvailabilityItemList.add(appointmentAvailabilityItem);
        } else {
          var appointmentAvailabilityItem = AppointmentAvailabilityItem(
              name: item['name'],
              stateName: item['state_name'],
              centerId: item['center_id'],
              districtName: item['district_name'],
              location: item['name'] + "\n" + item['location'],
              pincode: item['pincode']);
          appointmentAvailabilityItem.calendarAvailabilityDetail =
              calendarAvailabilityResponse;
          appointmentAvailabilityItemList.add(appointmentAvailabilityItem);
        }
      }
    }
    return appointmentAvailabilityItemList;
  }

  Future<AppointmentAvailabilityCalendarItem>
      getAppointmentAvailabilityCalendarByCenter(String centerId) async {
    appointmentAvailabilityCalendarItem = AppointmentAvailabilityCalendarItem();
    var response = await fetchAppointmentAvailablityCalendarByCenter(centerId);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseJson = json.decode(response.body);
      try {
        appointmentAvailabilityCalendarItem.name =
            responseJson['centers']['name'];
        appointmentAvailabilityCalendarItem.address =
            responseJson['centers']['address'];
        appointmentAvailabilityCalendarItem.pincode =
            responseJson['centers']['pincode'].toString();
        appointmentAvailabilityCalendarItem.fee =
            responseJson['centers']['fee_type'];
        appointmentAvailabilityCalendarItem.slotDetail = [];
        for (var item in responseJson['centers']['sessions']) {
          AppointmentAvailabilityCalendarItemSlotDetail slotDetailItem =
              AppointmentAvailabilityCalendarItemSlotDetail();
          slotDetailItem.date = item['date'];
          slotDetailItem.availableCapacity =
              item['available_capacity'].toString();
          slotDetailItem.minAgeLimit = item['min_age_limit'].toString();
          slotDetailItem.vaccine = item['vaccine'];
          slotDetailItem.availableCapacityDose1 =
              item['available_capacity_dose1'];
          slotDetailItem.availableCapacityDose2 =
              item['available_capacity_dose2'];
          slotDetailItem.slots = [];
          for (var slotItem in item['slots']) {
            slotDetailItem.slots.add(slotItem);
          }
          appointmentAvailabilityCalendarItem.slotDetail.add(slotDetailItem);
        }
      } catch (e) {}
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
  String name;
  String districtName;
  String stateName;
  String location;
  String pincode;
  int centerId;
  AppointmentAvailabilityCalendarItem calendarAvailabilityDetail;
  AppointmentAvailabilityItem(
      {this.name = "",
      this.districtName = "",
      this.stateName = "",
      this.location = "",
      this.pincode = "",
      this.centerId = 0})
      : calendarAvailabilityDetail = AppointmentAvailabilityCalendarItem();
}

class AppointmentAvailabilityCalendarItem {
  String name;
  String address;
  String pincode;
  String fee;
  List<AppointmentAvailabilityCalendarItemSlotDetail> slotDetail;
  AppointmentAvailabilityCalendarItem({
    this.name = "",
    this.address = "",
    this.pincode = "",
    this.fee = "",
  }) : slotDetail = [];
}

class AppointmentAvailabilityCalendarItemSlotDetail {
  String date;
  String availableCapacity;
  String minAgeLimit;
  String vaccine;
  int availableCapacityDose1;
  int availableCapacityDose2;
  List<String> slots;

  AppointmentAvailabilityCalendarItemSlotDetail({
    this.date = "",
    this.availableCapacity = "",
    this.minAgeLimit = "",
    this.vaccine = "",
    this.availableCapacityDose1 = 0,
    this.availableCapacityDose2 = 0,
  }) : slots = [];
}
