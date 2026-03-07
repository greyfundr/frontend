import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Keep your CurvedTopClipper and _DragHandle unchanged

class CurvedTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 20);
    var firstControlPoint = Offset(size.width / 4, 0);
    var firstEndPoint = Offset(size.width / 2, 1);
    var secondControlPoint = Offset(3 * size.width / 4, 0);
    var secondEndPoint = Offset(size.width, 30);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


Future<String?> showCategoryPicker(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return ClipPath(
            clipper: CurvedTopClipper(),
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  const _DragHandle(),
                  const SizedBox(height: 8),
                  const Text(
                    'Select Category',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: FutureBuilder<List<Map<String, String>>>(
                      future: _fetchCategories(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error loading categories\n${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No categories available'));
                        }

                        final categories = snapshot.data!;

                        return GridView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(20),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.9,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            return GestureDetector(
                              onTap: () => Navigator.pop(context, cat['label']),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 34,
                                    backgroundColor: const Color.fromARGB(255, 216, 245, 246),
                                    child: Image.asset(
                                      cat['icon']!,
                                      width: 40,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.error, size: 40),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    cat['label']!,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<List<Map<String, String>>> _fetchCategories() async {
  try {
    final response = await http.get(
      Uri.parse('https://api.greyfundr.com/campaign/getCategory'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map && data.containsKey('campaign')) {
        final List<dynamic> campaignList = data['campaign'];

        return campaignList.map((item) {
          return {
            'label': item['label']?.toString() ?? 'Unknown',
            'icon': item['icon']?.toString() ?? 'assets/icons/placeholder.png',
            // You can also keep 'id' if useful later: 'id': item['id']?.toString(),
          };
        }).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }
  } catch (e) {
    // You can log(e) here or use a proper logger
    rethrow; // Let FutureBuilder show the error
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}



