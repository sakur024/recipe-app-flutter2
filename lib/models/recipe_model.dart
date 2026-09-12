import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeModel {
  final String id;
  final String name;
  final String image;
  final String cal;
  final String time;
  final String rate;
  final String reviews;
  final String category;
  final List<double> ingredientsAmount;
  final List<String> ingredientsName;
  final List<String> ingredientsImage;

  RecipeModel({
    required this.id,
    required this.name,
    required this.image,
    required this.cal,
    required this.time,
    required this.rate,
    required this.reviews,
    required this.category,
    required this.ingredientsAmount,
    required this.ingredientsName,
    required this.ingredientsImage,
  });

  factory RecipeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return RecipeModel.fromMap(data, doc.id);
  }

  factory RecipeModel.fromMap(Map<String, dynamic> data, String id) {
    // Parse ingredientsAmount safely
    final rawAmounts = data['ingredientsAmount'];
    List<double> amounts = [];
    if (rawAmounts is List) {
      amounts = rawAmounts.map((e) => double.tryParse(e.toString()) ?? 0.0).toList();
    }

    // Parse ingredientsName safely
    final rawNames = data['ingredientsName'];
    List<String> names = [];
    if (rawNames is List) {
      names = rawNames.map((e) => e.toString()).toList();
    }

    // Parse ingredientsImage safely
    final rawImages = data['ingredientsImage'];
    List<String> images = [];
    if (rawImages is List) {
      images = rawImages.map((e) => e.toString()).toList();
    }

    return RecipeModel(
      id: id,
      name: data['name']?.toString() ?? "Recipe",
      image: data['image']?.toString() ?? "",
      cal: data['cal']?.toString() ?? "0",
      time: data['time']?.toString() ?? "0",
      rate: data['rate']?.toString() ?? "5.0",
      reviews: data['reviews']?.toString() ?? "0",
      category: data['category']?.toString() ?? "All",
      ingredientsAmount: amounts,
      ingredientsName: names,
      ingredientsImage: images,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'cal': cal,
      'time': time,
      'rate': rate,
      'reviews': reviews,
      'category': category,
      'ingredientsAmount': ingredientsAmount,
      'ingredientsName': ingredientsName,
      'ingredientsImage': ingredientsImage,
    };
  }

  Map<String, dynamic> toJson() {
    final map = toMap();
    map['id'] = id;
    return map;
  }

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? "";
    return RecipeModel.fromMap(json, id);
  }

  RecipeModel copyWith({
    String? id,
    String? name,
    String? image,
    String? cal,
    String? time,
    String? rate,
    String? reviews,
    String? category,
    List<double>? ingredientsAmount,
    List<String>? ingredientsName,
    List<String>? ingredientsImage,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      cal: cal ?? this.cal,
      time: time ?? this.time,
      rate: rate ?? this.rate,
      reviews: reviews ?? this.reviews,
      category: category ?? this.category,
      ingredientsAmount: ingredientsAmount ?? this.ingredientsAmount,
      ingredientsName: ingredientsName ?? this.ingredientsName,
      ingredientsImage: ingredientsImage ?? this.ingredientsImage,
    );
  }
}
