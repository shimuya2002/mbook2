import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mbook2/main_view_data.dart';
import 'package:mbook2/main_view_data_config.dart';
import 'package:mbook2/main_view_data_convert.dart';
import 'package:mbook2/main_view_nav_state.dart';
import 'package:mbook2/main_view_report.dart';
import 'package:mbook2/main_view_search.dart';

import 'package:provider/provider.dart';



import 'app_nav_state.dart';

import 'list_data_state.dart';
import 'config_state.dart';
import 'main_view_config.dart';
import 'main_view_list.dart';


class MainViewBodyWidget2 extends StatelessWidget {
  MainViewNavState _nav_state;
  MainViewDataState _data_state;

  MainViewBodyWidget2(this._nav_state,this._data_state);
  @override
  Widget build(BuildContext context) {
      switch(_nav_state.state) {
        case 0:
          {
            return MainViewList(_data_state);
          }
        case 1:
          {
            var b=_data_state.target;
            b=DateTime(b.year,b.month,1);
            var e=DateTime(b.month==12?b.year+1:b.year,b.month==12?1:b.month+1,1);
            e=e.add(Duration(seconds: -1));
            return MainViewReport(DateTimeRange(start:  b,end:  e));
          }
        case 2:
          {
            var b=_data_state.target;
            b=DateTime(b.year,b.month,1);
            var e=DateTime(b.month==12?b.year+1:b.year,b.month==12?1:b.month+1,1);
            e=e.add(Duration(seconds: -1));
            return MainViewSearch(DateTimeRange(start:  b,end:  e));
          }
        default:
          {
            if(null!=_nav_state.user_data){
              switch(_nav_state.user_data){
                case CONFIG_MODE.CONFIG_ABOUT:{}
                  break;
                case CONFIG_MODE.CONFIG_DATA:{
                  return MainViewDataConfig(_nav_state,_data_state);
                }
                case CONFIG_MODE.CONFIG_CONVERT_MIZUHO_DIRECT_FORMAT:{
                  return MainViewDataConvert(_nav_state);
                }
              }
            }
            return MainViewConfig(_nav_state,_data_state);
          }
      }
  }
}