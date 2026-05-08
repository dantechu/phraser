
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:phraser/consts/assets.dart';
import 'package:phraser/consts/const_strings.dart';
import 'package:phraser/floor_db/categories_dao.dart';
import 'package:phraser/services/model/categories_list_model.dart';
import 'package:phraser/services/model/category_sections.dart';
import 'package:phraser/services/model/data_repository.dart';
import 'package:phraser/services/model/section_list.dart';
import 'package:phraser/screens/intro/interest_life_areas_screen.dart';
import 'package:phraser/screens/intro/DAWidgets.dart';
import 'package:phraser/util/constant_strings.dart';
import 'package:phraser/util/constant_urls.dart';
import 'package:phraser/util/preferences.dart';
import 'package:phraser/services/services/web_service.dart';

import '../../floor_db/database.dart';
import '../../floor_db/section_dao.dart';
import '../../services/model/categories.dart';
import '../../util/utils.dart';

class IntroductionScreen extends StatefulWidget {
  @override IntroductionScreenState createState() => IntroductionScreenState();
}

class IntroductionScreenState extends State<IntroductionScreen> {
  PageController pageController = PageController();
  int currentPage = 0;

  List<WalkThroughModelClass> list = [];


  @override
  void initState() {
    super.initState();
    init();
   // checkForData();
    // getCategories();
    // getSectionsList();
  }



  Future<void> init() async {
    list.add(
      WalkThroughModelClass(title: 'It\'s time to Change!',subTitle: 'Read ${ConstStrings.kAppNamePlural} every day to help you build a positive mindset.', image: AppAssets.kIntroOne),
    );
    list.add(
      WalkThroughModelClass(title: 'No more disbelief!', subTitle: 'Change your negative thoughts in positive ones.',image: AppAssets.kIntroTwo),
    );
    list.add(
      WalkThroughModelClass(title: 'Home Widget', subTitle: 'View motivations from your selected sections directly on your home screen with our customizable widget.',image: AppAssets.kIntroHomeWidget),
    );
    list.add(
      WalkThroughModelClass(title: 'Good days are coming!', subTitle: '${ConstStrings.kAppNameSingular} will help you feel positive about yourself and boost your self-confidence', image: AppAssets.kIntroThree),
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ColorfulSafeArea(
      color: Theme.of(context).primaryColorLight,
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        body: Stack(
          children: [
            PageView(
              controller: pageController,
              children: list.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: commonCachedNetworkImage(
                          e.image,
                          fit: BoxFit.cover,
                          height: 220,
                          width: 220,
                        ).cornerRadiusWithClipRRect(20),
                      ),
                      32.height,
                      Text(
                        e.title!,
                        style: boldTextStyle(
                          size: 26,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      24.height,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          e.subTitle!,
                          style: secondaryTextStyle(
                            size: 16,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 120,
              child: DotIndicator(
                indicatorColor: Theme.of(context).primaryColor,
                pageController: pageController,
                pages: list,
                unselectedIndicatorColor: isDark ? Colors.grey[700]! : Colors.grey[400]!,
                onPageChanged: (index) {
                  setState(
                    () {
                      currentPage = index;
                    },
                  );
                },
              ),
            ),
            Positioned(
              bottom: 30,
              right: 0,
              left: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppButton(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    text: 'Skip',
                    color: isDark
                        ? Colors.grey[800]!
                        : Colors.grey[200]!,
                    textStyle: primaryTextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      weight: FontWeight.w600,
                    ),
                    onTap: () {
                      InterestLifeAreasScreen().launch(context);
                    },
                  ).visible(currentPage != 3).cornerRadiusWithClipRRect(12.0),
                  16.width,
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: AppButton(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      color: Colors.transparent,
                      elevation: 0,
                      text: currentPage != 3 ? 'Next' : 'Get Started',
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      onTap: () {
                        if (currentPage == 3) {
                          InterestLifeAreasScreen().launch(context);
                        } else {
                          pageController.animateToPage(
                            currentPage + 1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ).cornerRadiusWithClipRRect(12.0),
                  ).expand()
                ],
              ).paddingOnly(left: 20, right: 20),
            ),
          ],
        ),
      ),
    );
  }




}
