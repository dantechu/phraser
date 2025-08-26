import 'dart:convert';

import 'package:ai_interactions/models/ai_rc_datamodel.dart';
import 'package:ai_interactions/models/ai_request_model.dart';
import 'package:ai_interactions/models/ai_response_datamodel.dart';
import 'package:ai_interactions/models/message_datamodel.dart';
import 'package:core/core.dart';
import 'package:http/http.dart';

class OpenAIService {
  Future<Result<AIResponseDataModel, Object>> fetchAIResponse(
      {required AIRemoteConfigDataModel configs, required List<MessageDataModel> messages}) async {
    Map<String, String> headers = {'Content-Type': configs.contentType, 'Authorization': 'Bearer ${configs.apiKey.replaceAll('22222', '-')}'};
    try {
      final response = await post(Uri.parse(configs.baseURL), headers: headers, body: jsonEncode(AIRequestModel(model: configs.apiModel, messages: messages).toJson()));
      if (response.statusCode == 200) {
        return Success(AIResponseDataModel.fromJson(jsonDecode(utf8convert(response.body))));
      } else {
        return Failure(response.statusCode.toString());
      }
    } catch (e, s) {
      return Failure('$s');
    }
  }

  ///Converts the AI response string to UTF8 format so emojies and other
  ///languages could be parsed easily.
  String utf8convert(String text) {
    try {
      List<int> bytes = text.toString().codeUnits;
      return utf8.decode(bytes);
    } catch (e) {
      return text;
    }
  }
}
