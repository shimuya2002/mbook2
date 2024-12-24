import 'package:flutter/material.dart';
import 'package:mbook2/app_body_state.dart';
import 'package:mbook2/main_view_data.dart';
import 'package:mbook2/main_view_nav_state.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mbook2/data_helper.dart';

class MainViewMenu2 extends StatelessWidget {
  MainViewNavState _nav_state;
  MainViewDataState _data_state;
  MainViewMenu2(this._nav_state,this._data_state);
  @override
  Widget build(BuildContext context) {


    if (0 == _nav_state.state) {
      return Drawer(
          child: ListView(
              children: <Widget>[
                DrawerHeader(
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                    title: Text('Change date'),
                    onTap: () {
                      _on_change_date(context, _data_state);
                    }
                ),
                ListTile(
                    title: Text("Deselect"),
                    onTap: () {
                      Navigator.pop(context);
                      _data_state.clear_sel();
                    }
                ),
                ListTile(
                    title: Text("Copy"),
                    onTap: () async {
                      if (_data_state.is_sel_empty) {
                        _show_need_sel_item_alert(context);
                      }
                      Navigator.pop(context);
                      if (!_data_state.is_sel_empty) {
                        var db = DataHelper();
                        for (var i = 0; i < _data_state.sel_length; ++i) {
                          db.add((await _data_state.items)[_data_state
                              .get_sel(i)].clone());
                        }

                        _data_state.reload();
                      }
                    }
                ),
                ListTile(
                    title: Text("Delete"),
                    onTap: () async {
                      if (_data_state.is_sel_empty) {
                        _show_need_sel_item_alert(context);
                      }
                      Navigator.pop(context);
                      if (!_data_state.is_sel_empty) {
                        var db = DataHelper();

                        for (var i = 0; i < _data_state.sel_length; ++i) {
                          await db.delete(
                              (await _data_state.items)[_data_state
                                  .get_sel(i)]);
                        }

                        _data_state.reload();
                      }
                    })
              ])
      );
    }

    return Drawer(child: ListView());
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
