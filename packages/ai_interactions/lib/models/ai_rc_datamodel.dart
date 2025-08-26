import 'dart:convert';

///AI API model From RC
class AIRemoteConfigDataModel {
  AIRemoteConfigDataModel({
    required this.baseURL,
    required this.apiKey,
    required this.apiModel,
    required this.contentType,
    this.language
  });

  late String baseURL;
  late String apiKey;
  late String apiModel;
  late String contentType;
  String? language;

  AIRemoteConfigDataModel.fromJson(Map<String, dynamic> json) {
    baseURL = json['base_url'];
    apiKey = json['api_key'];
    apiModel = json['api_model'];
    contentType = json['content_type'];
    language = json['language'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['base_url'] = baseURL;
    data['api_key'] = apiKey;
    data['api_model'] = apiModel;
    data['content_type'] = contentType;
    data['language'] = language;
    return data;
  }

  String toRawJson() => json.encode(toJson());

  factory AIRemoteConfigDataModel.fromRawJson(String str) =>
      AIRemoteConfigDataModel.fromJson(json.decode(str));
}
