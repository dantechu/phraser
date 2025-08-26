import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:get/get.dart';
import 'package:phraser/ads/consts/ads_helper.dart';
import 'package:phraser/consts/text_themes.dart';
import 'package:phraser/consts/theme_images_list.dart';
import 'package:phraser/floor_db/favorites_dao.dart';
import 'package:phraser/screens/categories_list_screen.dart';
import 'package:phraser/services/model/data_repository.dart';
import 'package:phraser/util/Floor_db.dart';
import 'package:phraser/util/helper/route_helper.dart';
import 'package:phraser/util/preferences.dart';
import 'package:phraser/util/share_dialog.dart';
import 'package:phraser/util/utils.dart';

import '../services/view_model/phraser_view_model.dart';

class PhraserViewScreen extends StatefulWidget {
  const PhraserViewScreen({Key? key}) : super(key: key);

  @override
  State<PhraserViewScreen> createState() => _PhraserViewScreenState();
}

class _PhraserViewScreenState extends State<PhraserViewScreen> {
  void loadPhrasers() {}

  final CarouselController _carouselController = CarouselController();
  final _phraserViewModel = Get.put(PhraserViewModel());

  @override
  void initState() {
    super.initState();

    _phraserViewModel.themePosition = Preferences.instance.textThemePosition;
    AdsHelper.loadAdmobBannerAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<PhraserViewModel>(
        init: PhraserViewModel(),
        builder: (vm) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Image.asset(
                    ThemeImagesList.themeImagesList[_phraserViewModel.themePosition].themeImage,
                    fit: BoxFit.fill,
                    height: MediaQuery.of(context).size.height,
                  ),
                ),
                CarouselSlider(
                  options: CarouselOptions(
                    onPageChanged: (int index, _) {
                      Preferences.instance.currentPhraserPosition = index;
                      _phraserViewModel.isFavorites(DataRepository().currentPhrasersList[index]);
                      if (Preferences.instance.textThemePosition == 0) {
                        Random random = Random();
                        int randomPosition = random.nextInt(ThemeImagesList.themeImagesList.length);
                        _phraserViewModel.changeThemePosition(randomPosition);
                      }

                      testPrint(
                          'onPageChanged and new Position is ${_phraserViewModel.themePosition}');
                    },
                    initialPage: Preferences.instance.currentPhraserPosition,
                    height: MediaQuery.of(context).size.height,
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                    scrollDirection: Axis.vertical,
                    // autoPlay: false,
                  ),
                  items: DataRepository().currentPhrasersList.map((item) {

                    return Stack(
                      children: [
                        getTextTheme(
                          context,
                          item.quote,
                          _phraserViewModel.themePosition,
                          MediaQuery.of(context).size.height,
                          ThemeImagesList
                              .themeImagesList[_phraserViewModel.themePosition].textFontFamily,
                          ThemeImagesList
                              .themeImagesList[_phraserViewModel.themePosition].textColor,
                          ThemeImagesList.themeImagesList[_phraserViewModel.themePosition].textSize,
                          false,
                          ThemeImagesList
                              .themeImagesList[_phraserViewModel.themePosition].textWeight,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 100.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    try {
                                      final database = FloorDB.instance.floorDatabase;
                                      FavoritesDAO dao = database.favoritesDAO;
                                      if (!vm.isFavorite) {
                                        vm.isFavorite = true;
                                        dao.addPhraserToFavorite(item);
                                      } else {
                                        vm.isFavorite = false;
                                        dao.removeFromFavorites(item);
                                      }
                                    } catch(e) {
                                      ///Something went wrong
                                    }
                                   },
                                  child: Icon(
                                    vm.isFavorite ? Icons.favorite : Icons.favorite_border,
                                    size: 30.0,
                                    color: vm.isFavorite ? Colors.red : ThemeImagesList
                                        .themeImagesList[_phraserViewModel.themePosition].textColor,
                                  ),
                                ),
                                const SizedBox(
                                  width: 30.0,
                                ),
                                GestureDetector(
                                    onTap: () async {
                                      await Future.delayed(const Duration(microseconds: 200), () {
                                        showShareDialog(context: context, themeModel: ThemeImagesList
                                            .themeImagesList[_phraserViewModel.themePosition], textToShare: item.quote, themePosition: _phraserViewModel.themePosition);
                                      });
                                    },
                                    child: Icon(
                                      Icons.share,
                                      size: 30.0,
                                      color: ThemeImagesList
                                          .themeImagesList[_phraserViewModel.themePosition]
                                          .textColor,
                                    ))
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: EdgeInsets.only(left: 15.0, right: 5.0, bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => CategoriesListScreen()))
                                    .then((value) {
                                  setState(() {
                                    testPrint(
                                        'setState called with data length: ${DataRepository().currentPhrasersList.length}');
                                  });
                                });
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.category_outlined,
                                        size: 25.0,
                                      ),
                                      SizedBox(width: 3.0),
                                      Text(
                                        Preferences.instance.savedCategoryName,
                                        style: TextStyle(fontSize: 13.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            //todo: this will be a autoplay button
                            // Card(
                            //     shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(15.0),
                            //     ),
                            //     margin: EdgeInsets.only(left: 10.0),
                            //     child: Padding(
                            //       padding: const EdgeInsets.all(10.0),
                            //       child: Icon(
                            //         Icons.play_arrow_outlined,
                            //         size: 25.0,
                            //       ),
                            //     )),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                Get.toNamed(RouteHelper.chatScreen);
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                margin: const EdgeInsets.only( right: 10.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.mark_chat_unread_outlined,
                                        size: 25.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Get.toNamed(RouteHelper.phraserThemeListScreen)!.then((value) {
                                  _phraserViewModel
                                      .changeThemePosition(Preferences.instance.textThemePosition);
                                });
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.color_lens_outlined,
                                        size: 25.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Get.toNamed(RouteHelper.settingsScreen);
                              },
                              child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  margin: EdgeInsets.only(left: 10.0, right: 10.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Icon(
                                      Icons.person_outline,
                                      size: 25.0,
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
