import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// No longer needs SharedPreferences or ReviewService directly here

import 'package:myapp/core/services/order_service.dart';
import 'package:myapp/core/services/truckOwner_service.dart';
import 'package:myapp/screens/customer/orders/widgets/order_detail_screen.dart';
// import 'package:myapp/screens/customer/review/rate_truck_page.dart'; // Navigation handled by OrderDetailScreen

// --- Styles for Orders List Tab (Foodie Fleet Theme) ---
const Color ffListPrimaryColor = Colors.orange;
const Color ffListSurfaceColor = Colors.white;
const Color ffListChipSelectedColor = Colors.orange;
const Color ffListChipLabelSelectedColor = Colors.white;
const Color ffListChipLabelColor = Colors.black87;
const Color ffListBackgroundColor = Color(0xFFF8F9FA);
const Color ffListOnPrimaryColor = Colors.white;
const Color ffListOnSurfaceColor = Color(0xFF2D2D2D);
const Color ffListSecondaryTextColor = Color(0xFF6C757D);
const Color ffListDividerColor = Color(0xFFE0E0E0);

const double ffListPaddingMd = 16.0;
const double ffListPaddingSm = 8.0;
const double ffListPaddingXs = 4.0;
const double ffListBorderRadius = 12.0;
// --- End Styles ---

class OrdersListTab extends StatefulWidget {
  const OrdersListTab({super.key});

  @override
  State<OrdersListTab> createState() => _OrdersListTabState();
}

