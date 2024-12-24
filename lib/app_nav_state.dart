import 'package:flutter/material.dart';
import 'package:mbook2/app_body_state.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mbook2/data_helper.dart';
import 'edit_view.dart';
class AppNavState with ChangeNotifier {

  var _cur_state = 0;

  int get state => _cur_state;

  set state(s) {
    _cur_state = s;
    notifyListeners();
  }
}
class AppNavBar extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Consumer<AppNavState>(
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
class AppTitleBar extends StatelessWidget{
  static final DateFormat DAY_FMT=DateFormat("yyyy/MM/dd");
  @override
  Widget build(BuildContext context) {
    // TODO: implement build


    return Consumer2<AppNavState,TargetDateState>(
        builder:
            (context, nav_state,date_state, child) {



          var title = "";
          switch (nav_state.state) {
            case 0:
              title=DAY_FMT.format(date_state.target);
            case 3:
              {
                title = "Config";
              }
          }
          return Text(title);

        });
  }
}

