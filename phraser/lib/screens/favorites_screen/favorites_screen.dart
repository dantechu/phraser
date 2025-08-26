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
    return ColorfulSafeArea(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
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
                      child: Icon(Icons.close, size: 27.0,)),
                  SizedBox(width: 15.0),
                  Text('Favorites', style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold ),)
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
                          child: Text('No favorite found', style: TextStyle(fontSize: 20.0),));

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.only(left: 10.0, top: 5.0, bottom: 5.0, right: 10.0),
      child: Column(
        children: [

          Container(
            padding: EdgeInsets.only(left: 20.0, top: 20, bottom: 10, right: 20),
            child: Text('${phraser.quote}', style: TextStyle(fontSize: 16.0),textAlign: TextAlign.start),
          ),
          GestureDetector(
            onTap: () {
              final database = FloorDB.instance.floorDatabase;
              FavoritesDAO dao = database.favoritesDAO;
              dao.removeFromFavorites(phraser);
              setState(() {

              });
            },
            child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                  child: Icon(Icons.favorite, color: Colors.red),
                )),
          ),
        ],
      ),
    );
  }
}
