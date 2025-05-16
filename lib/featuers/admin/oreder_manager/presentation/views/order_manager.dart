import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:toury/core/utils/text_style.dart';
import 'package:toury/featuers/admin/oreder_manager/presentation/widgets/order_container.dart';

class OrderManagerView extends StatefulWidget {
  const OrderManagerView({super.key});

  @override
  State<OrderManagerView> createState() => _OrderManagerViewState();
}

class _OrderManagerViewState extends State<OrderManagerView> {
  List<QueryDocumentSnapshot> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        orders = snapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في جلب الطلبات: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الطلبات'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : orders.isEmpty
                  ? Center(child: Text('لا توجد طلبات جديدة', style: getBodyStyle()))
                  : RefreshIndicator(
                      onRefresh: _fetchOrders,
                      child: ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index].data() as Map<String, dynamic>;
                          return Column(
                            children: [
                              OrderContainer(
                                order: order,
                                orderId: orders[index].id,
                                onOrderCompleted: () => _fetchOrders(),
                              ),
                              Gap(10.h),
                            ],
                          );
                        },
                      ),
                    ),
        ),
      ),
    );
  }
}