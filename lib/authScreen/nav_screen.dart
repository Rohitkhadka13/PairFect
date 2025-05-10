import 'package:flutter/material.dart';
import 'package:pairfect/authScreen/chats_screen.dart';
import 'package:pairfect/authScreen/fyp_screen.dart';
import 'package:pairfect/authScreen/like_screen.dart';
import 'package:pairfect/authScreen/likesyou_screen.dart';
import 'package:pairfect/authScreen/matches_screen.dart';
import 'package:pairfect/peopleScreen/people_screen.dart';

import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../profileScreen/profile_screen.dart';



class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, required int initialIndex});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final PersistentTabController _controller = PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return [
      ProfileScreen(),
      ForYouPage(),
      PeopleScreen(),
      LikeScreen(),
      ChatsScreen(),


    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.person),
        title: "Profile",
        activeColorPrimary: Colors.red,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.disc_full_rounded),
        title: "Discover",
        activeColorPrimary: Colors.red,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.menu),
        title: "People",
        activeColorPrimary: Colors.red,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.favorite),
        title: "Like",
        activeColorPrimary: Colors.red,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.chat),
        title: "Chat",
        activeColorPrimary: Colors.red,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      navBarStyle: NavBarStyle.style14,
      backgroundColor: Colors.white,
      confineToSafeArea: true,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      hideNavigationBarWhenKeyboardAppears: true,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(20.0),
        colorBehindNavBar: Colors.white,
      ),


    );
  }
}
