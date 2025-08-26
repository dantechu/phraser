import 'package:ai_interactions/models/logged_interactions_model.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
enum ViewState { idle, busy }

class ChatViewModel extends GetxController {
  List<LoggedInteractionsModel> _localHistory = [];
  String _userPrompt = '';
  bool _isResponseRecieved = true;
  ScrollController scrollController = ScrollController();
  bool _isApiCalled = false;
  ViewState _viewState = ViewState.idle;

  set viewState(ViewState state) {
    _viewState = state;
    update();
  }

  ViewState get viewState => _viewState;


  set isApiCalled(bool val) {
    _isApiCalled = val;
    update();
  }

  bool get isApiCalled => _isApiCalled;



  set isResponseRecieved(bool val) {
    _isResponseRecieved = val;
    update();
  }

  bool get isResponseRecieved => _isResponseRecieved;

  set userPrompt(String prompt) {
    _userPrompt = prompt;
    update();
  }

  String get userPrompt => _userPrompt;

  set localHistory(List<LoggedInteractionsModel> model) {
    _localHistory = model;
    update();
  }

  List<LoggedInteractionsModel> get localHistory => _localHistory;

  ///[callOnChatScreenForInitData] is used to initialized video controller again on Chat screen if user select character again.
  Function()? _callOnCharScreenForInitData;
  set callOnCharScreenForInitData(Function()? func) {
    _callOnCharScreenForInitData = func;
    update();
  }

  Function()? get callOnCharScreenForInitData => _callOnCharScreenForInitData;
}
