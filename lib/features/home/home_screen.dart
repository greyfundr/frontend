import 'dart:math' as math;

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';

import 'package:greyfundr/components/custom_network_image.dart';
import 'package:greyfundr/features/createnew/create_new_screen.dart';
import 'package:greyfundr/features/event/event_screen.dart';
import 'package:greyfundr/features/invoice/invoice_screen.dart';
import 'package:greyfundr/features/charity/charity_screen.dart';

import 'package:greyfundr/components/custom_ontap.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/core/providers/wallet_provider.dart';
import 'package:greyfundr/features/home/add_money_sheet.dart';
import 'package:greyfundr/features/settings/settings_screen.dart';
import 'package:greyfundr/features/settings/transaction_history_screen.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);
    var userProfile = userProvider.userProfileModel;
    var walletModel = walletProvider.walletModel;
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
                          Text(
                            "${userProfile?.firstName} ${userProfile?.lastName}",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SvgPicture.asset("assets/svgs/notification.svg"),
              ],
            ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
            Gap(5),
            Divider(),
            Gap(5),

            Expanded(
              child: RefreshIndicator.adaptive(
                onRefresh: () async {
                  await userProvider.fetchUserProfileApi();
                  await walletProvider.fetchUserWallet();
                },
                child: ListView(
                  children: [
                    if (userProfile?.hasCompletedKyc == false)
                      IncompleteKycBadge().paddingSymmetric(
                        horizontal: SizeConfig.widthOf(5),
                      ),
                    Gap(10),

                    Row(
                      children: [

                         CustomOnTap(
  onTap: () {
    Get.to(
      () => EventScreen(), // ← replace with your actual screen/widget
      transition: Transition.rightToLeft,
    );
  },
  child: Image.asset(
    "assets/images/lifestyle.png",
    height: 250,
    width: SizeConfig.widthOf(50),
  ),
),


                         CustomOnTap(
  onTap: () {
    Get.to(
      () => InvoiceScreen(), // ← replace with your actual screen/widget
      transition: Transition.rightToLeft,
    );
  },
  child: Image.asset(
    "assets/images/invoice.png",
    height: 250,
    width: SizeConfig.widthOf(50),
  ),
),
                      ],
                    ),
                    Gap(20),
                    Row(
                      children: [
                        CustomOnTap(
  onTap: () {
    Get.to(
      () => CreateNewScreen(), 
      transition: Transition.rightToLeft,
    );
  },
  child: Image.asset(
    "assets/images/create_new.png",
    height: 250,
    width: SizeConfig.widthOf(50),
  ),
),
                          CustomOnTap(
  onTap: () {
    Get.to(
      () => CharityScreen(), // ← replace with your actual screen/widget
      transition: Transition.rightToLeft,
    );
  },
  child: Image.asset(
    "assets/images/charity.png",
    height: 250,
    width: SizeConfig.widthOf(50),
  ),
),
                      ],
                    ),
                    Gap(20),

                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Recent Transactions",
                              style: txStyle16SemiBold,
                            ),
                            CustomOnTap(
                              onTap: () {
                                Get.to(
                                  TransactionHistoryScreen(),
                                  transition: Transition.rightToLeft,
                                );
                              },
                              child: Row(
                                children: [
                                  Text(
                                    "View All",
                                    style: txStyle14SemiBold.copyWith(
                                      color: appPrimaryColor,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                    color: appPrimaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Gap(20),
                        ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          // padding: const EdgeInsets.symmetric(
                          //   horizontal: 16,
                          //   vertical: 20,
                          // ),
                          itemCount:
                              (walletProvider.transactionModel?.data?.length ??
                                      0) >
                                  3
                              ? 3
                              : walletProvider.transactionModel?.data?.length ??
                                    0,
                          separatorBuilder: (context, index) =>
                              Divider(color: Color(0xFFEEEEEE), thickness: 1),
                          itemBuilder: (context, index) {
                            final tx =
                                walletProvider.transactionModel?.data?[index];
                            return buildTransactionItem(tx!);
                          },
                        ),
                        Gap(40),
                      ],
                    ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
                  ],
                ),
              ),
            ),

            Container(
              height: 20,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/wallet_bg_arc.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.widthOf(5)),
              height: 80,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/wallet_bg.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total Balance", style: txStyle12wt),
                      Gap(5),
                      Text(
                        "${convertStringToCurrency(walletModel?.balance?.available ?? "0")}",
                        style: txStyle18SemiBold.copyWith(color: Colors.white),
                      ),
                      Gap(5),
                      Text(
                        "Ledger:  ${convertStringToCurrency("${walletModel?.balance?.ledger ?? "0"}")}",
                        style: txStyle12wt,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 27),
                      Text(
                        "Escrow:  ${convertStringToCurrency("${walletModel?.balance?.escrow ?? "0"}")}",
                        style: txStyle12wt,
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      showCustomBottomSheet(AddMoneySheet(), context);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/svgs/add_money.svg",
                          height: 30,
                        ),
                        Text("Add Money", style: txStyle12wt),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IncompleteKycBadge extends StatelessWidget {
  const IncompleteKycBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return CustomOnTap(
      onTap: () async {
        bool res = await userProvider.completeKycTemp();
        if (res) {
          userProvider.fetchUserProfileApi();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Color(0xffff534f),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white, size: 16),
            Gap(5),
            Text(
              "Kindly verify your account to access all features",
              style: txStyle12wt,
            ),
          ],
        ),
      ),
    );
  }
}