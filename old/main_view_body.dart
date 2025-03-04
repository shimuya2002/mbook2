import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mbook2/main_view_data.dart';
import 'package:mbook2/main_view_nav_state.dart';
import 'package:mbook2/main_view_report.dart';

import 'package:provider/provider.dart';



import '../lib/app_nav_state.dart';

import '../lib/list_data_state.dart';
import '../lib/config_state.dart';
import '../lib/main_view_config.dart';
import '../lib/main_view_list.dart';


class MainViewBodyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<MainViewNavState,MainViewDataState>(builder:(context, nav_state,data_state, child) {
      switch(nav_state.state){
        case 0:{

          return MainViewList(data_state);

        }

        default:
          return MainViewConfig(nav_state,data_state);

      }
    });

  }
}