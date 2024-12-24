import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import 'transaction.dart';
import 'edit_view.dart';
import 'package:mbook2/data_helper.dart';
import 'app_body_state.dart';
import 'size_config.dart';
class ListDataState with ChangeNotifier{
  late Future<List<Transaction>> _items;
  var _sel_list=[];
  var _total_value=0.0;

  set target_range(DateTimeRange range){
    _items=DataHelper().get_trans_list(
        range.start,
        range.end);
    _sel_list=[];
    _total_value=0;
  }

  Future<List<Transaction>> get items=>_items;
  double get total_value=>_total_value;
  void add_sel(int idx){
    _sel_list.add(idx);
    notifyListeners();
  }
  void remove_sel(int idx){
    _sel_list.remove(idx);
    notifyListeners();
  }
  bool contains_sel(int idx){
    return _sel_list.contains(idx);
  }
  void clear_sel(){
    this._sel_list.clear();
    notifyListeners();
  }
  int get_sel(int idx){
    return this._sel_list[idx];
  }
  bool get is_sel_empty=>this._sel_list.isEmpty;
  int get sel_length=>this._sel_list.length;

}
class ListWidget extends StatelessWidget  {

  ListDataState _items;
  TargetDateState _targetDate;
  ListWidget(this._targetDate, this._items);




  @override
  Widget build(BuildContext context) {


    return FutureBuilder(future:this._items.items ,
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
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Text(0.0==this._items.total_value?
                  "In $inValue Out ${outValue.abs()}":
                  "Total $this.items.total_value"
                      ,style:TextStyle(fontSize:24)),

                  SizedBox(height: SizeConfig.blockSizeVertical * 70, child:
                  ListView.builder(itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                            tileColor: this._items.contains_sel(index) ? Colors.blue : Colors.white,
                            title: Text(snapshot.data![index].toString()),
                            onTap: () {
                              _on_edit(context,snapshot.data![index]);
                            },
                            onLongPress: () {
                              if (this._items.contains_sel(index)) {
                                this._items.remove_sel(index);
                              } else {
                                this._items.add_sel(index);
                              }
                            }
                        );
                      }
                  ))]);
          }
          return Spacer();
        });
  }
  void _on_edit(BuildContext context, Transaction t) async {
    try {
      await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return EditTransaction(t, title: "");
      })).then((value) {
        if (null != value) {
          DataHelper().add(value);
          this._targetDate.target = ((value as Transaction).tDate.toLocal());
        }
      }
      );
    } catch (e) {
      print(e);
    }
  }
}