import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mbook2/app_body_state.dart';
import 'package:mbook2/main_view_body2.dart';
import 'package:mbook2/main_view_config.dart';
import 'package:mbook2/main_view_data.dart';
import 'package:mbook2/main_view_nav_bar2.dart';
import 'package:mbook2/main_view_nav_state.dart';
import 'package:mbook2/main_view_title2.dart';
import 'package:mbook2/transaction.dart' as mbook2;
import 'main_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'app_nav_state.dart';

import 'size_config.dart';
import 'package:mbook2/data_helper.dart';
import 'edit_view.dart';

import 'main_view_menu2.dart';

import 'package:provider/provider.dart';

class MainView4 extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Consumer2<MainViewNavState, MainViewDataState>(
        builder:
            (context, nav_state, data_state, child) {
          return Scaffold(
            appBar: AppBar(
              // TRY THIS: Try changing the color here to a specific color (to
              // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
              // change color while the other colors stay the same.
                backgroundColor: Theme
                    .of(context)
                    .colorScheme
                    .inversePrimary,
                // Here we take the value from the MyHomePage object that was created by
                // the App.build method, and use it to set our appbar title.
                title: MainViewTitle2(nav_state,data_state)),
            body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [MainViewBodyWidget2(nav_state,data_state)]
                ),
            bottomNavigationBar:
               MainViewNavBar2(nav_state),
            drawer:  MainViewMenu2(nav_state,data_state),
            floatingActionButton: _gen_float_action_btn(context,nav_state,data_state),
          );
        }
    );
  }

  FloatingActionButton? _gen_float_action_btn(BuildContext context,MainViewNavState nav_state, MainViewDataState data_state){
    if(0==nav_state.state){
      return FloatingActionButton(
        onPressed: (){_on_add_transaction(context,data_state);},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      );
    }
    return null;
  }


  void _on_add_transaction(BuildContext context,MainViewDataState data_state) async{

    try {
      await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return EditTransaction(null, title: "");
      })).then((value) async{
        if(null!=value) {
          await DataHelper().add(value);
          data_state.set_target(value.tDate.toLocal());

        }
      });
    }catch( e){
      print(e);
    }
  }

  void _on_change_date(BuildContext context,MainViewDataState data_state)async {

    final DateTime? datePicked = await showDatePicker(
        context: context,
        initialDate: data_state.target,
        firstDate: DateTime(2003),
        lastDate: DateTime(2100));
    if (null != datePicked) {
      data_state.set_target(DateTime(datePicked.year,datePicked.month,datePicked.day));
      Navigator.pop(context);


    }

  }

  void _show_need_sel_item_alert(BuildContext context){
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("項目を選択してください"),
          children: <Widget>[
            // コンテンツ領域
            ElevatedButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(1),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ]
          ,
        );
      },
    );
  }
}