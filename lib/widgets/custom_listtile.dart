import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final String? title;
  final IconData? leading;
  final String? trailing;
  final VoidCallback? onPressed;

  const CustomListTile({super.key, this.title, this.leading, this.trailing, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPressed,
      leading: Icon(leading, size: 28),
      title: Text(
        "$title",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$trailing",
              style: TextStyle(fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.chevron_right, size: 28),
        ],
      ),
    );
  }
}
