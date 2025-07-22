import 'package:flutter/material.dart';

class ActionZone extends StatelessWidget {
  const ActionZone({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey[50],
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Category Rail
          SizedBox(
            width: 150,
            child: ListView(
              children: [
                _buildCategoryButton(context, 'All', isSelected: true),
                _buildCategoryButton(context, 'Appetizers'),
                _buildCategoryButton(context, 'Mains'),
                _buildCategoryButton(context, 'Desserts'),
                _buildCategoryButton(context, 'Drinks'),
              ],
            ),
          ),
          const VerticalDivider(),
          // Main Action Area
          Expanded(
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search items by name or code...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16.0),
                // Menu Item Grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 150,
                          childAspectRatio: 3 / 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: 20, // Placeholder count
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 2,
                        child: InkWell(
                          onTap: () {
                            // Add item to order logic
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.fastfood),
                              const SizedBox(height: 8),
                              Text('Item ${index + 1}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(
    BuildContext context,
    String title, {
    bool isSelected = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? Theme.of(context).primaryColor
              : Colors.white,
          foregroundColor: isSelected
              ? Colors.white
              : Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(title),
      ),
    );
  }
}
