import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:phraser/services/model/categories.dart';
import 'package:phraser/services/model/category_sections.dart';
import 'package:phraser/services/model/data_repository.dart';
import 'package:phraser/services/view_model/categories_list_view_model.dart';
import 'package:phraser/widgets/section_categories_list.dart';

class CategoriesListScreen extends StatefulWidget {
  const CategoriesListScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesListScreen> createState() => _CategoriesListScreenState();
}

class _CategoriesListScreenState extends State<CategoriesListScreen> {

  List<CategorySections> sectionList = DataRepository().sectionList;
  List<Categories> categoriesList = DataRepository().categoriesList;

  final _categoriesListViewModel = Get.put(CategoriesListViewModel());

  @override
  void initState() {
    super.initState();
    _categoriesListViewModel.checkForData();
  }

  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
        body: GetBuilder<CategoriesListViewModel>(
          init: CategoriesListViewModel(),
          builder: (_){
            return ModalProgressHUD(
              inAsyncCall: _categoriesListViewModel.isCategoriesLoading,
              child: SingleChildScrollView(
                physics: ScrollPhysics(),
                child: Column(
                  children: [

                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                          padding: EdgeInsets.only(left: 15.0, top: 15.0, bottom: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                                onTap: (){
                                  Navigator.pop(context);
                                },
                                child: Icon(Icons.close, size: 27.0,)),
                            SizedBox(width: 15.0),
                            Text('Categories', style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold ),)
                          ],
                        ),

                      ),
                    ),

                    ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _categoriesListViewModel.currentSectionList.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          return SectionCategoriesList(categoriesList: _categoriesListViewModel.currentCategoriesList, sectionName: _categoriesListViewModel.currentSectionList[index].name);
                        }),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
