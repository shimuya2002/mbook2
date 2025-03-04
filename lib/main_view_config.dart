import 'package:flutter/material.dart';
import 'package:mbook2/main_view_nav_state.dart';
import 'size_config.dart';
import 'main_view_data.dart';
enum CONFIG_MODE{
  CONFIG_DATA(""),
  CONFIG_CONVERT_MIZUHO_DIRECT_FORMAT(FORMAT_MIZUHO_DIRECT),
  CONFIG_ABOUT("");

  const CONFIG_MODE(this.param);

  final String param;
  static const FORMAT_MIZUHO_DIRECT="Mizuho direct csv";
  static const FORMAT_TYPES = [FORMAT_MIZUHO_DIRECT];
}
class MainViewConfig extends StatelessWidget {

  MainViewNavState _nav_state;
  MainViewDataState _data_state;
  MainViewConfig(this._nav_state,this._data_state);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: SizeConfig.blockSizeVertical * 70, child: ListView(
      children: [

        ListTile(
          title: Row(children: [
            Icon(Icons.info),
            Text("App about")
          ],

          ),
          onTap: () {
            _nav_state.user_data=CONFIG_MODE.CONFIG_ABOUT;

          }
          ,),

        ListTile(
          title: Row(children: [
            Icon(Icons.data_exploration),
            Text("Data")
          ],

          ),
          onTap: () {
            _nav_state.user_data=CONFIG_MODE.CONFIG_DATA;

          }
          ,),

        ListTile(
          title: Row(children: [
            Icon(Icons.file_copy),
            Text("File convert")
          ],

          ),
          onTap: () {
            _nav_state.user_data=CONFIG_MODE.CONFIG_CONVERT_MIZUHO_DIRECT_FORMAT;

          }
          ,),
      ],
    ));
  }


}