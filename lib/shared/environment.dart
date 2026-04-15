
enum BuildFlavor { production, development }

BuildEnvironment get env => _env!;
BuildEnvironment? _env;

class BuildEnvironment {
  String host;

  final BuildFlavor flavor;

  BuildEnvironment._init({required this.host, required this.flavor});

  static void init({required flavor}) => _env ??= BuildEnvironment._init(
    host: switch (flavor) {
       BuildFlavor.production => '',
      BuildFlavor.development => 'https://dev.greyfundr.com/api/v1',
      Object() => throw UnimplementedError(),
      null => throw UnimplementedError(),
    },

    flavor: flavor,
  );
}

// https://back-end-z3es.onrender.com/l/zqsxupeOhy