//import 'package:flutter/foundation.dart';
import 'dart:collection';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mbook2/main_view_data.dart';
import 'main_view_title.dart';


import 'transaction.dart';
import 'edit_view.dart';
import 'package:mbook2/data_helper.dart';
import 'app_body_state.dart';
import 'size_config.dart';


class MainViewReport extends StatelessWidget {


  DateTimeRange _range;
  var _usage_value_tbl={};
  var _method_value_tbl={};
  static final _pie_color_tbl=[
    Colors.blue,
    Colors.amber,
    Colors.brown,
    Colors.deepOrange,
    Colors.deepPurple,

  ];
  MainViewReport(this._range);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
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


                  Text("Usages categories"),
                  SizedBox(
                    width: SizeConfig.screenWidth,
                    height: SizeConfig.screenHeight*0.3,
                    child: _gen_pie_chart(_usage_value_tbl),),
                  Column(
                    children: usage_widget_tbl,
                  ),
                  Text("Methods categories"),
                  SizedBox(
                    width: SizeConfig.screenWidth,
                    height: SizeConfig.screenHeight*0.3,
                    child: _gen_pie_chart(_method_value_tbl),),

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

  PieChart _gen_pie_chart(Map<dynamic,dynamic> data){

    List<PieChartSectionData> sectors=[];
    for(var k in data.keys){

      sectors.add(PieChartSectionData(
        color: _pie_color_tbl[sectors.length % _pie_color_tbl.length],
        value: data[k],
        title:k,
        radius: 50,
      ));
    }

    return PieChart(PieChartData(sections:sectors,centerSpaceRadius: 48.0));
  }
}