
class ConstantURls {

  static const String kBaseURL = 'http://phraser.amazingonlinecourse.com/';
  static const String kCategoryImagesBaseURL = 'http://phraser.amazingonlinecourse.com/upload/category/';


  static const String kGetCategories = '${kBaseURL}api/v1/api.php?get_categories';
  static const String kGetSections = '${kBaseURL}api/v1/api.php?get_category_sections';
  static const String kGetPhrasersByCategory = '${kBaseURL}api/v1/api.php?get_category_details&id=';
}