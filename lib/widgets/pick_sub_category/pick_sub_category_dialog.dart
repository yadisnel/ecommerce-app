import 'package:app/i18n/app_localizations.dart';
import 'package:app/models/base_model.dart';
import 'package:app/models/sub_category_model.dart';
import 'package:flutter/material.dart';

final pickSubCategoryDialogStateKey = new GlobalKey<_PickSubCategoryDialogState>();


class PickSubCategoryDialog extends StatefulWidget {
  final InputDecoration searchDecoration;
  final TextStyle searchStyle;
  final WidgetBuilder emptySearchBuilder;
  final List<SubCategoryModel> subCategories;


  PickSubCategoryDialog({
    Key key,
    this.emptySearchBuilder,
    this.subCategories,
    InputDecoration searchDecoration = const InputDecoration(),
    this.searchStyle,
  })  : assert(searchDecoration != null, 'searchDecoration must not be null!'),
        this.searchDecoration =
            searchDecoration.copyWith(prefixIcon: Icon(Icons.search)),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _PickSubCategoryDialogState();
}

class _PickSubCategoryDialogState extends State<PickSubCategoryDialog> {
  /// this is useful for filtering purpose
  List<BaseModel> filteredElements;
  String filter = "";

  @override
  Widget build(BuildContext context) {
    filteredElements =widget.subCategories
        .where((e) => e.toString().toUpperCase().contains(filter))
        .toList();
    if (filteredElements == null){
      filteredElements =  widget.subCategories;
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
