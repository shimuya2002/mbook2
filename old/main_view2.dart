import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mbook2/app_body_state.dart';
import 'package:mbook2/transaction.dart' as mbook2;
import 'main_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import '../lib/app_nav_state.dart';
import '../lib/size_config.dart';
import 'package:mbook2/data_helper.dart';
import '../lib/edit_view.dart';
import '../lib/list_data_state.dart';
class MainView2 extends StatefulWidget {
  const MainView2({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MainView2> createState() => _MainViewState2();
}

class _MainViewState2 extends State<MainView2> {
  var _app_nav_state=AppNavState();
  var _target_date=TargetDateState();
  var _list_state=ListDataState();
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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
                      create: (BuildContext context) => _app_nav_state),
                  ChangeNotifierProvider(create: (_) => _target_date)
                ],


                child: AppTitleBar())),
        floatingActionButton:0==_app_nav_state.state? FloatingActionButton(
          onPressed: _on_add_transaction,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ):null,
        drawer: 0==_app_nav_state.state?_gen_home_menu():null,
        body: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                  create: (BuildContext context) => _app_nav_state),
              ChangeNotifierProvider(create: (_) => _target_date),
              ChangeNotifierProvider(create: (_)=>_list_state)
            ],


            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [AppBodyWidget()])),

        bottomNavigationBar: ChangeNotifierProvider(
            create: (BuildContext context) => _app_nav_state,
            child: AppNavBar())
    );
  }

  Widget _gen_home_menu() {
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
                    setState(() {
                      this._list_state.clear_sel();
                    });
                  }
              ),
              ListTile(
                  title: Text("Copy"),
                  onTap: () async {
                    if (this._list_state.is_sel_empty) {
                      _show_need_sel_item_alert();
                    }
                    Navigator.pop(context);
                    if (!this._list_state.is_sel_empty) {
                      var db=DataHelper();
                      for (var i=0;i<this._list_state.sel_length;++i) {
                        db.add((await this._list_state.items)[this._list_state.get_sel(i)].clone());
                      }
                      setState(() async{

                        this._list_state.clear_sel();
                      });
                    }
                  }
              ),
              ListTile(
                  title: Text("Delete"),
                  onTap: () async {
                    if (this._list_state.is_sel_empty) {
                      _show_need_sel_item_alert();
                    }
                    Navigator.pop(context);
                    if (!this._list_state.is_sel_empty) {
                      var db=DataHelper();

                      for (var i=0;i<this._list_state.sel_length;++i) {
                        await db.delete((await this._list_state.items)[this._list_state.get_sel(i)]);
                      }
                      setState(() {
                        this._list_state.clear_sel();
                      }
                      );
                    }
                  })
            ])
    );
  }

  void _on_add_transaction() async{

    try {
      await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return EditTransaction(null, title: "");
      })).then((value) => setState(() {
        if(null!=value) {
          DataHelper().add(value);
          _target_date.target=(value.tDate.toLocal());

        }
      }));
    }catch( e){
      print(e);
    }
  }

  void _on_change_date()async {

    final DateTime? datePicked = await showDatePicker(
        context: context,
        initialDate: this._target_date.target,
        firstDate: DateTime(2003),
        lastDate: DateTime(2100));
    if (null != datePicked) {
      this._target_date.target=(DateTime(datePicked.year,datePicked.month,datePicked.day));
      this._list_state.target_range=this._target_date.target_range;
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