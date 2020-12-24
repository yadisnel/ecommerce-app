import 'package:app/blocs/bloc_provider.dart';
import 'package:app/blocs/chats_page_bloc.dart';
import 'package:flutter/material.dart';

class ChatsPage extends StatefulWidget {
  ChatsPage({
    Key key,
  }) : super(key: key);

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  ChatsPageBloc _networkPageBloc;

  @override
  void initState() {
    super.initState();
    _networkPageBloc = BlocProvider.of<ChatsPageBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _networkPageBloc.appConfigStream,
      initialData: null,
      builder: (context, snapshot) {
        if (!(snapshot.hasData && snapshot.data != null)) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return SizedBox.expand(
            child: Center(
          child: Text("Chats"),
        ));
      }, // access the data in our Stream here
    );
  }
}
