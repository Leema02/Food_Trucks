import 'package:flutter/material.dart';
import 'package:myapp/screens/auth/widgets/likebutton/LikeButton.dart';
import 'package:myapp/screens/auth/widgets/likebutton/model.dart';

class LikeButtonPage extends StatelessWidget {
  const LikeButtonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LikeButton'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            LikeButton(
              key: const Key('like1'),
              width: 80.0,
              onIconClicked: (bool isLike) {
                print("Heart 1: $isLike");
              },
            ),
            LikeButton(
              key: const Key('like2'),
              width: 80.0,
              circleStartColor: const Color(0xff00ddff),
              circleEndColor: const Color(0xff0099cc),
              dotColor: const DotColor(
                dotPrimaryColor: Color(0xff33b5e5),
                dotSecondaryColor: Color(0xff0099cc),
                dotThirdColor: Color(0xff0077b6),
                dotLastColor: Color(0xff023e8a),
              ),
              icon: const LikeIcon(
                Icons.home,
                iconColor: Colors.deepPurpleAccent,
              ),
              onIconClicked: (bool isLike) {
                print("Heart 2: $isLike");
              },
            ),
            LikeButton(
              key: const Key('like3'),
              width: 80.0,
              circleStartColor: const Color(0xff669900),
              circleEndColor: const Color(0xff669900),
              dotColor: const DotColor(
                dotPrimaryColor: Color(0xff669900),
                dotSecondaryColor: Color(0xff99cc00),
                dotThirdColor: Color(0xffbaffc9),
                dotLastColor: Color(0xff70e000),
              ),
              icon: const LikeIcon(
                Icons.adb,
                iconColor: Colors.green,
              ),
              onIconClicked: (bool isLike) {
                print("Heart 3: $isLike");
              },
            ),
          ],
        ),
      ),
    );
  }
}
