import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MatchScreen extends StatelessWidget {
  final String matchedUserName;
  final String interactionType;
  final String myImageUrl;
  final String imageUrl;

  const MatchScreen({
    super.key,
    required this.matchedUserName,
    required this.interactionType, required this.myImageUrl, required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff371F7D),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "It's  A  Match",
                style: GoogleFonts.styleScript(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "You and $matchedUserName $interactionType each other",
                style: GoogleFonts.rosario(
                  fontSize: 24,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.grey,
                          child: CircleAvatar(
                            radius: 65,
                            backgroundImage: NetworkImage(myImageUrl),
                          ),
                        ),
                        CircleAvatar(
                          radius: 75,
                          backgroundColor: Colors.grey,
                          child: CircleAvatar(
                            radius: 80,
                            backgroundImage: NetworkImage(imageUrl),
                          ),
                        ),
                      ],
                    ),

                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.pink,
                      ),
                      child: Icon(Icons.favorite, color: Colors.white, size: 70),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40,),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(

                      backgroundColor: Colors.red
                    ),
                    onPressed: (){}, child: Text("Send a Message",style: TextStyle(
                  fontSize: 24,
                  color: Colors.white
                ),)),
              ),
              SizedBox(height: 30,),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(

                      backgroundColor: Colors.transparent,
                      side: BorderSide(color: Colors.redAccent,width: 2)
                    ),
                    onPressed: (){}, child: Text("Keep Swiping",style: TextStyle(
                  fontSize: 24,
                  color: Colors.white
                ),)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
