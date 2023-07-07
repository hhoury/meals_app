import 'package:flutter/material.dart';
import 'package:meals_app/data/dummy_data.dart';
import 'package:meals_app/models/meal.dart';
import 'package:meals_app/screens/categories.dart';
import 'package:meals_app/screens/filters.dart';
import 'package:meals_app/screens/meals.dart';
import 'package:meals_app/widgets/main_drawer.dart';

const kInitialFilters = {
  Filter.glutenFree: false,
  Filter.lactoseFree: false,
  Filter.vegetarian: false,
  Filter.vegan: false,
};

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;
  final List<Meal> _favoriteMeals = [];
  Map<Filter, bool> _selectedFilters = kInitialFilters;
  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _toggleMealFavoriteStatus(Meal meal) {
    final isExisting = _favoriteMeals.contains(meal);
    if (isExisting) {
      setState(() {
        _favoriteMeals.remove(meal);
      });
      _showInfoMessage('Meal Removed From Favorites!');
    } else {
      setState(() {
        _favoriteMeals.add(meal);
      });
      _showInfoMessage('Meal Set As Favorite!');
    }
  }

  void _setScreen(String identifier) async {
    Navigator.of(context).pop();
    switch (identifier) {
      case 'filters':
        final result = await Navigator.of(context).push<Map<Filter, bool>>(
          MaterialPageRoute(
            builder: (ctx) => FiltersScreen(
              currentFilters: _selectedFilters,
            ),
          ),
        );
        setState(() {
          _selectedFilters = result ?? kInitialFilters;
        });
        break;
      default:
    }
  }

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final availableMeals = dummyMeals
        .where((meal) =>
            meal.isGlutenFree == _selectedFilters[Filter.glutenFree] &&
            meal.isLactoseFree == _selectedFilters[Filter.lactoseFree] &&
            meal.isVegetarian == _selectedFilters[Filter.vegetarian] &&
            meal.isVegan == _selectedFilters[Filter.vegan])
        .toList();
    Widget activePage = CategoriesScreen(
      onToggleFavoriteMeal: _toggleMealFavoriteStatus,
      availableMeals: availableMeals,
    );
    String activePageTitle = 'Categories';
    if (_selectedPageIndex == 1) {
      activePageTitle = 'Your Favorites';
      activePage = MealsScreen(
        meals: _favoriteMeals,
        onToggleFavoriteMeal: _toggleMealFavoriteStatus,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(activePageTitle),
      ),
      drawer: MainDrawer(
        onSelectScreen: _setScreen,
      ),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.set_meal), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favorites'),
        ],
        onTap: _selectPage,
      ),
    );
  }
}
