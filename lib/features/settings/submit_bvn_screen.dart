import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_app_bar.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:provider/provider.dart';

class SubmitBvnScreen extends StatefulWidget {
  const SubmitBvnScreen({super.key});

  @override
  State<SubmitBvnScreen> createState() => _SubmitBvnScreenState();
}

class _SubmitBvnScreenState extends State<SubmitBvnScreen> {
  final TextEditingController _bvnController = TextEditingController();

  @override
  void dispose() {
    _bvnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      appBar: CustomAppBar(title: "BVN Verification"),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            CustomTextField(
              controller: _bvnController,
              labelText: "Enter your BVN",
              hintText: "12345678901",
              textInputType: TextInputType.number,
              autoFocus: true,
            ),
            Spacer(),
            CustomButton(
              onTap: () async {
                bool res = await userProvider.submitBvn(
                  bvn: _bvnController.text.trim(),
                );
                if (res) {
                  Get.close(1);
                }
              },
              label: "Submit BVN",
            ),
          ],
        ).paddingSymmetric(horizontal: SizeConfig.widthOf(5), vertical: 20),
      ),
    );
  }
}
