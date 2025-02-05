import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final String? title;
  final IconData? leading;
  final String? trailing;
  final VoidCallback? onPressed;
  const CustomListTile({super.key, this.title, this.leading, this.trailing, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return  ListTile(
      onTap: onPressed,
      leading:Icon(leading),
      title: Text("$title",style: TextStyle(fontSize: 19),),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("$trailing",style: TextStyle(fontSize: 16),),
          Icon(Icons.chevron_right,size: 30,)
        ],
      ),
    );
  }
}
