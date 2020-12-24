import 'package:app/blocs/bloc_provider.dart';
import 'package:app/blocs/pick_province_dialog_bloc.dart';
import 'package:app/i18n/app_localizations.dart';
import 'package:app/models/base_model.dart';
import 'package:flutter/material.dart';

final pickProvinceDialogStateKey = new GlobalKey<_PickProvinceDialogState>();


class PickProvinceDialog extends StatefulWidget {
  final InputDecoration searchDecoration;
  final TextStyle searchStyle;
  final WidgetBuilder emptySearchBuilder;


  PickProvinceDialog({
    Key key,
    this.emptySearchBuilder,
    InputDecoration searchDecoration = const InputDecoration(),
    this.searchStyle,
  })  : assert(searchDecoration != null, 'searchDecoration must not be null!'),
        this.searchDecoration =
            searchDecoration.copyWith(prefixIcon: Icon(Icons.search)),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _PickProvinceDialogState();
}

class _PickProvinceDialogState extends State<PickProvinceDialog> {
  /// this is useful for filtering purpose
  List<BaseModel> filteredElements;
  String filter = "";

  PickProvinceDialogBloc _pickProvinceDialogBloc;

  void refreshStreams(){
    _pickProvinceDialogBloc.refreshStreams();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _pickProvinceDialogBloc.listProvincesStream,
        initialData: null,
        builder: (context, snapshotProvinces) {
          if (!(snapshotProvinces.hasData && snapshotProvinces.data != null)) {
            return SizedBox.expand(
              child: Container(
                decoration: BoxDecoration(color: Colors.white),
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
            );
          }
          filteredElements =snapshotProvinces.data
              .where((e) => e.toString().toUpperCase().contains(filter))
              .toList();
          if (filteredElements == null){
            filteredElements =  snapshotProvinces.data;
          }
          return SimpleDialog(
            title: Column(
              children: <Widget>[
                TextField(
                  style: widget.searchStyle,
                  decoration: widget.searchDecoration,
                  onChanged: _filterElements,
                ),
              ],
            ),
            children: [
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: ListView(
                      children: []..addAll(filteredElements.isEmpty
                          ? [_buildEmptySearchWidget(context)]
                          : filteredElements.map((e) => SimpleDialogOption(
                                key: Key(e.toString()),
                                child: _buildOption(e),
                                onPressed: () {
                                  _selectItem(e);
                                },
                              ))))),
            ],
          );
        });
  }

  Widget _buildOption(BaseModel e) {
    return Container(
      width: 400,
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Text(
              e.toString(),
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchWidget(BuildContext context) {
    if (widget.emptySearchBuilder != null) {
      return widget.emptySearchBuilder(context);
    }
    return Center(child: Text(AppLocalizations.of(context).translate('noResultsFound')));
  }

  @override
  void initState(){
    _pickProvinceDialogBloc = BlocProvider.of<PickProvinceDialogBloc>(context);
    super.initState();
  }

  void _filterElements(String s) {
    s = s.toUpperCase();
    setState(() {
      filter = s;
    });
  }

  void _selectItem(BaseModel e) {
    Navigator.pop(context, e);
  }
}
