import 'package:timezone/data/latest.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/timezone.dart' as tz;

class TimeZoneModel {
  factory TimeZoneModel() => _this ?? TimeZoneModel._();

  TimeZoneModel._() {
    initializeTimeZones();
  }
  static TimeZoneModel _this;

  Future<String> getTimeZoneName() async =>
      FlutterNativeTimezone.getLocalTimezone();

  Future<tz.Location> getLocation([String timeZoneName]) async {
    if (timeZoneName == null || timeZoneName.isEmpty) {
      timeZoneName = await getTimeZoneName();
    }
    return tz.getLocation(timeZoneName);
  }

  fromDateTime(DateTime dateTime) async {
    final timeZone = TimeZoneModel();

    // The device's timezone.
    String timeZoneName = await timeZone.getTimeZoneName();

    // Find the 'current location'
    final location = await timeZone.getLocation(timeZoneName);

    return tz.TZDateTime.from(dateTime, location);
  }
}
