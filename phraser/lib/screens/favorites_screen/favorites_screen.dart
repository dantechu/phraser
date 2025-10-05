import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:phraser/floor_db/favorites_dao.dart';
import 'package:phraser/services/model/phreasers_list_model.dart';
import 'package:phraser/util/Floor_db.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ColorfulSafeArea(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
          backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
          body: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 15.0, top: 10.0, bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.close, size: 27.0, color: Theme.of(context).iconTheme.color)),
                  SizedBox(width: 15.0),
                  Text('Favorites', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineMedium?.color
                  ))
                ],
              ),

            ),
          ),
          FutureBuilder<List<Phraser>>(
              future: getAllFavorites(),
              builder: (BuildContext context, AsyncSnapshot<List<Phraser>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                 return const Center(child: CircularProgressIndicator());
                } else {
                  if(snapshot.data !=  null && snapshot.data!.isNotEmpty) {
                    final List<Phraser> favoritesList = snapshot.data!;
                    return Container(
                      height: MediaQuery.of(context).size.height -150,
                      child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: favoritesList.length,
                          itemBuilder: (context, index) {
                            return getFavoritePhraserCard(favoritesList[index]);
                          }),
                    );
                  } else {
                      return Container(
                          margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/2.5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite_border,
                                size: 60.0,
                                color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
                              ),
                              SizedBox(height: 16.0),
                              Text(
                                'No favorites yet',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Tap the heart icon on quotes to add them here',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ));

                  }
                }
              })
        ],
      )),
    );
  }

  Future<List<Phraser>> getAllFavorites() async {
    final database = FloorDB.instance.floorDatabase;
    FavoritesDAO dao = database.favoritesDAO;

    return await dao.getAllFavoritesPhrasers();
  }

  Widget getFavoritePhraserCard(Phraser phraser) {
    return Card(
      elevation: Theme.of(context).brightness == Brightness.dark ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: Theme.of(context).brightness == Brightness.dark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).cardColor,
                    Theme.of(context).cardColor.withOpacity(0.8),
                  ],
                )
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      phraser.quote,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16.0,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (phraser.categoryName.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        phraser.categoryName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: () {
                      final database = FloorDB.instance.floorDatabase;
                      FavoritesDAO dao = database.favoritesDAO;
                      dao.removeFromFavorites(phraser);
                      setState(() {});
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
