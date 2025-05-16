import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:toury/featuers/customer/cart/presentation/screen/cart_screen.dart';
import 'package:toury/featuers/customer/home/presentation/screen/home_screen.dart';
import 'package:toury/featuers/customer/profile/presentation/screen/profile_screen.dart';


class CustomerNavBar extends StatefulWidget {
  const CustomerNavBar({super.key});

  @override
  State<CustomerNavBar> createState() => _CustomerNavBarState();
}

class _CustomerNavBarState extends State<CustomerNavBar> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CartScreen(),
    ProfileScreen(),
    // CartScreen(),
    // ProfileScreen(),
    
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20.r,
              color: Colors.black.withOpacity(0.1),
            )
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0.r, vertical: 8.r),
          child: GNav(
            backgroundColor: Colors.white,
            color: Colors.grey[800],
            activeColor: Colors.white,
            tabBackgroundColor: Colors.teal,
            gap: 8,
            padding:  EdgeInsets.all(12.r),
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'الرئيسية',
              ),
              GButton(
                icon: Icons.shopping_cart,
                text: 'السلة',
              ),
              GButton(
                icon: Icons.person,
                text: 'حسابي',
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
