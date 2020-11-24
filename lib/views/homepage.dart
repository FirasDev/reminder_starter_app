import 'package:reminder_Starter_App/alarm_config.dart';
import 'package:reminder_Starter_App/custom_theme.dart';
import 'package:reminder_Starter_App/models/alarm_data.dart';
import 'package:reminder_Starter_App/models/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../main.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'secondScreen.dart';

class AlarmSwitch extends StatefulWidget {
  final AlarmInfo alarmInfo;

  const AlarmSwitch({Key key, this.alarmInfo}) : super(key: key);

  @override
  _AlarmSwitchState createState() => _AlarmSwitchState(this.alarmInfo);
}

class _AlarmSwitchState extends State<AlarmSwitch> {
  _AlarmSwitchState(AlarmInfo _alarmInfo) {
    this.alarmInfo = _alarmInfo;
  }
  bool isSwitched;
  AlarmConfig _alarmConfig = AlarmConfig();
  AlarmInfo alarmInfo;

  @override
  Widget build(BuildContext context) {
    if (alarmInfo.isEnabled == null)
      isSwitched = true;
    else if (alarmInfo.isEnabled == 1)
      isSwitched = true;
    else if (alarmInfo.isEnabled == 0) isSwitched = false;
    return Switch(
      onChanged: (value) {
        setState(() {
          isSwitched = value;
        });
        alarmInfo.isEnabled = isSwitched == true ? 1 : 0;
        _alarmConfig.updateAlarm(alarmInfo);
      },
      value: isSwitched,
      activeColor: Colors.green,
      activeTrackColor: Colors.greenAccent,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage(
    this.notificationAppLaunchDetails, {
    Key key,
  }) : super(key: key);

  final NotificationAppLaunchDetails notificationAppLaunchDetails;
  bool get didNotificationLaunchApp =>
      notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _alarmTime;
  String _alarmTimeString;
  DateTime selectedDate = DateTime.now();
  AlarmConfig _alarmConfig = AlarmConfig();
  Future<List<AlarmInfo>> _alarms;
  List<AlarmInfo> alarms;
  AlarmInfo _scheduledAlarm;

  @override
  void initState() {
    _alarmTime = DateTime.now();
    _alarmConfig.initializeDatabase().then((value) {
      loadAlarms();
      _configureDidReceiveLocalNotificationSubject();
    });
    super.initState();
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        SecondScreen(receivedNotification.payload),
                  ),
                );
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  Future<List<AlarmInfo>> updateAndGetList() async {
    //await widget.feeds.update();

    // return the list here
    return _alarmConfig.getAlarms();
  }

  Future<void> refreshList() {
    // reload
    setState(() {
      _alarms = updateAndGetList();
    });
    return _alarmConfig.getAlarms();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void loadAlarms() async {
    _alarms = _alarmConfig.getAlarms();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Random random = new Random();
    String alarmTitle = "alarm";
    String occurence = "once";
    return Scaffold(
      backgroundColor: CustomColors.pageBackgroundColor,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 64),
        child: Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            Positioned(
              top: -MediaQuery.of(context).size.height / 30,
              child: Text(
                'Alarm Reminder for epap',
                style: TextStyle(
                    fontFamily: 'avenir',
                    fontWeight: FontWeight.w700,
                    color: CustomColors.primaryTextColor,
                    fontSize: 24),
              ),
            ),
            Container(
              child: FutureBuilder<List<AlarmInfo>>(
                future: _alarms,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    alarms = snapshot.data;
                    return Scrollbar(
                      child: RefreshIndicator(
                          child: ListView.builder(
                              itemCount: alarms.length,
                              itemBuilder: (context, index) {
                                var alarmTime = DateFormat('hh:mm aa')
                                    .format(alarms[index].alarmDateTime);
                                var gradientColor = GradientTemplate
                                    .gradientTemplate[
                                        alarms[index].gradientColorIndex]
                                    .colors;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 32),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: gradientColor,
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            gradientColor.last.withOpacity(0.4),
                                        blurRadius: 3,
                                        spreadRadius: 2,
                                        offset: Offset(4, 4),
                                      ),
                                    ],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(24)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Icon(
                                                Icons.label,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                alarms[index].title,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'avenir'),
                                              ),
                                            ],
                                          ),
                                          (AlarmSwitch(
                                              alarmInfo: alarms[index]))
                                        ],
                                      ),
                                      Text(
                                        'Mon-Fri',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'avenir'),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            alarmTime,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'avenir',
                                                fontSize: 24,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            color: Colors.redAccent,
                                            onPressed: () {
                                              _alarmConfig
                                                  .delete(alarms[index].id);
                                              setState(() {
                                                refreshList();
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          onRefresh: refreshList),
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
            Positioned(
              bottom: -MediaQuery.of(context).size.height / 60,
              right: MediaQuery.of(context).size.width / 3.5,
              child: Center(
                child: FlatButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  onPressed: () {
                    _alarmTimeString =
                        DateFormat('HH:mm').format(DateTime.now());
                    showModalBottomSheet(
                      useRootNavigator: true,
                      context: context,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setModalState) {
                            return Container(
                              decoration: BoxDecoration(color: Colors.black87),
                              height: MediaQuery.of(context).size.height / 2.6,
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  FlatButton(
                                      onPressed: () async {
                                        final DateTime picked =
                                            await showDatePicker(
                                          context: context,
                                          initialDate:
                                              selectedDate, // Refer step 1
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2025),
                                        );
                                        if (picked != null) {
                                          setState(() {
                                            selectedDate = picked;
                                          });
                                          var selectedTime =
                                              await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.now(),
                                          );
                                          if (selectedTime != null) {
                                            var selectedDateTime = DateTime(
                                                picked.year,
                                                picked.month,
                                                picked.day,
                                                selectedTime.hour,
                                                selectedTime.minute);
                                            _alarmTime = selectedDateTime;
                                            setModalState(() {
                                              _alarmTimeString =
                                                  selectedTime.toString();
                                            });
                                          }
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _alarmTimeString,
                                            style: TextStyle(
                                                fontSize: 32,
                                                color: Theme.of(context)
                                                    .accentColor),
                                          ),
                                          Icon(
                                            Icons.access_alarms,
                                            size: 32,
                                            color:
                                                Theme.of(context).accentColor,
                                          ),
                                        ],
                                      )),
                                  ListTile(
                                    title: Text('Repeat',
                                        style: TextStyle(color: Colors.white)),
                                    trailing: GestureDetector(
                                        onTap: () => {
                                              showModalBottomSheet(
                                                useRootNavigator: true,
                                                context: context,
                                                clipBehavior: Clip.antiAlias,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                    top: Radius.circular(24),
                                                  ),
                                                ),
                                                builder: (context) {
                                                  return StatefulBuilder(
                                                    builder: (context,
                                                        setModalState) {
                                                      return Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                color: Colors
                                                                    .black87),
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            3,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(32),
                                                        child: Column(
                                                          children: [
                                                            ListTile(
                                                              leading: Icon(
                                                                  Icons
                                                                      .arrow_forward_ios,
                                                                  color: Colors
                                                                      .white),
                                                              title:
                                                                  GestureDetector(
                                                                      onTap:
                                                                          () =>
                                                                              {
                                                                                setState(() {
                                                                                  occurence = "daily";
                                                                                }),
                                                                                Navigator.pop(context)
                                                                              },
                                                                      child:
                                                                          Text(
                                                                        'daily',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white),
                                                                      )),
                                                            ),
                                                            ListTile(
                                                                leading: Icon(
                                                                    Icons
                                                                        .arrow_forward_ios,
                                                                    color: Colors
                                                                        .white),
                                                                title:
                                                                    GestureDetector(
                                                                  onTap: () => {
                                                                    setState(
                                                                        () {
                                                                      occurence =
                                                                          "weekly";
                                                                    }),
                                                                    Navigator.pop(
                                                                        context)
                                                                  },
                                                                  child: Text(
                                                                      'Weekly',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white)),
                                                                )),
                                                            ListTile(
                                                                leading: Icon(
                                                                    Icons
                                                                        .arrow_forward_ios,
                                                                    color: Colors
                                                                        .white),
                                                                title:
                                                                    GestureDetector(
                                                                  onTap: () => {
                                                                    setState(
                                                                        () {
                                                                      occurence =
                                                                          "monthly";
                                                                    }),
                                                                    Navigator.pop(
                                                                        context)
                                                                  },
                                                                  child: Text(
                                                                      'Monthly',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white)),
                                                                )),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              )
                                            },
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              6,
                                          child: Row(
                                            children: [
                                              Text("Daily",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        )),
                                  ),
                                  ListTile(
                                      title: Text('Title',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      trailing: GestureDetector(
                                        onTap: () => {
                                          showModalBottomSheet(
                                            useRootNavigator: true,
                                            context: context,
                                            clipBehavior: Clip.antiAlias,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                top: Radius.circular(24),
                                              ),
                                            ),
                                            builder: (context) {
                                              return StatefulBuilder(
                                                builder:
                                                    (context, setModalState) {
                                                  return Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: MediaQuery.of(
                                                                context)
                                                            .viewInsets
                                                            .bottom),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Colors.black87),
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              5,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              32),
                                                      child: Column(
                                                        children: [
                                                          ListTile(
                                                            leading: Icon(
                                                              Icons.description,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            title:
                                                                new TextField(
                                                              onChanged:
                                                                  (value) => {
                                                                setState(() {
                                                                  alarmTitle =
                                                                      value;
                                                                })
                                                              },
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                              maxLines: 1,
                                                              cursorColor:
                                                                  Colors.white,
                                                              decoration:
                                                                  new InputDecoration(
                                                                enabledBorder:
                                                                    UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.white),
                                                                ),
                                                                focusedBorder:
                                                                    UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.white),
                                                                ),
                                                                border:
                                                                    UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.white),
                                                                ),
                                                                hoverColor:
                                                                    Colors
                                                                        .white,
                                                                labelStyle: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                                hintStyle: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                                hintText:
                                                                    "Alarm Name",
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          )
                                        },
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              6,
                                          child: Row(
                                            children: [
                                              Text("alarm",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )),
                                  FloatingActionButton.extended(
                                    onPressed: () async {
                                      int randomNumber = random.nextInt(5);
                                      DateTime scheduleAlarmDateTime;
                                      if (_alarmTime.isAfter(DateTime.now()))
                                        scheduleAlarmDateTime = _alarmTime;
                                      else
                                        scheduleAlarmDateTime =
                                            _alarmTime.add(Duration(days: 1));

                                      var alarmInfo = AlarmInfo(
                                        title: alarmTitle,
                                        occurence: occurence,
                                        alarmDateTime: scheduleAlarmDateTime,
                                        gradientColorIndex: randomNumber,
                                      );
                                      setState(() {
                                        _scheduledAlarm = alarmInfo;
                                      });
                                      _alarmConfig.insertAlarm(alarmInfo);
                                      setState(() {
                                        refreshList();
                                        Navigator.pop(context);
                                      });
                                    },
                                    icon: Icon(Icons.alarm),
                                    label: Text('Save'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                    scheduleAlarm(_scheduledAlarm);
                  },
                  child: Column(
                    children: <Widget>[
                      Image.asset(
                        'assets/add.png',
                        scale: 1.5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void scheduleAlarm(AlarmInfo _scheduledAlarm) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'alarm_notif', 'alarm_notif', 'epap notification',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        0,
        _scheduledAlarm?.title ?? "alarm",
        "Show reminder",
        platformChannelSpecifics,
        payload: 'epap');
  }
}
