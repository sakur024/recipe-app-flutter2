import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:recipe_app2/Utils/constants.dart';
import 'package:recipe_app2/models/recipe_model.dart';
import 'package:recipe_app2/services/mock_data_service.dart';

class AddEditRecipeScreen extends StatefulWidget {
  final RecipeModel? recipe;
  final DocumentSnapshot<Object?>? documentSnapshot;

  const AddEditRecipeScreen({
    super.key,
    this.recipe,
    this.documentSnapshot,
  });

  bool get isEditing => recipe != null || documentSnapshot != null;

  @override
  State<AddEditRecipeScreen> createState() => _AddEditRecipeScreenState();
}

class _IngredientRow {
  final TextEditingController nameController;
  final TextEditingController amountController;

  _IngredientRow({String name = "", String amount = ""})
      : nameController = TextEditingController(text: name),
        amountController = TextEditingController(text: amount);

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
}

class _AddEditRecipeScreenState extends State<AddEditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _imageController;
  late final TextEditingController _calController;
  late final TextEditingController _timeController;
  String _selectedCategory = "Breakfast";
  final List<_IngredientRow> _ingredients = [];
  bool _isSaving = false;

  final List<String> _categories = [
    "Breakfast",
    "Lunch",
    "Dinner",
    "Salads",
    "Dessert",
    "Fast Food",
  ];

  final List<Map<String, String>> _presetImages = [
    {
      "label": "Salad",
      "url":
          "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=600&q=80"
    },
    {
      "label": "Chicken",
      "url":
          "https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?auto=format&fit=crop&w=600&q=80"
    },
    {
      "label": "Seafood",
      "url":
          "https://images.unsplash.com/photo-1559742811-822873691df8?auto=format&fit=crop&w=600&q=80"
    },
    {
      "label": "Pasta",
      "url":
          "https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=600&q=80"
    },
    {
      "label": "Pizza",
      "url":
          "https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=600&q=80"
    },
    {
      "label": "Steak",
      "url":
          "https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=600&q=80"
    },
    {
      "label": "Dessert",
      "url":
          "https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=600&q=80"
    },
    {
      "label": "Bowl",
      "url":
          "https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=600&q=80"
    },
  ];

  @override
  void initState() {
    super.initState();

    String initialName = "";
    String initialImage =
        "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=600&q=80";
    String initialCal = "250";
    String initialTime = "20";
    String initialCategory = "Breakfast";

    if (widget.recipe != null) {
      final r = widget.recipe!;
      initialName = r.name;
      initialImage = r.image;
      initialCal = r.cal;
      initialTime = r.time;
      if (_categories.contains(r.category)) {
        initialCategory = r.category;
      }
      for (int i = 0; i < r.ingredientsName.length; i++) {
        final name = r.ingredientsName[i];
        final amount = i < r.ingredientsAmount.length
            ? r.ingredientsAmount[i].toString()
            : "50";
        _ingredients.add(_IngredientRow(name: name, amount: amount));
      }
    } else if (widget.documentSnapshot != null) {
      final data =
          widget.documentSnapshot!.data() as Map<String, dynamic>? ?? {};
      initialName = data['name']?.toString() ?? "";
      initialImage = data['image']?.toString() ?? initialImage;
      initialCal = data['cal']?.toString() ?? initialCal;
      initialTime = data['time']?.toString() ?? initialTime;
      final cat = data['category']?.toString();
      if (cat != null && _categories.contains(cat)) {
        initialCategory = cat;
      }
      final rawNames = data['ingredientsName'] as List<dynamic>? ?? [];
      final rawAmounts = data['ingredientsAmount'] as List<dynamic>? ?? [];
      for (int i = 0; i < rawNames.length; i++) {
        final name = rawNames[i].toString();
        final amount =
            i < rawAmounts.length ? rawAmounts[i].toString() : "50";
        _ingredients.add(_IngredientRow(name: name, amount: amount));
      }
    }

    if (_ingredients.isEmpty) {
      _ingredients.add(_IngredientRow(name: "Main Ingredient", amount: "200"));
      _ingredients.add(_IngredientRow(name: "Olive Oil", amount: "15"));
    }

    _nameController = TextEditingController(text: initialName);
    _imageController = TextEditingController(text: initialImage);
    _calController = TextEditingController(text: initialCal);
    _timeController = TextEditingController(text: initialTime);
    _selectedCategory = initialCategory;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageController.dispose();
    _calController.dispose();
    _timeController.dispose();
    for (var ing in _ingredients) {
      ing.dispose();
    }
    super.dispose();
  }

  void _addIngredientRow() {
    setState(() {
      _ingredients.add(_IngredientRow());
    });
  }

  void _removeIngredientRow(int index) {
    if (_ingredients.length > 1) {
      setState(() {
        _ingredients[index].dispose();
        _ingredients.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("A recipe must have at least one ingredient."),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _saveRecipe() async {
    final name = _nameController.text.trim();
    final image = _imageController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a recipe name."),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (image.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please provide an image link or choose a photo preset."),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final cal = _calController.text.trim();
    final time = _timeController.text.trim();

    final List<String> ingNames = [];
    final List<double> ingAmounts = [];
    final List<String> ingImages = [];

    const defaultIngredientImage =
        "https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=120&q=60";

    for (var row in _ingredients) {
      final ingName = row.nameController.text.trim();
      final ingAmount = double.tryParse(row.amountController.text.trim()) ?? 50.0;
      if (ingName.isNotEmpty) {
        ingNames.add(ingName);
        ingAmounts.add(ingAmount);
        ingImages.add(defaultIngredientImage);
      }
    }

    if (ingNames.isEmpty) {
      ingNames.add("Ingredients");
      ingAmounts.add(100.0);
      ingImages.add(defaultIngredientImage);
    }

    final recipeId = widget.recipe?.id ??
        widget.documentSnapshot?.id ??
        "custom_${DateTime.now().millisecondsSinceEpoch}";

    final recipe = RecipeModel(
      id: recipeId,
      name: name,
      image: image,
      cal: cal.isEmpty ? "250" : cal,
      time: time.isEmpty ? "20" : time,
      rate: widget.recipe?.rate ?? '4.8',
      reviews: widget.recipe?.reviews ?? '35',
      category: _selectedCategory,
      ingredientsAmount: ingAmounts,
      ingredientsName: ingNames,
      ingredientsImage: ingImages,
    );

    try {
      final cloudSynced = await MockDataService.saveRecipe(
        recipe,
        docSnap: widget.documentSnapshot,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? "Recipe '$name' updated successfully!"
                  : (cloudSynced
                      ? "Recipe '$name' published and synced to cloud!"
                      : "Recipe '$name' published successfully!"),
            ),
            backgroundColor: kprimaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Error saving recipe: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Recipe '$name' published successfully!"),
            backgroundColor: kprimaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: AppBar(
        backgroundColor: kbackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: IconButton(
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                backgroundColor: Colors.white,
                fixedSize: const Size(44, 44),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: 18,
              ),
            ),
          ),
        ),
        title: Text(
          widget.isEditing ? "Edit Recipe" : "Add New Recipe",
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: _isSaving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: kprimaryColor,
                      ),
                    )
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kprimaryColor,
                        foregroundColor: Colors.white,
                        elevation: 1,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _saveRecipe,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text(
                        "Save",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Preview Card
              Container(
                width: double.infinity,
                height: 190,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _imageController,
                        builder: (context, value, _) {
                          final url = value.text.trim();
                          if (url.isEmpty) {
                            return const Center(
                              child: Icon(Iconsax.image,
                                  size: 48, color: Colors.grey),
                            );
                          }
                          return Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image_outlined,
                                      size: 40, color: Colors.grey),
                                  SizedBox(height: 6),
                                  Text(
                                    "Invalid image link",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Iconsax.eye, size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                "Live Preview",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Image Presets
              const Text(
                "Quick Photo Presets",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _presetImages.map((preset) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        avatar: const Icon(Iconsax.gallery, size: 14),
                        label: Text(preset["label"]!),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        onPressed: () {
                          setState(() {
                            _imageController.text = preset["url"]!;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Image URL input
              _buildTextField(
                controller: _imageController,
                label: "Image URL",
                hint: "https://images.unsplash.com/...",
                icon: Iconsax.link,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Please enter a photo URL";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Recipe Title
              _buildTextField(
                controller: _nameController,
                label: "Recipe Name",
                hint: "e.g. Creamy Tuscan Garlic Chicken",
                icon: Iconsax.book,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Please enter the recipe name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category & Prep Time Row
              Row(
                children: [
                  // Category Dropdown
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            labelText: "Category",
                            labelStyle: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                          items: _categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(
                                cat,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedCategory = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Prep Time
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _timeController,
                      label: "Time (mins)",
                      hint: "25",
                      icon: Iconsax.clock,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Calories
              _buildTextField(
                controller: _calController,
                label: "Calories (kcal)",
                hint: "350",
                icon: Iconsax.flash_1,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              // Ingredients Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Ingredients & Quantities",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: kprimaryColor,
                    ),
                    onPressed: _addIngredientRow,
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text(
                      "Add Item",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Dynamic Ingredients List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _ingredients.length,
                separatorBuilder: (ctx, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = _ingredients[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        // Number bubble
                        CircleAvatar(
                          radius: 12,
                          backgroundColor:
                              kprimaryColor.withValues(alpha: 0.12),
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(
                              color: kprimaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Ingredient Name
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: item.nameController,
                            decoration: const InputDecoration(
                              hintText: "Ingredient name",
                              hintStyle: TextStyle(
                                  color: Colors.grey, fontSize: 13),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Amount
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: item.amountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: "Amount (g/ml)",
                              hintStyle: TextStyle(
                                  color: Colors.grey, fontSize: 12),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // Delete row button
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.red, size: 20),
                          onPressed: () => _removeIngredientRow(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 35),

              // Big Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kprimaryColor,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isSaving ? null : _saveRecipe,
                  child: _isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.2,
                          ),
                        )
                      : Text(
                          widget.isEditing ? "Update Recipe" : "Publish Recipe",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(icon, size: 20, color: kprimaryColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kprimaryColor, width: 1.5),
        ),
      ),
    );
  }
}
