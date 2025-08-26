
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
      WalkThroughModelClass(title: 'Good days are coming!', subTitle: '${ConstStrings.kAppNameSingular} will help you feel positive about yourself and boost your self-confidence', image: AppAssets.kIntroThree),
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      color: Theme.of(context).primaryColorLight,
      child: Scaffold(
        body: Stack(
          children: [
            PageView(
              controller: pageController,
              children: list.map((e) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    commonCachedNetworkImage(
                      e.image,
                      fit: BoxFit.cover,
                      height: 200,
                      width: 200,
                    ).cornerRadiusWithClipRRect(20),
                    20.height,
                    Text(e.title!, style: boldTextStyle(size: 22), textAlign: TextAlign.center),
                    40.height,
                    Text(
                      e.subTitle!,
                      style: secondaryTextStyle(size: 18),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              }).toList(),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 100,
              child: DotIndicator(
                indicatorColor: Theme.of(context).primaryColor,
                pageController: pageController,
                pages: list,
                unselectedIndicatorColor: grey,
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
              bottom: 20,
              right: 0,
              left: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppButton(
                    padding: EdgeInsets.all(12),
                    text: 'Skip',
                    color: context.cardColor,
                    textStyle: primaryTextStyle(),
                    onTap: () {
                      InterestLifeAreasScreen().launch(context);
                    },
                  ).visible(currentPage != 2).cornerRadiusWithClipRRect(10.0),
                  16.width,
                  AppButton(
                    padding: EdgeInsets.all(12),
                    color: Theme.of(context).primaryColor,
                    text: currentPage != 2 ? 'Next' : 'Continue',
                    textStyle: primaryTextStyle(color: white),
                    onTap: () {
                      if (currentPage == 2) {
                        InterestLifeAreasScreen().launch(context);
                      } else {
                        pageController.animateToPage(
                          currentPage + 1,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.linear,
                        );
                      }
                    },
                  ).cornerRadiusWithClipRRect(10.0).expand()
                ],
              ).paddingOnly(left: 16, right: 16),
            ),
          ],
        ),
      ),
    );
  }




}
