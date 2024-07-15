import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UtilRepository {
  static void toast(String msg) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0);
  }

  /// checks for update from android play store.
  static Future<bool> checkForUpdate() async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
        return true;
      }
    } catch (e) {
      UtilRepository.toast(e.toString());
    }
    return false;
  }

  ///Launches the given url
  static Future<void> launchLink(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      UtilRepository.toast(e.toString());
    }
  }

  static Future<void> launchEmail(
      {required List<String> emailAddresses,
      String? subject,
      String? body}) async {
    final String emails = emailAddresses.join(',');
    String emailSubject = Uri.encodeComponent(subject ?? "");
    String emailBody = Uri.encodeComponent(body ?? "");
    String emailUrl = "mailto:$emails?subject=$emailSubject&body=$emailBody";
    try {
      await launchUrlString(emailUrl);
    } catch (e) {
      UtilRepository.toast("Error redirecting to gmail.");
    }
  }
}
