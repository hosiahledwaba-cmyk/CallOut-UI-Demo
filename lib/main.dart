// lib/main.dart
/* README:
  Drop these files into lib/ of an existing Flutter project.
  
  Updates:
  - Added Auth (Login/Signup)
  - Added Async Data Fetching with Fallback
  
  Flow:
  Login -> Feed (Tries API, falls back to Mock)
*/

import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  runApp(const SafeSpaceApp());
}
