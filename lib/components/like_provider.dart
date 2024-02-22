// like_provider.dart

import 'package:flutter/foundation.dart';

class LikeProvider extends ChangeNotifier {
  // Add your like-related logic here
  // For example, a method to toggle likes

  void toggleLike(String blogId, bool isLiked) {
    // Your logic to toggle likes goes here
    // Notify listeners if the state changes
    notifyListeners();
  }
}
