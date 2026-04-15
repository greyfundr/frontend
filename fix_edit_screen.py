import sys

with open('lib/features/auth/create_transaction_pin_screen.dart', 'r') as f:
    content = f.read()

placeholder = """  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}"""

replacement = """  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xffD9F1F3),
      appBar: const CustomAppBar(title: ""),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Gap(20),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            'Confirm Transaction PIN',
                            textAlign: TextAlign.center,
                            style: txStyle32Bold.copyWith(
                              color: appPrimaryColor,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            'Please re-enter your transaction PIN to confirm',
                            style: txStyle14,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Gap(64),
                        PinCodeText(pin: authProvider.confirmNewPin),
                        const Spacer(),
                        NumPad(
                          onValue: (value) {
                            authProvider.addToPin(value, isConfirm: true);
                          },
                          onDelete: () {
                            authProvider.deleteFromPin(isConfirm: true);
                          },
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: CustomButton(
                            enabled:
                                authProvider.newPin.length == 6 &&
                                authProvider.newPin ==
                                    authProvider.confirmNewPin,
                            onTap: () async {
                              bool res = await walletProvider.setTransactionPin(
                                pin: authProvider.newPin,
                                confirmPin: authProvider.confirmNewPin,
                              );
                              if (res) {
                                // Refresh profile to reflect the changes
                                await Provider.of<UserProvider>(context, listen: false)
                                    .fetchUserProfileApi();
                                Get.offAll(
                                  () => const BottomNav(),
                                  transition: Transition.rightToLeft,
                                );
                              }
                            },
                            label: "Confirm PIN",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}"""

content = content.replace(placeholder, replacement)

imports = content.split('\n')
if "import 'package:greyfundr/core/providers/wallet_provider.dart';" not in content:
    imports.insert(3, "import 'package:greyfundr/core/providers/wallet_provider.dart';")
if "import 'package:greyfundr/features/shared/bottom_nav.dart';" not in content:
    imports.insert(3, "import 'package:greyfundr/features/shared/bottom_nav.dart';")
if "import 'package:greyfundr/core/providers/user_provider.dart';" not in content:
    imports.insert(3, "import 'package:greyfundr/core/providers/user_provider.dart';")

with open('lib/features/auth/create_transaction_pin_screen.dart', 'w') as f:
    f.write('\n'.join(imports))

