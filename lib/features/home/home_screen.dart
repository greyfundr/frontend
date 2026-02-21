import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:greyfundr/components/custom_network_image.dart';
import 'package:greyfundr/components/custom_ontap.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/features/settings/settings_screen.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    var userProfile = userProvider.userProfileModel;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomOnTap(
                  onTap: () {
                    Get.to(
                      SettingsScreen(),
                      transition: Transition.rightToLeft,
                    );
                  },
                  child: Row(
                    children: [
                      CustomNetworkImage(imageUrl: "imageUrl", radius: 40),
                      Gap(5),
                      Column(
                        children: [
                          Text("${userProfile?.firstName} ${userProfile?.lastName}"),
                        ],
                      )
                    ],
                  ),
                ),
                SvgPicture.asset("assets/svgs/notification.svg"),
              ],
            ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
            Gap(5),
            Divider(),
            Gap(5),
            
            Row(
              children: [
                Image.asset("assets/images/lifestyle.png", height: 250, width: SizeConfig.widthOf(50),),
                Image.asset("assets/images/invoice.png",height: 250,width: SizeConfig.widthOf(50)),
              ],
            ),
            Gap(20),
             Row(
              children: [
                Image.asset("assets/images/create_new.png", height: 250, width: SizeConfig.widthOf(50),),
                Image.asset("assets/images/charity.png",height: 250,width: SizeConfig.widthOf(50)),
              ],
            ),
            Spacer(),
            Container(
              height: 20,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage("assets/images/wallet_bg_arc.png"), fit: BoxFit.cover)
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.widthOf(5)),
              height: 80,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage("assets/images/wallet_bg.png"), fit: BoxFit.cover)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total Balance", style: txStyle14wt,),
                      Gap(5),
                      Text("₦72,311.00", style: txStyle20SemiBold.copyWith(color: Colors.white),),
                      Gap(5),
                      Text("You owe:  ₦23,200", style: txStyle14wt,)
                    ],
                  ),
                  // Text("You are owed:  ₦45,200", style: txStyle14wt,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/svgs/add_money.svg", height: 30,),
                      Text("Add Money", style: txStyle12wt,)
                    ],
                  )
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}
