import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:recipe_app2/Provider/favorite_provider.dart';
import 'package:recipe_app2/Utils/constants.dart';
import 'package:recipe_app2/Views/recipe_detail_screen.dart';
import 'package:recipe_app2/models/recipe_model.dart';

class FoodItemsDisplay extends StatelessWidget {
  final DocumentSnapshot<Object?>? documentSnapshot;
  final RecipeModel? recipe;

  const FoodItemsDisplay({
    super.key,
    this.documentSnapshot,
    this.recipe,
  }) : assert(documentSnapshot != null || recipe != null);

  @override
  Widget build(BuildContext context) {
    final provider = FavoriteProvider.of(context);
    final data = (documentSnapshot?.data() as Map<String, dynamic>?) ?? {};

    final String itemId = recipe?.id ?? documentSnapshot?.id ?? "recipe";
    final String name = recipe?.name ?? (data['name']?.toString() ?? "Recipe");
    final String image = recipe?.image ?? (data['image']?.toString() ?? "");
    final String cal = recipe?.cal ?? (data['cal']?.toString() ?? "0");
    final String time = recipe?.time ?? (data['time']?.toString() ?? "0");

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(
              documentSnapshot: documentSnapshot,
              recipe: recipe,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        width: 230,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: image.isNotEmpty
                      ? Image.network(
                          image,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          frameBuilder:
                              (context, child, frame, wasSync) {
                            if (wasSync || frame != null) return child;
                            return Container(
                              width: double.infinity,
                              height: 160,
                              color: Colors.grey.shade100,
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: kprimaryColor,
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: double.infinity,
                            height: 160,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(Icons.fastfood,
                                  color: Colors.grey, size: 40),
                            ),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: 160,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.fastfood,
                                color: Colors.grey, size: 40),
                          ),
                        ),
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Iconsax.flash_1,
                      size: 16,
                      color: Colors.grey,
                    ),
                    Text(
                      "$cal Cal",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const Text(
                      " · ",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.grey,
                      ),
                    ),
                    const Icon(
                      Iconsax.clock,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "$time Min",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Favorite toggle button
            Positioned(
              top: 5,
              right: 5,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: InkWell(
                  onTap: () {
                    provider.toggleFavorite(documentSnapshot ?? itemId);
                  },
                  child: Icon(
                    provider.isExist(documentSnapshot ?? itemId)
                        ? Iconsax.heart5
                        : Iconsax.heart,
                    color: provider.isExist(documentSnapshot ?? itemId)
                        ? Colors.red
                        : Colors.black,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
