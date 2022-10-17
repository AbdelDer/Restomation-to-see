import 'package:cool_alert/cool_alert.dart';

class Alerts {
  static customLoadingAlert(context) {
    CoolAlert.show(
        context: context,
        width: 200,
        type: CoolAlertType.loading,
        barrierDismissible: false);
  }
}
