import 'package:flutter/material.dart';
import 'package:pairfect/likes/likesyou_screen.dart';
import 'package:pairfect/likes/matches_screen.dart';

class LikeScreen extends StatefulWidget {
  const LikeScreen({super.key});

  @override
  State<LikeScreen> createState() => _LikeScreenState();
}

class _LikeScreenState extends State<LikeScreen> {
   bool showLikes = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Likes & Matches"),
      backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => setState(() => showLikes = true),
                child: Text(
                  "Likes You",
                  style: TextStyle(
                    color: showLikes ? Colors.red : Colors.grey,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => showLikes = false),
                child: Text(
                  "Matches",
                  style: TextStyle(
                    color: !showLikes ? Colors.red : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: showLikes
                ? LikesYouScreen()
                : YourMatchScreen(),
          ),
        ],
      ),
    );
  }
}

