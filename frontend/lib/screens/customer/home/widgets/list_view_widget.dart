import 'package:flutter/material.dart';
import 'package:myapp/screens/home/widgets/home_main_container.dart';

class ListViewWidget extends StatelessWidget {
  final String selectedLocation;
  final Widget header;

  const ListViewWidget({
    super.key,
    required this.selectedLocation,
    required this.header,
    required String cityName,
    required void Function() onHeaderTap,
    required void Function() onDrawerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        header,
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: HomeMainContainer(selectedLocation: selectedLocation),
          ),
        ),
      ],
    );
  }
}
