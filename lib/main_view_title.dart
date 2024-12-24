import 'package:flutter/material.dart';
import 'package:mbook2/app_body_state.dart';
import 'package:mbook2/main_view_data.dart';
import 'package:mbook2/main_view_nav_state.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';


class MainViewTitle extends StatelessWidget{
  static final DateFormat DAY_FMT=DateFormat("yyyy/MM/dd");
  @override
  Widget build(BuildContext context) {
    // TODO: implement build


    return Consumer2<MainViewNavState,MainViewDataState>(
        builder:
            (context, nav_state,data_state, child) {



          var title = "";
          switch (nav_state.state) {
            case 0:
              title=DAY_FMT.format(data_state.target);
            case 3:
              {
                title = "Config";
              }
          }
          return Text(title);

        });
  }
}