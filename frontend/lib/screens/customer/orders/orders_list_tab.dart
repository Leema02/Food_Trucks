import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/core/services/order_service.dart';
import 'package:myapp/core/services/truckOwner_service.dart';
import 'package:myapp/core/services/review_service.dart';
import 'package:myapp/screens/customer/review/rate_truck_page.dart';

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
  Set<int> expandedIndexes = {};

  @override
  void initState() {
    super.initState();
    fetchOrdersAndTrucks();
  }

  Future<void> fetchOrdersAndTrucks() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final orderResponse = await OrderService.getMyOrders();
      final truckList = await TruckOwnerService.getPublicTrucks();

      if (orderResponse.statusCode == 200) {
        setState(() {
          orders = jsonDecode(orderResponse.body);
          allTrucks = truckList;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              "Order Error: ${orderResponse.statusCode} ${orderResponse.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Connection Error: $e";
        isLoading = false;
      });
    }
  }

  String getTruckNameById(String truckId) {
    final truck = allTrucks.firstWhere(
      (t) => t['_id'] == truckId,
      orElse: () => null,
    );
    return truck?['truck_name'] ?? 'Unknown Truck';
  }

  String formatDateTime(String? isoDate) {
    if (isoDate == null) return '';
    final dt = DateTime.parse(isoDate).toLocal();
    final date = "${_monthName(dt.month)} ${dt.day}, ${dt.year}";
    final time =
        "${_formatHour(dt.hour)}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}";
    return "$date at $time";
  }

  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month - 1];
  }

  String _formatHour(int hour) {
    final h = hour % 12;
    return (h == 0 ? 12 : h).toString();
  }

  List<dynamic> getFilteredOrders() {
    if (selectedStatus == 'All') return orders;
    return orders
        .where((o) =>
            (o['status'] ?? '').toLowerCase() == selectedStatus.toLowerCase())
        .toList();
  }

  Future<bool> _isOrderAlreadyRated(
      String orderId, String truckId, List items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return false;

      final isTruckRated = await ReviewService.checkIfTruckRated(
        token: token,
        orderId: orderId,
        truckId: truckId,
      );

      for (final item in items) {
        final itemId = item['menu_id'] ?? item['item_id'] ?? '';
        final isItemRated = await ReviewService.checkIfMenuItemRated(
          token: token,
          orderId: orderId,
          itemId: itemId,
        );
        if (!isItemRated) return false;
      }

      return isTruckRated;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = getFilteredOrders();

    return isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.orange))
        : errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage))
            : Column(
                children: [
                  _buildFilterChips(),
                  const Divider(height: 1),
                  Expanded(
                    child: filteredOrders.isEmpty
                        ? const Center(child: Text("No matching orders found."))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredOrders.length,
                            itemBuilder: (context, index) {
                              final order = filteredOrders[index];
                              final isExpanded =
                                  expandedIndexes.contains(index);
                              final truckName =
                                  getTruckNameById(order['truck_id'] ?? '');
                              final orderType = order['order_type'] ?? 'pickup';
                              final status = order['status'] ?? 'unknown';
                              final total = order['total_price'] ?? 0.0;
                              final items =
                                  order['items'] as List<dynamic>? ?? [];
                              final createdAt =
                                  formatDateTime(order['createdAt']);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 14),
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      isExpanded
                                          ? expandedIndexes.remove(index)
                                          : expandedIndexes.add(index);
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Truck: $truckName",
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text("Ordered: $createdAt",
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey)),
                                        const SizedBox(height: 4),
                                        Text(
                                            "Type: ${orderType.toUpperCase()}"),
                                        const SizedBox(height: 4),
                                        Text("Status: ${status.toUpperCase()}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: status == 'completed'
                                                  ? Colors.green
                                                  : status == 'ready'
                                                      ? Colors.blue
                                                      : Colors.orange,
                                            )),
                                        const SizedBox(height: 4),
                                        Text(
                                            "Total: ₪${total.toStringAsFixed(2)}"),
                                        if (isExpanded && items.isNotEmpty) ...[
                                          const Divider(height: 20),
                                          const Text("Items:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 6),
                                          ...items.map((item) => Text(
                                              "- ${item['name']} × ${item['quantity']}")),
                                          const SizedBox(height: 12),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: FutureBuilder<bool>(
                                                future: _isOrderAlreadyRated(
                                                  order['_id'],
                                                  order['truck_id'],
                                                  items,
                                                ),
                                                builder: (context, snapshot) {
                                                  final alreadyRated =
                                                      snapshot.data ?? false;

                                                  // ✅ Only allow rating if order is COMPLETED
                                                  if ((order['status'] ?? '')
                                                          .toString()
                                                          .toLowerCase() !=
                                                      'completed') {
                                                    return const Text(
                                                      "Rating available after completion",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey),
                                                    );
                                                  }

                                                  return OutlinedButton.icon(
                                                    onPressed: alreadyRated
                                                        ? null
                                                        : () async {
                                                            final result =
                                                                await Navigator
                                                                    .push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (_) =>
                                                                    RateTruckPage(
                                                                  orderId: order[
                                                                      '_id'],
                                                                  truckId: order[
                                                                      'truck_id'],
                                                                  items: items,
                                                                ),
                                                              ),
                                                            );

                                                            if (result ==
                                                                true) {
                                                              fetchOrdersAndTrucks();
                                                            }
                                                          },
                                                    icon: Icon(alreadyRated
                                                        ? Icons.check_circle
                                                        : Icons.star_outline),
                                                    label: Text(alreadyRated
                                                        ? "Rated"
                                                        : "Rate"),
                                                  );
                                                }),
                                          ),
                                        ]
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
  }

  Widget _buildFilterChips() {
    final statuses = ['All', 'pending', 'preparing', 'ready', 'completed'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Wrap(
        spacing: 10,
        children: statuses.map((status) {
          final isSelected = selectedStatus == status;
          return ChoiceChip(
            label: Text(status.toUpperCase()),
            selected: isSelected,
            selectedColor: Colors.orange,
            onSelected: (_) {
              setState(() {
                selectedStatus = status;
              });
            },
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          );
        }).toList(),
      ),
    );
  }
}
