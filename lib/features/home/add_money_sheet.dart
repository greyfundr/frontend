import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/core/providers/wallet_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/moeny_formater.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AddMoneySheet extends StatefulWidget {
  const AddMoneySheet({super.key});

  @override
  State<AddMoneySheet> createState() => _AddMoneySheetState();
}

class _AddMoneySheetState extends State<AddMoneySheet> {
  var amountController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/images/bottom_sheet_curve_primary.png"),
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/wallet_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child:
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: SvgPicture.asset("assets/svgs/sheet_drag.svg"),
                      ),
                      Gap(20),
                      Text(
                        "Enter Amount",
                        style: txStyle18Bold.copyWith(color: Colors.white),
                      ),
                      Text(
                        "how much do you want to add to you GreyFundr wallet",
                        style: txStyle14wt,
                      ),
                      Gap(20),
                      CustomTextField(
                        // labelText: "Amount",
                        hintText: "₦0.00",
                        textInputType: TextInputType.number,
                        autoFocus: true,
                        formatters: MoneyInputFormatter(),
                        controller: amountController,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      Gap(20),
                      CustomButton(
                        enabled: amountController.text.isNotEmpty,
                        onTap: () async {
                          String res = await walletProvider
                              .initiateWalletFunding(
                                amount: amountController.text.replaceAll(
                                  ",",
                                  "",
                                ),
                              );
                          if (res.isNotEmpty) {
                            Get.close(1);
                            showCustomBottomSheet(
                              PaystackUrlSheet(
                                url: res,
                                onSuccess: () {
                                  Get.to(
                                    PaymentSuccessScreen(
                                      amount: amountController.text.replaceAll(
                                        ",",
                                        "",
                                      ),
                                    ),
                                    transition: Transition.rightToLeft,
                                  );
                                  walletProvider.fetchUserWallet();
                                },
                              ),
                              context,
                            );
                          }
                        },
                        label: "Add Money",
                        backgroundColor: appSecondaryColor,
                      ),
                    ],
                  ).paddingSymmetric(
                    horizontal: SizeConfig.widthOf(5),
                    vertical: 20,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaystackUrlSheet extends StatefulWidget {
  final String url;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;
  final String title;
  const PaystackUrlSheet({
    super.key,
    required this.url,
    this.onSuccess,
    this.onError,
    this.title = "Fund Wallet",
  });

  @override
  State<PaystackUrlSheet> createState() => _PaystackUrlSheetState();
}

class _PaystackUrlSheetState extends State<PaystackUrlSheet> {
  late WebViewController _webViewController;
  bool pageIniting = false;

  @override
  void initState() {
    super.initState();
    initializeWebViewController(widget.url);
  }

  @override
  void didUpdateWidget(covariant PaystackUrlSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detect if the URL has changed and reload the WebView
    if (oldWidget.url != widget.url) {
      log("URL updated: ${widget.url}");
      _webViewController.loadRequest(Uri.parse(widget.url));
    }
  }

  void initializeWebViewController(String url) {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            log("$progress");
            if (progress == 100) {
              pageIniting = false;
              setState(() {});
              return;
            }
            pageIniting = true;
            setState(() {});
          },
          onPageStarted: (url) => handleTransactionCheck(url),
          onPageFinished: (url) => handleTransactionCheck(url),
          onUrlChange: (change) => {
            setState(() {}),
            log("URL CHANGE::::::: ${change.url}"),
          },
          onHttpError: (HttpResponseError error) =>
              log("HTTP ERROR:::::: ${error.response}"),
          onWebResourceError: (WebResourceError error) =>
              log("WEB RESOURCE ERROR:::::: ${error.description}"),
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  void handleTransactionCheck(String url) {
    setState(() {});
    if (url.contains("paystack/success")) {
      Get.close(1);
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      }
      // showToast(error: "Transaction completed", type: "success");
      setState(() {});
      log("TRANSACTION COMPLETED::::::: $url");
      return;
    }

    if (url.contains("paystack/cancel")) {
      Get.close(1);
      if (widget.onError != null) {
        widget.onError!();
      }
      setState(() {});
      log("TRANSACTION CANCELED::::::: $url");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return pageIniting
        ? SizedBox(
            height: SizeConfig.heightOf(90),
            child: Center(
              child: SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  backgroundColor: appPrimaryColor.withOpacity(.5),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    appPrimaryColor,
                  ),
                ),
              ),
            ),
          )
        : SizedBox(
            height: SizeConfig.heightOf(85),
            child: Padding(
              padding: MediaQuery.of(context).viewInsets,

              child: Column(
                children: [
                  Image.asset("assets/images/bottom_sheet_cureve_right.png"),
                  Container(
                    color: Color(0xffF1F1F7),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.widthOf(2),
                        vertical: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.title, style: txStyle20Bold),
                          IconButton(
                            onPressed: () {
                              Get.close(1);
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Gap(10),
                  Expanded(
                    child: WebViewWidget(controller: _webViewController),
                  ),
                ],
              ),
            ),
          );
  }
}

class PaymentSuccessScreen extends StatelessWidget {
  final String amount;
  const PaymentSuccessScreen({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            "assets/lottie/Success.json",
            height: 150,
            width: 150,
            repeat: false,
          ),

          Gap(20),
          Text("Payment Successful", style: txStyle30SemiBold),
          Gap(10),
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: "You have successfully added ",
                style: txStyle14.copyWith(color: Colors.black),
                children: [
                  TextSpan(
                    text: convertStringToCurrency(amount),
                    style: txStyle14.copyWith(
                      color: appPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: " to your wallet",
                    style: txStyle14.copyWith(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          Gap(SizeConfig.heightOf(20)),
          CustomButton(
            onTap: () {
              Get.close(1);
            },
            label: "Go Back",
          ),
        ],
      ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
    );
  }
}
