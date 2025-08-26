import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:phraser/screens/notification_settings/model/custom_notifications_model.dart';
import 'package:phraser/services/model/categories.dart';
import 'package:phraser/services/model/data_repository.dart';
import 'package:phraser/util/colors.dart';
import 'package:phraser/util/constant_urls.dart';


class NotificationsCategoriesScreen extends StatefulWidget {
  const NotificationsCategoriesScreen({Key? key, required this.selectedCategoryList}) : super(key: key);

  final List<NotificationCategory> selectedCategoryList;

  @override
  State<NotificationsCategoriesScreen> createState() => _NotificationsCategoriesScreenState();
}

class _NotificationsCategoriesScreenState extends State<NotificationsCategoriesScreen> {


  List<Categories> categoriesList = DataRepository().categoriesList;

  @override
  void initState() {
    super.initState();
    updateCategoriesList();
  }

  void updateCategoriesList() {
    categoriesList = DataRepository().categoriesList;
    final trueList = categoriesList.where((element) => element.isSelected == true);
    for(final item in trueList) {
      categoriesList.singleWhere((element) => element == item).isSelected = false;
    }
    for(final category in widget.selectedCategoryList) {
      categoriesList.singleWhere((element) => element.categoryId == category.id).isSelected = true;
    }
    setState(() {

    });
  }

  @override
  void dispose() {
    super.dispose();
    categoriesList = [];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context,categoriesList);

          categoriesList = [];
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            leading: InkWell(
                onTap: () {
                  Navigator.pop(context,categoriesList);

                  categoriesList = [];
                },
                child: Icon(Icons.arrow_back)),
            title: Text('Select Categories'),
            actions: [
              // TextButton(onPressed: (){}, child: Text('Save', style: TextStyle(color: Colors.white, fontSize: 18),))
            ],
          ),
          body: ListView.builder(
            itemCount: categoriesList.length,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 3.0),
                margin: EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: kPrimaryColor.withOpacity(0.5), // Customize the shade color here
                    width: 0.5, // Customize the border width as needed
                  ),
                ),
                child: ListTile(
                  leading:  Container(
                    width: 60.0,
                    height: 60.0,
                    child: Card(
                      shadowColor: Colors.grey,
                      margin: EdgeInsets.zero,
                      child: CachedNetworkImage(imageUrl: ConstantURls.kCategoryImagesBaseURL+categoriesList[index].categoryImage, fit:  BoxFit.fill),
                    ).cornerRadiusWithClipRRect(30),
                  ),
                  title: Text(categoriesList[index].categoryName),
                  trailing: RoundedCheckBox(
                    isChecked: categoriesList[index].isSelected ?? false,
                    checkedColor: Colors.blueAccent,
                    onTap: (value) {
                      setState(() {
                        categoriesList[index].isSelected = value;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}


class MotivationalCategory {
  final String name;
  bool isSelected;

  MotivationalCategory(this.name, this.isSelected);
}
