




import 'package:intl/intl.dart';

import 'package:uuid/uuid.dart';




abstract class Currency{
  var value=0.0;

  Currency(double v)
  {
    value=v;
  }





  static Currency parse(String sourceString){
    if(sourceString.length>JPY.syb.length &&
        JPY.syb==sourceString.substring(0,JPY.syb.length)){
      return JPY(double.parse(sourceString.substring(JPY.syb.length)));
    }
    return JPY(double.parse(sourceString));

  }

  factory Currency.fromJSON(Map<String,dynamic> json){
    return Currency.parse(json["value"]);
  }
  Currency clone();

}

class JPY extends Currency{

  static const syb="￥";


  JPY(super.v);



  @override String toString(){
    return "$syb$value";
  }
  @override
  Currency clone(){
    return JPY(this.value);
  }


}
enum STORAGE_MODE{
  MODE_WSTORAGE,
  MODE_FIRESTORE,
  MODE_INDEDEXDB,
}
enum OUTPUT_FORMAT{
  FMT_CSV,
  FMT_JSON
}

class Transaction {

  static final STORAGE_MODE storageMode=STORAGE_MODE.MODE_INDEDEXDB;
  static final OUTPUT_FORMAT fmtMode=OUTPUT_FORMAT.FMT_JSON;//OUTPUT_FORMAT.FMT_CSV;
  static final _uuid = Uuid();

  static final DateFormat _t_format = DateFormat.Hm(Intl.systemLocale);



  String tid = "";
  DateTime tDate = DateTime.now();
  String method = "";
  String usage = "";

  Currency _value = JPY(0.0);
  String note = "";


  Transaction() {
    tid = _uuid.v7();
  }

  static Transaction create(DateTime _tDate,String _method,String _usage,String value,String _note){
    var t=Transaction();
    t.tDate=_tDate;
    t.method=_method;
    t.usage=_usage;
    t._value=Currency.parse(value);
    t.note=_note;
    return t;
  }

  String toString() {
    return "${_t_format.format(tDate.toLocal())} $method $usage $_value $note";
  }

  String toCSVString() {
    return "$tid,${tDate.toIso8601String()},$method,$usage,$_value,$note";
  }

  factory Transaction.fromJson(Map<String,dynamic> json){
    var t=Transaction();
    t.tid=json["tid"];
    t.tDate=DateTime.parse(json["tdate"]);
    t.method=json["method"];
    t.usage=json["usage"];
    t._value=Currency.parse(json["value"]);
    t.note=json["note"];
    return t;


  }
  Map<String,dynamic> toJson(){
    return {
      "tid":tid,
      "tdate":tDate.toIso8601String(),
      "method":method,
      "usage":usage,
      "value":_value.toString(),
      "note":note
    };
  }
  double get_value() {
    return _value.value;
  }

  Transaction clone(){
    var newT=Transaction();
    newT.tDate=this.tDate;
    newT.method=this.method;
    newT.usage=this.usage;
    newT._value=this._value.clone();
    newT.note=this.note;
    return newT;
  }
  static Transaction create_from_csv(String sourceString) {
    var params = sourceString.split(",");
    if (1 < params.length) {
      var t = Transaction();
      t.tid = params[0];
      if(!Uuid.isValidUUID(fromString:  t.tid)){
        t.tid=_uuid.v7();
      }

      t.tDate = DateTime.parse(params[1]);

      t.method = params[2];
      t.usage = params[3];
      t._value = Currency.parse(params[4]);
      if(params.length>5) {
        t.note = params[5];
      }else{
        t.note="";
      }
      return t;
    }else{
      throw FormatException("Invalid format:$sourceString");
    }

  }




}