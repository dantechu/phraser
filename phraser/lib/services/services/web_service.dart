import 'package:dio/dio.dart';

class Resource<T> {
  final String url;
  T Function(Response response) parse;

  Resource({required this.url, required this.parse});
}

class WebService {
  Future<T> load<T>(Resource<T> resource) async {
    var response = await Dio().get(resource.url);
    print('Webservice response code: ${response.statusCode}');
    print('Webservice response body: ${response.data}');
    if (response.statusCode == 200) {
      return resource.parse(response);
    } else {
      throw Exception('Failed to load data!');
    }
  }
}