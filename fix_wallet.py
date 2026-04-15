with open('lib/core/providers/wallet_provider.dart', 'r') as f:
    data = f.read()

data = data.replace("EasyLoading.show(status: 'Creating transaction limit...');", "EasyLoading.show(status: 'Setting transaction pin...');")

with open('lib/core/providers/wallet_provider.dart', 'w') as f:
    f.write(data)
