import 'dart:io';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phraser/consts/colors.dart';
import 'package:phraser/consts/text_themes.dart';
import 'package:phraser/consts/theme_images_list.dart';
import 'package:phraser/services/model/phraser_theme_model.dart';
import 'package:phraser/util/back_drop_filter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

void showShareDialog({required BuildContext context,required ThemeModel themeModel,required String textToShare, required int themePosition}) async {
  final ScreenshotController screenshotController = ScreenshotController();
  showDialog(
      context: context,
      builder: (context) => BackDropFilterWidget(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                        alignment: Alignment.center,
                        child: Container(
                          decoration: BoxDecoration(color: Colors.grey.withOpacity(.5), borderRadius: BorderRadius.circular(10)),
                          width: context.percentWidth * 95,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: context.percentHeight * 65,
                                  child: SingleChildScrollView(
                                    child: Screenshot(
                                      controller: screenshotController,
                                      child: SizedBox(
                                        width: context.width,
                                        child: Container(
                                          color: AppColors.primaryColor,
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.topCenter,
                                                child: SingleChildScrollView(
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  child: Container(
                                                    height: context.height/1.4,
                                                    child: Stack(
                                                      children: [
                                                        Container(
                                                          width: MediaQuery.of(context).size.width,
                                                          height: context.height/1.4,
                                                          child: Image.asset(
                                                            ThemeImagesList.themeImagesList[themePosition].themeImage,
                                                            fit: BoxFit.fill,
                                                            height: MediaQuery.of(context).size.height,
                                                          ),
                                                        ),
                                                        getTextTheme(
                                                          context,
                                                          textToShare,
                                                          themePosition,
                                                          MediaQuery.of(context).size.height,
                                                          ThemeImagesList
                                                              .themeImagesList[themePosition].textFontFamily,
                                                          ThemeImagesList
                                                              .themeImagesList[themePosition].textColor,
                                                          ThemeImagesList.themeImagesList[themePosition].textSize,
                                                          true,
                                                          ThemeImagesList
                                                              .themeImagesList[themePosition].textWeight,
                                                        ),

                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.0,),
                                Container(
                                  width: context.width,
                                  height: 45,
                                  margin: EdgeInsets.symmetric(horizontal: 10.0),
                                  child: ElevatedButton(
                                    child: Text('Share as Image', style: TextStyle(fontSize: 18),),
                                    onPressed: () {
                                      screenshotController.capture().then((value) {
                                        _saveAndShare(value!);
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(height: 10.0,),
                                Container(
                                  width: context.width,
                                  height: 45,
                                  margin: EdgeInsets.symmetric(horizontal: 10.0),
                                  child: ElevatedButton(
                                    child: Text('Share text only', style: TextStyle(fontSize: 18),),
                                    onPressed: () {
                                      Share.share( '${textToShare}',);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                );
              },
            ),
          ));
}

Future _saveAndShare(Uint8List bytes) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final image = File('${directory.path}/something.png');
    image.writeAsBytesSync(bytes);
    if (Platform.isIOS) {
      await Share.shareXFiles([XFile(image.path)]);
    } else {
      await Share.shareXFiles([XFile(image.path)], );
    }
  } catch (e, s) {
    debugPrint('share dialog error: $e-$s');
  }
}