class _OrdersListTabState extends State<OrdersListTab> {
  List<dynamic> orders = [];
  List<dynamic> allTrucks = [];
  bool isLoading = true;
  String errorMessage = '';
  String selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    fetchOrdersAndTrucks();
  }

  Future<void> fetchOrdersAndTrucks() async {
    if (!mounted) return;
    setState(() { isLoading = true; errorMessage = ''; });
    try {
      final orderResponse = await OrderService.getMyOrders();
      final truckListResponse = await TruckOwnerService.getPublicTrucks();
      if (!mounted) return;
      List<dynamic> fetchedOrders = [];
      List<dynamic> fetchedTrucks = [];
      if (orderResponse.statusCode == 200) {
        final decoded = jsonDecode(orderResponse.body);
        fetchedOrders = (decoded is List) ? decoded : [];
      } else {
        errorMessage = "Failed to load orders (Err ${orderResponse.statusCode}). ";
      }
      fetchedTrucks = truckListResponse;
      setState(() {
        orders = fetchedOrders;
        allTrucks = fetchedTrucks;
        isLoading = false;
        if (fetchedOrders.isNotEmpty || fetchedTrucks.isNotEmpty) {
          if(errorMessage.startsWith("Error fetching data")){ errorMessage = ''; }
        }
      });
    } catch (e) {
      if (!mounted) return;
      errorMessage = "Error fetching data. Check connection.";
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String getTruckNameById(String truckId) {
    if (truckId.isEmpty) return 'Unknown Truck';
    final truck = allTrucks.firstWhere(
            (t) => t is Map<String, dynamic> && t['_id'] == truckId,
        orElse: () => null);
    return truck?['truck_name'] as String? ?? 'Unknown Truck';
  }

  String formatDateTime(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'Date N/A';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return DateFormat('MMM d, yyyy \'at\' hh:mm a').format(dt);
    } catch (e) { return 'Invalid Date'; }
  }

  List<dynamic> getFilteredOrders() {
    if (selectedStatus.toLowerCase() == 'all') return orders;
    return orders.where((o) {
      final status = o['status'] as String? ?? '';
      return status.toLowerCase() == selectedStatus.toLowerCase();
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Colors.green.shade700;
      case 'ready': return Colors.blue.shade700;
      case 'preparing': return Colors.orange.shade800;
      case 'pending': return Colors.amber.shade800;
      case 'cancelled': case 'rejected': return Colors.red.shade700;
      default: return ffListSecondaryTextColor;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Icons.check_circle_rounded;
      case 'ready': return Icons.restaurant_rounded;
      case 'preparing': return Icons.outdoor_grill_rounded;
      case 'pending': return Icons.hourglass_top_rounded;
      case 'cancelled': case 'rejected': return Icons.cancel_rounded;
      default: return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = getFilteredOrders();
    return Scaffold(
      backgroundColor: ffListBackgroundColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: ffListPrimaryColor))
          : errorMessage.isNotEmpty
          ? Center(child: Padding(padding: const EdgeInsets.all(ffListPaddingMd), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48), const SizedBox(height: ffListPaddingSm), Text(errorMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 16), textAlign: TextAlign.center), const SizedBox(height: ffListPaddingMd), ElevatedButton.icon(icon: const Icon(Icons.refresh_rounded, color: ffListOnPrimaryColor), label: const Text("Try Again", style: TextStyle(color: ffListOnPrimaryColor)), onPressed: fetchOrdersAndTrucks, style: ElevatedButton.styleFrom(backgroundColor: ffListPrimaryColor),)])))
          : Column(
        children: [
          _buildFilterChips(),
          const Divider(height: 1, color: ffListDividerColor, indent: ffListPaddingMd, endIndent: ffListPaddingMd),
          Expanded(
            child: filteredOrders.isEmpty
                ? Center(child: Padding(padding: const EdgeInsets.all(ffListPaddingMd), child: Text(selectedStatus == 'All' ? "You have no orders yet." : "No orders found for '$selectedStatus'.", style: const TextStyle(fontSize: 16, color: ffListSecondaryTextColor), textAlign: TextAlign.center,)))
                : RefreshIndicator(
              onRefresh: fetchOrdersAndTrucks, color: ffListPrimaryColor,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(ffListPaddingMd, ffListPaddingSm, ffListPaddingMd, ffListPaddingMd),
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = filteredOrders[index] as Map<String, dynamic>;
                  final truckName = getTruckNameById(order['truck_id'] as String? ?? '');
                  final status = order['status'] as String? ?? 'Unknown';
                  final total = (order['total_price'] as num?)?.toDouble() ?? 0.0;
                  final createdAt = formatDateTime(order['createdAt'] as String?);
                  final itemCount = (order['items'] as List<dynamic>? ?? []).length;

                  return Card(
                    margin: const EdgeInsets.only(bottom: ffListPaddingMd - 4),
                    elevation: 2.0, shadowColor: Colors.grey.withOpacity(0.25),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ffListBorderRadius)),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderDetailScreen(
                              order: order, // Pass the full order map
                              truckName: truckName,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(ffListBorderRadius),
                      child: Padding(
                        padding: const EdgeInsets.all(ffListPaddingMd - 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [ Expanded(child: Text(truckName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: ffListOnSurfaceColor), overflow: TextOverflow.ellipsis)), const SizedBox(width: ffListPaddingSm), Text("₪${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ffListPrimaryColor))]),
                            const SizedBox(height: ffListPaddingXs / 2),
                            Text("Order ID: ...${(order['_id'] as String? ?? 'N/A').characters.takeLast(6)}", style: const TextStyle(fontSize: 12, color: ffListSecondaryTextColor)),
                            const SizedBox(height: ffListPaddingXs),
                            Text("Placed: $createdAt", style: const TextStyle(fontSize: 12, color: ffListSecondaryTextColor)),
                            const SizedBox(height: ffListPaddingSm / 1.5),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Row(children: [ Icon(_getStatusIcon(status), color: _getStatusColor(status), size: 18), const SizedBox(width: ffListPaddingXs), Text(status.toUpperCase(), style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: _getStatusColor(status)))]), Text("$itemCount item${itemCount != 1 ? 's' : ''}", style: const TextStyle(fontSize: 13, color: ffListSecondaryTextColor))]),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final statuses = ['All', 'Pending', 'Preparing', 'Ready', 'Completed', 'Cancelled'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ffListPaddingMd / 2, vertical: ffListPaddingSm + 2),
      child: SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: statuses.map((status) {
            final isSelected = selectedStatus.toLowerCase() == status.toLowerCase();
            return Padding(
              padding: const EdgeInsets.only(right: ffListPaddingSm - 2),
              child: ChoiceChip(
                label: Text(status.toUpperCase(), style: const TextStyle(fontSize: 13)),
                selected: isSelected,
                selectedColor: ffListChipSelectedColor,
                backgroundColor: Theme.of(context).chipTheme.backgroundColor ?? Colors.grey.shade200,
                labelStyle: TextStyle(color: isSelected ? ffListChipLabelSelectedColor : (Theme.of(context).chipTheme.labelStyle?.color ?? ffListChipLabelColor), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                onSelected: (_) { if(mounted) setState(() { selectedStatus = status; }); },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? ffListChipSelectedColor : (Theme.of(context).chipTheme.shape as RoundedRectangleBorder?)?.side.color ?? Colors.grey.shade300)),
                padding: const EdgeInsets.symmetric(horizontal: ffListPaddingSm + 2, vertical: ffListPaddingSm / 2),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}