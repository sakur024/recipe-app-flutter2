import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app2/Provider/favorite_provider.dart';
import 'package:recipe_app2/Provider/meal_plan_provider.dart';
import 'package:recipe_app2/Provider/quantity.dart';
import 'package:recipe_app2/Utils/constants.dart';
import 'package:recipe_app2/Views/notifications_screen.dart';
import 'package:recipe_app2/Widget/my_icon_button.dart';
import 'package:recipe_app2/Widget/quantity_increment_decrement.dart';
import 'package:recipe_app2/models/recipe_model.dart';

class RecipeDetailScreen extends StatefulWidget {
  final DocumentSnapshot<Object?>? documentSnapshot;
  final RecipeModel? recipe;

  const RecipeDetailScreen({
    super.key,
    this.documentSnapshot,
    this.recipe,
  }) : assert(documentSnapshot != null || recipe != null);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  @override
  void initState() {
    super.initState();
    final data = (widget.documentSnapshot?.data() as Map<String, dynamic>?) ?? {};
    final rawAmounts = widget.recipe?.ingredientsAmount ?? data['ingredientsAmount'];

    List<double> baseAmounts = [];
    if (rawAmounts is List) {
      baseAmounts = rawAmounts
          .map<double>((amount) => double.tryParse(amount.toString()) ?? 0.0)
          .toList();
    }
    if (baseAmounts.isEmpty) {
      baseAmounts = [100.0, 50.0, 30.0];
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuantityProvider>(context, listen: false)
          .setBaseIngredientAmounts(baseAmounts);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = FavoriteProvider.of(context);
    final quantityProvider = Provider.of<QuantityProvider>(context);
    final data = (widget.documentSnapshot?.data() as Map<String, dynamic>?) ?? {};

    final dynamic itemRef = widget.documentSnapshot ?? (widget.recipe?.id ?? "recipe");
    final String name = widget.recipe?.name ?? (data['name']?.toString() ?? "Recipe Detail");
    final String image = widget.recipe?.image ?? (data['image']?.toString() ?? "");
    final String cal = widget.recipe?.cal ?? (data['cal']?.toString() ?? "0");
    final String time = widget.recipe?.time ?? (data['time']?.toString() ?? "0");
    final String rate = widget.recipe?.rate ?? (data['rate']?.toString() ?? "4.8");
    final String reviews = widget.recipe?.reviews ?? (data['reviews']?.toString() ?? "24");

    final rawIngredients = widget.recipe?.ingredientsName ?? data['ingredientsName'];
    final List<String> ingredientsName = (rawIngredients is List)
        ? rawIngredients.map((e) => e.toString()).toList()
        : ["Ingredient 1", "Ingredient 2", "Ingredient 3"];

    final rawImages = widget.recipe?.ingredientsImage ?? data['ingredientsImage'];
    final List<String> ingredientsImage = (rawImages is List)
        ? rawImages.map((e) => e.toString()).toList()
        : [];

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: startCookingAndFavoriteButton(provider, itemRef),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // Top header image with Hero animation
                Hero(
                  tag: 'recipe_image_${widget.recipe?.id ?? widget.documentSnapshot?.id ?? "recipe"}',
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 2.1,
                    width: double.infinity,
                    child: image.isNotEmpty
                        ? Image.network(
                            image,
                            fit: BoxFit.cover,
                            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                              if (wasSynchronouslyLoaded || frame != null) return child;
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                            ),
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.fastfood, size: 48, color: Colors.grey),
                          ),
                  ),
                ),
                // Back button & Actions
                Positioned(
                  top: 40,
                  left: 15,
                  right: 15,
                  child: Row(
                    children: [
                      MyIconButton(
                        icon: Icons.arrow_back_ios_new,
                        pressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Spacer(),
                      MyIconButton(
                        icon: Iconsax.notification,
                        hasBadge: true,
                        pressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: MediaQuery.of(context).size.width,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Iconsax.flash_1,
                        size: 20,
                        color: Colors.grey,
                      ),
                      Text(
                        "$cal Cal",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
                        size: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "$time Min",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Rating & Reviews
                  Row(
                    children: [
                      const Icon(
                        Iconsax.star1,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        rate,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Text(
                        "/5",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "$reviews Reviews",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Ingredients & Servings Header
                  Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ingredients",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "How many servings?",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      QuantityIncrementDecrement(
                        currentNumber: quantityProvider.currentNumber,
                        onAdd: () => quantityProvider.increaseQuantity(),
                        onRemov: () => quantityProvider.decreaseQuantity(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Ingredients List
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ingredient Images
                      Column(
                        children: List.generate(
                          ingredientsName.length,
                          (idx) => Container(
                            height: 55,
                            width: 55,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.grey.shade100,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: (idx < ingredientsImage.length &&
                                      ingredientsImage[idx].isNotEmpty)
                                  ? Image.network(
                                      ingredientsImage[idx],
                                      fit: BoxFit.cover,
                                      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                        if (wasSynchronouslyLoaded || frame != null) return child;
                                        return Container(
                                          color: Colors.grey.shade100,
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.egg_alt_outlined, color: Colors.grey),
                                    )
                                  : const Icon(Icons.egg_alt_outlined, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Ingredient Names
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            ingredientsName.length,
                            (idx) => Container(
                              height: 55,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  ingredientsName[idx],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Scaled Amounts
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(
                          quantityProvider.updateIngredientAmounts.length,
                          (idx) => Container(
                            height: 55,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "${quantityProvider.updateIngredientAmounts[idx]}g",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget startCookingAndFavoriteButton(FavoriteProvider provider, dynamic itemRef) {
    final bool isFav = provider.isExist(itemRef);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Add to Plan Primary Button with gradient & glow
          Expanded(
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF56AB2F),
                    Color(0xFFA8E063),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF56AB2F).withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _showScheduleDialog(context),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.calendar_add, size: 22, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          "Add to Meal Plan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Heart Favorite Button
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: isFav ? const Color(0xFFFFF0F0) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isFav ? const Color(0xFFFF8A8A) : Colors.grey.shade300,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isFav
                      ? const Color(0xFFFF5252).withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => provider.toggleFavorite(itemRef),
                child: Center(
                  child: Icon(
                    isFav ? Iconsax.heart5 : Iconsax.heart,
                    color: isFav ? const Color(0xFFFF3B30) : Colors.black87,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog(BuildContext context) {
    final data = (widget.documentSnapshot?.data() as Map<String, dynamic>?) ?? {};
    final String recipeName = widget.recipe?.name ?? (data['name']?.toString() ?? "Recipe");
    final String cal = widget.recipe?.cal ?? (data['cal']?.toString() ?? "250");
    final String img = widget.recipe?.image ?? (data['image']?.toString() ?? "");
    String chosenDay = "Mon";
    String chosenType = "Lunch";
    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final types = ["Breakfast", "Lunch", "Dinner", "Snack"];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModal) => Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add '$recipeName' to Meal Plan",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text("Select Day", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: days.map((d) {
                  final isSel = chosenDay == d;
                  return ChoiceChip(
                    label: Text(d),
                    selected: isSel,
                    selectedColor: kprimaryColor,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (val) {
                      if (val) setModal(() => chosenDay = d);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text("Meal Time", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: types.map((t) {
                  final isSel = chosenType == t;
                  return ChoiceChip(
                    label: Text(t),
                    selected: isSel,
                    selectedColor: kprimaryColor,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (val) {
                      if (val) setModal(() => chosenType = t);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kprimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    final meal = PlannedMeal(
                      id: "plan_${DateTime.now().millisecondsSinceEpoch}",
                      day: chosenDay,
                      mealType: chosenType,
                      recipeName: recipeName,
                      time: chosenType == "Breakfast"
                          ? "08:30 AM"
                          : (chosenType == "Lunch" ? "01:00 PM" : "07:30 PM"),
                      calories: "$cal Cal",
                      imageUrl: img.isNotEmpty
                          ? img
                          : "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=80",
                    );
                    await Provider.of<MealPlanProvider>(context, listen: false).addMeal(meal);
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Scheduled '$recipeName' for $chosenDay!"),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Confirm Schedule",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
