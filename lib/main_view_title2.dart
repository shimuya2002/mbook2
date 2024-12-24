import 'package:flutter/material.dart';
import 'package:mbook2/app_body_state.dart';
import 'package:mbook2/main_view_data.dart';
import 'package:mbook2/main_view_nav_state.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';


class MainViewTitle2 extends StatelessWidget {
  static final DateFormat DAY_FMT = DateFormat("yyyy/MM/dd");
  MainViewNavState _nav_state;
  MainViewDataState _data_state;

  MainViewTitle2(this._nav_state,this._data_state);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build


    var title = "";
    switch (_nav_state.state) {
      case 0:
        title = DAY_FMT.format(_data_state.target);
      case 3:
        {
          title = "Config";
        }
    }
    return Text(title);
  }
}