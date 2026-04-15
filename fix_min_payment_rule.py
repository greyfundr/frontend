import re

with open('lib/features/bill/bill_payment_method_screen.dart', 'r') as f:
    content = f.read()

# 1. Update text for the field
content = content.replace(
    """                      Text(
                        widget.minPaymentAmount > 0
                            ? 'Amount to Pay (Partial allowed)'
                            : 'Total Amount',""",
    """                      Text(
                        (widget.minPaymentAmount > 0 || widget.payingRemainingAmount)
                            ? 'Amount to Pay (Partial allowed)'
                            : 'Total Amount',"""
)

# 2. Update the TextFormField condition
content = content.replace(
    """                      widget.minPaymentAmount > 0
                          ? TextFormField(""",
    """                      (widget.minPaymentAmount > 0 || widget.payingRemainingAmount)
                          ? TextFormField("""
)

# 3. Update the Min/Max text condition
content = content.replace(
    """                      if (widget.minPaymentAmount > 0) ...[
                        const Gap(4),
                        Text(
                          'Min: ${convertStringToCurrency(widget.minPaymentAmount.toString())} • Max: ${convertStringToCurrency(widget.amount.toString())}',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                _amountToPay < widget.minPaymentAmount ||
                                    _amountToPay > widget.amount
                                ? Colors.red
                                : Colors.grey[600],
                          ),
                        ),
                      ],""",
    """                      if (widget.minPaymentAmount > 0 && !widget.payingRemainingAmount) ...[
                        const Gap(4),
                        Text(
                          'Min: ${convertStringToCurrency(widget.minPaymentAmount.toString())} • Max: ${convertStringToCurrency(widget.amount.toString())}',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                _amountToPay < widget.minPaymentAmount ||
                                    _amountToPay > widget.amount
                                ? Colors.red
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                      if (widget.payingRemainingAmount) ...[
                        const Gap(4),
                        Text(
                          'Max: ${convertStringToCurrency(widget.amount.toString())}',
                          style: TextStyle(
                            fontSize: 11,
                            color: _amountToPay > widget.amount
                                ? Colors.red
                                : Colors.grey[600],
                          ),
                        ),
                      ],"""
)

# 4. Update the validator check for continue button
content = content.replace(
    """                      if (widget.minPaymentAmount > 0) {
                        if (_amountToPay < widget.minPaymentAmount) {
                          showErrorToast(
                            'Amount cannot be less than minimum allowed',
                          );
                          return;
                        }
                        if (_amountToPay > widget.amount) {
                          showErrorToast(
                            'Amount cannot be greater than total owed',
                          );
                          return;
                        }
                      }""",
    """                      if (widget.minPaymentAmount > 0 && !widget.payingRemainingAmount) {
                        if (_amountToPay < widget.minPaymentAmount) {
                          showErrorToast(
                            'Amount cannot be less than minimum allowed',
                          );
                          return;
                        }
                      }
                      if (widget.minPaymentAmount > 0 || widget.payingRemainingAmount) {
                        if (_amountToPay > widget.amount) {
                          showErrorToast(
                            'Amount cannot be greater than total owed',
                          );
                          return;
                        }
                      }"""
)

with open('lib/features/bill/bill_payment_method_screen.dart', 'w') as f:
    f.write(content)

