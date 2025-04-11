import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import 'package:myapp/screens/account/account.dart';
import 'package:myapp/screens/cart/cart.dart';
import 'package:myapp/constant/colors.dart';
import 'package:myapp/constant/images.dart';
import 'package:myapp/screens/home/widgets/bottom_nav_bar.dart';
import 'package:myapp/screens/login/widgets/card_more_widget.dart';
import 'package:myapp/screens/login/widgets/card_widget.dart';
import 'package:myapp/screens/login/widgets/home_page_custom_shape.dart';
import 'package:myapp/screens/login/widgets/likebutton/LikeButton.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

int _currentIndex = 0;

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late PageController _pageController;

  String _selectedLocation = "Istanbul, TR";
  bool selectedColor = true;
  Position? currentLocation;
  bool showMaps = false;

  final List<Marker> _mapMarkers = [];
  final List<String> _location = ["Newyork, NY", "Dubai", "Istanbul, TR"];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, keepPage: true);

    Geolocator.getCurrentPosition().then((position) {
      setState(() {
        currentLocation = position;
        showMaps = true;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  void _addMarker(LatLng position, String title, String snippet) {
    final marker = Marker(
      width: 40,
      height: 40,
      point: position,
      child: const Icon(
        Icons.location_on,
        color: Colors.orange,
        size: 36,
      ),
    );

    setState(() {
      _mapMarkers.add(marker);
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: buildFloatingActionButton(),
      bottomNavigationBar: HomeBottomNavBar(
        onTabSelected: _onTabTapped,
        currentIndex: _currentIndex, // ✅ FIXED!
      ),
      endDrawer: buildEndDrawer(),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          buildListViewPage(media),
          buildMapViewPage(media),
          Cart(),
          const Account(),
        ],
      ),
    );
  }

  Widget buildListViewPage(Size media) => Stack(
        children: [
          SizedBox(
            width: media.width,
            height: media.height,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  buildHeaderStack(media),
                  buildHomeMainContainer(),
                ],
              ),
            ),
          ),
        ],
      );

  Widget buildMapViewPage(Size media) => Stack(
        children: [
          SizedBox(
            width: media.width,
            height: media.height,
            child: showMaps
                ? FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(currentLocation!.latitude,
                          currentLocation!.longitude),
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.myapp',
                      ),
                      MarkerLayer(markers: _mapMarkers),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          Positioned(
            bottom: 0,
            child: SizedBox(
              height: 280,
              width: media.width,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  GestureDetector(
                    onTap: () {
                      _addMarker(
                        LatLng(41.087381, 28.788369),
                        "Cafe De Perks",
                        "Good food",
                      );
                    },
                    child: CardListWidget(
                      heartIcon: LikeButton(
                          key: const Key('like1'),
                          width: 70,
                          onIconClicked: (isLike) {}),
                      foodDetail: "Desert - Fast Food - Alcohol",
                      foodName: "Cafe De Perks",
                      vote: 4.5,
                      foodTime: "15-30 min",
                      image: AppImages.image1[0],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _addMarker(
                        LatLng(41.056120, 28.721480),
                        "Cafe De Istanbul",
                        "Great spot",
                      );
                    },
                    child: CardListWidget(
                      heartIcon: LikeButton(
                          key: const Key('like2'),
                          width: 70,
                          onIconClicked: (isLike) {}),
                      foodDetail: "Desert - Fast Food - Alcohol",
                      foodName: "Cafe De Istanbul",
                      vote: 4.5,
                      foodTime: "15-60 min",
                      image: AppImages.image1[1],
                    ),
                  ),
                ],
              ),
            ),
          ),
          buildHeaderStack(media),
        ],
      );

  Stack buildHeaderStack(Size media) {
    return Stack(
      children: [
        ClipPath(
          clipper: CustomShapeClipper(),
          child: Container(
            height: Platform.isIOS ? 200 : 150,
            width: media.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.orangeColor, AppColors.orangeLightColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Padding(
          padding: Platform.isAndroid
              ? const EdgeInsets.only(left: 20, top: 30, right: 10)
              : const EdgeInsets.only(left: 20, top: 50, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: Row(
                    children: [
                      Text(
                        _selectedLocation,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(FontAwesomeIcons.caretDown,
                          color: Colors.white, size: 12),
                    ],
                  ),
                  iconSize: 0,
                  items: _location.map((location) {
                    return DropdownMenuItem(
                      value: location,
                      child:
                          Text(location, style: const TextStyle(fontSize: 18)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLocation = value!;
                    });
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.tune, color: Colors.white),
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              )
            ],
          ),
        ),
        buildPositionedButtons(),
      ],
    );
  }

  Widget buildFloatingActionButton() {
    return GestureDetector(
      onTap: () {
        print("FAB tapped");
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 12),
        height: 55,
        width: 55,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.orangeColor,
              AppColors.orangeLightColor.withOpacity(0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: AppColors.orangeColor,
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(
          FontAwesomeIcons.solidStar,
          size: 26,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildHomeMainContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 22.0, bottom: 10),
          child: Text(
            "Featured Restaurants in $_selectedLocation",
            style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 18,
              fontFamily: "Poppins",
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            padding: const EdgeInsets.only(right: 20),
            scrollDirection: Axis.horizontal,
            itemCount: AppImages.image1.length,
            itemBuilder: (BuildContext context, int index) {
              return CardListWidget(
                heartIcon: LikeButton(
                  key: ObjectKey(index.toString()),
                  width: 70,
                  onIconClicked: (bool isLike) {},
                ),
                image: AppImages.image1[index],
                foodDetail: "Desert - Fast Food - Alcohol",
                foodName: "Cafe De Perks",
                vote: 4.5,
                foodTime: "15-30 min",
              );
            },
          ),
        ),
        Divider(
            height: 25, thickness: 1.5, color: AppColors.greyColor.shade300),
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 22.0, bottom: 10),
          child: Text(
            "More Restaurants in $_selectedLocation",
            style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 18,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        CardMoreWidget(
          image: AppImages.image1[1],
          foodDetail: "Desert - Fast Food - Alcohol",
          foodName: "Cafe De Ankara",
          vote: 4.5,
          foodTime: "15-30 min",
          status: "CLOSE",
          statusColor: Colors.pinkAccent,
          heartIcon: LikeButton(
              width: 70,
              key: const Key('like2'),
              onIconClicked: (bool isLike) {}),
        ),
        CardMoreWidget(
          heartIcon: LikeButton(
            width: 70,
            key: const Key('like2'),
            onIconClicked: (bool isLike) {},
          ),
          image: AppImages.image1[0],
          foodDetail: "Desert - Fast Food - Alcohol",
          foodName: "Cafe De NewYork",
          vote: 4.5,
          foodTime: "15-30 min",
          status: "OPEN",
          statusColor: Colors.green,
        ),
      ],
    );
  }

  Positioned buildPositionedButtons() {
    return Positioned(
      bottom: 10,
      left: 40,
      right: 40,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              blurRadius: 8,
              spreadRadius: 1,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                _pageController.jumpToPage(0);
                setState(() {
                  selectedColor = true;
                });
              },
              child: Text(
                "List View",
                style: TextStyle(
                  color: selectedColor
                      ? AppColors.orangeColor
                      : AppColors.greyColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  fontFamily: "Poppins",
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: VerticalDivider(color: Colors.black),
            ),
            GestureDetector(
              onTap: () {
                _pageController.jumpToPage(1);
                setState(() {
                  selectedColor = false;
                });
              },
              child: Text(
                "Map View",
                style: TextStyle(
                  color: selectedColor
                      ? AppColors.greyColor
                      : AppColors.orangeColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  fontFamily: "Poppins",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEndDrawer() {
    return Stack(
      children: [
        Theme(
          data: ThemeData(canvasColor: Colors.transparent),
          child: SizedBox(
            width: 80,
            height: 150,
            child: Drawer(
              elevation: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 75,
                    decoration: BoxDecoration(
                      color: AppColors.orangeColor,
                      borderRadius:
                          const BorderRadius.only(topLeft: Radius.circular(10)),
                    ),
                    child: const Icon(Icons.shopping_cart,
                        color: Colors.white, size: 32),
                  ),
                  Container(
                    height: 75,
                    decoration: BoxDecoration(
                      color: AppColors.orangeLightColor,
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10)),
                    ),
                    child: const Icon(Icons.contact_phone,
                        color: Colors.white, size: 32),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 42,
          top: -10,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 16),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }
}
