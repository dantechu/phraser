import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:phraser/consts/assets.dart';
import 'package:phraser/screens/notification_settings/model/notification_model.dart';
import 'package:phraser/screens/notification_settings/notification_helper.dart';
import 'package:phraser/screens/notification_settings/service/notifications_service.dart';
import 'package:phraser/util/colors.dart';
import 'package:phraser/util/helper/route_helper.dart';
import 'package:phraser/util/preferences.dart';

class FreeNotificationSettingsScreen extends StatefulWidget {
  const FreeNotificationSettingsScreen({Key? key, required this.willPop}) : super(key: key);

  final bool willPop;

  @override
  _FreeNotificationSettingsScreenState createState() => _FreeNotificationSettingsScreenState();
}

class _FreeNotificationSettingsScreenState extends State<FreeNotificationSettingsScreen> {
  TimeOfDay _startTime = TimeOfDay(hour: 5, minute: 0,);
  TimeOfDay _endTime = TimeOfDay(hour: 21, minute: 0);
  double _frequency = 4.0;
  NotificationsModel? _notificationsModel;


  void _selectStartTime(BuildContext context) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (newTime != null) {
      setState(() {
        _startTime = newTime;
      });
    }
  }

  void _selectEndTime(BuildContext context) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (newTime != null) {
      setState(() {
        _endTime = newTime;
      });
    }
  }

  void _onFrequencyChanged(double value) {
    setState(() {
      _frequency = value;
    });
  }

  // More reliable iOS permission checking using flutter_local_notifications
  Future<bool> _checkIOSNotificationPermission() async {
    try {
      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      
      // Method 1: Try to query pending notifications
      try {
        final List<PendingNotificationRequest> pendingNotifications = 
            await flutterLocalNotificationsPlugin.pendingNotificationRequests();
        debugPrint('iOS: Successfully queried ${pendingNotifications.length} pending notifications');
      } catch (e) {
        debugPrint('iOS: Could not query pending notifications: $e');
      }
      
      // Method 2: Try to show a test notification immediately and cancel it
      try {
        const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
          'test_channel', 'Test Channel',
          importance: Importance.low,
          priority: Priority.low,
        );
        const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
          presentAlert: false,
          presentBadge: false,
          presentSound: false,
        );
        const NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidDetails, 
          iOS: iosDetails,
        );
        
        // Try to show a silent test notification using the designated test ID
        const testId = 99999; // NotificationIdRanges.testNotificationId
        await flutterLocalNotificationsPlugin.show(
          testId,
          '', // Empty title
          '', // Empty body
          platformChannelSpecifics,
        );
        
        // Immediately cancel the test notification
        await flutterLocalNotificationsPlugin.cancel(testId);
        
        debugPrint('iOS: Successfully showed and cancelled test notification - permission granted');
        return true;
      } catch (e) {
        debugPrint('iOS: Could not show test notification: $e');
        
        // Fallback to permission_handler
        final permissionStatus = await Permission.notification.status;
        debugPrint('iOS: Fallback permission handler status: $permissionStatus');
        
        // On iOS, be more lenient with permission status interpretation
        // Sometimes permission_handler is not 100% accurate on iOS
        if (permissionStatus == PermissionStatus.granted ||
            permissionStatus == PermissionStatus.provisional ||
            permissionStatus == PermissionStatus.limited) {
          debugPrint('iOS: Permission handler indicates permission is granted');
          return true;
        }
        
        // Final fallback: if user reports they have enabled notifications in settings
        // but permission_handler says denied, we'll assume it's a permission_handler bug
        debugPrint('iOS: Permission handler says denied but user may have enabled in settings');
        debugPrint('iOS: This might be a permission_handler limitation on iOS');
        
        return false;
      }
    } catch (e) {
      debugPrint('iOS: Error in permission check: $e');
      return false;
    }
  }

  Future<void> _saveNotificationSettings() async {
    try {
      // Store context before async operations
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      
      // Save notification settings
      String startHour = _startTime.hour.toInt() < 10 ? '0${_startTime.hour}' : _startTime.hour.toString();
      String startMinute = _startTime.minute.toInt() < 10 ? '0${_startTime.minute}' : _startTime.minute.toString();
      String endtHour = _endTime.hour.toInt() < 10 ? '0${_endTime.hour}' : _endTime.hour.toString();
      String endMinute = _endTime.minute.toInt() < 10 ? '0${_endTime.minute}' : _endTime.minute.toString();
      
      NotificationsModel model = NotificationsModel(
          startAt: '$startHour:$startMinute',
          endAt: '$endtHour:$endMinute',
          frequency: _frequency.toInt(), 
          notificationData: ['notification 1','notification 2', 'notification 2']);
      
      NotificationConfigService.instance.notificationDetails = model;

      // Schedule free notifications (ID range 1000-1999)
      // This will cancel only existing free notifications and create new ones
      // Pro notifications (ID range 2000-2999) remain unaffected
      await NotificationHelper.instance.reScheduleFreeNotifications();

      // Show success message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Notification settings saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      if (widget.willPop) {
        navigator.pop();
      } else {
        Get.offAllNamed(RouteHelper.phraserScreen);
      }
    } catch (e) {
      debugPrint('Error saving notification settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPermissionSettingsDialog() {
    debugPrint('Showing permission settings dialog');
    
    final String instructions = defaultTargetPlatform == TargetPlatform.iOS
        ? 'Go to Settings > I AM Blessed > Notifications and turn on "Allow Notifications".'
        : 'Go to Settings > Apps > I AM Blessed > Notifications and turn on notifications.';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notification Permission Required'),
          content: Text(
            'To receive daily motivation reminders, please enable notification permission from your device settings.\n\n$instructions',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            if (defaultTargetPlatform == TargetPlatform.iOS) ...[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Skip permission check and proceed (iOS workaround)
                  _saveNotificationSettings();
                },
                child: Text('I\'ve Enabled It', style: TextStyle(fontSize: 12)),
              ),
            ],
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    _notificationsModel = NotificationConfigService.instance.notificationDetails;
    if(_notificationsModel != null) {
      _startTime = TimeOfDay.fromDateTime(DateTime.parse('2022-01-01 ${_notificationsModel!.startAt}:00'));
      _endTime =  TimeOfDay.fromDateTime(DateTime.parse('2022-01-01 ${_notificationsModel!.endAt}:00'));
      _frequency = _notificationsModel?.frequency.toDouble() ?? 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back)),
        title: Text('Notifications Settings'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SizedBox(height: 50.0,),
              Container(
                  width: 100.0,
                  height: 100.0,
                  child: Image.asset(AppAssets.kNotificationIcon)),
              SizedBox(height: 20.0,),
              Text('Set daily motivation reminders\nto stay blessed', style: TextStyle(fontSize: 20.0),textAlign: TextAlign.center,),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                margin: EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
                child: ListTile(
                  leading: Container(
                      margin: EdgeInsets.only(top: 8.0),
                      child: Icon(Icons.timer_outlined, color: kPrimaryColor,)),
                  title: Text('Starts at'),
                  subtitle: Text(_startTime.format(context)),
                  onTap: () => _selectStartTime(context),
                ),
              ),
              Card(
                margin: EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
                child: ListTile(
                  leading: Container(
                      margin: EdgeInsets.only(top: 8.0),
                      child: Icon(Icons.timer_outlined, color: kPrimaryColor,)),
                  title: Text('Ends at'),
                  subtitle: Text(_endTime.format(context)),
                  onTap: () => _selectEndTime(context),
                ),
              ),
              Card(
                margin: EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
                child: ListTile(
                  leading: Container(
                      margin: EdgeInsets.only(top: 8.0),
                      child: Icon(Icons.speed, color: kPrimaryColor,)),
                  title: Text('Frequency      ${_frequency.toInt()}'),
                  subtitle: Row(
                    children: [
                      Text('0'),
                      Container(
                        width: MediaQuery.of(context).size.width/1.7,
                        child: Slider(
                          value: _frequency,
                          min: 0.0,
                          max: 10.0,
                          divisions: 10,
                          onChanged: _onFrequencyChanged,
                        ),
                      ),
                      Text('10'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
              width: MediaQuery.of(context).size.width,
              height: 45.0,
              margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 70.0),
              child: ElevatedButton(
                  onPressed: () async {
                    if(Preferences.instance.isFirstOpen) {
                      Preferences.instance.isFirstOpen = false;
                    }
                    
                    // Store context before async operations
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    
                    // Validate settings first
                    if (_frequency <= 0) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text('Please select a frequency greater than 0'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    
                    // Check if start time is before end time
                    final startMinutes = _startTime.hour * 60 + _startTime.minute;
                    final endMinutes = _endTime.hour * 60 + _endTime.minute;
                    
                    if (startMinutes >= endMinutes) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text('End time must be after start time'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    
                    // Check notification permission first
                    bool permissionGranted = false;
                    
                    if (defaultTargetPlatform == TargetPlatform.iOS) {
                      // iOS-specific permission handling with more reliable checking
                      debugPrint('iOS: Checking notification permission...');
                      
                      // First, try the more reliable method
                      bool hasPermissionReliable = await _checkIOSNotificationPermission();
                      debugPrint('iOS: Reliable permission check result: $hasPermissionReliable');
                      
                      if (hasPermissionReliable) {
                        permissionGranted = true;
                        debugPrint('iOS: Permission confirmed as granted');
                      } else {
                        // Permission not granted, try to request it
                        debugPrint('iOS: Permission not granted, requesting...');
                        final permissionStatus = await Permission.notification.status;
                        debugPrint('iOS: Current permission status: $permissionStatus');
                        
                        if (permissionStatus == PermissionStatus.denied) {
                          final requestResult = await Permission.notification.request();
                          debugPrint('iOS: Permission request result: $requestResult');
                          
                          if (requestResult == PermissionStatus.granted || 
                              requestResult == PermissionStatus.provisional) {
                            // Double-check with reliable method after granting
                            permissionGranted = await _checkIOSNotificationPermission();
                            debugPrint('iOS: Final permission check after request: $permissionGranted');
                          } else {
                            // User denied, show settings dialog
                            debugPrint('iOS: User denied permission, showing settings dialog');
                            _showPermissionSettingsDialog();
                            return;
                          }
                        } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
                          debugPrint('iOS: Permission permanently denied, showing settings dialog');
                          _showPermissionSettingsDialog();
                          return;
                        } else {
                          // Other status, use reliable check result
                          permissionGranted = hasPermissionReliable;
                          debugPrint('iOS: Using reliable check result: $permissionGranted');
                        }
                      }
                    } else {
                      // Android-specific permission handling
                      final permissionStatus = await Permission.notification.status;
                      debugPrint('Android permission status: $permissionStatus');
                      
                      if (permissionStatus == PermissionStatus.permanentlyDenied) {
                        _showPermissionSettingsDialog();
                        return;
                      }
                      
                      if (permissionStatus != PermissionStatus.granted) {
                        final requestResult = await Permission.notification.request();
                        debugPrint('Android permission request result: $requestResult');
                        
                        if (requestResult == PermissionStatus.permanentlyDenied) {
                          _showPermissionSettingsDialog();
                          return;
                        }
                        
                        permissionGranted = requestResult == PermissionStatus.granted;
                      } else {
                        permissionGranted = true;
                      }
                    }
                    
                    if (!permissionGranted) {
                      if (defaultTargetPlatform == TargetPlatform.iOS) {
                        // On iOS, if we reach here without permission, show settings dialog
                        _showPermissionSettingsDialog();
                      } else {
                        // On Android, show snackbar for temporary denial
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text('Notification permission is required to set reminders'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                      return;
                    }

                    // Save notification settings
                    await _saveNotificationSettings();
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                  ))),
        ],
      ),
    );
  }
}