import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:toury/core/functions/navigation.dart';
import 'package:toury/core/widgets/custom_button.dart';
import 'package:toury/featuers/admin/products_manager/presentation/widgets/edit_product.dart';

class ProductManagerView extends StatefulWidget {
  const ProductManagerView({super.key});

  @override
  State<ProductManagerView> createState() => _ProductManagerViewState();
}

class _ProductManagerViewState extends State<ProductManagerView> {
  TextEditingController productNameController = TextEditingController();
  TextEditingController productTypeController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المنتجات'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Gap(50.h),
               
                TextFormField(
                  controller: productNameController,
                  decoration: InputDecoration(
                    hintText: 'اسم المنتج',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                Gap(20.h),
                TextFormField(
                  controller: productTypeController,
                  decoration: InputDecoration(
                    hintText: 'الصنف ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                Gap(20.h),
                TextFormField(
                  controller: productPriceController,
                  keyboardType: TextInputType.number,
                 decoration:InputDecoration(
                    hintText: 'السعر ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ) , 
                ),
                Gap(20.h),
                CustomButton(width: 200.w,text: 'اضف منتج', onPressed: (){
                  if (_formKey.currentState!.validate()) {
                    FirebaseFirestore.instance.collection('products').add({
                      'productName': productNameController.text,
                      'productType': productTypeController.text,
                      'productPrice': productPriceController.text,
                    }).then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم اضافة المنتج بنجاح')),
                      );
                      productNameController.clear();
                      productTypeController.clear();
                      productPriceController.clear();
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('فشل في اضافة المنتج: $error')),
                      );
                    });
                    
                  }
                }),
                Gap(40.h),
                CustomButton(width: 200.w,text: 'تعديل الاسعار', onPressed: (){
                  push(context,const EditProductView());
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}