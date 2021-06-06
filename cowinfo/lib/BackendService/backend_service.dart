import 'package:cowinfo/BackendService/cowin_availability_service.dart';

class BackendService with AppointmentAvailabilityDetail {
  static BackendService _instance = BackendService();

  //method to access all the methods from the mixin and local methods
  static BackendService getInstance() {
    return _instance;
  }
}
