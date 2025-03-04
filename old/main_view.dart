import 'dart:io';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mbook2/data_helper.dart';




import '../lib/transaction.dart';
import '../lib/size_config.dart';
import '../lib/edit_view.dart';

import 'package:file_selector/file_selector.dart';
import 'dart:convert';
import 'dart:io' as io;
import "package:universal_html/html.dart" as html;
import 'package:package_info_plus/package_info_plus.dart';

import 'package:external_path/external_path.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:charset_converter/charset_converter.dart';

class MainView extends StatefulWidget {
  const MainView({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {


  var _cur_tab = 0;

  var _total_value=0.0;

  var _sel_list=[];
  DateTimeRange _target_date_range=DateTimeRange(start: DateTime.now(), end: DateTime.now());
  DateTime _cur_date=DateTime.now();





  static final DateFormat DAY_FMT=DateFormat("yyyy/MM/dd");
  var _version="";
  var _buildNumber="";


  static final _mizuho_date_fmt=DateFormat("yyyy.MM.dd");


  _MainViewState(){
    set_cur_date(_cur_date);

   }

  void getVer() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      //_appName = packageInfo.appName;
      //_packageName = packageInfo.packageName;
      _version = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }
   @override void initState() {
    // TODO: implement initState
    super.initState();

    getVer();


  }
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
          title: Text( 0==_cur_tab?
          (_sel_list.isEmpty?
          "${DAY_FMT.format(_cur_date)}":
          "Total $_total_value"):
          widget.title),
        ),

        body:Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: gen_content_view()),
        floatingActionButton: FloatingActionButton(
          onPressed: _on_add_transaction,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _cur_tab,
          onTap: _on_tab_tapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
            BottomNavigationBarItem(icon: Icon(Icons.report), label: '集計'),

            BottomNavigationBarItem(icon: Icon(Icons.search), label: '検索'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: '設定'),
          ],
          type: BottomNavigationBarType.fixed,
        ),
        // This trailing comma makes auto-formatting nicer for build methods.
    drawer: 0==_cur_tab?_gen_home_menu():null,

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
                      _sel_list = [];
                      _total_value=0.0;
                    });
                  }
              ),
              ListTile(
                  title: Text("Copy"),
                  onTap: () async {
                    if (_sel_list.isEmpty) {
                      _show_need_sel_item_alert();
                    }
                    Navigator.pop(context);
                    if (_sel_list.isNotEmpty) {
                      var list = await DataHelper().get_trans_list(
                          _target_date_range.start, _target_date_range.end);
                      setState(() {
                        var db=DataHelper();
                        for (var i in _sel_list) {
                          db.add(list[i].clone());
                        }
                        _sel_list = [];
                        _total_value=0;
                      });
                    }
                  }
              ),
              ListTile(
                  title: Text("Delete"),
                  onTap: () async {
                    if (_sel_list.isEmpty) {
                      _show_need_sel_item_alert();
                    }
                    Navigator.pop(context);
                    if (_sel_list.isNotEmpty) {
                      var db=DataHelper();
                      var list = await db.get_trans_list(
                          _target_date_range.start, _target_date_range.end);
                      for (var i in _sel_list) {
                        await db.delete(list[i]);
                      }
                      setState(() {

                        _sel_list = [];
                        _total_value=0;
                      }
                      );
                    }
                  })
            ])
    );
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
  void _on_change_date()async {

    final DateTime? datePicked = await showDatePicker(
        context: context,
        initialDate: _cur_date,
        firstDate: DateTime(2003),
        lastDate: DateTime(2100));
    if (null != datePicked) {
      set_cur_date(DateTime(datePicked.year,datePicked.month,datePicked.day));
      _sel_list=[];
      Navigator.pop(context);
      setState(() {

      });


    }

  }
  void set_cur_date(DateTime d){
    var ndate=DateTime(d.year,d.month,d.day);


    var nmdate=ndate.add(Duration(days: 1));

    _target_date_range=DateTimeRange(start: DateTime(ndate.year,ndate.month,ndate.day), end: nmdate.subtract(Duration(seconds: 1)));
    _cur_date=ndate;

  }
  void _on_add_transaction() async{
    _sel_list=[];
    _total_value=0;
    try {
      await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return EditTransaction(null, title: "");
      })).then((value) => setState(() {
        if(null!=value) {
          DataHelper().add(value);
          set_cur_date(value.tDate.toLocal());

        }
      }));
    }catch( e){
      print(e);
    }
  }


  void _on_tab_tapped(int i) {
    _cur_tab=i;
    _sel_list=[];
    _total_value=0;
    setState(() {



    });


  }
  List<Widget> _gen_report() {
    var b = DateTime(
        _target_date_range.start.year, _target_date_range.start.month, 1);
    var e = DateTime(
        b.month < 12 ? b.year : b.year + 1, b.month < 12 ? b.month + 1 : 1, 1);
    e.subtract(Duration(seconds: 1));
    return [
      FutureBuilder(future: DataHelper().get_trans_list(
          b, e),
          builder: (BuildContext context,
              AsyncSnapshot<List<Transaction>> snapshot) {
            if (snapshot.hasData) {
              var inValue = 0.0;
              var outValue = 0.0;
              var tbl = HashMap<String, double>();
              for (var t in snapshot.data!) {
                if (0 < t.get_value()) {
                  inValue += t.get_value();
                } else {
                  outValue += t.get_value();
                  if (tbl.containsKey(t.usage)) {
                    tbl[t.usage] = tbl[t.usage]! + t.get_value();
                  } else {
                    tbl[t.usage] = t.get_value();
                  }
                }
              }
              return Column(
                  children: [
                    Text("${DAY_FMT.format(b)}-${DAY_FMT.format(e.subtract(Duration(days:1)))}"),
                    Text("In $inValue Out ${outValue.abs()}"),
                    SizedBox(height: SizeConfig.blockSizeVertical * 70,
                        child: ListView.builder(itemCount: tbl.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                  title: Text("${tbl.keys.elementAt(
                                      index)} ${tbl[tbl.keys.elementAt(index)]!
                                      .abs()}")
                              );
                            }))
                  ]
              );
            } else {
              return Spacer();
            }
          })
    ];
  }
  List<Widget> gen_content_view(){

    switch(_cur_tab) {
      case 0:
        {



          return [gen_list()];
        }
      case 1:
        {
          return _gen_report();
        }
      case 3:
        {

          return [
            _gen_config()
          ];
        }
    }
    return [Spacer()];
  }

  Widget _gen_config() {
    return SizedBox(height: SizeConfig.blockSizeVertical * 70, child:ListView(
      children: [



        Text("Ver $_version"),
        Text("Build number $_buildNumber"),
        ListTile(
          title: Row(children: [
            Icon(Icons.upload_file),
            Text("Import from file")
          ],

          ),
          onTap: _on_import_file
          ,),
        ListTile(
          title: Row(children: [
            Icon(Icons.file_download_done_sharp),
            Text("Export to file")
          ],

          ),
          onTap: _on_export_file
          ,),
        ListTile(
          title: Row(
            children: [Icon(Icons.clear), Text("Clear all data")],

          ),
          onTap: _on_clear_data
          ,)
      ],
    ));
  }
  void _on_import_file() async{
    final XFile? file = await openFile(

    );


    if (file != null) {

      var db=DataHelper();
      var methods = await db.get_method_list();
      var usages = await db.get_usage_list();
      var tranList = List<Transaction>.empty(growable: true);
      var mAddList = List<String>.empty(growable: true);
      var uAddList = List<String>.empty(growable: true);
      final String str_data = kIsWeb
          ? await file.readAsString(encoding: utf8)
          :
      (await CharsetConverter.decode("UTF-8", (await file.readAsBytes())));
      if("csv"==file.name.substring(file.name.lastIndexOf(".")+1)) {


        var rows = str_data.split("\n");

        if (rows.isNotEmpty && !rows[0].startsWith("支店名")) {
          for (var line in rows) {
            var obj = Transaction.create_from_csv(line);
            if (null != obj) {
              tranList.add(obj);

              if (!methods.contains(obj.method) &&
                  !mAddList.contains(obj.method)) {
                mAddList.add(obj.method);
              }
              if (!usages.contains(obj.usage) &&
                  !uAddList.contains(obj.usage)) {
                uAddList.add(obj.usage);
              }
            }
          }
        } else {
          for (var i = 13; i < rows.length; ++i) {
            var line = rows[i];


            var params = line.split(",");

            //log("length=${params.length} $line");
            if (1 == params.length)
              continue;
            var value = "";
            var date = _mizuho_date_fmt.parse(params[1]);
            if (params[2].isEmpty) {
              value = params[3];
            } else {
              value = "-${params[2]}";
            }
            var note = params[4];

            var t = Transaction.create(date, "", "", value, note);
            tranList.add(t);
          }
        }
      }else {
        List<dynamic> json = jsonDecode(str_data);
        for (var i in json) {
          var obj = Transaction.fromJson(i);
          tranList.add(obj);
          if (!methods.contains(obj.method) &&
              !mAddList.contains(obj.method)) {
            mAddList.add(obj.method);
          }
          if (!usages.contains(obj.usage) &&
              !uAddList.contains(obj.usage)) {
            uAddList.add(obj.usage);
          }
        }
      }

      await db.add_range(tranList);

      await db.add_method_range(mAddList);
      await db.add_usage_range(uAddList);

    }
    _on_tab_tapped(0);
  }
  void _on_export_file() async {
    var list=await DataHelper().getAllData();
    var csv="";
    if(OUTPUT_FORMAT.FMT_CSV== Transaction.fmtMode) {
      for (var t in list) {
        csv += "${t.toCSVString()}\n";
      }
    }else{


      csv=jsonEncode(list);
    }


    if (kIsWeb) {

      final anchor = html.AnchorElement(
          href: OUTPUT_FORMAT.FMT_CSV==Transaction.fmtMode?
            "data:text/csv;charset=utf-8,$csv":
          "data:text/json;charset=utf-8,$csv"
      );
      if(OUTPUT_FORMAT.FMT_CSV==Transaction.fmtMode) {
        anchor.download = "moneybook.csv";
      }else{
        anchor.download = "moneybook.json";

      }
      anchor.click();
    }else {
      if (io.Platform.isAndroid) {
        await [Permission.storage].request();
      }

      var savePath = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOWNLOADS);
      savePath = "$savePath/moneybook.csv";
      try {
        // 上記フルパスにFileクラスのインスタンスを設定
        var savedFile = File(savePath);

        // 上記インスタンスにファイル内容を書き込む（ここで初めてファイルが保存される）
        await savedFile.writeAsBytes(
            utf8.encode(csv));
      } catch (e) {
        print(e);
      }
    }
    _on_tab_tapped(0);
  }
  void _on_clear_data(){

    DataHelper().clear();
    _on_tab_tapped(0);
  }


  Widget gen_list() {

    return FutureBuilder(future: DataHelper().get_trans_list(
        _target_date_range.start, _target_date_range.end),
        builder: (BuildContext context,
            AsyncSnapshot<List<Transaction>> snapshot) {
          if (snapshot.hasData) {
            
            var inValue=0.0;
            var outValue=0.0;
            for(var t in snapshot.data!){
              if(t.get_value()>0){
                inValue+=t.get_value();
              }else{
                outValue+=t.get_value();
              }

            }
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
              Text("In $inValue",style:TextStyle(fontSize:24)),

              Text("Out ${outValue.abs()}",style:TextStyle(fontSize:24)),
              SizedBox(height: SizeConfig.blockSizeVertical * 70, child:
            ListView.builder(itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                      tileColor: _sel_list.contains(index) ? Colors.blue : Colors.white,
                      title: Text(snapshot.data![index].toString()),
                      onTap: () {
                        _on_edit(snapshot.data![index]);
                      },
                      onLongPress: () {

                        setState((){
                          if(_sel_list.contains(index)){
                            _total_value-=snapshot.data![index].get_value();
                            _sel_list.remove(index);
                          }else{
                            _total_value+=snapshot.data![index].get_value();
                            _sel_list.add(index);

                          }

                        });

                      }
                  );
                }
            ))]);
          }
          return Spacer();
        });
  }


  void _on_edit(Transaction t) async {
    try {
      await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return EditTransaction(t, title: "");
      })).then((value) => setState(() {
        if(null!=value) {
          DataHelper().add(value);
          set_cur_date((value as Transaction).tDate.toLocal());
        }
      }));
    }catch( e){
      print(e);
    }
  }
}
