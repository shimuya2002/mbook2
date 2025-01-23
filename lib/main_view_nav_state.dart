import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class MainViewNavState with ChangeNotifier {

  var _cur_state = 0;

  var _user_data=null;
  int get state => _cur_state;

  set state(s) {
    _cur_state = s;
    notifyListeners();
  }
  dynamic get user_data =>_user_data;
  set user_data(o){
    _user_data=o;
    notifyListeners();
  }

}