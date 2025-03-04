import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:mbook2/main_view_data.dart';
import 'package:mbook2/main_view_nav_state.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:io' as io;
import "package:universal_html/html.dart" as html;
import 'package:package_info_plus/package_info_plus.dart';

import 'package:external_path/external_path.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:charset_converter/charset_converter.dart';
import 'app_nav_state.dart';
import 'size_config.dart';
import 'package:mbook2/data_helper.dart';
import 'transaction.dart';
import 'package:provider/provider.dart';
class MainViewDataConfig extends StatelessWidget {
  static final _mizuho_date_fmt=DateFormat("yyyy.MM.dd");
  MainViewNavState _nav_state;
  MainViewDataState _data_state;
  MainViewDataConfig(this._nav_state,this._data_state);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: SizeConfig.blockSizeVertical * 70, child: ListView(
      children: [


        ListTile(
          title: Row(children: [
            Icon(Icons.upload_file),
            Text("Import from file")
          ],

          ),
          onTap: () {
            _on_import_file(_nav_state);
          }
          ,),
        ListTile(
          title: Row(children: [
            Icon(Icons.file_download_done_sharp),
            Text("Export to file")
          ],

          ),
          onTap: () {
            _on_export_file(_nav_state);
          }
          ,),
        ListTile(
          title: Row(
            children: [Icon(Icons.clear), Text("Clear all data")],

          ),
          onTap: () async{
            await _on_clear_data(_nav_state);
          }
          ,)
      ],
    ));
  }

  void _on_import_file(MainViewNavState nav_state) async {
    final XFile? file = await openFile(

    );


    if (file != null) {
      var db = DataHelper();
      var methods = await db.get_method_list();
      var usages = await db.get_usage_list();
      var tranList = List<Transaction>.empty(growable: true);
      var mAddList = List<String>.empty(growable: true);
      var uAddList = List<String>.empty(growable: true);
      final String str_data = kIsWeb
          ? await file.readAsString(encoding: utf8)
          :
      (await CharsetConverter.decode("UTF-8", (await file.readAsBytes())));
      if ("csv" == file.name.substring(file.name.lastIndexOf(".") + 1)) {
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
          for (var i = 10; i < rows.length; ++i) {
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
      } else {
        List<dynamic> json = jsonDecode(str_data);
        for (var i in json) {
          var obj = Transaction.fromJson(i);
          tranList.add(obj);
          if (!methods.contains(obj.method) &&
              !mAddList.contains(obj.method) && obj.method.isNotEmpty) {
            mAddList.add(obj.method);
          }
          if (!usages.contains(obj.usage) &&
              !uAddList.contains(obj.usage) && obj.usage.isNotEmpty) {
            uAddList.add(obj.usage);
          }
        }
      }

      await db.add_range(tranList);

      await db.add_method_range(mAddList);
      await db.add_usage_range(uAddList);
    }
    nav_state.state=0;
    nav_state.user_data=null;
  }

  void _output_anchor_data(List<dynamic> data){
    var csv="";
    if (OUTPUT_FORMAT.FMT_CSV == Transaction.fmtMode) {
      for (var t in data) {
        csv += "${t.toCSVString()}\n";
      }
    } else {
      csv = jsonEncode(data);
    }
    final anchor = html.AnchorElement(
        href: OUTPUT_FORMAT.FMT_CSV == Transaction.fmtMode ?
        "data:text/csv;charset=utf-8,$csv" :
        "data:text/json;charset=utf-8,$csv"
    );
    if (OUTPUT_FORMAT.FMT_CSV == Transaction.fmtMode) {
      anchor.download = "moneybook${DateTime.now()}.csv";
    } else {
      anchor.download = "moneybook${DateTime.now()}.json";
    }
    anchor.click();

  }
  void _on_export_file(MainViewNavState nav_state) async {
    var list = await DataHelper().getAllData();
    var csv = "";


    if (kIsWeb) {

      if(list.isNotEmpty) {
        var targetYear = list[0].tDate.year;
        var tmpList=[];
        /*for (var i = 0; i < list.length; ++i) {
          if(targetYear!=list[i].tDate.year){
            _output_anchor_data(tmpList);
            tmpList.clear();
            targetYear=list[i].tDate.year;
          }
            tmpList.add(list[i]);

        }
        _output_anchor_data(tmpList);
*/
        _output_anchor_data(list);
      }

    } else {
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
    nav_state.state=0;
    nav_state.user_data=null;
  }

  Future<void> _on_clear_data(MainViewNavState nav_state) async{
    DataHelper().clear();
    nav_state.state=0;
    nav_state.user_data=null;
    await _data_state.reload();
  }
}