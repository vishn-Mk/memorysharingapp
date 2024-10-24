import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestCameraPermission() async {
    return await Permission.camera.request().isGranted;
  }

  static Future<bool> requestMicrophonePermission() async {
    return await Permission.microphone.request().isGranted;
  }

  static Future<bool> requestStoragePermission() async {
    return await Permission.storage.request().isGranted;
  }
}
