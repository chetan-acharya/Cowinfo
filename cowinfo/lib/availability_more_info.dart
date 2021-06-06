import 'package:cowinfo/BackendService/cowin_availability_service.dart';
import 'package:flutter/material.dart';

class AvailabilityMoreInfo extends StatefulWidget {
  AvailabilityMoreInfo(
      {Key? key, required this.appointmentAvailabilityCalendarItem})
      : super(key: key);
  final AppointmentAvailabilityCalendarItem appointmentAvailabilityCalendarItem;

  @override
  _AvailabilityMoreInfoState createState() => _AvailabilityMoreInfoState();
}

class _AvailabilityMoreInfoState extends State<AvailabilityMoreInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
              child: Text(
                widget.appointmentAvailabilityCalendarItem.name,
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Text(
                  widget.appointmentAvailabilityCalendarItem.address +
                      "  " +
                      widget.appointmentAvailabilityCalendarItem.pincode,
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 18, left: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Icon(
                        Icons.monetization_on,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Fee : ",
                            style:
                                TextStyle(color: Colors.white, fontSize: 20)),
                        Text(widget.appointmentAvailabilityCalendarItem.fee,
                            style: TextStyle(
                                color: Colors.greenAccent, fontSize: 20)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: ListView(
                  children: widget
                      .appointmentAvailabilityCalendarItem.slotDetail
                      .map((slotDetailItem) {
                return Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.white)),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Date : ",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                            Text(slotDetailItem.date,
                                style: TextStyle(
                                    color: Colors.greenAccent, fontSize: 20)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Available capacity : ",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                            Text(slotDetailItem.availableCapacity,
                                style: TextStyle(
                                    color: Colors.greenAccent, fontSize: 20)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Minimum age limit : ",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                            Text(slotDetailItem.minAgeLimit,
                                style: TextStyle(
                                    color: Colors.greenAccent, fontSize: 20)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Vaccine : ",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                            Text(slotDetailItem.vaccine,
                                style: TextStyle(
                                    color: Colors.greenAccent, fontSize: 23)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Available capacity dose 1 : ",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                            Text(
                                slotDetailItem.availableCapacityDose1
                                    .toString(),
                                style: TextStyle(
                                    color: Colors.greenAccent, fontSize: 20)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Available capacity dose 2 : ",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                            Text(
                                slotDetailItem.availableCapacityDose2
                                    .toString(),
                                style: TextStyle(
                                    color: Colors.greenAccent, fontSize: 20)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Sessions : ",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                      ),
                      Column(
                        children: slotDetailItem.slots.map((slot) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(slot,
                                    style: TextStyle(
                                        color: Colors.greenAccent,
                                        fontSize: 18)),
                              ),
                            ],
                          );
                        }).toList(),
                      )
                    ],
                  ),
                );
              }).toList()),
            )
          ],
        ));
  }
}
