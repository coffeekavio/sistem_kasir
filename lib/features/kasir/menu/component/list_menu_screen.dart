import 'package:flutter/material.dart';
import 'package:kasir/store/data_menu.dart';
import 'package:kasir/features/kasir/menu/component/manual_screen.dart';

class ListMenuScreen extends StatelessWidget {
  final List<Map<String, dynamic>> filteredMenu;
  final String searchText;
  final TextEditingController searchController;
  final String selectedSection;
  final String selectedCategory;
  final Function(String) onSearchChanged;
  final Function(String) onCategoryChanged;
  final Function(String) onSectionChanged;
  final Function(Map<String, dynamic>) onAddToCart;
  final Function() onShowManualScreen;
  final Function(String) generateMenuAbbreviation;
  final Function(String, int)? onAddManualItem;

  const ListMenuScreen({
    super.key,
    required this.filteredMenu,
    required this.searchText,
    required this.searchController,
    required this.selectedSection,
    required this.selectedCategory,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onSectionChanged,
    required this.onAddToCart,
    required this.onShowManualScreen,
    required this.generateMenuAbbreviation,
    this.onAddManualItem,
  });

  static const List<String> _categories = [
    "All",
    "Coffee",
    "Beverages",
    "BBQ",
    "Snacks",
    "Desserts",
  ];

  static const List<String> _sections = ["Manual", "Produk", "Favorit"];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView.separated(
          itemCount: filteredMenu.length,
          separatorBuilder: (_, __) => SizedBox(height: 4),
          itemBuilder: (context, index) {
            final item = filteredMenu[index];
            return GestureDetector(
              onTap: () => onAddToCart(item),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Color(0xFF1E88E5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Text(
                                    generateMenuAbbreviation(item["name"]!),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                item["name"]!,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                  color: Color(0xFF3E2723),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF1E88E5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: Text(
                        "Rp ${item["price"]}",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
