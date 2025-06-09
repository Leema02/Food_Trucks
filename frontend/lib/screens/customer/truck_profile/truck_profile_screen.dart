import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:latlong2/latlong.dart';
import 'package:myapp/screens/customer/truck_profile/map_route_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:myapp/core/services/menu_service.dart';
import 'package:myapp/screens/customer/menu/menu_card.dart';
import '../explore/event_booking/truck_booking_screen.dart';


const Color ffPrimaryColor = Color(0xFFFF6B35);
const Color ffPrimaryDark = Color(0xFFE55A2A);
const Color ffSurfaceColor = Color(0xFFFFFFFF);
const Color ffBackgroundColor = Color(0xFFFFFFFF);
const Color ffOnPrimaryColor = Color(0xFFFFFFFF);
const Color ffOnSurfaceColor = Color(0xFF2D2D2D);
const Color ffSecondaryTextColor = Color(0xFF6C757D);
const Color ffAccentColor = Color(0xFFFFD166);
const Color ffSuccessColor = Color(0xFF4CAF50);

const double ffPaddingMd = 20.0;
const double ffPaddingSm = 12.0;
const double ffPaddingXs = 8.0;
const double ffPaddingLg = 28.0;
const double ffBorderRadius = 24.0;
const double ffProfileImageHeight = 280.0;
const double ffIconSize = 24.0;

TextStyle ffTitleStyle = const TextStyle(
  fontSize: 28.0,
  fontWeight: FontWeight.w800,
  color: ffOnSurfaceColor,
  letterSpacing: -0.5,
);

TextStyle ffSectionTitleStyle = const TextStyle(
  fontSize: 22.0,
  fontWeight: FontWeight.w700,
  color: ffOnSurfaceColor,
);

TextStyle ffBodyStyle = const TextStyle(
  fontSize: 16.0,
  fontWeight: FontWeight.w500,
  color: ffSecondaryTextColor,
  height: 1.5,
);

TextStyle ffInfoStyle = const TextStyle(
  fontSize: 16.0,
  fontWeight: FontWeight.w600,
  color: ffOnSurfaceColor,
);

class TruckProfileScreen extends StatefulWidget {
  final String truckId;
  final double? initialAverageRating;
  final int initialReviewCount;

  const TruckProfileScreen({
    super.key,
    required this.truckId,
    this.initialAverageRating,
    required this.initialReviewCount,
  });

  @override
  State<TruckProfileScreen> createState() => _TruckProfileScreenState();
}

class _TruckProfileScreenState extends State<TruckProfileScreen> {
  Map<String, dynamic>? _truckData;
  List<dynamic> _menuItems = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isFavorite = false;
  double? _displayAverageRating;
  int _displayReviewCount = 0;

