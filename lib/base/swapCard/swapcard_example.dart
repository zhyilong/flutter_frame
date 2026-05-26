/*
 * Created by zhyilong on 2026/5/23
 */

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_demo/base/swapCard/swapCardWidget.dart';

class SwapcardExample extends StatefulWidget {
  const SwapcardExample({super.key});

  @override
  State<SwapcardExample> createState() => _SwapcardExampleState();
}

class _SwapcardExampleState extends State<SwapcardExample> {
  final List<String> _urls = [
    "https://picsum.photos/800/600?random=1",
    "https://picsum.photos/800/600?random=2",
    "https://picsum.photos/800/600?random=3",
    "https://picsum.photos/800/600?random=4",
    "https://picsum.photos/800/600?random=5",
  ];

  String _statusMessage = "Slide or tap the center card";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SwapCard Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 300,
              child: SwapCardWidget(
                itemCount: _urls.length,
                minScale: 0.4, // Optional: customize minimum scale (default is 0.5)
                initialPage: 2, // Optional: start from page 2 (default is 0)
                autoPlay: true, // Optional: enable auto play (default is false)
                autoPlayInterval: const Duration(seconds: 3), // Optional: interval (default is 3 seconds)
                loop: true, // Optional: enable infinite loop (default is false)
                itemBuilder: (context, index) {
                  // Custom card widget - just provide your widget, scaling is automatic
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        // boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, spreadRadius: 2)],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: _urls[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(color: Colors.grey[300], child: const Icon(Icons.error)),
                        ),
                      ),
                    ),
                  );
                },
                onSlideStop: (centerIndex) {
                  // Callback when sliding stops
                  setState(() {
                    _statusMessage = "Slid to card ${centerIndex + 1}";
                  });
                },
                onCenterCardTap: (index) {
                  // Callback when center card is tapped
                  setState(() {
                    _statusMessage = "Tapped card ${index + 1}";
                  });
                },
              ),
            ),
            const SizedBox(height: 40),
            Text(_statusMessage, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
