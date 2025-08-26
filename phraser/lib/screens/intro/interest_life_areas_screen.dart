import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:phraser/consts/assets.dart';
import 'package:phraser/screens/categories_list_screen.dart';
import 'package:phraser/screens/intro/DatingAppModel.dart';
import 'package:phraser/screens/notification_settings/free_notifications_settings.dart';
import 'package:phraser/screens/notification_settings/notification_settings.dart';
import 'package:phraser/screens/phraser_view.dart';
import 'package:phraser/util/preferences.dart';

class InterestLifeAreasScreen extends StatefulWidget {
  @override
  InterestLifeAreasScreenState createState() => InterestLifeAreasScreenState();
}

class InterestLifeAreasScreenState extends State<InterestLifeAreasScreen> {




  late List<DatingAppModel> list;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    list = getInterests();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  List<DatingAppModel> getInterests() {
    List<DatingAppModel> list = [];
    list.add(DatingAppModel(name: 'Achieving goals'));
    list.add(DatingAppModel(name: 'Positive Mindset'));
    list.add(DatingAppModel(name: 'Self-esteem'));
    list.add(DatingAppModel(name: 'Stress & Anxiety'));
    list.add(DatingAppModel(name: 'Relationship'));
    list.add(DatingAppModel(name: 'Happiness'));

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      color: Theme.of(context).primaryColorLight,
      child: Scaffold(
       body: Column(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           Column(
             children: [
               Column(
                 children: [
                   80.height,
                   Container(
                     width: 100.0,
                     height: 100.0,
                     child: Image.asset(AppAssets.kPrayerIcon),
                   ),
                   30.height,
                   Text('What areas of your life would you like to improve ?', style: primaryTextStyle(size: 20), textAlign: TextAlign.center,),

                 ],
               ),
             ],
           ),

           Wrap(
             alignment: WrapAlignment.center,
             spacing: 0,
             runSpacing: 2,
             children: list
                 .asMap()
                 .map(
                   (e, i) {
                     return MapEntry(
                       e,
                       Container(
                         width: context.width() * 0.46 - 24,
                         decoration: BoxDecoration(
                           border: Border.all(color: i.mISCheck.validate() ? Theme.of(context).primaryColor : grey),
                           borderRadius: BorderRadius.circular(10),
                           color: i.mISCheck!
                               ? Theme.of(context).primaryColor
                                   : white,
                         ),
                         margin: EdgeInsets.all(8),
                         padding: EdgeInsets.all(8),
                         child: Text(i.name.validate(),
                             style: boldTextStyle(
                                 color: i.mISCheck!
                                     ? white
                                         : black),
                             textAlign: TextAlign.center),
                       ).onTap(() {
                         i.mISCheck = !i.mISCheck!;
                         setState(() {});
                       }, splashColor: white, highlightColor: white),
                     );
                   },
                 )
                 .values
                 .toList(),
           ),
           Column(
             children: [
               AppButton(
                 width: context.width(),
                 color: Theme.of(context).primaryColor,
                 onTap: () {
                  // Preferences.instance.isFirstOpen = false;
                  const FreeNotificationSettingsScreen(willPop: false,).launch(context);
                 },
                 text: 'Continue',
                 textStyle: boldTextStyle(color: white),
               ).cornerRadiusWithClipRRect(10.0),
             ],
           ),
         ],
       ).paddingOnly(left: 16, right: 16, bottom: 70),
      ),
    );
  }
}