  Future<void> _openRouteInMap() async {
    if (_truckData == null) return;

    final location = _truckData!['location'];
    if (location == null ||
        location['latitude'] == null ||
        location['longitude'] == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Truck location is not available.')),
        );
      }
      return;
    }

    final double latitude = location['latitude'];
    final double longitude = location['longitude'];
    final String truckName = _truckData!['truck_name'] ?? 'The Truck';

    final truckPosition = LatLng(latitude, longitude);

    // Navigate to the new map screen
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MapRouteScreen(truckPosition: truckPosition, truckName: truckName),

        ),
      );
    }
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _displayAverageRating = widget.initialAverageRating;
    _displayReviewCount = widget.initialReviewCount;
    _fetchTruckAndMenuDetails();
    _loadFavoriteStatus();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildStatusPill({required bool isOpen}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isOpen ? ffSuccessColor.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOpen ? ffSuccessColor : Colors.red.shade400,
          width: 1.5,
        ),
      ),
      child: Text(
        isOpen ? "Open" : "Closed",
        style: TextStyle(
          color: isOpen ? ffSuccessColor : Colors.red.shade700,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _getTruckStatus(String? openTimeStr, String? closeTimeStr) {
    if (openTimeStr == null || closeTimeStr == null) {
      return const SizedBox.shrink();
    }
    try {
      final now = DateTime.now();
      final openTime = DateFormat("hh:mm a").parse(openTimeStr);
      final closeTime = DateFormat("hh:mm a").parse(closeTimeStr);

      final todayOpen = DateTime(now.year, now.month, now.day, openTime.hour, openTime.minute);
      final todayClose = DateTime(now.year, now.month, now.day, closeTime.hour, closeTime.minute);

      final bool isOpen = now.isAfter(todayOpen) && now.isBefore(todayClose);

      return _buildStatusPill(isOpen: isOpen);
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Future<void> _loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _isFavorite = prefs.getBool('fav_${widget.truckId}') ?? false;
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _isFavorite = !_isFavorite;
      prefs.setBool('fav_${widget.truckId}', _isFavorite);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _isFavorite ? ffSuccessColor : ffSecondaryTextColor,
        content: Text(
          _isFavorite ? 'Added to favorites!' : 'Removed from favorites',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _fetchTruckAndMenuDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final String truckUrl = 'http://10.0.2.2:5000/api/trucks/${widget.truckId}';
      final truckResponse = await http.get(Uri.parse(truckUrl), headers: {
        'Authorization': 'Bearer $token'
      }).timeout(const Duration(seconds: 15));

      if (!mounted) return;
      if (truckResponse.statusCode == 200) {
        _truckData = jsonDecode(truckResponse.body) as Map<String, dynamic>;

        final menuResponse = await MenuService.getMenuItems(widget.truckId);
        if (!mounted) return;
        if (menuResponse.statusCode == 200) {
          _menuItems = jsonDecode(menuResponse.body) as List<dynamic>? ?? [];
        } else {
          _errorMessage += 'Could not load menu. ';
        }
      } else {
        _errorMessage += 'Failed to load truck details. ';
      }
    } catch (e) {
      _errorMessage += 'An error occurred.';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Helper widget for the compact info items (Address, Hours, Rating)
  Widget _buildCompactInfoItem(IconData icon, {required Widget content}) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: ffPrimaryColor, size: ffIconSize + 4),
          const SizedBox(height: ffPaddingXs),
          DefaultTextStyle(
            style: ffInfoStyle.copyWith(fontSize: 14.5, height: 1.3),
            textAlign: TextAlign.center,
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: ffBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: ffPrimaryColor, size: 20),
            const SizedBox(width: 6),
            Text(label, style: ffInfoStyle.copyWith(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: ffBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: ffPrimaryColor),
              const SizedBox(height: ffPaddingMd),
              Text("Loading delicious details...", style: ffBodyStyle),
            ],
          ),
        ),
      );
    }

    if (_truckData == null) {
      return Scaffold(
        backgroundColor: ffBackgroundColor,
        appBar: AppBar(
          title: Text(_errorMessage.contains("truck details") ? "Error Loading Truck" : "Truck Not Found"),
          backgroundColor: ffSurfaceColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ffOnSurfaceColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(ffPaddingMd),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded, size: 64, color: Colors.red.shade300),
                const SizedBox(height: ffPaddingMd),
                Text("Oops! Something went wrong", style: ffTitleStyle.copyWith(fontSize: 24), textAlign: TextAlign.center),
                const SizedBox(height: ffPaddingSm),
                Text(
                  _errorMessage.isNotEmpty ? _errorMessage : "Could not load truck details. Please check your connection and try again.",
                  style: ffBodyStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ffPaddingLg),
                ElevatedButton(
                  onPressed: _fetchTruckAndMenuDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ffPrimaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text("Try Again", style: ffBodyStyle.copyWith(color: ffOnPrimaryColor)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final truck = _truckData!;
    final String? imagePath = truck['logo_image_url'] as String?;
    final String imageUrl = imagePath != null
        ? (imagePath.startsWith('http') ? imagePath : 'http://10.0.2.2:5000$imagePath')
        : 'https://via.placeholder.com/800x400.png?text=${Uri.encodeComponent(truck['truck_name'] ?? 'Truck')}';

    final Widget infoCard = Container(
      padding: const EdgeInsets.all(ffPaddingMd),
      decoration: BoxDecoration(
        color: ffSurfaceColor,
        borderRadius: BorderRadius.circular(ffBorderRadius),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.08),
        //     blurRadius: 20,
        //     offset: const Offset(0, 4),
        //   )
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(truck['truck_name'] ?? 'Truck Name', style: ffTitleStyle),),
              const SizedBox(height: ffPaddingXs / 2),
              _getTruckStatus(
                truck['operating_hours']?['open'],
                truck['operating_hours']?['close'],
              ),
            ],
          ),
          const SizedBox(height: ffPaddingXs / 2),


          Row(
            children: [
              Icon(Icons.location_city_rounded, color: ffSecondaryTextColor, size: 18),
              const SizedBox(width: ffPaddingXs),
              Text(truck['city'] ?? 'N/A', style: ffBodyStyle.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: ffPaddingSm),
            child: Divider(color: Colors.grey.shade200),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCompactInfoItem(Icons.place_rounded, content: Text(truck['location']?['address_string'] ?? 'Not specified')),
              _buildCompactInfoItem(Icons.access_time_filled_rounded, content: Text('${truck['operating_hours']?['open'] ?? '--'} - ${truck['operating_hours']?['close'] ?? '--'}')),
              _buildCompactInfoItem(
                Icons.star_rounded,
                content: (_displayReviewCount > 0 && _displayAverageRating != null)
                    ? Column(
                  children: [
                    Text('${_displayAverageRating!.toStringAsFixed(1)} / 5.0', style: ffInfoStyle.copyWith(fontSize: 14.5)),
                    Text('($_displayReviewCount Reviews)', style: ffBodyStyle.copyWith(fontSize: 12, height: 1.2)),
                  ],
                ) : Text('No Reviews', style: ffBodyStyle.copyWith(fontSize: 14.5)),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: ffPaddingSm),
            child: Divider(color: Colors.grey.shade200),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                backgroundColor: ffPrimaryColor.withOpacity(0.1),
                label: Text(truck['cuisine_type'] ?? 'Cuisine', style: ffInfoStyle.copyWith(color: ffPrimaryDark, fontSize: 14)),
                padding: const EdgeInsets.symmetric(horizontal: ffPaddingSm, vertical: ffPaddingXs),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              Row(
                children: [
                  _buildActionButton(Icons.directions_car_filled_rounded, "Route", _openRouteInMap),
                  const SizedBox(width: ffPaddingXs),
                  _buildActionButton(Icons.share_location_rounded, "Share", () {}),
                ],
              )
            ],
          ),
        ],
      ),
    );

    const cardOverlap = 50.0;
    const fixedCardHeight = 240.0;
    final cardTopPosition = ffProfileImageHeight - cardOverlap;
    double scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0;

    return Scaffold(
      backgroundColor: ffBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: ffProfileImageHeight,
                pinned: false,
                backgroundColor: ffSurfaceColor,
                elevation: scrollOffset > (cardTopPosition - kToolbarHeight) ? 2.0 : 0.0,
                leading: Padding(
                  padding: const EdgeInsets.all(ffPaddingXs),
                  child: CircleAvatar(
                    backgroundColor: ffSurfaceColor.withOpacity( scrollOffset > (cardTopPosition - kToolbarHeight) ? 0.0 : 0.7),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      color: scrollOffset > (cardTopPosition - kToolbarHeight) ? ffPrimaryColor : ffOnSurfaceColor,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(ffPaddingXs),
                    child: CircleAvatar(
                      backgroundColor: ffSurfaceColor.withOpacity(scrollOffset > (cardTopPosition - kToolbarHeight) ? 0.0 : 0.7),
                      child: IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: _isFavorite ? Colors.redAccent : (scrollOffset > (cardTopPosition - kToolbarHeight) ? ffPrimaryColor : ffOnSurfaceColor),
                        ),
                        onPressed: _toggleFavorite,
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  centerTitle: true,
                  titlePadding: const EdgeInsets.symmetric(horizontal: 50, vertical: ffPaddingSm + 2),
                  title: scrollOffset > (cardTopPosition - kToolbarHeight)
                      ? Text(
                    truck['truck_name'] ?? 'Truck Profile',
                    style: const TextStyle(color: ffPrimaryColor, fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                  )
                      : null,
                  background: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey.shade200, child: const Center(child: CircularProgressIndicator(color: ffPrimaryColor))),
                    errorWidget: (context, url, error) => Container(color: Colors.grey.shade200, child: const Icon(Icons.food_bank_rounded, size: 80, color: Colors.grey)),
                  ),
                ),
              ),

              // **FIX**: This placeholder now reserves the exact vertical space
              // needed for the part of the card that appears *below* the image.
              SliverToBoxAdapter(
                child: SizedBox(
                  height: fixedCardHeight - cardOverlap,
                ),
              ),

              // **FIX**: This section is now its own Sliver, with its own
              // padding, which restores the space between the card area and the "About Us" title.
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(ffPaddingMd, ffPaddingLg, ffPaddingMd, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (truck['description'] != null && (truck['description'] as String).isNotEmpty) ...[
                        const SizedBox(height: 30.0),

                        Text("About Us", style: ffSectionTitleStyle),
                        const SizedBox(height: ffPaddingSm),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(ffPaddingMd),
                          decoration: BoxDecoration(color: ffSurfaceColor, borderRadius: BorderRadius.circular(ffBorderRadius - ffPaddingXs)),
                          child: Text(truck['description'], style: ffBodyStyle),
                        ),
                        const SizedBox(height: ffPaddingLg - ffPaddingXs),
                      ],
                      Row(
                        children: [
                          Text("Our Menu", style: ffSectionTitleStyle),
                          const SizedBox(width: ffPaddingXs),
                          if (_menuItems.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: ffPrimaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                              child: Text("${_menuItems.length} items", style: ffBodyStyle.copyWith(color: ffPrimaryDark, fontWeight: FontWeight.w600, fontSize: 13)),
                            ),
                        ],
                      ),
                      const SizedBox(height: ffPaddingSm),
                    ],
                  ),
                ),
              ),

              if (_menuItems.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(ffPaddingMd, 0, ffPaddingMd, ffPaddingMd),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: ffPaddingMd),
                          child: MenuCard(item: _menuItems[index], truckId: widget.truckId, truckCity: truck['city'] ?? 'N/A'),
                        );
                      },
                      childCount: _menuItems.length,
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: ffPaddingLg, horizontal: ffPaddingMd),
                    child: Column(
                      children: [
                        const SizedBox(height: ffPaddingMd),
                        Icon(Icons.menu_book_rounded, size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: ffPaddingSm),
                        Text(
                          _errorMessage.contains('menu') && _menuItems.isEmpty ? "Could not load menu at this time." : "Menu coming soon!",
                          style: ffBodyStyle.copyWith(fontSize: 18, color: ffSecondaryTextColor),
                          textAlign: TextAlign.center,
                        ),
                        if (!_errorMessage.contains('menu') && _menuItems.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: ffPaddingXs),
                            child: Text("Check back later for delicious updates.", style: ffBodyStyle.copyWith(fontSize: 14, color: Colors.grey.shade500), textAlign: TextAlign.center),
                          ),
                      ],
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: ffPaddingLg * 2.5)),
            ],
          ),

          AnimatedBuilder(
            animation: _scrollController,
            builder: (context, child) {
              double top = cardTopPosition;
              if (_scrollController.hasClients && _scrollController.offset > 0) {
                top -= _scrollController.offset;
              }
              // **FIX**: The check that made the card "stick" at the top has been removed.
              // Now it will continue scrolling up past 0 into negative values,
              // moving it off-screen.

              return Positioned(
                top: top,
                left: ffPaddingMd,
                right: ffPaddingMd,
                child: child!,
              );
            },
            child: infoCard,
          ),

          if (_truckData != null)
            Positioned(
              bottom: ffPaddingMd,
              left: ffPaddingMd,
              right: ffPaddingMd,
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => TruckBookingScreen(truck: truck)));
                },
                backgroundColor: ffPrimaryDark,
                foregroundColor: ffOnPrimaryColor,
                icon: const Icon(Icons.calendar_month_rounded),
                label: const Text("Book Event", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
        ],
      ),
    );
  }
}