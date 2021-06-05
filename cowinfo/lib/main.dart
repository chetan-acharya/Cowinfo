import 'package:cowinfo/BackendService/backend_service.dart';
import 'package:cowinfo/BackendService/cowin_availability_service.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import 'availability_more_info.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CoWInfo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'CoWInfo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String latitude = "";
  List<AppointmentAvailabilityItem>? appointmentAvailabilityItem;
  Future<List<AppointmentAvailabilityItem>?> GetUserLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return appointmentAvailabilityItem;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return appointmentAvailabilityItem;
      }
    }

    _locationData = await location.getLocation();
    appointmentAvailabilityItem = await BackendService.getInstance()
        ?.getAppointmentAvailabilityByLatLong(_locationData.latitude.toString(),
            _locationData.longitude.toString());
    return appointmentAvailabilityItem;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: FutureBuilder<List<AppointmentAvailabilityItem>?>(
        future: GetUserLocation(),
        builder: (BuildContext context,
            AsyncSnapshot<List<AppointmentAvailabilityItem>?> snapshot) {
          if (snapshot.hasData) {
            return Center(
                child: ListView(
              children: snapshot.data!.map((appointmentAvailabilityDetail) {
                return Builder(
                  builder: (BuildContext context) {
                    return Row(
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextButton(
                              child:
                                  Text(appointmentAvailabilityDetail.location!),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => AvailabilityMoreInfo(
                                          key: UniqueKey(),
                                          centerId:
                                              appointmentAvailabilityDetail
                                                  .centerId!
                                                  .toString(),
                                        )));
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }).toList(),
            ));
          } else if (snapshot.hasError) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
