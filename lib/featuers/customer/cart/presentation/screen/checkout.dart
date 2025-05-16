
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toury/core/functions/navigation.dart';
import 'package:toury/core/models/order_model.dart';
import 'package:toury/core/services/local_storage.dart';
import 'package:toury/core/utils/text_style.dart';
import 'package:toury/core/widgets/custom_button.dart';
import 'package:toury/featuers/customer/cart/data/model/cart_model.dart';
import 'package:toury/featuers/customer/customer_nav_bar.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.cartItems, required this.total});
  final List<CartItem> cartItems;
  final double total;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isSubmitting = false;

  String paymentMethod = 'كاش عند الاستلام';
  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<String> _createOrder() async {
    try {
      final userId = AppLocalStorage.getData(key: AppLocalStorage.userToken);
      if (userId == null) throw Exception('User ID not found');

      final total = widget.cartItems.fold(
          0.0, (sum, item) => sum + (item.price * item.quantity));

      final orderItems = widget.cartItems.map((item) => OrderItem(
            productId: item.productId,
            name: item.productName,
            price: item.price,
            quantity: item.quantity,
            weight: item.weight,
          )).toList();

      final orderRef = await FirebaseFirestore.instance.collection('orders').add({
        'userId': userId,
        'status': 'pending',
        'paymentMethod': paymentMethod,
        'contact': {
          'phone': _phoneController.text,
          'address': _addressController.text,
        },
        'items': orderItems.map((item) => item.toMap()).toList(),
        'total': total,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _clearCart(userId);
      return orderRef.id;
    } catch (e) {
      debugPrint('Error creating order: $e');
      throw Exception('فشل إنشاء الطلب: ${e.toString()}');
    }
  }

  Future<void> _clearCart(String userId) async {
    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart');

    final snapshot = await cartRef.get();
    final batch = FirebaseFirestore.instance.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء الطلب بنجاح '),
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // تنظيف الحقول بعد النجاح
      _addressController.clear();
      _phoneController.clear();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل إنشاء الطلب: ${e.toString()}'),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مراجعة الطلب'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'عنوان التوصيل',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    hintText: 'اكتب عنوانك بالتفصيل...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.r)),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFE6EFF9),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'رقم التواصل',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'اكتب رقم تليفونك...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.r)),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFE6EFF9),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'طريقة الدفع',
                  style: getTitleStyle(),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: const Text('كاش عند الاستلام'),
                        value: 'كاش عند الاستلام',
                        groupValue: paymentMethod,
                        onChanged: (value) {
                          if (mounted) {
                            setState(() {
                              paymentMethod = value!;
                            });
                          }
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('فودافون كاش'),
                        value: 'فودافون كاش',
                        groupValue: paymentMethod,
                        onChanged: (value) {
                          if (mounted) {
                            setState(() {
                              paymentMethod = value!;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                CustomButton(
                  text: 'تأكيد الطلب',
                  
                  onPressed: () {
                    if (!_isSubmitting && _formKey.currentState!.validate()) {
                      _createOrder();
                      _submitOrder();
                      _clearCart(AppLocalStorage.getData(key: AppLocalStorage.userToken)!);
                     
                      pushAndRemoveUntil(context,const CustomerNavBar());
                    }
                  }
                  
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
