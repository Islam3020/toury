// import 'package:supabase_flutter/supabase_flutter.dart';

// class CartRepository {
//   final SupabaseClient supabase;

//   CartRepository(this.supabase);

//   Future<void> addProductToCart({
//     required String productName,
//     required double price,
//     required double weight,
//     required String cutType,
//     required int quantity,
//   }) async {
//     await supabase.from('carts').insert({
//       'user_id': supabase.auth.currentUser!.id,
//       'product_name': productName,
//       'price': price,
//       'weight': weight,
//       'cut_type': cutType,
//       'quantity': quantity,
//     });
//   }

//   Future<List<Map<String, dynamic>>> getCartItems() async {
//     final response = await supabase
//         .from('carts')
//         .select()
//         .eq('user_id', supabase.auth.currentUser!.id);
//     return List<Map<String, dynamic>>.from(response);
//   }

//   Future<void> updateProductQuantity({
//     required int cartItemId,
//     required int newQuantity,
//   }) async {
//     await supabase
//         .from('carts')
//         .update({'quantity': newQuantity})
//         .eq('id', cartItemId);
//   }

//   Future<void> removeProductFromCart(int cartItemId) async {
//     await supabase.from('carts').delete().eq('id', cartItemId);
//   }

//   Future<void> clearCart() async {
//     await supabase
//         .from('carts')
//         .delete()
//         .eq('user_id', supabase.auth.currentUser!.id);
//   }

//   Future<void> placeOrder({
//   required String userId,
//   required String address,
//   required String phone,
//   required String paymentMethod,
// }) async {
//   final client = supabase; // أو أي اسم بتستخدمه للـ Supabase client

//   // أولاً: استرجع المنتجات الموجودة في السلة
//   final cartResponse = await client
//       .from('cart')
//       .select()
//       .eq('user_id', userId);

//   final cartItems = cartResponse as List;

//   if (cartItems.isEmpty) {
//     throw Exception('السلة فارغة');
//   }

//   // ثانيًا: أضف الطلب إلى جدول orders
//   final orderInsert = await client
//       .from('orders')
//       .insert({
//         'user_id': userId,
//         'address': address,
//         'phone': phone,
//         'payment_method': paymentMethod,
//       })
//       .select()
//       .single();

//   final orderId = orderInsert['id'];

//   // ثالثًا: أضف المنتجات إلى جدول order_items
//   final orderItems = cartItems.map((item) {
//     final product = item['product'];
//     return {
//       'order_id': orderId,
//       'product_id': product['id'],
//       'product_name': product['name'],
//       'price': product['price'],
//       'weight': product['weight'],
//       'quantity': item['quantity'],
//     };
//   }).toList();

//   await client.from('order_items').insert(orderItems);

//   // رابعًا: فرّغ السلة
//   await client.from('cart').delete().eq('user_id', userId);
// }

// }