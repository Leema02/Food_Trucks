import 'dart:convert';
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/core/services/review_service.dart';
import 'package:myapp/screens/customer/review/rate_truck_page.dart';

// --- Import your new service ---
import 'package:myapp/core/services/estimate_service.dart';

// --- Enhanced Styles for Order Detail (Foodie Fleet Theme) ---
const Color ffDetailPrimaryColor = Color(0xFFFF6B00);
const Color ffDetailPrimaryLight = Color(0xFFFF9D4D);
const Color ffDetailPrimaryDark = Color(0xFFD95B00);
const Color ffDetailSurfaceColor = Colors.white;
const Color ffDetailBackgroundColor = Color(0xFFF8F9FA);
const Color ffDetailBackgroundColorr = Color(0xFFD9DCDE);

const Color ffDetailOnPrimaryColor = Colors.white;
const Color ffDetailOnSurfaceColor = Color(0xFF2D2D2D);
const Color ffDetailSecondaryTextColor = Color(0xFF6C757D);
const Color ffDetailDividerColor = Color(0xFFE0E0E0);
const Color ffDetailAccentColor = Color(0xFFFFD166);
const Color ffDetailSuccessColor = Color(0xFF4CAF50);
const Color ffDetailWarningColor = Color(0xFFFF9800);
const Color ffDetailErrorColor = Color(0xFFF44336);

const double ffDetailPaddingLg = 24.0;
const double ffDetailPaddingMd = 16.0;
const double ffDetailPaddingSm = 12.0;
const double ffDetailPaddingXs = 8.0;
const double ffDetailBorderRadius = 18.0;
const double ffDetailElevation = 6.0;

TextStyle ffDetailTitleStyle = const TextStyle(
  fontSize: 24.0,
  fontWeight: FontWeight.w800,
  color: ffDetailOnSurfaceColor,
  letterSpacing: -0.5,
);

TextStyle ffDetailSectionTitleStyle = const TextStyle(
  fontSize: 20.0,
  fontWeight: FontWeight.w700,
  color: ffDetailOnSurfaceColor,
);

TextStyle ffDetailLabelStyle = TextStyle(
  fontSize: 15.0,
  color: ffDetailSecondaryTextColor,
  fontWeight: FontWeight.w500,
);

TextStyle ffDetailValueStyle = const TextStyle(
  fontSize: 16.0,
  color: ffDetailOnSurfaceColor,
  fontWeight: FontWeight.w600,
);

TextStyle ffDetailItemNameStyle = const TextStyle(
  fontSize: 16.0,
  color: ffDetailOnSurfaceColor,
  fontWeight: FontWeight.w600,
);

TextStyle ffDetailItemDetailStyle = TextStyle(
  fontSize: 14.0,
  color: ffDetailSecondaryTextColor.withOpacity(0.8),
);

TextStyle ffDetailTimerMainStyle = const TextStyle(
  fontSize: 28.0,
  fontWeight: FontWeight.w800,
  color: ffDetailPrimaryColor,
);

TextStyle ffDetailTimerSubStyle = TextStyle(
  fontSize: 14.0,
  color: ffDetailSecondaryTextColor,
  fontWeight: FontWeight.w500,
);
// --- End Styles ---

class OrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  final String truckName;

  const OrderDetailScreen({
    super.key,
    required this.order,
    required this.truckName,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  // Timer State Variables
  bool _isLoadingTimeEstimate = false;
  int? _pendingTimeMinutes;
  int? _preparingTimeMinutes;
  DateTime? _timerStartTime;
  Duration? _currentTimerTotalDuration;
  Duration _remainingDuration = Duration.zero;
  bool _isFinishingUp = false;
  Timer? _timer;

  // Rating State Variables
  bool _alreadyRated = false;
  bool _checkingIfRated = true;

  @override
  void initState() {
    super.initState();
    final String status =
        (widget.order['status'] as String? ?? '').toLowerCase();

    // Fetch estimates for 'pending' or 'preparing' statuses
    if (status == 'preparing' || status == 'pending') {
      _fetchEstimateAndStartTimer();
    }

    if (status == 'completed') {
      _checkIfOrderRated();
    } else {
      _checkingIfRated = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Sets up the timer based on the current order status.
  void _setupTimerForCurrentStatus() {
    final status = (widget.order['status'] as String? ?? '').toLowerCase();

    if (status == 'pending' &&
        _pendingTimeMinutes != null &&
        _pendingTimeMinutes! > 0) {
      String startTimeStr = widget.order['createdAt'] as String;
      _timerStartTime =
          DateTime.tryParse(startTimeStr)?.toLocal() ?? DateTime.now();
      _currentTimerTotalDuration = Duration(minutes: _pendingTimeMinutes!);
      _startTimer();
    } else if (status == 'preparing' &&
        _preparingTimeMinutes != null &&
        _preparingTimeMinutes! > 0) {
      String startTimeStr =
          widget.order['updatedAt'] ?? widget.order['createdAt'];
      _timerStartTime =
          DateTime.tryParse(startTimeStr)?.toLocal() ?? DateTime.now();
      _currentTimerTotalDuration = Duration(minutes: _preparingTimeMinutes!);
      _startTimer();
    }
  }

  void _startTimer() {
    if (_currentTimerTotalDuration == null || _timerStartTime == null) return;

    final elapsedDuration = DateTime.now().difference(_timerStartTime!);
    final remaining = _currentTimerTotalDuration! - elapsedDuration;

    if (remaining.isNegative) {
      setState(() {
        _remainingDuration = Duration.zero;
        _isFinishingUp = true;
      });
      return;
    }

    setState(() {
      _remainingDuration = remaining;
      _isFinishingUp = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_remainingDuration.inSeconds > 0) {
          _remainingDuration = _remainingDuration - const Duration(seconds: 1);
        } else {
          _isFinishingUp = true;
          timer.cancel();
        }
      });
    });
  }

  /// Fetches estimate from the backend service and starts the appropriate timer.
  Future<void> _fetchEstimateAndStartTimer() async {
    if (!mounted) return;
    final String orderId = widget.order['_id'] as String? ?? '';
    if (orderId.isEmpty) return;

    setState(() => _isLoadingTimeEstimate = true);

    try {
      final estimateData = await EstimateService.getEstimate(orderId);
      if (!mounted) return;

      if (estimateData != null) {
        setState(() {
          _pendingTimeMinutes = (estimateData['partOne'] as num?)?.toInt();
          _preparingTimeMinutes = (estimateData['partTwo'] as num?)?.toInt();
        });
        _setupTimerForCurrentStatus();
      }
    } catch (e) {
      print("Error fetching estimate from service: $e");
    } finally {
      if (mounted) setState(() => _isLoadingTimeEstimate = false);
    }
  }

  String _formatDateTime(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return DateFormat('MMM d, yyyy \'at\' hh:mm a').format(dt);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return ffDetailSuccessColor;
      case 'ready':
        return Colors.blue.shade600;
      case 'preparing':
        return ffDetailWarningColor;
      case 'pending':
        return Colors.amber.shade700;
      case 'cancelled':
      case 'rejected':
        return ffDetailErrorColor;
      default:
        return ffDetailSecondaryTextColor;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle_rounded;
      case 'ready':
        return Icons.restaurant_menu_rounded;
      case 'preparing':
        return Icons.outdoor_grill_rounded;
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'cancelled':
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Future<void> _checkIfOrderRated() async {
    if (!mounted) return;
    setState(() => _checkingIfRated = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        if (mounted) setState(() => _alreadyRated = true);
        return;
      }
      final String orderId = widget.order['_id'] as String;
      final String truckId = widget.order['truck_id'] as String;
      final List items = widget.order['items'] as List<dynamic>? ?? [];

      final bool truckRated = await ReviewService.checkIfTruckRated(
          token: token, orderId: orderId, truckId: truckId);
      if (!truckRated) {
        if (mounted) setState(() => _alreadyRated = false);
        return;
      }
      for (final item in items) {
        if (item is Map<String, dynamic>) {
          final itemId =
              item['menu_id'] as String? ?? item['item_id'] as String? ?? '';
          if (itemId.isNotEmpty) {
            final bool itemRated = await ReviewService.checkIfMenuItemRated(
                token: token, orderId: orderId, itemId: itemId);
            if (!itemRated) {
              if (mounted) setState(() => _alreadyRated = false);
              return;
            }
          }
        }
      }
      if (mounted) setState(() => _alreadyRated = true);
    } catch (e) {
      print("Error checking rating status: $e");
      if (mounted) setState(() => _alreadyRated = true);
    } finally {
      if (mounted) setState(() => _checkingIfRated = false);
    }
  }

  Widget _buildOrderStatusStagesWidget(String currentStatusStr) {
    final stages = ['Pending', 'Preparing', 'Ready', 'Completed'];
    final currentStatus = currentStatusStr.toLowerCase();
    int currentIndex =
        stages.indexWhere((s) => s.toLowerCase() == currentStatus);

    if (currentIndex == -1 &&
        (currentStatus == 'cancelled' || currentStatus == 'rejected')) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: ffDetailPaddingSm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getStatusIcon(currentStatus)),
            const SizedBox(width: ffDetailPaddingXs),
            Text(
              currentStatusStr.toUpperCase(),
              style: TextStyle(
                color: _getStatusColor(currentStatus),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }
    if (currentIndex == -1) currentIndex = 0;

    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: ffDetailPaddingSm + 2, horizontal: ffDetailPaddingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ffDetailBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(stages.length, (index) {
          final bool isActive = index <= currentIndex;
          final bool isCurrent = index == currentIndex;
          final Color activeColor = ffDetailPrimaryColor;
          final Color inactiveColor = Colors.grey.shade300;
          final Color arrowColor = isActive ? activeColor : inactiveColor;

          return Row(
            children: [
              if (index > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8)
                      .copyWith(bottom: 19),
                  child: Icon(
                    Icons.arrow_forward,
                    color: arrowColor,
                    size: 25,
                  ),
                ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? activeColor : Colors.white,
                      border: Border.all(
                        color: isActive ? activeColor : inactiveColor,
                        width: 2,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: activeColor.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Icon(
                        isCurrent
                            ? _getStatusIcon(stages[index])
                            : (isActive
                                ? Icons.check_rounded
                                : Icons.circle_outlined),
                        color: isActive ? Colors.white : inactiveColor,
                        size: isCurrent ? 18 : 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: ffDetailPaddingXs),
                  Text(
                    stages[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent
                          ? activeColor
                          : (isActive
                              ? ffDetailOnSurfaceColor
                              : ffDetailSecondaryTextColor),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTimerProgressWidget() {
    final status = (widget.order['status'] as String? ?? '').toLowerCase();

    if (_isLoadingTimeEstimate && _currentTimerTotalDuration == null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: ffDetailPaddingMd),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ffDetailBorderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: ffDetailPrimaryColor),
            ),
            const SizedBox(width: ffDetailPaddingSm),
            Text(
              "Getting estimated time...",
              style: TextStyle(
                  fontSize: 14,
                  color: ffDetailSecondaryTextColor,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
      );
    }

    // Only show if we have a valid timer running for the current state.
    final hasValidTimer = (status == 'pending' &&
            _pendingTimeMinutes != null &&
            _pendingTimeMinutes! > 0) ||
        (status == 'preparing' &&
            _preparingTimeMinutes != null &&
            _preparingTimeMinutes! > 0);
    if (!hasValidTimer ||
        _timerStartTime == null ||
        _currentTimerTotalDuration == null) {
      return const SizedBox.shrink();
    }

    final progress = _isFinishingUp
        ? 1.0
        : 1.0 -
            (_remainingDuration.inSeconds /
                _currentTimerTotalDuration!.inSeconds);

    // Dynamic UI elements based on status
    final String titleText =
        status == 'pending' ? "AWAITING CONFIRMATION" : "PREPARATION STATUS";
    final String subtitleText = _isFinishingUp
        ? "Should be ready soon!"
        : (status == 'pending'
            ? "Estimated time until accepted"
            : "Estimated time remaining");
    final DateTime estimatedFinishTime =
        _timerStartTime!.add(_currentTimerTotalDuration!);

    return Container(
      margin: const EdgeInsets.only(bottom: ffDetailPaddingMd),
      padding: const EdgeInsets.all(ffDetailPaddingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ffDetailBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            titleText,
            style: ffDetailLabelStyle.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: ffDetailPaddingSm),
          SizedBox(
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 240,
                  height: 100,
                  child: CustomPaint(
                    painter: SemiCircleProgressPainter(
                      progress: 1.0,
                      backgroundColor: ffDetailBackgroundColorr,
                      progressColor: Colors.transparent,
                      strokeWidth: 12,
                    ),
                  ),
                ),
                SizedBox(
                  width: 240,
                  height: 100,
                  child: CustomPaint(
                    painter: SemiCircleProgressPainter(
                      progress: progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.transparent,
                      progressColor: ffDetailPrimaryColor,
                      strokeWidth: 12,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _isFinishingUp
                        ? Text(
                            "FINISHING UP!",
                            style: ffDetailTimerMainStyle.copyWith(
                              fontSize: 22,
                              color: ffDetailSuccessColor,
                            ),
                          )
                        : Text(
                            "${_remainingDuration.inMinutes.remainder(60)}:${(_remainingDuration.inSeconds.remainder(60)).toString().padLeft(2, '0')}",
                            style: ffDetailTimerMainStyle.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                  color: ffDetailPrimaryColor.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                    const SizedBox(height: 8),
                    Text(
                      subtitleText,
                      style: ffDetailTimerSubStyle,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: ffDetailPaddingMd),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: ffDetailBackgroundColor,
              color: ffDetailPrimaryColor,
            ),
          ),
          const SizedBox(height: ffDetailPaddingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Started: ${DateFormat('h:mm a').format(_timerStartTime!)}",
                style: ffDetailLabelStyle.copyWith(fontSize: 12),
              ),
              Text(
                "Estimated: ${DateFormat('h:mm a').format(estimatedFinishTime)}",
                style: ffDetailLabelStyle.copyWith(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSectionWidget(BuildContext context) {
    final String status =
        (widget.order['status'] as String? ?? '').toLowerCase();
    if (status != 'completed') return const SizedBox.shrink();

    if (_checkingIfRated) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: ffDetailPaddingMd),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ffDetailBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: ffDetailPrimaryColor,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(ffDetailPaddingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ffDetailBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ffDetailPrimaryLight.withOpacity(0.1),
            ffDetailAccentColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: ffDetailAccentColor,
                size: 28,
              ),
              const SizedBox(width: ffDetailPaddingSm),
              Text(
                "Enjoyed Your Meal?",
                style: ffDetailSectionTitleStyle.copyWith(
                  color: ffDetailOnSurfaceColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: ffDetailPaddingSm),
          Text(
            _alreadyRated
                ? "Thank you for your feedback! Your review helps others discover great food."
                : "Share your experience to help other foodies and support our vendors!",
            style: ffDetailLabelStyle.copyWith(fontSize: 14),
          ),
          const SizedBox(height: ffDetailPaddingMd),
          ElevatedButton(
            onPressed: _alreadyRated
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Viewing review feature coming soon!"),
                      ),
                    );
                  }
                : () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RateTruckPage(
                          orderId: widget.order['_id'] as String,
                          truckId: widget.order['truck_id'] as String,
                          items: widget.order['items'] as List<dynamic>? ?? [],
                        ),
                      ),
                    );
                    if (result == true && mounted) {
                      _checkIfOrderRated();
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: _alreadyRated
                  ? ffDetailSecondaryTextColor.withOpacity(0.7)
                  : ffDetailPrimaryColor,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(vertical: ffDetailPaddingSm + 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ffDetailBorderRadius),
              ),
              elevation: 2,
              shadowColor: ffDetailPrimaryColor.withOpacity(0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _alreadyRated
                      ? Icons.rate_review_rounded
                      : Icons.star_rounded,
                  size: 20,
                ),
                const SizedBox(width: ffDetailPaddingXs),
                Text(
                  _alreadyRated ? "View Your Review" : "Rate This Order",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String orderIdShort = (widget.order['_id'] as String? ?? 'N/A')
        .characters
        .takeLast(8)
        .toString()
        .toUpperCase();
    final String orderType =
        (widget.order['order_type'] as String?)?.toUpperCase() ?? 'N/A';
    final String status = widget.order['status'] as String? ?? 'UNKNOWN';
    final double total =
        (widget.order['total_price'] as num?)?.toDouble() ?? 0.0;
    final List<dynamic> items = widget.order['items'] as List<dynamic>? ?? [];
    final String createdAt =
        _formatDateTime(widget.order['createdAt'] as String?);
    final String currentStatus = status.toLowerCase();

    return Scaffold(
      backgroundColor: ffDetailBackgroundColor,
      appBar: AppBar(
        title: Text('Order #$orderIdShort',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: ffDetailPrimaryColor,
        foregroundColor: ffDetailOnPrimaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(ffDetailBorderRadius),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ffDetailPaddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderStatusStagesWidget(status),
            const SizedBox(height: ffDetailPaddingMd),
            if (currentStatus == 'pending' || currentStatus == 'preparing')
              _buildTimerProgressWidget(),
            Container(
              padding: const EdgeInsets.all(ffDetailPaddingMd),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(ffDetailBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: ffDetailPrimaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.restaurant_rounded,
                          color: ffDetailPrimaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: ffDetailPaddingSm),
                      Text(
                        widget.truckName,
                        style: ffDetailTitleStyle.copyWith(
                          fontSize: 20,
                          color: ffDetailOnSurfaceColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ffDetailPaddingMd),
                  _buildDetailRow("Order ID:", orderIdShort),
                  _buildDetailRow("Date Placed:", createdAt),
                  _buildDetailRow("Order Type:", orderType),
                  const SizedBox(height: ffDetailPaddingSm),
                  Row(
                    children: [
                      Text("Status:", style: ffDetailLabelStyle),
                      const SizedBox(width: ffDetailPaddingXs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ffDetailPaddingSm,
                          vertical: ffDetailPaddingXs / 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getStatusIcon(status),
                              color: _getStatusColor(status),
                              size: 16,
                            ),
                            const SizedBox(width: ffDetailPaddingXs / 2),
                            Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: _getStatusColor(status),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ffDetailPaddingMd),
                  const Divider(height: 1, color: ffDetailDividerColor),
                  const SizedBox(height: ffDetailPaddingMd),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order Total:",
                        style: ffDetailLabelStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "₪${total.toStringAsFixed(2)}",
                        style: ffDetailValueStyle.copyWith(
                          fontSize: 20,
                          color: ffDetailPrimaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: ffDetailPaddingMd),
            if (items.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(
                    left: ffDetailPaddingXs, bottom: ffDetailPaddingSm),
                child: Text(
                  "ITEMS ORDERED (${items.length})",
                  style: ffDetailSectionTitleStyle.copyWith(fontSize: 18),
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: ffDetailPaddingSm),
                itemBuilder: (context, index) {
                  final item = items[index] as Map<String, dynamic>;
                  final String itemName = item['name'] ?? 'Unknown Item';
                  final int quantity = (item['quantity'] as num?)?.toInt() ?? 0;
                  final double price =
                      (item['price'] as num?)?.toDouble() ?? 0.0;
                  final String? itemImageUrl = item['image_url'] as String?;

                  return Container(
                    padding: const EdgeInsets.all(ffDetailPaddingSm),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(ffDetailBorderRadius - 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (itemImageUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: itemImageUrl.startsWith('http')
                                  ? itemImageUrl
                                  : 'http://10.0.2.2:5000$itemImageUrl',
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              placeholder: (ctx, url) => Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Icon(Icons.image_outlined,
                                      color: Colors.grey),
                                ),
                              ),
                              errorWidget: (ctx, url, err) => Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey.shade100,
                                child: const Center(
                                  child: Icon(Icons.broken_image_outlined,
                                      color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        if (itemImageUrl != null)
                          const SizedBox(width: ffDetailPaddingSm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(itemName, style: ffDetailItemNameStyle),
                              const SizedBox(height: ffDetailPaddingXs / 2),
                              Row(
                                children: [
                                  Text(
                                    "Qty: $quantity",
                                    style: ffDetailItemDetailStyle.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: ffDetailPaddingSm),
                                  Text(
                                    "₪${price.toStringAsFixed(2)} each",
                                    style: ffDetailItemDetailStyle,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "₪${(price * quantity).toStringAsFixed(2)}",
                          style: ffDetailValueStyle.copyWith(
                            fontSize: 16,
                            color: ffDetailOnSurfaceColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: ffDetailPaddingMd),
            ],
            _buildReviewSectionWidget(context),
            const SizedBox(height: ffDetailPaddingLg),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ffDetailPaddingXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: ffDetailLabelStyle,
            ),
          ),
          const SizedBox(width: ffDetailPaddingXs),
          Expanded(
            child: Text(
              value,
              style: ffDetailValueStyle,
            ),
          ),
        ],
      ),
    );
  }
}

class SemiCircleProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  SemiCircleProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    this.strokeWidth = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - strokeWidth / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      backgroundPaint,
    );

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant SemiCircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class _ArrowPainter extends CustomPainter {
  final Color color;
  final bool isActive;

  _ArrowPainter({required this.color, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = isActive ? 2.5 : 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final centerY = size.height / 2;
    final segmentWidth = size.width / 8;

    for (var i = 0; i < 6; i++) {
      final xStart = i * segmentWidth;
      final xEnd = xStart + segmentWidth * 0.8;

      if (xEnd < size.width - 15) {
        path.moveTo(xStart, centerY);
        path.lineTo(xEnd, centerY);
      }
    }

    path.moveTo(size.width - 15, centerY);
    path.lineTo(size.width - 5, centerY);
    path.lineTo(size.width - 10, centerY - 7);
    path.moveTo(size.width - 5, centerY);
    path.lineTo(size.width - 10, centerY + 7);

    path.moveTo(2, centerY - 3);
    path.lineTo(0, centerY);
    path.lineTo(2, centerY + 3);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
