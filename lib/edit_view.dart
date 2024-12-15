import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mbook2/data_helper.dart';
import 'transaction.dart';

import 'size_config.dart';

class EditTransaction extends StatefulWidget {
  EditTransaction(
      this.target,
      {super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  final String title;
  final Transaction? target;
  @override
  State<EditTransaction> createState() => _EditTransactionState();
}
class _EditTransactionState extends State<EditTransaction> {
  var _type = 0;

  final date_fmt = DateFormat("yyyy/MM/dd");
  final time_fmt = DateFormat("HH:mm");

  String? _usage="";
  String? _method="";
  TextEditingController _controller = TextEditingController();
  String _valueText="0";
  DateTime? _date_time=null;


  @override
  Widget build(BuildContext context) {
    if(null==_date_time) {
      if (null == this.widget.target) {
        _date_time = DateTime.now();
      }else {
        _date_time = this.widget.target!.tDate.toLocal();
        _type=0>this.widget.target!.get_value()?1:0;

        _method=this.widget.target!.method;
        _usage=this.widget.target!.usage;

        _valueText=this.widget.target!.get_value().abs().toString();
        _controller.text=this.widget.target!.note;
      }
    }
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
          automaticallyImplyLeading: false,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
            child: Column(
                children: [
                  Row(children: [
                    Text("種別"),
                    Flexible(
                        child: RadioListTile(
                            title: Text("収入"),
                            value: 0,
                            groupValue: _type,
                            onChanged: _onTypeChanged)),
                    Flexible(
                        child: RadioListTile(
                            title: Text("支出"),
                            value: 1,
                            groupValue: _type,
                            onChanged: _onTypeChanged)),

                  ],

                  ),
                  Row(
                    children: [
                      Container(
                          width: SizeConfig.blockSizeHorizontal * 30,
                          child: Text("Date")),
                      Container(
                          width: SizeConfig.blockSizeHorizontal * 30,
                          child: Text("${date_fmt.format(_date_time!)}")),
                      ElevatedButton(
                        child: Text("Change"),
                        onPressed: () {
                          _onDateChange(context);
                        },

                      )
                    ],

                  ),
                  Row(
                    children: [
                      Container(
                          width: SizeConfig.blockSizeHorizontal * 30,
                          child: Text("Time")),
                      Container(
                          width: SizeConfig.blockSizeHorizontal * 30,
                          child: Text("${time_fmt.format(_date_time!)}")),
                      ElevatedButton(
                        child: Text("Change"),
                        onPressed: () {
                          _onTimeChange(context);
                        },
                      )
                    ],
                  ),
                  Row(
                      children: [
                        Container(
                            width: SizeConfig.blockSizeHorizontal * 30,
                            child: const Text("支払方法")),
                        _gen_method_dropdown()]),
                  Row(
                      children: [

                        Container(
                            width: SizeConfig.blockSizeHorizontal * 30,
                            child: Text("使途")),
                        _gen_usage_dropdown()
                      ]),
                  Row(
                    children: [
                      Container(
                          width: SizeConfig.blockSizeHorizontal * 30,
                          child: Text("備考")),
                      Container(
                          width: SizeConfig.blockSizeHorizontal * 70,
                          child: TextField(
                            controller: _controller,


                          ))

                    ],
                  ),
                  Row(children: [
                    Container(width: SizeConfig.blockSizeHorizontal * 30,
                        child: Text("金額")),
                    Container(width: SizeConfig.blockSizeHorizontal * 30,
                        child: Text("${_valueText}")),
                  ],),
                  Table(

                    children: [
                      TableRow(children: [
                        ElevatedButton(
                          child: Text("%"),
                          onPressed: () {},
                        ),
                        ElevatedButton(
                          child: Text("AC"),
                          onPressed: () {
                            setState(() {
                              _valueText = "0";
                            });
                          },
                        ),
                        ElevatedButton(
                          child: Text("BS"),
                          onPressed: () {
                            var text = _valueText;
                            setState(() {
                              if (0 < text.length) {
                                _valueText =
                                    text.substring(0, text.length - 1);
                                if(0==_valueText.length){
                                  _valueText="0";
                                }
                              } else {
                                _valueText = "0";
                              }
                            });
                          },
                        ),
                        ElevatedButton(
                          child: Text("/"),
                          onPressed: () {
                            _onValueAdded("/");
                          },
                        ),
                      ]),
                      TableRow(children: [
                        ElevatedButton(
                          child: Text("7"),
                          onPressed: () {
                            _onValueAdded("7");
                          },
                        ),
                        ElevatedButton(
                          child: Text("8"),
                          onPressed: () {
                            _onValueAdded("8");
                          },
                        ),
                        ElevatedButton(
                          child: Text("9"),
                          onPressed: () {
                            _onValueAdded("9");
                          },
                        ),
                        ElevatedButton(
                          child: Text("*"),
                          onPressed: () {
                            _onValueAdded("*");
                          },
                        ),
                      ]),

                      TableRow(children: [
                        ElevatedButton(
                          child: Text("4"),
                          onPressed: () {
                            _onValueAdded("4");
                          },
                        ),
                        ElevatedButton(
                          child: Text("5"),
                          onPressed: () {
                            _onValueAdded("5");
                          },
                        ),
                        ElevatedButton(
                          child: Text("6"),
                          onPressed: () {
                            _onValueAdded("6");
                          },
                        ),
                        ElevatedButton(
                          child: Text("-"),
                          onPressed: () {
                            _onValueAdded("-");
                          },
                        )
                      ]),

                      TableRow(children: [
                        ElevatedButton(
                          child: Text("1"),
                          onPressed: () {
                            _onValueAdded("1");
                          },
                        ),
                        ElevatedButton(
                          child: Text("2"),
                          onPressed: () {
                            _onValueAdded("2");
                          },
                        ),
                        ElevatedButton(
                          child: Text("3"),
                          onPressed: () {
                            _onValueAdded("3");
                          },
                        ),
                        ElevatedButton(
                          child: Text("+"),
                          onPressed: () {
                            _onValueAdded("+");
                          },
                        )
                      ]),
                      TableRow(
                        children: [
                          ElevatedButton(
                            child: Text("0"),
                            onPressed: () {
                              _onValueAdded("0");
                            },
                          ),
                          ElevatedButton(
                            child: Text("."),
                            onPressed: () {
                              _onValueAdded(".");
                            },
                          ),
                          Text(""),
                          ElevatedButton(
                            child: Text("="),
                            onPressed: () {
                              _calc();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                      children: [
                        ElevatedButton(
                          child: Text("OK"),
                          onPressed: _onOk,
                        ),
                        ElevatedButton(
                          child: Text("CANCEL"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ])


                ])));
  }


  Widget _gen_method_dropdown() {
    return FutureBuilder(
        future: DataHelper().get_method_list(),
        builder: (BuildContext context,
            AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.hasData) {
            if (!snapshot.data!.isEmpty &&
                !snapshot.data!.contains(_method!)) {
              _method = snapshot.data!.first;
            }
            return DropdownButton<String>(
              value: _method,
              onChanged: (newValue) {
                setState(() {
                  if (null != newValue) {
                    _method = newValue;
                  }
                });
              },
              items: snapshot.data!
                  .map<DropdownMenuItem<String>>(
                      (String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
            );
          } else {
            return DropdownButton<String>(
                value: null,
                onChanged: (value) {},
                items: []);
          }
        }
    );
  }
  Widget _gen_usage_dropdown() {
    return FutureBuilder(
        future: DataHelper().get_usage_list(),
        builder: (BuildContext context,
            AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.hasData) {
            if (!snapshot.data!.isEmpty &&
                !snapshot.data!.contains(_usage!)) {
              _usage = snapshot.data!.first;
            }
            return DropdownButton<String>(
              value: _usage,
              onChanged: (newValue) {
                setState(() {
                  if (null != newValue) {
                    _usage = newValue;
                  }
                });
              },
              items: snapshot.data!
                  .map<DropdownMenuItem<String>>(
                      (String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
            );
          } else {
            return DropdownButton<String>(
                value: null,
                onChanged: (value) {},
                items: []);
          }
        }
    );
  }

  ///種別が変更された
  void _onTypeChanged(int? v) async {

    if(null!=v){
      setState(() {
        _type=v;
      });
    }
  }
  void _onDateChange(context) async {
    var curDate = DateTime.now();
    if (null != _date_time) {
      curDate = _date_time!;
    }
    final DateTime? datePicked = await showDatePicker(
        context: context,
        initialDate: curDate,
        firstDate: DateTime(2003),
        lastDate: DateTime(curDate.year + 1));
    if (null != datePicked) {
      setState(() {
        _date_time= DateTime(datePicked!.year,datePicked!.month,datePicked!.day,curDate.hour,curDate.minute);
      });
    }
  }

  void _onTimeChange(context) async {
    var curDate = DateTime.now();
    if (null != _date_time) {
      curDate = _date_time!;
    }
    final initialTime = TimeOfDay(hour: curDate.hour, minute: curDate.minute);
    final TimeOfDay? newTime =
    await showTimePicker(context: context, initialTime: initialTime);
    if (null != newTime) {
      setState(() {
        _date_time = DateTime(curDate.year, curDate.month, curDate.day,
            newTime.hour, newTime.minute);
      });
    }
  }
  void _onValueAdded(String t){
    setState(() {
      if ("0" != _valueText) {
        //updateValue(notifier.value + valueAdded);
        _valueText+=t;
      } else {
        _valueText=t;
      }

    });
  }
  void _calc(){
    var item = _valueText;
    var v1 = 0.0;
    var v2 = 0.0;
    var tmp = "";
    var op = "";
    for (var i = 0; i < item.length; ++i) {
      var c = item[i];
      if ("%" == c || "*" == c || "/" == c || "-" == c || "+" == c) {
        if (0 == op.length) {
          v1 = double.parse(tmp);
        } else {
          v2 = double.parse(tmp);
          if ("%" == op) {
            v1 = v1 % v2;
          } else if ("*" == op) {
            v1 = v1 * v2;
          } else if ("/" == op) {
            v1 = v1 / v2;
          } else if ("-" == op) {
            v1 = v1 - v2;
          } else if ("+" == op) {
            v1 = v1 + v2;
          }
        }

        tmp = "";
        op = c;
      } else {
        tmp = tmp + c;
      }
    }
    if (tmp.isNotEmpty) {
      v2 = double.parse(tmp);
      if ("%" == op) {
        v1 = v1 % v2;
      } else if ("*" == op) {
        v1 = v1 * v2;
      } else if ("/" == op) {
        v1 = v1 / v2;
      } else if ("-" == op) {
        v1 = v1 - v2;
      } else if ("+" == op) {
        v1 = v1 + v2;
      } else {
        v1 = v2;
      }
    }
    setState(() {
      _valueText=(v1.toStringAsFixed(2));

    });
  }


  void _onOk(){

    _calc();
    var value=double.parse(_valueText);
    var t=Transaction.create(_date_time!.toUtc(),null==_method?"":_method!,null==_usage?"":_usage!,(0!=_type?-value:value).toString(), _controller.text);
    if(null!=widget.target){
      t.tid=widget.target!.tid;
    }
    Navigator.of(context).pop(t);
  }
  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }
}