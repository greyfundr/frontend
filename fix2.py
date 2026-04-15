import sys

with open('lib/features/bill/bill_payment_method_screen.dart', 'r') as f:
    text = f.read()

bad_block = """                    if (_selectedPaymentMethod == 'paystack') {
                      final authUrl = await newSplitBillProvider
                          .payForSPlitBillWithPaystack(
                            participantId: widget.participantId,
                            billId: widget.billID,
                            amount: _amountToPay.toString(),
                          );

                      if (success && mounted) {
                        Get.close(1);
                        newSplitBillProvider.getMySplitBills();
                        newSplitBillProvider.getSplitBillInvites();
                      }
                      return;
                    }"""

text = text.replace(bad_block, "")

# Fix the next one to use _amountToPay
text = text.replace(
    """                    if (_selectedPaymentMethod == 'paystack') {
                      final authUrl = await newSplitBillProvider
                          .payForSPlitBillWithPaystack(
                            participantId: widget.participantId,
                            billId: widget.billID,
                            amount: widget.amount.toString(),
                          );""",
    """                    if (_selectedPaymentMethod == 'paystack') {
                      final authUrl = await newSplitBillProvider
                          .payForSPlitBillWithPaystack(
                            participantId: widget.participantId,
                            billId: widget.billID,
                            amount: _amountToPay.toString(),
                          );"""
)

with open('lib/features/bill/bill_payment_method_screen.dart', 'w') as f:
    f.write(text)
