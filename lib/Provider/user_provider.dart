import 'package:flutter/cupertino.dart';
import 'package:restomation/MVVM/Models/Customer%20Model/customer_model.dart';

class CustomerProvider extends ChangeNotifier {
  CustomerModel? _customerModel;
  CustomerModel? get customerModel => _customerModel;
  void setCustomer(CustomerModel customerModel) {
    _customerModel = customerModel;
  }
}
