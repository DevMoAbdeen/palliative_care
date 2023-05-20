import 'package:flutter/material.dart';
import 'package:palliative_care/components/shimmer_components.dart';
import 'package:shimmer/shimmer.dart';
import '../constants.dart';

class AllShimmerLoaded {
  static Shimmer shimmerArticle(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(25)),
                color: Colors.white,
              ),
            ),
            kSizeBoxH8,
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(25)),
                color: Colors.white,
              ),
            ),
            kSizeBoxH8,
            Container(
              height: 16,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(25)),
                color: Colors.white,
              ),
            ),
            kSizeBoxH16,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  height: 24,
                  width: width > 500 ? width / 4 : width / 3,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    color: Colors.white,
                  ),
                ),
                Container(
                  height: 24,
                  width: width > 500 ? width / 4 : width / 3,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    color: Colors.white,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  //////////////////////////////////

  static Shimmer shimmerAllUsers() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: const UserInfo(),
    );
  }

  //////////////////////////////////

  static Shimmer shimmerActivity() {
    return Shimmer.fromColors(
      baseColor: kBackgroundColor,
      highlightColor: Colors.grey[300]!,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            height: 60,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.white,
            ),
          ),
          // kSizeBoxH8,
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            height: 20,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.white,
            ),
          ),
          kSizeBoxH16,
        ],
      ),
    );
  }

  //////////////////////////////////

  static Shimmer shimmerDoctorProfile() {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.white,
              ),
            ),
            kSizeBoxH16,
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              height: 20,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.white,
              ),
            ),
            kSizeBoxH16,
            kDivider,
            kSizeBoxH16,
            Column(
              children: const [
                UserInfo(),
                UserInfo(),
                UserInfo(),
                UserInfo(),
              ],
            )
          ],
        ));
  }

  //////////////////////////////////

  static Shimmer shimmerPatientProfile() {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: SafeArea(
          child: ListView(
            children: [
              kSizeBoxH16,
              const CircleAvatar(
                radius: 70,
                backgroundColor: Colors.white,
              ),
              kSizeBoxH16,
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                height: 20,
                width: 200,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.white,
                ),
              ),
              kSizeBoxH16,
              kDivider,
              kSizeBoxH16,
              Column(
                children: const [
                  UserInfo(),
                  UserInfo(),
                  UserInfo(),
                  UserInfo(),
                ],
              )
            ],
          ),
        ),
    );
  }
}
