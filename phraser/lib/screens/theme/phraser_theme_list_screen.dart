import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:phraser/ads/consts/ads_helper.dart';
import 'package:phraser/consts/text_themes.dart';
import 'package:phraser/consts/theme_images_list.dart';
import 'package:phraser/util/preferences.dart';

class PhraserThemeListScreen extends StatefulWidget {
  const PhraserThemeListScreen({Key? key}) : super(key: key);

  @override
  State<PhraserThemeListScreen> createState() => _PhraserThemeListScreenState();
}

class _PhraserThemeListScreenState extends State<PhraserThemeListScreen> {
  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
        body: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 15.0, top: 20.0, bottom: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.close,
                          size: 27.0,
                        )),
                    const SizedBox(width: 15.0),
                    const Text(
                      'Themes',
                      style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 5.0),
            Expanded(
              child: GridView.builder(
                  itemCount: ThemeImagesList.themeImagesList.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 3 / 4),
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Card(
                        margin: EdgeInsets.zero,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            InkWell(
                              onTap: () {
                                Preferences.instance.textThemePosition = index;
                                Navigator.pop(context);
                              },
                              child: Image.asset(
                                ThemeImagesList.themeImagesList[index].themeImage,
                                fit: BoxFit.fill,
                              ),
                            ),
                            getTextTheme(
                              context,
                              index == 0 ? 'Random' : 'Phraser',
                              index,
                              MediaQuery.of(context).size.height / 4,
                              ThemeImagesList.themeImagesList[index].textFontFamily,
                              ThemeImagesList.themeImagesList[index].textColor,
                              ThemeImagesList.themeImagesList[index].textSize,
                              false,
                              ThemeImagesList.themeImagesList[index].textWeight,
                            ),
                          ],
                        ),
                      ).cornerRadiusWithClipRRect(10),
                    );
                  }),
            ),
            SizedBox(
              height: 5.0,
            ),
            if (!Preferences.instance.isPremiumApp &&
                AdsHelper.themesBannerAd.bannerAd != null &&
                AdsHelper.themesBannerAd.isAdLoaded != null &&
                AdsHelper.themesBannerAd.isAdLoaded!)
              SizedBox(
                height: 60,
                child: AdWidget(ad: AdsHelper.themesBannerAd.bannerAd!),
              )
          ],
        ),
      ),
    );
  }
}
