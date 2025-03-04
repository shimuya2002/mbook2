import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mbook2/app_body_state.dart';
import 'main_view_body.dart';
import 'package:mbook2/main_view_config.dart';
import 'package:mbook2/main_view_data.dart';
import 'main_view_nav_bar.dart';
import 'package:mbook2/main_view_nav_state.dart';
import '../lib/main_view_title.dart';
import 'package:mbook2/transaction.dart' as mbook2;
import 'main_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import '../lib/app_nav_state.dart';
import '../lib/main_view_list.dart';
import '../lib/size_config.dart';
import 'package:mbook2/data_helper.dart';
import '../lib/edit_view.dart';
import '../lib/list_data_state.dart';
import '../lib/main_view_menu.dart';

class MainView3 extends StatefulWidget {
  const MainView3({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MainView3> createState() => _MainViewState3();
}

class _MainViewState3 extends State<MainView3> {

  var _data_state = MainViewDataState(DateTime.now());
  var _nav_state = MainViewNavState();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

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
          title: MultiProvider(
              providers: [
                ChangeNotifierProvider(
                    create: (BuildContext context) => _nav_state),
                ChangeNotifierProvider(create: (_) => _data_state)
              ],


              child: MainViewTitle())),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [ MultiProvider(
              providers: [
                ChangeNotifierProvider(
                    create: (BuildContext context) => _nav_state),
                ChangeNotifierProvider(create: (_) => _data_state)
              ],


              child: MainViewBodyWidget())
          ]),
      bottomNavigationBar: ChangeNotifierProvider(
          create: (BuildContext context) => _nav_state,
          child: MainViewNavBar()),
      drawer:MultiProvider(
          providers: [
            ChangeNotifierProvider(
                create: (BuildContext context) => _nav_state),
            ChangeNotifierProvider(create: (_) => _data_state)
          ],child:MainViewMenu()),
      floatingActionButton: _gen_float_action_btn(),
    );
  }


  FloatingActionButton? _gen_float_action_btn(){
    if(0==_nav_state.state){
      return FloatingActionButton(
      onPressed: _on_add_transaction,
      tooltip: 'Increment',
      child: const Icon(Icons.add),
      );
    }
    return null;
  }

  Widget? _gen_drawer() {
    if(0==_nav_state.state) {
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
                    onTap: _on_change_date
                ),
                ListTile(
                    title: Text("Deselect"),
                    onTap: () {
                      Navigator.pop(context);
                      _data_state.clear_sel();
                      setState(() {
                      });
                    }
                ),
                ListTile(
                    title: Text("Copy"),
                    onTap: () async {
                      if (_data_state.is_sel_empty) {
                        _show_need_sel_item_alert();
                      }
                      Navigator.pop(context);
                      if (!_data_state.is_sel_empty) {
                        var db = DataHelper();
                        for (var i = 0; i < _data_state.sel_length; ++i) {
                          db.add((await _data_state.items)[_data_state
                              .get_sel(i)].clone());
                        }

                        _data_state.reload();
                        setState(()  {
                        });
                      }
                    }
                ),
                ListTile(
                    title: Text("Delete"),
                    onTap: () async {
                      if (_data_state.is_sel_empty) {
                        _show_need_sel_item_alert();
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

                        setState(() {
                        }
                        );
                      }
                    })
              ])
      );
    }
    return null;
  }

  void _on_add_transaction() async{

    try {
      await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return EditTransaction(null, title: "");
      })).then((value) async{
        if(null!=value) {
          await DataHelper().add(value);
          _data_state.set_target(value.tDate.toLocal());

        }
        setState(() {});
      });
    }catch( e){
      print(e);
    }
  }

  void _on_change_date()async {

    final DateTime? datePicked = await showDatePicker(
        context: context,
        initialDate: _data_state.target,
        firstDate: DateTime(2003),
        lastDate: DateTime(2100));
    if (null != datePicked) {
      _data_state.set_target(DateTime(datePicked.year,datePicked.month,datePicked.day));
      Navigator.pop(context);
      setState(() {

      });


    }

  }

  void _show_need_sel_item_alert(){
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