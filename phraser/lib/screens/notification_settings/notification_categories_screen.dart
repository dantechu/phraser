import 'package:cached_network_image/cached_network_image.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
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
    final selectedCount = categoriesList.where((cat) => cat.isSelected == true).length;
    
    return ColorfulSafeArea(
      color: Theme.of(context).primaryColor,
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, categoriesList);
          categoriesList = [];
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Theme.of(context).primaryColor,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context, categoriesList);
                categoriesList = [];
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Categories',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$selectedCount selected',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              if (selectedCount > 0)
                Container(
                  margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, categoriesList);
                      categoriesList = [];
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: CustomScrollView(
              slivers: [
                
                // Header description as sliver
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Choose the types of motivational content you want to receive in your notifications.',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Categories grid as sliver
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildCategoryCard(context, index);
                      },
                      childCount: categoriesList.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                  ),
                ),
                
                // Bottom spacing as sliver
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, int index) {
    final category = categoriesList[index];
    final isSelected = category.isSelected ?? false;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          categoriesList[index].isSelected = !isSelected;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor 
                : Theme.of(context).primaryColor.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category image with selection indicator
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: ConstantURls.kCategoryImagesBaseURL + category.categoryImage,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Icon(
                          Icons.category_outlined,
                          color: Theme.of(context).primaryColor,
                          size: 30,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Icon(
                          Icons.category_outlined,
                          color: Theme.of(context).primaryColor,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Category name
            Text(
              category.categoryName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Theme.of(context).textTheme.titleMedium?.color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 8),
            
            // Selection indicator text
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).primaryColor.withOpacity(0.1) 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isSelected ? 'Selected' : 'Tap to select',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isSelected 
                      ? Theme.of(context).primaryColor 
                      : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ),
          ],
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
