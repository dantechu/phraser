import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:phraser/consts/const_strings.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsAndPolicyTextWidget extends StatelessWidget {
  const TermsAndPolicyTextWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(children: [
          const TextSpan(text: 'By clicking continue,\nyou will accept ', style: TextStyle(color: Colors.blueGrey)),
          TextSpan(
              text: 'Terms of Use (EULA)',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline, color: Colors.blueGrey),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  await _launchUrl(
                    //TODO: change this string from const.dart when other pr's merged
                      ConstStrings.kAppTermsAndConditionsLink);
                }),
          const TextSpan(text: ' \nand ', style: TextStyle(color: Colors.blueGrey)),
          TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                  decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  await _launchUrl(
                    //TODO: change this string from const.dart when other pr's merged
                      ConstStrings.kAppPrivacyLink);
                }),
        ], style: TextStyle(color: Colors.white,)));
  }

  _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }
}
