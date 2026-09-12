import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recipe_app2/models/recipe_model.dart';

class MockDataService {
  static final List<Map<String, dynamic>> defaultCategories = [
    {"name": "All"},
    {"name": "Breakfast"},
    {"name": "Lunch"},
    {"name": "Dinner"},
    {"name": "Salads"},
    {"name": "Dessert"},
    {"name": "Fast Food"},
  ];

  static final List<Map<String, dynamic>> defaultRecipes = [
    // --- BREAKFAST ---
    {
      "name": "Fluffy Blueberry Pancakes",
      "image":
          "https://images.unsplash.com/photo-1528207776546-365bb710ee93?auto=format&fit=crop&w=600&q=80",
      "cal": "340",
      "time": "20",
      "rate": "4.9",
      "reviews": "86",
      "category": "Breakfast",
      "ingredientsAmount": [200.0, 100.0, 250.0, 40.0],
      "ingredientsName": [
        "All-Purpose Flour",
        "Fresh Blueberries",
        "Whole Milk",
        "Pure Maple Syrup"
      ],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1498557850523-fd3d118b962e?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1587049352846-4a222e784d38?auto=format&fit=crop&w=120&q=60",
      ],
    },
    {
      "name": "Avocado Toast & Poached Egg",
      "image":
          "https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=600&q=80",
      "cal": "280",
      "time": "15",
      "rate": "4.8",
      "reviews": "64",
      "category": "Breakfast",
      "ingredientsAmount": [120.0, 150.0, 100.0, 5.0],
      "ingredientsName": [
        "Sourdough Bread",
        "Ripe Avocado",
        "Farm Eggs",
        "Red Chili Flakes"
      ],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1516467508483-a7212febe31a?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1596040033229-a9821ebd058d?auto=format&fit=crop&w=120&q=60",
      ],
    },
    {
      "name": "Oatmeal Banana Porridge",
      "image":
          "https://images.unsplash.com/photo-1517673132405-a56a62b18caf?auto=format&fit=crop&w=600&q=80",
      "cal": "290",
      "time": "10",
      "rate": "4.7",
      "reviews": "39",
      "category": "Breakfast",
      "ingredientsAmount": [100.0, 150.0, 80.0, 20.0],
      "ingredientsName": [
        "Rolled Oats",
        "Almond Milk",
        "Ripe Banana",
        "Pure Honey"
      ],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1586444248902-2f64eddc13df?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1587049352846-4a222e784d38?auto=format&fit=crop&w=120&q=60",
      ],
    },
    {
      "name": "Loaded Breakfast Burrito",
      "image":
          "https://images.unsplash.com/photo-1626700051175-6818013e1d4f?auto=format&fit=crop&w=600&q=80",
      "cal": "420",
      "time": "18",
      "rate": "4.7",
      "reviews": "51",
      "category": "Breakfast",
      "ingredientsAmount": [80.0, 120.0, 50.0, 40.0],
      "ingredientsName": [
        "Flour Tortilla",
        "Scrambled Eggs",
        "Cheddar Cheese",
        "Fresh Tomato Salsa"
      ],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1516467508483-a7212febe31a?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=120&q=60",
      ],
    },

    // --- LUNCH ---
    {
      "name": "Thai Green Noodle Salad",
      "image":
          "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=600&q=80",
      "cal": "340",
      "time": "18",
      "rate": "4.5",
      "reviews": "22",
      "category": "Lunch",
      "ingredientsAmount": [160.0, 70.0, 50.0, 30.0],
      "ingredientsName": [
        "Rice Noodles",
        "Cucumber",
        "Fresh Cilantro",
        "Peanut Sauce"
      ],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1612927601601-6638404737ce?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1449339854873-750e6913301b?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=120&q=60",
      ],
    },
    {
      "name": "Creamy Tuscan Garlic Chicken",
      "image":
          "https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?auto=format&fit=crop&w=600&q=80",
      "cal": "460",
      "time": "25",
      "rate": "4.9",
      "reviews": "94",
      "category": "Lunch",
      "ingredientsAmount": [250.0, 120.0, 80.0, 40.0],
      "ingredientsName": [
        "Chicken Cutlets",
        "Heavy Cream",
        "Baby Spinach",
        "Sun-Dried Tomatoes"
      ],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1604503468506-a8da13d82791?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=120&q=60",
      ],
    },
    {
      "name": "Smoked Turkey Club Sandwich",
      "image":
          "https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&w=600&q=80",
      "cal": "390",
      "time": "12",
      "rate": "4.6",
      "reviews": "48",
      "category": "Lunch",
      "ingredientsAmount": [100.0, 120.0, 40.0, 50.0],
      "ingredientsName": [
        "Multi-Grain Bread",
        "Smoked Turkey",
        "Crisp Bacon",
        "Fresh Tomatoes"
      ],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1604503468506-a8da13d82791?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1528607929212-2636ec44253e?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=120&q=60",
      ],
    },
    {
      "name": "Creamy Tomato Basil Penne",
      "image":
          "https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=600&q=80",
      "cal": "410",
      "time": "22",
      "rate": "4.8",
      "reviews": "73",
      "category": "Lunch",
      "ingredientsAmount": [200.0, 150.0, 40.0, 15.0],
      "ingredientsName": [
        "Penne Pasta",
        "San Marzano Tomatoes",
        "Grated Parmesan",
        "Fresh Sweet Basil"
      ],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1612927601601-6638404737ce?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1452195100486-9cc805987862?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&w=120&q=60",
      ],
    },

    // --- DINNER ---
    {
      "name": "Garlic Herb Butter Salmon",
      "image":
          "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&w=600&q=80",
      "cal": "480",
      "time": "25",
      "rate": "4.9",
      "reviews": "112",
      "category": "Dinner",
      "ingredientsAmount": [220.0, 30.0, 100.0, 30.0],
      "ingredientsName": [
        "Salmon Fillet",
        "Garlic Butter",
        "Fresh Asparagus",
        "Lemon Slices"
      ],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1515471209610-dae1c92d8777?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&w=120&q=60",
      ],
    },
    {
      "name": "Shrimp Kale Power Bowl",
      "image":
          "https://images.unsplash.com/photo-1559742811-822873691df8?auto=format&fit=crop&w=600&q=80",
      "cal": "320",
      "time": "25",
      "rate": "4.9",
      "reviews": "54",
      "category": "Dinner",
      "ingredientsAmount": [180.0, 120.0, 60.0, 15.0],
      "ingredientsName": [
        "Tiger Shrimp",
        "Chopped Kale",
        "Hass Avocado",
        "Lime Dressing"
      ],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1524179091875-bf99a9a6fa57?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&w=120&q=60",
      ],
    },
    {
      "name": "Tender Rosemary Ribeye Steak",
      "image":
          "https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=600&q=80",
      "cal": "560",
      "time": "30",
      "rate": "5.0",
      "reviews": "128",
      "category": "Dinner",
      "ingredientsAmount": [300.0, 10.0, 35.0, 8.0],
      "ingredientsName": [
        "Ribeye Steak",
        "Fresh Rosemary",
        "Salted Butter",
        "Crushed Black Pepper"
      ],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1596040033229-a9821ebd058d?auto=format&fit=crop&w=120&q=60",
      ],
    },
    {
      "name": "Creamy Wild Mushroom Risotto",
      "image":
          "https://images.unsplash.com/photo-1633964913295-ceb43826e7c9?auto=format&fit=crop&w=600&q=80",
      "cal": "430",
      "time": "35",
      "rate": "4.7",
      "reviews": "62",
      "category": "Dinner",
      "ingredientsAmount": [180.0, 150.0, 300.0, 45.0],
      "ingredientsName": [
        "Arborio Rice",
        "Wild Mushrooms",
        "Vegetable Broth",
        "Parmesan Cheese"
      ],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1452195100486-9cc805987862?auto=format&fit=crop&w=120&q=60",
      ],
    },

    // --- SALADS ---
    {
      "name": "Grilled Chicken Caesar Salad",
      "image":
          "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=600&q=80",
      "cal": "270",
      "time": "20",
      "rate": "4.8",
      "reviews": "76",
      "category": "Salads",
      "ingredientsAmount": [200.0, 120.0, 40.0, 30.0],
      "ingredientsName": [
        "Grilled Chicken Breast",
        "Romaine Lettuce",
        "Shaved Parmesan",
        "Caesar Dressing"
      ],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1604503468506-a8da13d82791?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1556801712-76c8eb07bbc9?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1452195100486-9cc805987862?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?auto=format&fit=crop&w=120&q=60",
      ],
    },
    {
      "name": "Crispy Mushroom & Spinach Salad",
      "image":
          "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=600&q=80",
      "cal": "180",
      "time": "15",
      "rate": "4.6",
      "reviews": "28",
      "category": "Salads",
      "ingredientsAmount": [150.0, 80.0, 40.0, 20.0],
      "ingredientsName": [
        "Sliced Mushrooms",
        "Baby Spinach",
        "Crumbled Feta",
        "Minced Garlic"
      ],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1452195100486-9cc805987862?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=120&q=60",
      ],
    },
    {
      "name": "Mediterranean Greek Salad",
      "image":
          "https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=600&q=80",
      "cal": "220",
      "time": "12",
      "rate": "4.9",
      "reviews": "89",
      "category": "Salads",
      "ingredientsAmount": [140.0, 100.0, 50.0, 60.0],
      "ingredientsName": [
        "Crisp Cucumbers",
        "Cherry Tomatoes",
        "Kalamata Olives",
        "Greek Feta Block"
      ],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1449339854873-750e6913301b?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?auto=format&fit=crop&w=120&q=60",
      ],
    },
    {
      "name": "Caprese Salad with Glaze",
      "image":
          "https://images.unsplash.com/photo-1592417817098-8f3d69102a47?auto=format&fit=crop&w=600&q=80",
      "cal": "240",
      "time": "10",
      "rate": "4.8",
      "reviews": "53",
      "category": "Salads",
      "ingredientsAmount": [150.0, 150.0, 20.0, 25.0],
      "ingredientsName": [
        "Buffalo Mozzarella",
        "Vine Tomatoes",
        "Sweet Basil",
        "Balsamic Glaze"
      ],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?auto=format&fit=crop&w=120&q=60",
      ],
    },

    // --- DESSERT ---
    {
      "name": "Berry Chia Seed Pudding",
      "image":
          "https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=600&q=80",
      "cal": "210",
      "time": "12",
      "rate": "4.9",
      "reviews": "67",
      "category": "Dessert",
      "ingredientsAmount": [60.0, 180.0, 70.0, 15.0],
      "ingredientsName": [
        "Chia Seeds",
        "Coconut Milk",
        "Fresh Berries",
        "Maple Syrup"
      ],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1509358271058-acd22cc93898?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1464965911861-746a04b4bca6?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1587049352846-4a222e784d38?auto=format&fit=crop&w=120&q=60",
      ],
    },
    {
      "name": "Molten Chocolate Lava Cake",
      "image":
          "https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=600&q=80",
      "cal": "490",
      "time": "25",
      "rate": "5.0",
      "reviews": "142",
      "category": "Dessert",
      "ingredientsAmount": [150.0, 80.0, 45.0, 10.0],
      "ingredientsName": [
        "Dark Chocolate 70%",
        "Unsalted Butter",
        "Pastry Flour",
        "Vanilla Extract"
      ],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1587049352846-4a222e784d38?auto=format&fit=crop&w=120&q=60",
      ],
    },
    {
      "name": "Classic New York Cheesecake",
      "image":
          "https://images.unsplash.com/photo-1533134242443-d4fd215305ad?auto=format&fit=crop&w=600&q=80",
      "cal": "440",
      "time": "45",
      "rate": "4.9",
      "reviews": "105",
      "category": "Dessert",
      "ingredientsAmount": [250.0, 100.0, 60.0, 30.0],
      "ingredientsName": [
        "Cream Cheese",
        "Graham Cracker Crust",
        "Cane Sugar",
        "Strawberry Coulis"
      ],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1587049352846-4a222e784d38?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1464965911861-746a04b4bca6?auto=format&fit=crop&w=120&q=60",
      ],
    },
    {
      "name": "Italian Tiramisu Delight",
      "image":
          "https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?auto=format&fit=crop&w=600&q=80",
      "cal": "380",
      "time": "30",
      "rate": "4.8",
      "reviews": "91",
      "category": "Dessert",
      "ingredientsAmount": [120.0, 180.0, 80.0, 15.0],
      "ingredientsName": [
        "Ladyfinger Biscuits",
        "Mascarpone Cream",
        "Espresso Coffee",
        "Cocoa Powder"
      ],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=120&q=60",
      ],
    },

    // --- FAST FOOD ---
    {
      "name": "Gourmet Smash Cheeseburger",
      "image":
          "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=600&q=80",
      "cal": "620",
      "time": "20",
      "rate": "4.9",
      "reviews": "168",
      "category": "Fast Food",
      "ingredientsAmount": [200.0, 80.0, 40.0, 25.0],
      "ingredientsName": [
        "Ground Chuck Beef",
        "Brioche Burger Buns",
        "American Cheddar",
        "Secret Burger Sauce"
      ],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?auto=format&fit=crop&w=120&q=60",
      ],
    },
    {
      "name": "Crispy Buffalo Chicken Wings",
      "image":
          "https://images.unsplash.com/photo-1567620832903-9fc6debc209f?auto=format&fit=crop&w=600&q=80",
      "cal": "540",
      "time": "28",
      "rate": "4.8",
      "reviews": "114",
      "category": "Fast Food",
      "ingredientsAmount": [350.0, 60.0, 20.0, 40.0],
      "ingredientsName": [
        "Fresh Chicken Wings",
        "Spicy Buffalo Sauce",
        "Salted Butter",
        "Blue Cheese Dip"
      ],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1604503468506-a8da13d82791?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1596040033229-a9821ebd058d?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?auto=format&fit=crop&w=120&q=60",
      ],
    },
    {
      "name": "Stone-Baked Pepperoni Pizza",
      "image":
          "https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=600&q=80",
      "cal": "590",
      "time": "22",
      "rate": "4.9",
      "reviews": "195",
      "category": "Fast Food",
      "ingredientsAmount": [250.0, 80.0, 120.0, 60.0],
      "ingredientsName": [
        "Artisan Pizza Dough",
        "Crushed Tomato Sauce",
        "Mozzarella Cheese",
        "Spicy Pepperoni"
      ],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=120&q=60",
      ],
    },
    {
      "name": "Golden Truffle Parmesan Fries",
      "image":
          "https://images.unsplash.com/photo-1576107232684-1279f3908594?auto=format&fit=crop&w=600&q=80",
      "cal": "390",
      "time": "18",
      "rate": "4.7",
      "reviews": "78",
      "category": "Fast Food",
      "ingredientsAmount": [300.0, 15.0, 30.0, 10.0],
      "ingredientsName": [
        "Russet Potatoes",
        "White Truffle Oil",
        "Grated Parmesan",
        "Fresh Parsley"
      ],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1452195100486-9cc805987862?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&w=120&q=60",
      ],
    },
  ];

  static final List<RecipeModel> customRecipes = [];
  static const String _storageKey = "saved_custom_recipes_v1";

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(_storageKey);
      if (savedJson != null && savedJson.isNotEmpty) {
        final List<dynamic> list = jsonDecode(savedJson);
        customRecipes.clear();
        for (var item in list) {
          if (item is Map<String, dynamic>) {
            customRecipes.add(RecipeModel.fromJson(item));
          }
        }
      }
    } catch (e) {
      debugPrint("Custom recipes init error: $e");
    }
  }

  static Future<void> _persistCustomRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = customRecipes.map((r) => r.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(list));
    } catch (e) {
      debugPrint("Custom recipes persist error: $e");
    }
  }

  static List<RecipeModel> get allRecipes {
    return [...customRecipes, ...mockRecipes];
  }

  static List<RecipeModel> get mockRecipes {
    return defaultRecipes.asMap().entries.map((entry) {
      return RecipeModel.fromMap(entry.value, "mock_${entry.key}");
    }).toList();
  }

  /// Saves a recipe to both local storage (immediate guarantee)
  /// and Firestore (cloud sync with timeout).
  static Future<bool> saveRecipe(RecipeModel recipe, {DocumentSnapshot? docSnap}) async {
    // 1. Update in-memory and local storage immediately
    final existingIndex = customRecipes.indexWhere(
      (r) => r.id == recipe.id || r.name.trim().toLowerCase() == recipe.name.trim().toLowerCase(),
    );
    if (existingIndex >= 0) {
      customRecipes[existingIndex] = recipe;
    } else {
      customRecipes.insert(0, recipe);
    }
    await _persistCustomRecipes();

    // 2. Sync to Firestore in the cloud
    bool cloudSuccess = false;
    try {
      final collection = FirebaseFirestore.instance.collection("Complete-Flutter-App");
      if (docSnap != null) {
        await docSnap.reference
            .update(recipe.toMap())
            .timeout(const Duration(seconds: 4));
        cloudSuccess = true;
      } else if (recipe.id.isNotEmpty &&
          !recipe.id.startsWith("custom_") &&
          !recipe.id.startsWith("mock_")) {
        await collection
            .doc(recipe.id)
            .set(recipe.toMap(), SetOptions(merge: true))
            .timeout(const Duration(seconds: 4));
        cloudSuccess = true;
      } else {
        final docRef = await collection
            .add(recipe.toMap())
            .timeout(const Duration(seconds: 4));
        cloudSuccess = true;
        final updatedRecipe = RecipeModel(
          id: docRef.id,
          name: recipe.name,
          image: recipe.image,
          cal: recipe.cal,
          time: recipe.time,
          rate: recipe.rate,
          reviews: recipe.reviews,
          category: recipe.category,
          ingredientsAmount: recipe.ingredientsAmount,
          ingredientsName: recipe.ingredientsName,
          ingredientsImage: recipe.ingredientsImage,
        );
        final idx = customRecipes.indexWhere((r) => r.id == recipe.id);
        if (idx >= 0) {
          customRecipes[idx] = updatedRecipe;
          await _persistCustomRecipes();
        }
      }
    } catch (e) {
      debugPrint("Cloud sync note (saved locally): $e");
    }

    return cloudSuccess;
  }

  /// Deletes a recipe from local storage and Firestore.
  static Future<bool> deleteRecipe(String id, {DocumentSnapshot? docSnap}) async {
    customRecipes.removeWhere((r) => r.id == id);
    await _persistCustomRecipes();

    bool cloudSuccess = false;
    try {
      if (docSnap != null) {
        await docSnap.reference.delete().timeout(const Duration(seconds: 4));
        cloudSuccess = true;
      } else if (id.isNotEmpty && !id.startsWith("custom_") && !id.startsWith("mock_")) {
        await FirebaseFirestore.instance
            .collection("Complete-Flutter-App")
            .doc(id)
            .delete()
            .timeout(const Duration(seconds: 4));
        cloudSuccess = true;
      }
    } catch (e) {
      debugPrint("Cloud delete note (deleted locally): $e");
    }
    return cloudSuccess;
  }

  // Auto-seeds Firestore with initial categories and recipes if empty
  static Future<void> seedFirestoreIfEmpty() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Fetch existing categories
      final catSnap = await firestore
          .collection("App-Category")
          .get()
          .timeout(const Duration(seconds: 4));

      final existingCatNames = catSnap.docs
          .map((doc) => doc.data()['name']?.toString() ?? "")
          .toSet();

      for (var cat in defaultCategories) {
        if (!existingCatNames.contains(cat['name'])) {
          try {
            await firestore
                .collection("App-Category")
                .add(cat)
                .timeout(const Duration(seconds: 3));
          } catch (e) {
            debugPrint("Category add error: $e");
          }
        }
      }

      // Check and seed / correct recipes in Firestore
      final recipeSnap = await firestore
          .collection("Complete-Flutter-App")
          .get()
          .timeout(const Duration(seconds: 5));

      for (var recipe in defaultRecipes) {
        final recipeName = (recipe['name']?.toString() ?? "").toLowerCase();
        final matchingDoc = recipeSnap.docs
            .cast<QueryDocumentSnapshot?>()
            .firstWhere(
              (d) =>
                  (d?.data() as Map<String, dynamic>?)?['name']
                      ?.toString()
                      .toLowerCase() ==
                  recipeName,
              orElse: () => null,
            );

        if (matchingDoc == null) {
          try {
            await firestore
                .collection("Complete-Flutter-App")
                .add(recipe)
                .timeout(const Duration(seconds: 3));
            debugPrint("Seeded recipe: ${recipe['name']}");
          } catch (e) {
            debugPrint("Recipe add note: $e");
          }
        } else {
          // If existing recipe in Firestore has wrong category or wrong image, correct it!
          final existingData = matchingDoc.data() as Map<String, dynamic>? ?? {};
          if (existingData['category'] != recipe['category'] ||
              existingData['image'] != recipe['image']) {
            try {
              await matchingDoc.reference.update({
                'category': recipe['category'],
                'image': recipe['image'],
                'ingredientsName': recipe['ingredientsName'],
                'ingredientsAmount': recipe['ingredientsAmount'],
                'ingredientsImage': recipe['ingredientsImage'],
              }).timeout(const Duration(seconds: 3));
              debugPrint("Corrected existing recipe: ${recipe['name']}");
            } catch (e) {
              debugPrint("Recipe correction note: $e");
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Note: Auto-seeding skipped or partial: $e");
    }
  }
}
