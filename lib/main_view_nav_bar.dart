import 'package:flutter/material.dart';
import 'package:mbook2/app_body_state.dart';
import 'package:mbook2/main_view_nav_state.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mbook2/data_helper.dart';
import 'edit_view.dart';

class MainViewNavBar extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Consumer<MainViewNavState>(
        builder:
            (context, state, child) {
          return BottomNavigationBar(
            currentIndex: state.state,
            onTap: (v) {
              state.state = v;
            },
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
              BottomNavigationBarItem(icon: Icon(Icons.report), label: '集計'),

              BottomNavigationBarItem(icon: Icon(Icons.search), label: '検索'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings), label: '設定'),
            ],
            type: BottomNavigationBarType.fixed,
          );
        });
  }

}