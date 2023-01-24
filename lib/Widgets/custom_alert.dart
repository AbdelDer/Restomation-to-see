import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';

class Alerts {
  static customLoadingAlert(BuildContext context, {String? text}) {
    CoolAlert.show(
        context: context,
        width: 200,
        type: CoolAlertType.loading,
        title: text,
        barrierDismissible: false);
  }
}
