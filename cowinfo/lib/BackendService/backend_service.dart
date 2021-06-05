import 'package:cowinfo/BackendService/cowin_availability_service.dart';

class BackendService with AppointmentAvailabilityDetail {
  static BackendService? _instance;

  //method to access all the methods from the mixin and local methods
  static BackendService? getInstance() {
    if (_instance == null) {
      _instance = BackendService();
    }
    return _instance;
  }
}
