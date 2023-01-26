class CustomerModel {
  CustomerModel({
    required this.name,
    required this.phone,
    required this.isTableClean,
    this.hasNewItems,
    this.orderStatus,
    this.tableId,
    this.tableName,
    this.waiter,
  });
  final String? name;
  final String? phone;
  final String? isTableClean;
  final String? hasNewItems;
  final String? orderStatus;
  final String? tableId;
  final String? tableName;
  final String? waiter;
}
