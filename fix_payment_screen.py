import re

with open('lib/features/bill/bill_payment_method_screen.dart', 'r') as f:
    content = f.read()

# Add minPaymentAmount
content = re.sub(
    r"final double amount;",
    r"final double amount;\n  final double minPaymentAmount;",
    content
)

content = re.sub(
    r"required this.amount,\n  }\);",
    r"required this.amount,\n    this.minPaymentAmount = 0,\n  });",
    content
)

edit_screen_state = """class _BillPaymentMethodScreenState extends State<BillPaymentMethodScreen> {
  String _selectedPaymentMethod = 'wallet';
  late TextEditingController _amountController;
  late double _amountToPay;

  @override
  void initState() {
    super.initState();
    _amountToPay = widget.amount;
    _amountController = TextEditingController(text: widget.amount.toStringAsFixed(2));
    Future.delayed(Duration.zero, () {
      final walletProvider = Provider.of<WalletProvider>(
        context,
        listen: false,
      );
      walletProvider.fetchUserWallet();
    });
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }"""

content = re.sub(
    r"class _BillPaymentMethodScreenState extends State<BillPaymentMethodScreen> \{.*?(?=  double _toDouble)",
    edit_screen_state + "\n\n",
    content,
    flags=re.DOTALL
)

amount_widget_replace = """              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xffECECF2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.minPaymentAmount > 0 ? 'Amount to Pay (Partial allowed)' : 'Total Amount',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(6),
                    widget.minPaymentAmount > 0
                        ? TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [NumberTextInputFormatter()],
                            style: txStyle24SemiBold,
                            decoration: const InputDecoration(
                              prefixText: '₦',
                              prefixStyle: txStyle24SemiBold,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            onChanged: (val) {
                              final text = val.replaceAll(',', '');
                              setState(() {
                                _amountToPay = double.tryParse(text) ?? 0.0;
                              });
                            },
                          )
                        : Text(
                            convertStringToCurrency(widget.amount.toString()),
                            style: txStyle24SemiBold,
                          ),
                    if (widget.minPaymentAmount > 0) ...[
                      const Gap(4),
                      Text(
                        'Min: ${convertStringToCurrency(widget.minPaymentAmount.toString())} • Max: ${convertStringToCurrency(widget.amount.toString())}',
                        style: TextStyle(
                          fontSize: 11,
                          color: _amountToPay < widget.minPaymentAmount || _amountToPay > widget.amount
                              ? Colors.red
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),"""

content = re.sub(
    r"              Container\(\n                width: double.infinity,\n                padding: const EdgeInsets.all\(14\),.*?style: txStyle24SemiBold,\n                    \),\n                  \],\n                \),\n              \),",
    amount_widget_replace,
    content,
    flags=re.DOTALL
)

# Fix the continue buttons
button_replace = """                    if (widget.minPaymentAmount > 0) {
                      if (_amountToPay < widget.minPaymentAmount) {
                        showErrorToast('Amount cannot be less than minimum allowed');
                        return;
                      }
                      if (_amountToPay > widget.amount) {
                         showErrorToast('Amount cannot be greater than total owed');
                         return;
                      }
                    }

                    if (_selectedPaymentMethod == 'wallet') {
                      if (walletBalance < _amountToPay) {
                        showErrorToast('Insufficient wallet balance');
                        return;
                      }

                      showCustomBottomSheet(
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Enter Transaction PIN",
                                style: txStyle20Bold.copyWith(color: Colors.black),
                              ),
                              const Gap(8),
                              const Text(
                                "Please enter your 6-digit transaction PIN to confirm this payment.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                              const Gap(24),
                              PINCodeInput2(
                                inputLenght: 6,
                                onComplete: (pin) async {
                                  Get.back();
                                  final success = await newSplitBillProvider
                                      .payForSPlitBillWithWallet(
                                        participantId: widget.participantId,
                                        billId: widget.billID,
                                        amount: _amountToPay.toString(),
                                        transactionPin: pin,
                                      );

                                  if (success && mounted) {
                                    Get.close(1);
                                    newSplitBillProvider.getMySplitBills();
                                    newSplitBillProvider.getSplitBillInvites();
                                  }
                                },
                              ),
                              const Gap(24),
                            ],
                          ),
                        ),
                        context,
                      );
                      return;
                    }

                    if (_selectedPaymentMethod == 'paystack') {
                      final authUrl = await newSplitBillProvider
                          .payForSPlitBillWithPaystack(
                            participantId: widget.participantId,
                            billId: widget.billID,
                            amount: _amountToPay.toString(),
                          );"""

content = re.sub(
    r"                    if \(_selectedPaymentMethod == 'wallet'\) \{.*?amount: widget\.amount\.toString\(\),\n                          \);",
    button_replace,
    content,
    flags=re.DOTALL
)

if "import 'package:greyfundr/components/custom_pin_input.dart';" not in content:
    content = "import 'package:greyfundr/components/custom_pin_input.dart';\n" + content

with open('lib/features/bill/bill_payment_method_screen.dart', 'w') as f:
    f.write(content)

