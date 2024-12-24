import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mbook2/main_view_data.dart';
import 'package:mbook2/main_view_title.dart';


import 'transaction.dart';
import 'edit_view.dart';
import 'package:mbook2/data_helper.dart';
import 'app_body_state.dart';
import 'size_config.dart';


class MainViewReport extends StatelessWidget {


  DateTimeRange _range;
  var _usage_value_tbl={};
  var _method_value_tbl={};
  MainViewReport(this._range);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: DataHelper().get_trans_list(_range.start, _range.end),
        builder: (BuildContext context,
            AsyncSnapshot<List<Transaction>> snapshot) {
          if (snapshot.hasData) {
            var inValue=0.0;
            var outValue=0.0;
            for(var t in snapshot!.data!){
              if(_usage_value_tbl.containsKey(t.usage)){
                _usage_value_tbl[t.usage]+=t.get_value();
              }else{
                _usage_value_tbl[t.usage]=t.get_value();
              }

              if(_method_value_tbl.containsKey(t.method)){
                _method_value_tbl[t.method]+=t.get_value();
              }else{
                _method_value_tbl[t.method]=t.get_value();
              }
              if(0>t.get_value()){
                outValue+=t.get_value();
              }else{
                inValue+=t.get_value();
              }
            }

            var method_widget_tbl=List<Widget>.empty(growable: true);
            for(var k in _method_value_tbl.keys){
              method_widget_tbl.add(Text("$k ${_method_value_tbl[k]}"));

            }
            var usage_widget_tbl=List<Widget>.empty(growable: true);
            for(var k in _usage_value_tbl.keys){
              usage_widget_tbl.add(Text("$k ${_usage_value_tbl[k]}"));

            }

            return
                SingleChildScrollView(
                child: Column(
                children: [
                  Text("${MainViewTitle.DAY_FMT.format(_range.start)}-${MainViewTitle.DAY_FMT.format(_range.end)}"),
                  Text("In $inValue Out ${outValue.abs()}"),
                  Text("Methods categories"),
                  Column(
                    children: usage_widget_tbl,
                  ),
                  Text("Usages categories"),
                  Column(
                    children: method_widget_tbl,
                  ),
                ]
            ));
          }else{
            return Spacer();
          }
        });
  }
}