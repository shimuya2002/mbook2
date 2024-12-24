import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';



import 'app_nav_state.dart';

import 'list_data_state.dart';
import 'config_state.dart';
class TargetDateState with ChangeNotifier {
  var _target_date=DateTime.now();
  var _target_date_range=DateTimeRange(start: DateTime.now(), end: DateTime.now());

  DateTime get target =>_target_date;
  set target(DateTime d){
    var ndate=DateTime(d.year,d.month,d.day);


    var nmdate=ndate.add(Duration(days: 1));

    _target_date_range=DateTimeRange(start: DateTime(ndate.year,ndate.month,ndate.day), end: nmdate.subtract(Duration(seconds: 1)));
    _target_date=ndate;
    notifyListeners();
  }
  DateTimeRange get target_range=>_target_date_range;


}

class AppBodyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer3<AppNavState,TargetDateState,ListDataState>(
        builder:
    (context, nav_state,date_state,list_state, child) {

          switch(nav_state.state){
            case 0:
              {
                list_state.target_range=(date_state.target_range);
                return ListWidget(date_state,list_state);

              }
            default:
              return DataConfigWidget(nav_state);

          }

    });
  }
}


