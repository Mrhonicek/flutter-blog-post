import 'package:flutter/material.dart';

class ImageViewer extends StatefulWidget {
  final String imageUrl;

  const ImageViewer({
    super.key,
    required this.imageUrl,
  });

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  double _scale = 1.0;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Viewer'),
      ),
      body: Stack(
        children: [
          InteractiveViewer(
            panEnabled: true,
            scaleEnabled: true,
            scaleFactor: _scale,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : (_hasError
                    ? const Center(child: Text('Error loading image'))
                    : Image.network(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                      )),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.zoom_in),
                  onPressed: () => setState(() => _scale *= 1.5),
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_out),
                  onPressed: () => setState(() => _scale /= 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
