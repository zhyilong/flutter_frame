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
  LoopMode _selectedLoopMode = LoopMode.largeNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SwapCard Example'),
        actions: [
          DropdownButton<LoopMode>(
            value: _selectedLoopMode,
            onChanged: (LoopMode? newValue) {
              setState(() {
                _selectedLoopMode = newValue!;
                _statusMessage = "Loop Mode: ${_getLoopModeName(newValue)}";
              });
            },
            items: const [
              DropdownMenuItem(value: LoopMode.disabled, child: Text("No Loop")),
              DropdownMenuItem(value: LoopMode.largeNumber, child: Text("Large Number")),
              DropdownMenuItem(value: LoopMode.copyJump, child: Text("Copy Jump")),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 300,
              child: SwapCardWidget(
                key: ValueKey(_selectedLoopMode),  // 切换模式时重新创建组件
                itemCount: _urls.length,
                minScale: 0.4,
                initialPage: 2,
                autoPlay: false,
                autoPlayInterval: const Duration(seconds: 3),
                loopMode: _selectedLoopMode,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        // boxShadow: [
                        //   BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, spreadRadius: 2),
                        // ],
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
                  setState(() {
                    _statusMessage = "Slid to card ${centerIndex + 1}";
                  });
                },
                onCenterCardTap: (index) {
                  setState(() {
                    _statusMessage = "Tapped card ${index + 1}";
                  });
                },
              ),
            ),
            const SizedBox(height: 40),
            Text(
              _statusMessage,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text("Current Mode: ${_getLoopModeName(_selectedLoopMode)}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  String _getLoopModeName(LoopMode mode) {
    switch (mode) {
      case LoopMode.disabled:
        return "No Loop";
      case LoopMode.largeNumber:
        return "Large Number (方案一)";
      case LoopMode.copyJump:
        return "Copy Jump (方案二)";
    }
  }
}
