import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class MatchScreen extends StatelessWidget {
  final String currentUserName;
  final String matchedUserName;

  const MatchScreen({
    Key? key,
    required this.currentUserName,
    required this.matchedUserName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('$currentUserName matched with $matchedUserName!'),
      ),
    );
  }
}
