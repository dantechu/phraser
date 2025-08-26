import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:phraser/util/utils.dart';
import 'package:url_launcher/url_launcher.dart';


class MyFunctions {
  //Static function to launch any simple browsable url
  static void launchBrowsableURL(
      {required String url, required BuildContext context}) async {
    if(!url.toLowerCase().startsWith('http')){
      url = 'https://'+url;
    }
    if (!await launch('$url')) {
      throw messageError(context, 'Could not launch: $url');
    }
  }

  //Static function to launch phone call
  static void launchCallURL(
      {required String url, required BuildContext context}) async {
    if (!await launch('tel://$url')) {
      throw messageError(context, 'Could not launch: $url');
    }
  }

  // Static function to send sms on phone number
  // static void sendSMSToPhone(
  //     {required BuildContext context,
  //       required String message,
  //       required List<String> recipents}) async {
  //   String _result = await sendSMS(message: message, recipients: recipents)
  //       .catchError((onError) {
  //     messageError(context, '$onError');
  //   });
  //   print(_result);
  // }

  static String getBase64FormatFile(String path) {
    File file = File(path);
    List<int> fileInByte = file.readAsBytesSync();
    String fileInBase64 = base64Encode(fileInByte);
    return fileInBase64;
  }

  static void sendEmail(
      {required BuildContext context,
      required List<String> recipients,
      required String body,
      required String subject}) async {
    final Email emailLaunch = Email(
      body: body,
      subject: subject,
      recipients: recipients,
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(emailLaunch);
    } catch (e) {
      throw messageError(context, 'Error: $e');
    }
  }

  static void leaveFeedback({required BuildContext context}) async {
    const String emailAddress = 'feedback@digitalblocsstudios.com';
    final Email emailLaunch = Email(
      body: '',
      subject: '',
      recipients: [emailAddress],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(emailLaunch);
    } catch (e) {
      throw messageError(context, 'Email: $emailAddress \n Error: $e');
    }
  }




}
