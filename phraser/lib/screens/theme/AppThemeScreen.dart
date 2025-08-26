
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';

import '../../theme/theme_controller.dart';
import '../../widgets/theme_item_widget.dart';

class AppThemeScreen extends StatefulWidget {
  const AppThemeScreen({Key? key}) : super(key: key);

  @override
  _AppThemeScreenState createState() => _AppThemeScreenState();
}

class _AppThemeScreenState extends State<AppThemeScreen> {


  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
        color: Theme
            .of(context)
            .primaryColor,
        child: Scaffold(
          appBar: AppBar(
            leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back)),
            title: Text('Select App Theme'),
          ),
          body: Column(children: [
            ThemeItemWidget(
                isActiveItem: getActiveTheme(ThemeMode.light),
                title: 'Light Theme', onTap: () {
              ThemeController().saveTheme(ThemeMode.light);
              ThemeController().switchTheme();
              setState(() {});
            }),
            ThemeItemWidget(
                isActiveItem: getActiveTheme(ThemeMode.dark),
                title: 'Dark Theme', onTap: () {
              ThemeController().saveTheme(ThemeMode.dark);
              ThemeController().switchTheme();
              setState(() {});
            }),
            ThemeItemWidget(
                isActiveItem: getActiveTheme(ThemeMode.system),
                title: 'System Default', onTap: () {
              ThemeController().saveTheme(ThemeMode.system);
              ThemeController().switchTheme();
              setState(() {});
            }),
          ]),
        ));
  }

  bool getActiveTheme(ThemeMode currentThemeItem) {
    if (currentThemeItem == ThemeController().themeMode) {
      return true;
    } else {
      return false;
    }
  }
}
