import 'package:flutter/cupertino.dart';
import 'package:restomation/MVVM/Models/Customer%20Model/customer_model.dart';

import '../MVVM/Models/Customer Model/customer_order_model.dart';

class CustomerProvider extends ChangeNotifier {
  CustomerModel? _customerModel;
  CustomerModel? get customerModel => _customerModel;
  void setCustomer(CustomerModel customerModel) {
    _customerModel = customerModel;
  }

  void updateCustomerModel(CustomerOrderModel customerOrderModel) {
    _customerModel = CustomerModel(
      name: customerOrderModel.name,
      phone: customerOrderModel.phone,
      isTableClean: customerOrderModel.isTableClean,
      hasNewItems: customerOrderModel.hasNewItems,
      orderStatus: customerOrderModel.orderStatus,
      tableId: customerOrderModel.tableId,
      tableName: customerOrderModel.tableName,
      waiter: customerOrderModel.waiter,
    );
  }
}
