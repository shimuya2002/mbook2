import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class MainViewNavState with ChangeNotifier {

  var _cur_state = 0;

  int get state => _cur_state;

  set state(s) {
    _cur_state = s;
    notifyListeners();
  }
}