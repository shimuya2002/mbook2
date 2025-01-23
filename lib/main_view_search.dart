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

class MainViewSearch extends StatefulWidget {
  MainViewSearch(this._def_range);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  DateTimeRange _def_range;

  @override
  State<MainViewSearch> createState() => _MainViewSearchState();
}

class _MainViewSearchState extends State<MainViewSearch> {


  Map<String, bool> _methods_flags = {};
  Map<String, bool> _usages_flags = {};

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
      SizedBox(height: SizeConfig.blockSizeVertical * 70, child:SingleChildScrollView(

               child: Column(
              children: [
                Text("Method show flags"),
                     
                     _methods_flags.isEmpty ? FutureBuilder(
                        future: DataHelper().get_method_list(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<String>> snapshot) {
                          if (snapshot.hasData) {
                            for (var k in snapshot.data!) {
                              _methods_flags[k] = true;
                            }
                            return _gen_check_list(_methods_flags);
                          }


                          return SizedBox(height: SizeConfig.blockSizeVertical * 30,width: SizeConfig.blockSizeHorizontal * 70, child:Text(""));
                        }
                    ) : _gen_check_list(_methods_flags),

                Text("Usage show flags"),
                 _methods_flags.isEmpty ? FutureBuilder(
                        future: DataHelper().get_usage_list(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<String>> snapshot) {
                          if (snapshot.hasData) {
                            for (var k in snapshot.data!) {
                              _usages_flags[k] = true;
                            }
                            return _gen_check_list(_usages_flags);
                          }


                          return SizedBox(height: SizeConfig.blockSizeVertical * 30,width: SizeConfig.blockSizeHorizontal * 70, child:Text(""));
                        }
                    ) : _gen_check_list(_usages_flags),
              ])));
  }

  Widget _gen_check_list(Map<String,bool> flags) {
    List<Widget> check_list = [];
    for (var k in flags.keys) {
      check_list.add(
          Row(children: [

            Checkbox(value: flags[k], onChanged: (nv) {
              setState((){flags[k] = nv!;});

            }),
            Text(k)

          ],)
      );
    }
    return  SizedBox(height: SizeConfig.blockSizeVertical * 30,width: SizeConfig.blockSizeHorizontal * 70, child:ListView(children:check_list,));
  }
}