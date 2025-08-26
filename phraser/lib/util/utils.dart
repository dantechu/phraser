import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math';


bool disableDPrint = false;

dprint(String str){
  if (disableDPrint)
    return;
  if (!kReleaseMode || kIsWeb) print(str);
}

testPrint(var message){
  if(kDebugMode) {
    print('========>  ${message.toString()}');
  }
}


toastGreen(String message){
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0
  );
}
toastGrey(String message){
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.grey.shade700,
      textColor: Colors.white,
      fontSize: 16.0
  );
}

toastRed(String message){
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0
  );
}

toastRedLong(String message){
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0
  );


}

messageOk(BuildContext context, String _text){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      duration: Duration(seconds: 3),
      content: Text(_text,
        style: TextStyle(color: Colors.white), textAlign: TextAlign.center,)));
}

messageError(BuildContext context, String _text){
  dprint("messageError $_text");
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
      action:  SnackBarAction(
        label: 'Close',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
      content: Text(_text,
        style: TextStyle(color: Colors.white), textAlign: TextAlign.center,)));
}

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
}

String generateCode6(){
  var i1 = Random().nextInt(9);
  var i2 = Random().nextInt(9);
  var i3 = Random().nextInt(9);
  var i4 = Random().nextInt(9);
  var i5 = Random().nextInt(9);
  var i6 = Random().nextInt(9);
  return "$i1$i2$i3$i4$i5$i6";
}

Color getColor(String? boardColor){
  if (boardColor == null) {
    return Colors.red;
  }
  var t = int.tryParse(boardColor);
  if (t != null) {
    return Color(t);
  }
  return Colors.red;
}

Color toColor(String? boardColor){
  if (boardColor == null) {
    return Colors.red;
  }
  var t = int.tryParse(boardColor);
  if (t != null) {
    return Color(t);
  }
  return Colors.red;
}

int toInt(String str){
  int ret = 0;
  try {
    ret = int.parse(str);
  }catch(_){}
  return ret;
}

double toDouble(String str){
  double ret = 0;
  try {
    ret = double.parse(str);
  }catch(_){}
  return ret;
}

bool validateEmail(String value) {
  var pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(value)) {
    return false;
  } else {
    return true;
  }
}

String checkPhoneNumber(String _phoneText){
  String s = "";
  for (int i = 0; i < _phoneText.length; i++) {
    int c = _phoneText.codeUnitAt(i);
    if ((c == "1".codeUnitAt(0)) || (c == "2".codeUnitAt(0)) || (c == "3".codeUnitAt(0)) ||
        (c == "4".codeUnitAt(0)) || (c == "5".codeUnitAt(0)) || (c == "6".codeUnitAt(0)) ||
        (c == "7".codeUnitAt(0)) || (c == "8".codeUnitAt(0)) || (c == "9".codeUnitAt(0)) ||
        (c == "0".codeUnitAt(0)) || (c == "+".codeUnitAt(0))) {
      String h = String.fromCharCode(c);
      s = "$s$h";
    }
  }
  return s;
}

textFieldToEnd(TextEditingController _controllerName){
  _controllerName.selection = TextSelection.fromPosition(
    TextPosition(offset: _controllerName.text.length),
  );
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    // etc.
  };
}


/*
  zip

  использование

  for (var pair in zip([_serverGroup, _cartGroup])){
    var s = pair[0]; // _serverGroup
    var c = pair[1]; // _cartGroup
    if (c.price == s.price && c.discPrice == s.discPrice)
      s.selected = true;
    else
      _notEqual = true;
  }

 */
Iterable<List<T>> zip<T>(Iterable<Iterable<T>> iterables) sync* {
  if (iterables.isEmpty) return;
  final iterators = iterables.map((e) => e.iterator).toList(growable: false);
  while (iterators.every((e) => e.moveNext())) {
    yield iterators.map((e) => e.current).toList(growable: false);
  }
}
