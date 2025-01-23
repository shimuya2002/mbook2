import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mbook2/main_view_data.dart';


import 'transaction.dart';
import 'edit_view.dart';
import 'package:mbook2/data_helper.dart';
import 'app_body_state.dart';
import 'size_config.dart';


class MainViewList extends StatelessWidget  {



  late MainViewDataState _data;

  MainViewList(this._data);



  @override
  Widget build(BuildContext context) {

      return FutureBuilder(future: _data.items,
          builder: (BuildContext context,
              AsyncSnapshot<List<Transaction>> snapshot) {
            if (snapshot.hasData) {
              var inValue = 0.0;
              var outValue = 0.0;
              for (var t in snapshot.data!) {
                if (t.get_value() > 0) {
                  inValue += t.get_value();
                } else {
                  outValue += t.get_value();
                }
              }
              var totalValue=0.0;
              if(!_data.is_sel_empty){
                for(var i=0;i < _data.sel_length;++i){
                  totalValue+=snapshot!.data![_data.get_sel(i)].get_value();

                }
              }
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_data.is_sel_empty?
                    "In $inValue Out ${outValue.abs()}" :
                    "Total $totalValue"
                        , style: TextStyle(fontSize: 24)),

                    SizedBox(height: SizeConfig.blockSizeVertical * 70, child:
                    ListView.builder(itemCount: snapshot.data!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                              tileColor: _data.contains_sel(index)
                                  ? Colors.blue
                                  : Colors.white,
                              title: Text(snapshot.data![index].toString()),
                              onTap: () {
                                _on_edit(context,_data, snapshot.data![index]);
                              },
                              onLongPress: () {
                                if (_data.contains_sel(index)) {
                                  _data.remove_sel(index);
                                } else {
                                  _data.add_sel(index);
                                }
                              }
                          );
                        }
                    ))
                  ]);
            }
            return Spacer();
          });

  }
  void _on_edit(BuildContext context,MainViewDataState data, Transaction t) async {
    try {
      await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return EditTransaction(t, title: "");
      })).then((value) async{
        if (null != value) {
          DataHelper().add(value);
          data.set_target ((value as Transaction).tDate.toLocal());
        }
      }
      );
    } catch (e) {
      print(e);
    }
  }
}