import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toury/core/functions/navigation.dart';
import 'package:toury/core/services/local_storage.dart';
import 'package:toury/core/utils/colors.dart';
import 'package:toury/core/utils/text_style.dart';
import 'package:toury/core/widgets/custom_button.dart';
import 'package:toury/featuers/customer/cart/data/model/cart_model.dart';
import 'package:toury/featuers/customer/cart/presentation/screen/checkout.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final Stream<List<CartItem>> _cartStream;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = AppLocalStorage.getData(key: AppLocalStorage.userToken);
    _cartStream = _getCartItems(_userId ?? '');
  }

  Stream<List<CartItem>> _getCartItems(String userId) {
    if (userId.isEmpty) return Stream.value([]);
    
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .snapshots()
        .handleError((error) {
          debugPrint('Error fetching cart: $error');
          return const Stream.empty();
        })
        .map((snapshot) => snapshot.docs
            .map((doc) => CartItem.fromFirestore(doc))
            .toList());
  }

  double _calculateTotalPrice(List<CartItem> cartItems) {
    return cartItems.fold(0.0, (sum, item) => sum + item.total);
  }

  Future<void> _removeFromCart(String cartItemId) async {
    try {
      if (_userId == null) return;
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('cart')
          .doc(cartItemId)
          .delete();
          
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف المنتج من السلة')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الحذف: ${e.toString()}')),
      );
    }
  }

  Future<void> _clearCart() async {
    try {
      if (_userId == null) return;
      
      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('cart');
          
      final snapshot = await cartRef.get();
      final batch = FirebaseFirestore.instance.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('السلة'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<CartItem>>(
        stream: _cartStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }
          
          final cartItems = snapshot.data ?? [];
          
          if (cartItems.isEmpty) {
            return const Center(child: Text('السلة فارغة'));
          }
          
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: cartItems.length,
                  separatorBuilder: (_, __) => Divider(height: 20.h),
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        color: Colors.grey[200],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: getTitleStyle(color: AppColors.black),
                                ),
                                SizedBox(height: 8.h),
                                Text('الوزن: ${item.weight} كجم'),
                                Text('السعر للوحدة: ${item.price} ج.م'),
                                SizedBox(height: 8.h),
                                Text(
                                  'الإجمالي: ${item.total} ج.م',
                                  style: getTitleStyle(color: AppColors.black),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeFromCart(item.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الإجمالي: ${_calculateTotalPrice(cartItems).toStringAsFixed(2)} ج.م',
                      style: getTitleStyle(color: AppColors.black),
                    ),
                    CustomButton(
                      width: 120.w,
                      text: 'إتمام الطلب',
                      onPressed: () {
                        push(
                          context, 
                          CheckoutScreen(
                            cartItems: cartItems,
                            total: _calculateTotalPrice(cartItems),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}