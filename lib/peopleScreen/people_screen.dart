import 'package:flutter/material.dart';
import 'package:flutter_tindercard_2/flutter_tindercard_2.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> profiles = [
    {
      "name": "Alice",
      "age": 24,
      "image": "https://t4.ftcdn.net/jpg/03/83/25/83/360_F_383258331_D8imaEMl8Q3lf7EKU2Pi78Cn0R7KkW9o.jpg",
    },
    {
      "name": "Bob",
      "age": 27,
      "image": "https://thumbs.dreamstime.com/b/excited-african-american-man-pointing-finger-background-template-text-stock-photo-149317403.jpg",
    },
    {
      "name": "Charlie",
      "age": 22,
      "image": "https://t4.ftcdn.net/jpg/03/83/25/83/360_F_383258331_D8imaEMl8Q3lf7EKU2Pi78Cn0R7KkW9o.jpg",
    },
    {
      "name": "Diana",
      "age": 25,
      "image": "https://thumbs.dreamstime.com/b/excited-african-american-man-pointing-finger-background-template-text-stock-photo-149317403.jpg",
    },
    {
      "name": "Ethan",
      "age": 30,
      "image": "https://t4.ftcdn.net/jpg/03/83/25/83/360_F_383258331_D8imaEMl8Q3lf7EKU2Pi78Cn0R7KkW9o.jpg",
    },
  ];

  final CardController _controller = CardController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text(
          "PairFect",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: profiles.isNotEmpty
                ? TinderSwapCard(
              swipeUp: true,
              swipeDown: false,
              orientation: AmassOrientation.top,
              totalNum: profiles.length,
              stackNum: 3,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              minWidth: MediaQuery.of(context).size.width * 0.8,
              minHeight: MediaQuery.of(context).size.height * 0.7,
              cardBuilder: (context, index) {
                final profile = profiles[index];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        profile['image'],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Text(
                        "${profile['name']}, ${profile['age']}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
              cardController: _controller,
              swipeCompleteCallback: (CardSwipeOrientation orientation, int index) {
                final profile = profiles[index];
                if (orientation == CardSwipeOrientation.right) {
                  print("Liked ${profile['name']}");
                } else if (orientation == CardSwipeOrientation.left) {
                  print("Disliked ${profile['name']}");
                } else if (orientation == CardSwipeOrientation.up) {
                  print("Superliked ${profile['name']}");
                }
                setState(() {
                  profiles.removeAt(index);
                });
              },
            )
                : Center(
              child: Text(
                "No more profiles!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (profiles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildIconButton(
                    icon: Icons.close,
                    color: Colors.red,
                    onPressed: () => _controller.triggerLeft(),
                  ),
                  _buildIconButton(
                    icon: Icons.star,
                    color: Colors.blue,
                    onPressed: () => _controller.triggerUp(),
                  ),
                  _buildIconButton(
                    icon: Icons.favorite,
                    color: Colors.green,
                    onPressed: () => _controller.triggerRight(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        iconSize: 40,
        onPressed: onPressed,
      ),
    );
  }
}
