import 'package:cached_network_image/cached_network_image.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:phraser/ads/consts/ads_helper.dart';
import 'package:phraser/floor_db/current_phraser_dao.dart';
import 'package:phraser/floor_db/phrasers_dao.dart';
import 'package:phraser/helper/navigation_helper.dart';
import 'package:phraser/main.dart';
import 'package:phraser/screens/in_app_purchase/preimum_app_screen.dart';
import 'package:phraser/services/model/categories.dart';
import 'package:phraser/screens/phraser_view.dart';
import 'package:phraser/services/model/data_repository.dart';
import 'package:phraser/services/model/phreasers_list_model.dart';
import 'package:phraser/util/Floor_db.dart';
import 'package:phraser/util/constant_urls.dart';
import 'package:phraser/util/preferences.dart';
import 'package:phraser/util/utils.dart';

import '../floor_db/database.dart';
import '../util/constant_strings.dart';

class SectionCategoriesList extends StatefulWidget {
  const SectionCategoriesList({Key? key, required this.categoriesList, required this.sectionName}) : super(key: key);

  final String sectionName;
  final List<Categories> categoriesList;

  @override
  State<SectionCategoriesList> createState() => _SectionCategoriesListState();
}

class _SectionCategoriesListState extends State<SectionCategoriesList> {
  List<Categories> updatedList = [];

  @override
  void initState() {
   getCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(widget.sectionName,style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
        ),
       Container(
         height: 210.0,
         child: ListView.builder(
             shrinkWrap: true,
             scrollDirection: Axis.horizontal,
             itemCount: updatedList.length,
             itemBuilder: (context, index) {
           return Padding(
             padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 SizedBox(
                   height: 140,
                   width: 140,
                   child: Stack(
                     children: [
                       InkWell(
                         onTap: ()async {

                           if(updatedList[index].categoryType != 'Free' && !Preferences.instance.isPremiumApp) {
                             if(AdsHelper.freeTriesRewardedAd != null) {
                               _showCustomDialog(context, index);
                             } else {
                               NavigationHelper.pushRoute(context, const PremiumAppScreen());
                             }
                           }else {
                             Preferences.instance.currentPhraserPosition = 0;
                             Preferences.instance.savedCategoryName =
                                 updatedList[index].categoryName;
                             final database = FloorDB.instance.floorDatabase;
                             PhrasersDAO phraserDAO = database.phraserDAO;
                             CurrentPhrasersDAO currentPhraserDAO = database
                                 .currentPhraserDAO;
                             List<Phraser> list = await phraserDAO
                                 .getAllPhrasers(
                                 updatedList[index].categoryName);

                             testPrint('selected phrasers length is : ${list
                                 .length}');
                             try{
                               await currentPhraserDAO.deleteCurrentPhrasers();
                             } catch (e){
                               debugPrint('---> table not created yet| $e');
                             }

                          await  currentPhraserDAO.insertAllCurrentPhrasers(list)
                                 .then((value) {
                               testPrint('current phrasers saved into db');
                             });
                             DataRepository().currentPhrasersList = list;
                             Navigator.pop(context);
                             if(AdsHelper.freeTriesInterstitialAd != null){
                               try {
                                 AdsHelper.freeTriesInterstitialAd!.show();

                                 AdsHelper.freeTriesInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
                                   onAdImpression: (impression) {
                                     AdsHelper.freeTriesInterstitialAd = null;
                                   }
                                 );

                               } catch(e) {
                                 debugPrint('Error in displaying ad: $e');
                               }
                             } else {
                               AdsHelper.loadAdmobInterstitialAd();
                             }
                           }
                         //  NavigationHelper.pushReplacement(context, const PhraserViewScreen());
                         },
                         child: Card(
                           shadowColor: Colors.grey,
                           margin: EdgeInsets.zero,
                           child: CachedNetworkImage(imageUrl: ConstantURls.kCategoryImagesBaseURL+updatedList[index].categoryImage, fit:  BoxFit.contain),
                         ).cornerRadiusWithClipRRect(10),
                       ),
                       if(updatedList[index].categoryType != 'Free')
                        Padding(
                         padding: EdgeInsets.all(8.0),
                         child: Align(
                             alignment: Alignment.bottomRight,
                             child: Icon(Preferences.instance.isPremiumApp ? Icons.lock_open_sharp : Icons.lock, color: Colors.white,)),
                       ),
                     ],
                   ),
                 ),
                 SizedBox(height: 5.0),
                 Text(updatedList[index].categoryName, style: TextStyle(fontSize: 16.0),),
               ],
             ),
           );
         }),
       )
      ],
    );
  }


  void _showCustomDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "Category locked",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  "Buy premium or watch video ad unlock category.",
                  style: TextStyle(fontSize: 16.0),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.0),
                if(AdsHelper.freeTriesRewardedAd != null)
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: 45.0,
                    margin: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          if(AdsHelper.freeTriesRewardedAd != null) {
                            try {
                              AdsHelper.freeTriesRewardedAd!.show(onUserEarnedReward: (adview, reward) async {
                                  Preferences.instance.currentPhraserPosition = 0;
                                  Preferences.instance.savedCategoryName =
                                      updatedList[index].categoryName;
                                  final database = FloorDB.instance.floorDatabase;
                                  PhrasersDAO phraserDAO = database.phraserDAO;
                                  CurrentPhrasersDAO currentPhraserDAO = database
                                      .currentPhraserDAO;
                                  List<Phraser> list = await phraserDAO
                                      .getAllPhrasers(
                                      updatedList[index].categoryName);

                                  testPrint('selected phrasers length is : ${list
                                      .length}');
                                  try{
                                    await currentPhraserDAO.deleteCurrentPhrasers();
                                  } catch (e){
                                    debugPrint('---> table not created yet| $e');
                                  }

                                  await  currentPhraserDAO.insertAllCurrentPhrasers(list)
                                      .then((value) {
                                    testPrint('current phrasers saved into db');
                                  });
                                  DataRepository().currentPhrasersList = list;
                                AdsHelper.freeTriesRewardedAd = null;
                                //AdsHelper.loadRewardedVideoAd();
                              });

                              AdsHelper.freeTriesRewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
                                onAdDismissedFullScreenContent: (data) async {
                                  try {
                                    await Future.delayed(const Duration(milliseconds: 500), () {
                                      Navigator.pop(globalNavigatorKey.currentContext!);
                                    //  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PhraserViewScreen()));
                                    });
                                  } catch(e) {
                                    debugPrint('--->  Error in popping: $e');
                                  }
                                }
                              );
                            } catch (e) {
                              debugPrint('Error in displaying ad');
                            }
                          }
                        },
                        child: const Text(
                          'Watch Video (ad)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                        ))),
                SizedBox(height: 20.0),
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: 45.0,
                    margin: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          NavigationHelper.pushRoute(context, const PremiumAppScreen());
                        },
                        child: const Text(
                          'Get Premium',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                        ))),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        );
      },
    );
  }



  getCategories() {
    for(var category in widget.categoriesList) {
      if(category.categorySection == widget.sectionName) {
        updatedList.add(category);
      }
    }
  }
}
