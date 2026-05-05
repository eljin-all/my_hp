import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class OrganScreen extends StatelessWidget {
  final String organName;
  final String modelPath;

  const OrganScreen({
    super.key,
    required this.organName,
    required this.modelPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(organName)),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: ModelViewer(
              src: modelPath,
              autoRotate: true,
              cameraControls: true,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey[200],
              child: const Text(
                "Список болезней (заглушка)",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}