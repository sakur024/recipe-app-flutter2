import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app2/Provider/meal_plan_provider.dart';
import 'package:recipe_app2/Utils/constants.dart';
import 'package:recipe_app2/Views/recipe_detail_screen.dart';
import 'package:recipe_app2/models/recipe_model.dart';
import 'package:recipe_app2/services/mock_data_service.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  int selectedDayIndex = 0;
  final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  final List<String> fullDays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  List<RecipeModel> _availableRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableRecipes();
  }

  Future<void> _loadAvailableRecipes() async {
    // Start with all 24 verified recipes and custom recipes
    _availableRecipes = List.from(MockDataService.allRecipes);
    try {
      if (Firebase.apps.isNotEmpty) {
        final snap = await FirebaseFirestore.instance
            .collection("Complete-Flutter-App")
            .get()
            .timeout(const Duration(seconds: 4));
        if (snap.docs.isNotEmpty) {
          final cloudRecipes =
              snap.docs.map((d) => RecipeModel.fromFirestore(d)).toList();
          
          final Map<String, RecipeModel> combined = {};
          // Add local updated recipes first
          for (var r in MockDataService.allRecipes) {
            combined[r.name.toLowerCase()] = r;
          }
          // Merge cloud recipes (keeping updated local images if cloud has old URL)
          for (var cr in cloudRecipes) {
            final key = cr.name.toLowerCase();
            if (combined.containsKey(key)) {
              // Prefer the verified recipe if image or category is newer
              final local = combined[key]!;
              if (local.image != cr.image) {
                combined[key] = cr.copyWith(image: local.image);
              } else {
                combined[key] = cr;
              }
            } else {
              combined[key] = cr;
            }
          }
          
          if (mounted) {
            setState(() {
              _availableRecipes = combined.values.toList();
            });
          }
        }
      }
    } catch (_) {}
  }

  void _showAddMealDialog(BuildContext context, String currentDay) {
    int activeTab = 0; // 0: Select from Recipes, 1: Custom Meal
    String chosenDay = currentDay;
    RecipeModel? selectedRecipe =
        _availableRecipes.isNotEmpty ? _availableRecipes.first : null;
    String searchFilter = "";
    String selectedCategory = "All";
    String selectedMealType = selectedRecipe?.category == "Breakfast"
        ? "Breakfast"
        : (selectedRecipe?.category == "Dinner" ? "Dinner" : "Lunch");
    String selectedTime = selectedMealType == "Breakfast"
        ? "08:30 AM"
        : (selectedMealType == "Dinner" ? "07:30 PM" : "12:30 PM");

    final customTitleController = TextEditingController();
    final customCalController = TextEditingController(text: "300 Cal");
    final customTimeController = TextEditingController(text: "12:30 PM");
    final searchController = TextEditingController();

    final categories = ["All", "Breakfast", "Lunch", "Dinner", "Salads", "Dessert"];
    final mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final filteredRecipes = _availableRecipes.where((r) {
            final matchesCategory = selectedCategory == "All" ||
                r.category.toLowerCase() == selectedCategory.toLowerCase();
            final matchesSearch = searchFilter.isEmpty ||
                r.name.toLowerCase().contains(searchFilter.toLowerCase());
            return matchesCategory && matchesSearch;
          }).toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.88,
            padding: EdgeInsets.only(
              top: 16,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Add Meal for $chosenDay",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Select from existing recipes or enter custom",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Day Selector Chips (Mon, Tue, Wed, Thu, Fri, Sat, Sun)
                Row(
                  children: [
                    const Text(
                      "Day:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: days.map((d) {
                            final isSel = chosenDay == d;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(d),
                                selected: isSel,
                                selectedColor: kprimaryColor,
                                labelStyle: TextStyle(
                                  color: isSel ? Colors.white : Colors.black87,
                                  fontWeight:
                                      isSel ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
                                ),
                                onSelected: (val) {
                                  if (val) {
                                    setModalState(() => chosenDay = d);
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Segmented Switcher (From Recipes vs Custom Meal)
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() => activeTab = 0);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: activeTab == 0
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: activeTab == 0
                                  ? [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Select Recipe (${_availableRecipes.length})",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: activeTab == 0
                                    ? kprimaryColor
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() => activeTab = 1);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: activeTab == 1
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: activeTab == 1
                                  ? [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Custom Meal",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: activeTab == 1
                                    ? kprimaryColor
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Content based on tab
                Expanded(
                  child: activeTab == 0
                      // TAB 0: SELECT RECIPE
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Search bar
                            TextField(
                              controller: searchController,
                              onChanged: (val) {
                                setModalState(() => searchFilter = val);
                              },
                              decoration: InputDecoration(
                                hintText: "Search recipe by name...",
                                hintStyle: TextStyle(
                                    color: Colors.grey.shade400, fontSize: 13),
                                prefixIcon: const Icon(Iconsax.search_normal,
                                    size: 18, color: Colors.grey),
                                suffixIcon: searchFilter.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18),
                                        onPressed: () {
                                          searchController.clear();
                                          setModalState(
                                              () => searchFilter = "");
                                        },
                                      )
                                    : null,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 14),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade200),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade200),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Category Chips
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: categories.map((cat) {
                                  final isSel = selectedCategory == cat;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      label: Text(cat),
                                      selected: isSel,
                                      selectedColor: kprimaryColor,
                                      labelStyle: TextStyle(
                                        color: isSel
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: isSel
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 12,
                                      ),
                                      onSelected: (val) {
                                        if (val) {
                                          setModalState(
                                              () => selectedCategory = cat);
                                        }
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Recipe List
                            Expanded(
                              child: filteredRecipes.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Iconsax.search_status,
                                              size: 36,
                                              color: Colors.grey.shade400),
                                          const SizedBox(height: 8),
                                          Text(
                                            "No recipes found matching '$searchFilter'",
                                            style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: filteredRecipes.length,
                                      itemBuilder: (context, idx) {
                                        final recipe = filteredRecipes[idx];
                                        final isSelected = selectedRecipe?.name ==
                                            recipe.name;

                                        return GestureDetector(
                                          onTap: () {
                                            setModalState(() {
                                              selectedRecipe = recipe;
                                              if (recipe.category ==
                                                  "Breakfast") {
                                                selectedMealType = "Breakfast";
                                                selectedTime = "08:30 AM";
                                              } else if (recipe.category ==
                                                  "Dinner") {
                                                selectedMealType = "Dinner";
                                                selectedTime = "07:30 PM";
                                              } else {
                                                selectedMealType = "Lunch";
                                                selectedTime = "12:30 PM";
                                              }
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 180),
                                            margin: const EdgeInsets.only(
                                                bottom: 10),
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? kprimaryColor.withValues(
                                                      alpha: 0.08)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: isSelected
                                                    ? kprimaryColor
                                                    : Colors.grey.shade200,
                                                width: isSelected ? 2 : 1,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(
                                                      alpha: 0.02),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: Image.network(
                                                    recipe.image,
                                                    width: 60,
                                                    height: 60,
                                                    cacheWidth: 180,
                                                    cacheHeight: 180,
                                                    fit: BoxFit.cover,
                                                    frameBuilder: (context, child, frame, wasSync) {
                                                      if (wasSync || frame != null) return child;
                                                      return Container(
                                                        width: 60,
                                                        height: 60,
                                                        color: Colors.grey.shade100,
                                                      );
                                                    },
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Container(
                                                      width: 60,
                                                      height: 60,
                                                      color:
                                                          Colors.grey.shade200,
                                                      child: const Icon(
                                                          Icons.restaurant,
                                                          color: Colors.grey),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        recipe.name,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          Icon(Iconsax.flash_1,
                                                              size: 14,
                                                              color: Colors
                                                                  .orange
                                                                  .shade700),
                                                          const SizedBox(
                                                              width: 3),
                                                          Text(
                                                            "${recipe.cal} Cal",
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors.grey
                                                                  .shade700,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                          const Icon(
                                                              Iconsax.clock,
                                                              size: 13,
                                                              color:
                                                                  Colors.grey),
                                                          const SizedBox(
                                                              width: 3),
                                                          Text(
                                                            "${recipe.time} Min",
                                                            style: const TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .grey),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Icon(
                                                  isSelected
                                                      ? Icons
                                                          .check_circle_rounded
                                                      : Icons
                                                          .radio_button_unchecked,
                                                  color: isSelected
                                                      ? kprimaryColor
                                                      : Colors.grey.shade400,
                                                  size: 22,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        )
                      // TAB 1: CUSTOM MEAL
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              TextField(
                                controller: customTitleController,
                                decoration: InputDecoration(
                                  labelText: "Recipe or Meal Name",
                                  hintText:
                                      "e.g. Avocado Toast, Protein Shake",
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade200),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade200),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: customCalController,
                                      decoration: InputDecoration(
                                        labelText: "Calories",
                                        hintText: "300 Cal",
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade200),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade200),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: customTimeController,
                                      decoration: InputDecoration(
                                        labelText: "Scheduled Time",
                                        hintText: "12:30 PM",
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade200),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade200),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 10),

                // Meal Type Selector
                Row(
                  children: [
                    const Text(
                      "Meal Type:",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: mealTypes.map((type) {
                            final isSel = selectedMealType == type;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(type),
                                selected: isSel,
                                selectedColor: kprimaryColor,
                                labelStyle: TextStyle(
                                  color: isSel ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    setModalState(() {
                                      selectedMealType = type;
                                      if (type == "Breakfast") {
                                        selectedTime = "08:30 AM";
                                      } else if (type == "Lunch") {
                                        selectedTime = "12:30 PM";
                                      } else if (type == "Dinner") {
                                        selectedTime = "07:30 PM";
                                      } else {
                                        selectedTime = "04:00 PM";
                                      }
                                    });
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Add to Plan Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kprimaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () async {
                      String mealName = "";
                      String calories = "";
                      String imageUrl = "";
                      String time = "";

                      if (activeTab == 0) {
                        if (selectedRecipe == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Please select a recipe from the list")),
                          );
                          return;
                        }
                        mealName = selectedRecipe!.name;
                        calories = "${selectedRecipe!.cal} Cal";
                        imageUrl = selectedRecipe!.image;
                        time = selectedTime;
                      } else {
                        mealName = customTitleController.text.trim();
                        if (mealName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Please enter a meal name")),
                          );
                          return;
                        }
                        calories = customCalController.text.trim().isEmpty
                            ? "250 Cal"
                            : (customCalController.text.trim().contains("Cal")
                                ? customCalController.text.trim()
                                : "${customCalController.text.trim()} Cal");
                        imageUrl =
                            "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=80";
                        time = customTimeController.text.trim().isEmpty
                            ? "12:30 PM"
                            : customTimeController.text.trim();
                      }

                      final newMeal = PlannedMeal(
                        id: "meal_${DateTime.now().millisecondsSinceEpoch}",
                        day: chosenDay,
                        mealType: selectedMealType,
                        recipeName: mealName,
                        time: time,
                        calories: calories,
                        imageUrl: imageUrl,
                      );

                      await Provider.of<MealPlanProvider>(context,
                              listen: false)
                          .addMeal(newMeal);

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        final dayIdx = days.indexOf(chosenDay);
                        if (dayIdx != -1) {
                          setState(() {
                            selectedDayIndex = dayIdx;
                          });
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text("Scheduled '$mealName' for $chosenDay!"),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Text(
                      activeTab == 0 && selectedRecipe != null
                          ? "Schedule '${selectedRecipe!.name}' for $chosenDay"
                          : "Add Meal to $chosenDay Plan",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openMealDetails(BuildContext context, PlannedMeal meal) {
    RecipeModel? matchedRecipe;
    for (var r in _availableRecipes) {
      if (r.name.toLowerCase() == meal.recipeName.toLowerCase()) {
        matchedRecipe = r;
        break;
      }
    }

    if (matchedRecipe == null) {
      for (var r in MockDataService.mockRecipes) {
        if (r.name.toLowerCase() == meal.recipeName.toLowerCase()) {
          matchedRecipe = r;
          break;
        }
      }
    }

    final cleanCal = meal.calories.replaceAll(RegExp(r'[^0-9]'), '');
    final cleanTime = meal.time.replaceAll(RegExp(r'[^0-9]'), '');

    matchedRecipe ??= RecipeModel(
      id: meal.id,
      name: meal.recipeName,
      image: meal.imageUrl,
      cal: cleanCal.isNotEmpty ? cleanCal : "250",
      time: cleanTime.isNotEmpty ? cleanTime : "20",
      rate: "4.8",
      reviews: "18",
      category: meal.mealType,
      ingredientsAmount: [150.0, 50.0, 20.0],
      ingredientsName: ["Primary Ingredient", "Seasoning & Herbs", "Olive Oil"],
      ingredientsImage: [
        "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?auto=format&fit=crop&w=120&q=60",
      ],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeDetailScreen(
          recipe: matchedRecipe,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentDay = days[selectedDayIndex];
    final fullDay = fullDays[selectedDayIndex];
    final mealProvider = Provider.of<MealPlanProvider>(context);
    final dayMeals = mealProvider.mealsForDay(currentDay);
    final totalCals = mealProvider.totalCaloriesForDay(currentDay);

    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: AppBar(
        backgroundColor: kbackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Meal Planner",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh, color: Colors.black87),
            tooltip: "Sync with Cloud",
            onPressed: () async {
              await mealProvider.loadMeals();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Meal plan synchronized with Cloud Firestore!"),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kprimaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Meal",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () => _showAddMealDialog(context, currentDay),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Week Days Selector Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  days.length,
                  (index) {
                    final isSelected = selectedDayIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDayIndex = index;
                        });
                      },
                      child: Container(
                        width: 55,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? kprimaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              days[index],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white70 : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${index + 10}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Plan Summary Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kBannerColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: kBannerColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kBannerColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Iconsax.calendar_tick, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$fullDay's Nutrition Plan",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Total: $totalCals Cal planned • ${dayMeals.length} Meals",
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Scheduled Meals List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Planned Meals",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "${dayMeals.length} Scheduled",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (mealProvider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (dayMeals.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(Iconsax.calendar_remove, size: 45, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      "No meals planned for $fullDay",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Tap below to schedule a healthy dish!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kprimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      onPressed: () => _showAddMealDialog(context, currentDay),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(
                        "Add Meal for $fullDay",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...dayMeals.map(
                (meal) => Dismissible(
                  key: Key(meal.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                  ),
                  onDismissed: (_) {
                    mealProvider.deleteMeal(meal.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Removed ${meal.recipeName} from plan"),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _openMealDetails(context, meal),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            meal.imageUrl,
                            width: 75,
                            height: 75,
                            cacheWidth: 225,
                            cacheHeight: 225,
                            fit: BoxFit.cover,
                            frameBuilder: (context, child, frame, wasSync) {
                              if (wasSync || frame != null) return child;
                              return Container(
                                width: 75,
                                height: 75,
                                color: Colors.grey.shade100,
                                child: const Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: kprimaryColor,
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 75,
                              height: 75,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.fastfood, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: kprimaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  meal.mealType,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: kprimaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                meal.recipeName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: meal.isCompleted
                                      ? Colors.grey
                                      : Colors.black87,
                                  decoration: meal.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Iconsax.clock,
                                      size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    meal.time,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(Iconsax.flash_1,
                                      size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    meal.calories,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            meal.isCompleted
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: meal.isCompleted ? kBannerColor : Colors.grey,
                            size: 26,
                          ),
                          onPressed: () {
                            mealProvider.toggleCompleted(meal);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(meal.isCompleted
                                    ? "Marked ${meal.recipeName} as pending"
                                    : "Marked ${meal.recipeName} as completed!"),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 70), // Bottom padding for FAB
          ],
        ),
      ),
    );
  }
}

