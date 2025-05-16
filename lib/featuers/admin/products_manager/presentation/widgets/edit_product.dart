import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:toury/core/utils/text_style.dart';
import 'package:toury/core/widgets/custom_button.dart';
class EditProductView extends StatefulWidget {
  const EditProductView({super.key});

  @override
  State<EditProductView> createState() => _EditProductViewState();
}

class _EditProductViewState extends State<EditProductView> {
  List<QueryDocumentSnapshot> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  Future<void> getProducts() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    setState(() {
      products = snapshot.docs;
      isLoading = false;
    });
  }

  
  Future<void> _updateProductPrice(String productId, double newPrice) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({'productPrice': newPrice});
      
      // تحديث الواجهة بعد التعديل
      final updatedSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();
          
      setState(() {
        products = updatedSnapshot.docs;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث السعر بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تحديث السعر: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تعديل المنتج', style: getTitleStyle()),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? Center(child: Text('لا يوجد منتجات', style: getBodyStyle()))
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    var product = products[index].data() as Map<String, dynamic>;
                    var productId = products[index].id;

                    TextEditingController controller = TextEditingController(
                      text: product['productPrice']?.toString() ?? '',
                    );

                    return ExpansionTile(
                      title: Text("${product['productName']}  ${product['productPrice']}", style: getBodyStyle()),
                      children: [
                        TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: 'سعر المنتج',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        Gap(10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButton(
                              width: 100.w,
                              text: 'حفظ',
                             onPressed: () async {
                                          if (controller.text.isNotEmpty) {
                                            await _updateProductPrice(
                                              productId, 
                                              controller.text.isNotEmpty ? double.parse(controller.text) : 0.0,
                                            );
                                          }
                                        },
                            ),
                            CustomButton(
                              width: 100.w,
                              text: 'حذف',
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('products')
                                    .doc(productId)
                                    .delete();
                                setState(() {
                                  products.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}