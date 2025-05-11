import 'package:flutter/material.dart';
import 'package:myapp/screens/auth/widgets/card_more_widget.dart';
import 'package:myapp/screens/auth/widgets/card_widget.dart';
import 'package:myapp/core/constants/colors.dart';
import 'package:myapp/core/constants/images.dart';
import 'package:myapp/screens/auth/widgets/likebutton/LikeButton.dart';

class HomeMainContainer extends StatelessWidget {
  final String selectedLocation;

  const HomeMainContainer({Key? key, required this.selectedLocation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 10),

        // ✨ Top Title — show the selected location
        Padding(
          padding: const EdgeInsets.only(left: 22.0, bottom: 10),
          child: Text(
            "Featured Restaurants in $selectedLocation",
            style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 18,
              fontFamily: "Poppins",
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // 🥘 Restaurant Cards (horizontal ListView)
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

        // ➖ Divider
        Divider(
          height: 25,
          thickness: 1.5,
          color: AppColors.greyColor.shade300,
        ),

        // 🍴 More Restaurants title
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 22.0, bottom: 10),
          child: Text(
            "More Restaurants in $selectedLocation",
            style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 18,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        // 🥙 More Restaurant Cards (vertical list)
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
            onIconClicked: (bool isLike) {},
          ),
        ),
        CardMoreWidget(
          heartIcon: LikeButton(
            width: 70,
            key: const Key('like3'),
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
}
