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
import 'package:greyfundr/shared/custom_message_modal.dart';

import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AddMoneyBottomSheet extends StatefulWidget {
  const AddMoneyBottomSheet({super.key});

  @override
  State<AddMoneyBottomSheet> createState() => _AddMoneyBottomSheetState();
}

class _AddMoneyBottomSheetState extends State<AddMoneyBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  bool _isProcessing = false;
  bool _amountValid = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_validateAmount);
  }

  @override
  void dispose() {
    _amountController.removeListener(_validateAmount);
    _amountController.dispose();
    super.dispose();
  }

  void _validateAmount() {
    final clean = _amountController.text.replaceAll(',', '');
    final value = double.tryParse(clean) ?? 0.0;
    setState(() => _amountValid = value >= 500);
  }

  Future<void> _onContinue() async {
    if (!_amountValid) {

      // showToast(error: "Minimum amount is ₦500", type: "error");

       CustomMessageModal.show(
        context: context,
        message: "Minimum amount is ₦500",
        isSuccess: false,
      );

      return;
    }

    setState(() => _isProcessing = true);

    try {
      final walletProvider = Provider.of<WalletProvider>(context, listen: false);
      final cleanAmount = _amountController.text.replaceAll(',', '');
      final res = await walletProvider.initiateWalletFunding(amount: cleanAmount);

      if (res.isNotEmpty) {
        if (mounted) Navigator.pop(context); // Close current sheet
        showCustomBottomSheet(
          PaystackUrlSheet(
            url: res,
            onSuccess: () {
              Get.to(
                PaymentSuccessScreen(amount: cleanAmount),
                transition: Transition.rightToLeft,
              );
              walletProvider.fetchUserWallet();
            },
          ),
          context,
        );
      } else {
        // showToast(error: "Failed to initiate payment", type: "error");

        CustomMessageModal.show(
        context: context,
        message: "Failed to initiate payment",
        isSuccess: false,
      );

      }
    } catch (e) {
      // showToast(error: "Error: $e", type: "error");
        CustomMessageModal.show(
          context: context,
          message: "An error occurred. Please try again.",
          isSuccess: false,
        );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF007A74), Color(0xFF004D4A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.widthOf(5),
          vertical: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: SvgPicture.asset("assets/svgs/sheet_drag.svg")),
            Gap(20),
            Text(
              "Add Money",
              style: txStyle18Bold.copyWith(color: Colors.white),
            ),
            Text(
              "How much do you want to add to your GreyFundr wallet?",
              style: txStyle14wt,
            ),
            Gap(20),
            CustomTextField(
              hintText: "₦0.00",
              textInputType: TextInputType.number,
              autoFocus: true,
              formatters: MoneyInputFormatter(),
              controller: _amountController,
              onChanged: (value) {
                setState(() {});
              },
            ),
            Gap(20),
            CustomButton(
              enabled: _amountValid && !_isProcessing,
              onTap: _onContinue,
              label: "Add Money",
              backgroundColor: appSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

// Reusing your PaystackUrlSheet and PaymentSuccessScreen (unchanged)
class PaystackUrlSheet extends StatefulWidget {
  final String url;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;
  const PaystackUrlSheet({
    super.key,
    required this.url,
    this.onSuccess,
    this.onError,
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
    if (oldWidget.url != widget.url) {
      _webViewController.loadRequest(Uri.parse(widget.url));
    }
  }

  void initializeWebViewController(String url) {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() => pageIniting = progress != 100);
          },
          onPageStarted: handleTransactionCheck,
          onPageFinished: handleTransactionCheck,
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
    if (url.contains("paystack/success")) {
      Get.close(1);
      widget.onSuccess?.call();
    } else if (url.contains("paystack/cancel")) {
      Get.close(1);
      widget.onError?.call();
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
                  valueColor: const AlwaysStoppedAnimation<Color>(appPrimaryColor),
                ),
              ),
            ),
          )
        : SizedBox(
            height: SizeConfig.heightOf(90),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.widthOf(2),
                    vertical: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Fund wallet", style: txStyle20Bold),
                      IconButton(
                        onPressed: () => Get.close(1),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(child: WebViewWidget(controller: _webViewController)),
              ],
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
          Gap(20),
          CustomButton(
            onTap: () => Get.close(1),
            label: "Go Back",
          ),
        ],
      ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
    );
  }
}