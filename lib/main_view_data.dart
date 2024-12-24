import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import 'transaction.dart';
import 'edit_view.dart';
import 'package:mbook2/data_helper.dart';
import 'app_body_state.dart';
import 'size_config.dart';
class MainViewDataState with ChangeNotifier{
  late Future<List<Transaction>> _items;
  late DateTime _target;
  late DateTimeRange _target_range;
  var _sel_list=[];
  var _total_value=0.0;

  MainViewDataState(DateTime d){

    set_target(d);
  }

 void set_target(DateTime d){

    _set_cur_date(d);
    notifyListeners();
  }

  DateTime get target=>_target;
  void target_range(DateTimeRange range) {
    _target_range=range;
    _target = range.start;

    reload();
  }

  DateTimeRange get_target_range(){
    return _target_range;
  }

  void _set_cur_date(DateTime d) {
    var ndate = DateTime(d.year, d.month, d.day);


    var nmdate = ndate.add(Duration(days: 1));

    _target_range = DateTimeRange(
        start: DateTime(ndate.year, ndate.month, ndate.day),
        end: nmdate.subtract(Duration(seconds: 1)));
    _target = ndate;


    reload();
  }

  Future<List<Transaction>> get items=>_items;
  double get total_value=>_total_value;
  void add_sel(int idx){
    _sel_list.add(idx);
    notifyListeners();
  }
  void remove_sel(int idx){
    _sel_list.remove(idx);
    notifyListeners();
  }
  bool contains_sel(int idx){
    return _sel_list.contains(idx);
  }
  void clear_sel(){
    this._sel_list.clear();
    notifyListeners();
  }
  int get_sel(int idx){
    return this._sel_list[idx];
  }
  void reload(){
    _items = DataHelper().get_trans_list(
        _target_range.start,
        _target_range.end);
    _sel_list = [];
    _total_value = 0;
    notifyListeners();
  }
  bool get is_sel_empty=>this._sel_list.isEmpty;
  int get sel_length=>this._sel_list.length;
}