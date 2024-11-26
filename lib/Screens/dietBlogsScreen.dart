import 'package:diet_management_suppport_app/main.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Importing the package for opening URLs

class DietBlogsScreen extends StatefulWidget {
  const DietBlogsScreen({super.key});

  @override
  State<DietBlogsScreen> createState() => _DietBlogsScreenState();
}

class _DietBlogsScreenState extends State<DietBlogsScreen> {
  // List of sample diet blogs
  final List<Map<String, String>> blogs = [
    {'title': 'Pinch of Yum', 'url': 'https://pinchofyum.com'},
    {'title': 'Harvard Healthy', 'url': 'https://www.health.harvard.edu/blog'},
    {'title': 'Minimalist Baker', 'url': 'https://minimalistbaker.com'},
    {
      'title': 'A Healthy Slice of Life',
      'url': 'https://www.ahealthysliceoflife.com',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Popular Diet Blogs',
          style: TextStyle(color: Colors.blueAccent),
        ),
      ),
      body: Column(
        children: [
          // Adding a header text at the top
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Text(
              'Discover our top picks to help you deepen your knowledge about nutrition and master healthy cooking!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: kIsDark ? Colors.white : Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          // GridView displaying popular blogs
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: blogs.length,
              itemBuilder: (context, index) {
                final blog = blogs[index];
                return GestureDetector(
                  onTap: () async {
                    final url =
                        Uri.parse(blog['url']!); // Convert URL string to Uri
                    if (await canLaunchUrl(url)) {
                      // Check if the URL can be launched
                      await launchUrl(
                          url); // Launch the URL in the default browser
                    } else {
                      // Handle the error if the URL cannot be launched
                      throw 'Could not launch $url';
                    }
                  },
                  child: Card(
                    elevation: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.article, size: 50),
                        Text(
                          blog['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
