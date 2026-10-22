abstract class AlarmPort {
  Future<bool> getAlarmStatus();

  Future<bool> activateAlarm();

  Future<bool> deactivateAlarm();

  Future<bool> toggleAlarm(bool currentStatus);

  Future<String> getPassword();

  Future<String> setPassword(String password);
}
