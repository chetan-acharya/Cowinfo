import 'package:cowinfo/BackendService/backend_service.dart';
import 'package:cowinfo/BackendService/cowin_availability_service.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'availability_more_info.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lat = prefs.getString('lat') ?? '';
    String long = prefs.getString('long') ?? '';
    String userEmail = prefs.getString('userEmail') ?? '';
    if (lat != '' && userEmail != '') {
      List<AppointmentAvailabilityItem> appointmentAvailabilityItem =
          await BackendService.getInstance()
              .getAppointmentAvailabilityByLatLong(lat, long, false);
      AppointmentAvailabilityCalendarItem appointmentAvailabilityCalendarItem =
          AppointmentAvailabilityCalendarItem();
      for (var item in appointmentAvailabilityItem) {
        if (item.calendarAvailabilityDetail.name != '' &&
            item.calendarAvailabilityDetail.slotDetail.length > 0 &&
            int.parse(item.calendarAvailabilityDetail.slotDetail[0]
                    .availableCapacity) >
                0) {
          appointmentAvailabilityCalendarItem = item.calendarAvailabilityDetail;
          break;
        }
      }
      if (appointmentAvailabilityCalendarItem.name != '' &&
          int.parse(appointmentAvailabilityCalendarItem
                  .slotDetail[0].availableCapacity) >
              0) {
        String username = 'codeninja300@gmail.com';
        String password = 'CodeNinja@300';
        String mailTopHeader =
            "<p>Hi,</p>\n<p>Greetings from CowInfo !</p>\n<p>Vaccination slot found available in your area at ${DateTime.now()}</p>\n<p>Below are the details :</p>\n<h3>${appointmentAvailabilityCalendarItem.name}</h3>\n<h3>${appointmentAvailabilityCalendarItem.address}</h3>\n<h3>${appointmentAvailabilityCalendarItem.pincode}</h3>\n<p>Fee : ${appointmentAvailabilityCalendarItem.fee}</p>";
        String mailBody = "";
        int slotCount = 1;
        for (var item in appointmentAvailabilityCalendarItem.slotDetail) {
          mailBody = mailBody + "\n <p>Slot $slotCount -</p>";
          mailBody = mailBody + "\n<p>Date : ${item.date}</p>";
          mailBody = mailBody +
              "\n<p>Available Capacity : ${item.availableCapacity}</p>";
          mailBody =
              mailBody + "\n<p>Minimum age limit : ${item.minAgeLimit}</p>";
          mailBody = mailBody + "\n<h3>Vaccine : ${item.vaccine}</h3>";
          mailBody = mailBody +
              "\n<p>Available Dose 1 : ${item.availableCapacityDose1}</p>";
          mailBody = mailBody +
              "\n<p>Available Dose 2 : ${item.availableCapacityDose2}</p>";
          mailBody = mailBody + "\n<p>Slot Timings :</p>";
          for (var slotTimingItem in item.slots) {
            mailBody = mailBody + "\n<p>$slotTimingItem</p>";
          }
          slotCount++;
        }
        String mailBottom =
            "\n\n\n <p>Note : You are getting this E-Mail because you have enabled slot availability notification in CowInfo application. To stop recieving these mails please disable notification in the app.</p>\n\n\n<p>Thanks,</p>\n<p>CowInfo</p>";
        final smtpServer = gmail(username, password);
        final message = mailer.Message()
          ..from = mailer.Address(username, 'CoWinfo')
          ..recipients.add(userEmail)
          ..bccRecipients.add(mailer.Address('chetanlml@gmail.com'))
          ..subject = 'Vaccination slot is available in your area !'
          ..text = 'Vaccination slot is available in your area !'
          ..html = mailTopHeader + mailBody + mailBottom;

        try {
          final sendReport = await mailer.send(message, smtpServer);
          print('Message sent: ' + sendReport.toString());
        } on mailer.MailerException catch (e) {
          print('Message not sent.');
          for (var p in e.problems) {
            print('Problem: ${p.code}: ${p.msg}');
          }
        }
      }
    }
    return Future.value(true);
  });
}

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

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String latitude = "";
  bool isHindi = false;
  String userEmail = "";
  late SharedPreferences prefs;
  bool isLocationUpdated = false;
  bool _serviceEnabled = false;
  Location location = Location();
  late LocationData previousLocationData;
  PermissionStatus _permissionGranted = PermissionStatus.denied;

  // get user location and check for available appointments in the location
  Future<List<AppointmentAvailabilityItem>>
      getUserLocationAndAppointmentAvailabilityList() async {
    final List<AppointmentAvailabilityItem> appointmentAvailabilityItem;
    try {
      if (_serviceEnabled) {
        _serviceEnabled = await location.serviceEnabled();
        if (!_serviceEnabled) {
          _serviceEnabled = await location.requestService();
          if (!_serviceEnabled) {
            appointmentAvailabilityItem = [];
            return appointmentAvailabilityItem;
          }
        }
      }
      if (_permissionGranted != PermissionStatus.granted) {
        _permissionGranted = await location.hasPermission();
        if (_permissionGranted == PermissionStatus.denied) {
          _permissionGranted = await location.requestPermission();
          if (_permissionGranted != PermissionStatus.granted) {
            appointmentAvailabilityItem = [];
            return appointmentAvailabilityItem;
          }
        }
      }
      if (!isLocationUpdated) {
        LocationData _locationData = await location.getLocation();
        prefs.setString('lat', _locationData.latitude.toString());
        prefs.setString('long', _locationData.longitude.toString());
        isLocationUpdated = true;
        previousLocationData = _locationData;
      }
      appointmentAvailabilityItem = await BackendService.getInstance()
          .getAppointmentAvailabilityByLatLong(
              previousLocationData.latitude.toString(),
              previousLocationData.longitude.toString(),
              isHindi);
    } catch (e) {
      String lat = prefs.getString('lat') ?? '0';
      String long = prefs.getString('long') ?? '0';
      var appointmentAvailabilityItemPreviousLocation = await BackendService()
          .getAppointmentAvailabilityByLatLong(lat, long, isHindi);
      return appointmentAvailabilityItemPreviousLocation;
    }
    return appointmentAvailabilityItem;
  }

  List<bool> isSelected = [false, true];
  final emailTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setValuesFromSharedPreference();
  }

  setValuesFromSharedPreference() async {
    prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('userEmail') ?? '';
    bool hindi = prefs.getBool('isHindi') ?? false;
    setState(() {
      userEmail = email;
      isHindi = hindi;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      body: FutureBuilder<List<AppointmentAvailabilityItem>>(
        future: getUserLocationAndAppointmentAvailabilityList(),
        builder: (BuildContext context,
            AsyncSnapshot<List<AppointmentAvailabilityItem>> snapshot) {
          Widget children;
          if (snapshot.hasData) {
            children = snapshot.data!.length > 0
                ? Center(child: getAvailableAppointmentCenterList(snapshot))
                : Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            "No vaccination center found near you !",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            "Note : Location is necessary for this app to run properly. Make sure location permission is enabled for the app.",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        )
                      ],
                    ),
                  );
          } else if (snapshot.hasError) {
            children = getErrorWidget();
          } else {
            children = getLoadingWidget();
          }
          return Column(
            children: [
              getAlertsAndLanguageToggleButton(),
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 10),
                child: getListHeaderTextWidget(),
              ),
              Flexible(
                child: children,
                flex: 10,
              ),
            ],
          );
        },
      ),
    );
  }

  Center getErrorWidget() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.error,
          color: Colors.red,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "No vaccincation centers found in your area !",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        )
      ],
    ));
  }

  Center getLoadingWidget() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Finding vaccination centers near you...",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        )
      ],
    ));
  }

  Center getListHeaderTextWidget() {
    return Center(
        child: Text(
      "Vaccination Centers Near You :",
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
      ),
    ));
  }

  Flexible getAlertsAndLanguageToggleButton() {
    return Flexible(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            getAlertNotifyButton(),
            // Padding(
            //   padding: const EdgeInsets.only(right: 10),
            //   child: ToggleButtons(
            //     borderColor: Colors.white,
            //     selectedBorderColor: Colors.white,
            //     color: Colors.white,
            //     selectedColor: Colors.amberAccent,
            //     fillColor: Colors.purple,
            //     children: [
            //       Text(
            //         "हिंदी",
            //       ),
            //       Text("English")
            //     ],
            //     isSelected: isSelected,
            //     onPressed: (int index) {
            //       setState(() {
            //         if (index == 0) {
            //           isSelected[0] = true;
            //           isSelected[1] = false;
            //           isHindi = true;
            //           prefs.setBool('isHindi', isHindi);
            //         } else {
            //           isSelected[0] = false;
            //           isSelected[1] = true;
            //           isHindi = false;
            //           prefs.setBool('isHindi', isHindi);
            //           Workmanager().registerPeriodicTask(
            //             "1",
            //             "checkSlotAvailability",
            //             frequency: Duration(minutes: 15),
            //             constraints: Constraints(
            //               networkType: NetworkType.connected,
            //             ),
            //           );
            //         }
            //       });
            //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            //         content: Text("Translating..."),
            //       ));
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Padding getAlertNotifyButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: TextButton(
        style: TextButton.styleFrom(
          primary: Colors.white,
          backgroundColor: Colors.purple,
          onSurface: Colors.grey,
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Icon(
                Icons.notification_add,
                color: Colors.yellowAccent,
              ),
            ),
            Text(
              userEmail == ''
                  ? "Notify me on slot availability"
                  : "Slot Notification is enabled",
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
        onPressed: () {
          if (userEmail == '') {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) {
                  return AlertDialog(
                    title: Text("Notify me on slot availability"),
                    content: SizedBox(
                      height: 100,
                      width: double.infinity,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text("Please enter your E-Mail ID:"),
                          ),
                          TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Your Email',
                            ),
                            controller: emailTextController,
                          )
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          child: Text("Cancel")),
                      TextButton(
                          onPressed: () {
                            bool emailValid = RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(emailTextController.text);
                            if (!emailValid) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text("Please enter a valid Email ID"),
                              ));
                            } else {
                              setState(() {
                                userEmail = emailTextController.text;
                              });
                              prefs.setString(
                                  'userEmail', emailTextController.text);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text("Slot Notification is enabled"),
                              ));
                              Workmanager().initialize(callbackDispatcher);
                              Workmanager().registerPeriodicTask(
                                "1",
                                "checkSlotAvailability",
                                frequency: Duration(hours: 1),
                                constraints: Constraints(
                                  networkType: NetworkType.connected,
                                ),
                              );
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          },
                          child: Text("OK"))
                    ],
                  );
                });
          } else {
            showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: Text("Notify me on slot availability"),
                    content: SizedBox(
                        height: 50,
                        width: double.infinity,
                        child:
                            Text("Do you want to disable slot notification ?")),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          child: Text("Cancel")),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              userEmail = '';
                            });
                            prefs.setString('userEmail', '');
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Slot Notification is disabled"),
                            ));
                            Workmanager().cancelAll();
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          child: Text("Yes"))
                    ],
                  );
                });
          }
        },
      ),
    );
  }

  ListView getAvailableAppointmentCenterList(
      AsyncSnapshot<List<AppointmentAvailabilityItem>> snapshot) {
    return ListView(
      children: snapshot.data!.map((appointmentAvailabilityDetail) {
        bool isDataAvailable =
            appointmentAvailabilityDetail.calendarAvailabilityDetail.name != "";
        return Builder(
          builder: (BuildContext context) {
            return ListTile(
                onTap: () {
                  if (isDataAvailable) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AvailabilityMoreInfo(
                              key: UniqueKey(),
                              appointmentAvailabilityCalendarItem:
                                  appointmentAvailabilityDetail
                                      .calendarAvailabilityDetail,
                            )));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text("Slot data is not available for this center !"),
                    ));
                  }
                },
                // tileColor: Color.fromRGBO(58, 66, 86, 1.0),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                leading: Container(
                  padding: EdgeInsets.only(right: 12.0),
                  decoration: new BoxDecoration(
                      border: new Border(
                          right: new BorderSide(
                              width: 1.0, color: Colors.white24))),
                  child: Icon(Icons.medical_services, color: Colors.white),
                ),
                title: Text(
                  appointmentAvailabilityDetail.location,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

                subtitle: Row(
                  children: <Widget>[
                    Icon(Icons.linear_scale,
                        color: isDataAvailable
                            ? Colors.greenAccent
                            : Colors.yellowAccent),
                    Text(
                        isDataAvailable
                            ? " Slot data available"
                            : "Slot data not available",
                        style: TextStyle(color: Colors.white))
                  ],
                ),
                trailing: Icon(Icons.keyboard_arrow_right,
                    color: Colors.white, size: 30.0));
          },
        );
      }).toList(),
    );
  }
}
