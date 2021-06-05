import 'package:cowinfo/BackendService/backend_service.dart';
import 'package:cowinfo/BackendService/cowin_availability_service.dart';
import 'package:flutter/material.dart';

class AvailabilityMoreInfo extends StatefulWidget {
  AvailabilityMoreInfo({Key? key, required this.centerId}) : super(key: key);
  String centerId;

  @override
  _AvailabilityMoreInfoState createState() => _AvailabilityMoreInfoState();
}

class _AvailabilityMoreInfoState extends State<AvailabilityMoreInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<AppointmentAvailabilityCalendarItem?>(
        future: BackendService.getInstance()
            ?.getAppointmentAvailabilityCalendarByCenter(widget.centerId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(child: Text(snapshot.data!.name!));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
