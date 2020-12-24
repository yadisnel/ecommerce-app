import 'package:app/blocs/bloc_provider.dart';
import 'package:app/blocs/pick_category_dialog_bloc.dart';
import 'package:app/blocs/pick_province_dialog_bloc.dart';
import 'package:app/models/base_model.dart';
import 'package:app/models/sub_category_model.dart';
import 'package:flutter/material.dart';
import 'pick_sub_category_dialog.dart';

final pickSubCategoryStateKey = new GlobalKey<_PickSubCategoryWidgetState>();

class PickSubCategoryWidget extends StatefulWidget {
  final ValueChanged<BaseModel> onChanged;

  //Exposed new method to get the initial information of the country
  final TextStyle textStyle;
  final EdgeInsetsGeometry padding;
  final InputDecoration searchDecoration;
  final TextStyle searchStyle;
  final WidgetBuilder emptySearchBuilder;
  final String hintText;
  final List<SubCategoryModel> subCategories;

  /// aligns the flag and the Text left
  final bool alignLeft;
  final List<String> selectionFilter;

  PickSubCategoryWidget(
      {Key key,
      this.onChanged,
      this.selectionFilter = const [],
      this.textStyle,
      this.padding = const EdgeInsets.all(0.0),
      this.searchDecoration = const InputDecoration(),
      this.searchStyle,
      this.emptySearchBuilder,
      this.alignLeft = false,
      this.subCategories,
      this.hintText})
      : assert(hintText != null, 'hintText must not be null!'),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _PickSubCategoryWidgetState();
  }
}

class _PickSubCategoryWidgetState extends State<PickSubCategoryWidget> {
  BaseModel selectedItem;

  _PickSubCategoryWidgetState();

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: widget.padding,
      onPressed: _showSelectionDialog,
      child: Flex(
        direction: Axis.horizontal,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            fit: widget.alignLeft ? FlexFit.tight : FlexFit.loose,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  selectedItem != null
                      ? selectedItem.toString()
                      : widget.hintText,
                  style: widget.textStyle ?? Theme.of(context).textTheme.button,
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: 26.0,
                  color: Colors.grey[700],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void resetState(){
    setState(() {
      selectedItem = null;
    });
  }

  void _showSelectionDialog() {
    showDialog(
      context: context,
      builder: (_) => BlocProvider(
        bloc: PickCategoryDialogBloc(),
        child: PickSubCategoryDialog(
          subCategories: widget.subCategories,
          key: pickSubCategoryDialogStateKey,
          emptySearchBuilder: widget.emptySearchBuilder,
          searchDecoration: widget.searchDecoration,
          searchStyle: widget.searchStyle,
        ),
      ),
    ).then((e) {
      if (e != null) {
        setState(() {
          selectedItem = e;
        });
        _publishSelection(e);
      }
    });
  }

  void _publishSelection(BaseModel e) {
    if (widget.onChanged != null) {
      widget.onChanged(e);
    }
  }
}
