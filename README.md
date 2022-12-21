# restomation

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


--to test Razorpay in debug mode
Go to flutter\bin\cache and remove a file named: flutter_tools.stamp
Go to flutter\packages\flutter_tools\lib\src\web and open the file chrome.dart.
Find '--disable-extensions'
Add '--disable-web-security'