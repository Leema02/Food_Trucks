import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:myapp/core/constants/colors.dart';
import 'package:myapp/screens/auth/login/widgets/card_more_shape.dart';

class CardMoreWidget extends StatefulWidget {
  final String image;
  final String foodName;
  final String foodDetail;
  final String foodTime;
  final String status;
  final Color statusColor;
  final double vote;
  final Widget heartIcon;

  const CardMoreWidget({
    super.key,
    required this.image,
    required this.foodDetail,
    required this.foodName,
    required this.vote,
    required this.foodTime,
    required this.status,
    required this.heartIcon,
    required this.statusColor,
  });

  @override
  State<CardMoreWidget> createState() => CardMoreWidgetState();
}

class CardMoreWidgetState extends State<CardMoreWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: Material(
        elevation: 4,
        shadowColor: Colors.white54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      child: CachedNetworkImage(
                        imageUrl: widget.image,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        height: 45,
                        width: 45,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.lightGreen,
                        ),
                        child: widget.heartIcon,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      child: Container(
                        padding: const EdgeInsets.only(left: 10),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black87],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Expanded(
                              flex: 4,
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    height: 18,
                                    width: 35,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.lightGreen,
                                    ),
                                    child: Center(
                                      child: Text(
                                        widget.vote.toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  ...List.generate(
                                    5,
                                    (index) => Icon(
                                      Icons.star,
                                      size: 16,
                                      color: index < 4
                                          ? Colors.yellow
                                          : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    "(11)",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  const Icon(
                                    FontAwesomeIcons.clock,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.foodTime,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: "Poppins",
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      child: ClipPath(
                        clipper: CardMoreClipper(),
                        child: Container(
                          padding: const EdgeInsets.only(top: 5, left: 12),
                          decoration: BoxDecoration(
                            color: widget.statusColor,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10)),
                          ),
                          height: 60,
                          width: 60,
                          child: Transform.rotate(
                            angle: pi * 1.75,
                            child: Text(
                              widget.status,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "KoHo"),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.foodName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.foodDetail,
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: "Poppins",
                                color: AppColors.greyColor,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        FontAwesomeIcons.dollarSign,
                        size: 12,
                        color: AppColors.orangeColor,
                      ),
                      Icon(
                        FontAwesomeIcons.dollarSign,
                        size: 12,
                        color: AppColors.orangeColor,
                      ),
                      Icon(
                        FontAwesomeIcons.dollarSign,
                        size: 12,
                        color: AppColors.greyColor,
                      ),
                      Icon(
                        FontAwesomeIcons.dollarSign,
                        size: 12,
                        color: AppColors.greyColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
