import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'shopping_screen.dart';
import 'favorities_screen.dart';

class BottomNavScreen extends StatelessWidget {
  final PersistentTabController _controller = PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return [
      AnaEkran(),
      FavorilerEkrani(),
      CartScreen(),
      LoginScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home),
        title: 'Anasayfa',
        activeColorPrimary: Colors.pink,
        inactiveColorPrimary: Colors.pink.shade200,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.favorite),
        title: 'Favorilerim',
        activeColorPrimary: Colors.pink,
        inactiveColorPrimary: Colors.pink.shade200,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.shopping_cart),
        title: 'Sepetim',
        activeColorPrimary: Colors.pink,
        inactiveColorPrimary: Colors.pink.shade200,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.account_circle),
        title: 'Hesabım',
        activeColorPrimary: Colors.pink,
        inactiveColorPrimary: Colors.pink.shade200,
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
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white,
      ),
      navBarStyle: NavBarStyle.style9,
      onItemSelected: (index) {
        _controller.index = index;
      },
    );
  }
}
