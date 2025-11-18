import 'package:flutter/material.dart';

class WasteModel {
  final String name;
  final String description;
  final int points; // poin per kg
  final IconData icon;
  final Color color;

  WasteModel({
    required this.name,
    required this.description,
    required this.points,
    required this.icon,
    required this.color,
  });
}
