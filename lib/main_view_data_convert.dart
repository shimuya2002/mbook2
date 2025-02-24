import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:mbook2/main_view_config.dart';
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
//import 'package:flutter_charset_detector/flutter_charset_detector.dart';
class MainViewDataConvert extends StatelessWidget {
  static final _mizuho_date_fmt = DateFormat("yyyy.MM.dd");


  MainViewNavState _state;

  MainViewDataConvert(this._state);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
        children: [
          Row(
              children: [
                Text("File format"),
                DropdownButton<String>(
                    value: (_state.user_data as CONFIG_MODE).param,
                    onChanged: (newValue) {


                    },
                    items: CONFIG_MODE.FORMAT_TYPES.map<
                        DropdownMenuItem<String>>(
                            (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).
                    toList()

                )
              ]),
          Row(
              children: [
                ElevatedButton(
                  child: Text("OK"),
                  onPressed: _onOk,
                ),
                ElevatedButton(
                  child: Text("CANCEL"),
                  onPressed: () {
                    _state.user_data = null;
                  },
                )
              ])
        ]
    );
  }

  void _onOk() async {
    final XFile? file = await openFile(

    );


    if (file != null) {


      var tranList = List<Transaction>.empty(growable: true);
      final conv_char_set=CONFIG_MODE.FORMAT_MIZUHO_DIRECT==(_state.user_data as CONFIG_MODE).param?
      "Shift_JIS":
      "UTF-8";
      print("Convert charset type ${conv_char_set}");
     final String str_data = kIsWeb
          ? await file.readAsString(encoding: utf8) :
      (await CharsetConverter.decode(
          conv_char_set, (await file.readAsBytes())));
/*

      final String str_data=await CharsetDetector.detect(await file.readAsBytes());*/
      print("Convert complete.${str_data}");
      var rows = str_data.split("\n");
      for (var i = 13; i < rows.length; ++i) {
        var line = rows[i];


        var params = line.split(",");

        //log("length=${params.length} $line");
        if (1 == params.length)
          continue;
        var value = "";
        var date = _mizuho_date_fmt.parse(params[1]).toUtc();
        if (params[2].isEmpty) {
          value = params[3];
        } else {
          value = "-${params[2]}";
        }
        var note = params[5];

        var t = Transaction.create(date, "", "", value, note);
        tranList.add(t);
      }
      var csv = "";
      if (OUTPUT_FORMAT.FMT_CSV == Transaction.fmtMode) {
        for (var t in tranList) {
          csv += "${t.toCSVString()}\n";
        }
      } else {
        csv = jsonEncode(tranList);
      }
      final anchor = html.AnchorElement(
          href: OUTPUT_FORMAT.FMT_CSV == Transaction.fmtMode ?
          "data:text/csv;charset=utf-8,$csv" :
          "data:text/json;charset=utf-8,$csv"
      );
      if (OUTPUT_FORMAT.FMT_CSV == Transaction.fmtMode) {
        anchor.download = "convert.csv";
      } else {
        anchor.download = "convert.json";
      }
      anchor.click();
    }

  }
}