// lib/widgets/side_menu.dart
import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  final String selectedPage;
  final Function(String) onSelect;

  const SideMenu({super.key, required this.selectedPage, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final menuItems = ['Товары', 'Изображения товаров', 'Категории', 'Заказы'];

    return Container(
      width: 240,
      color: Colors.grey[200],
      child: ListView(
        children: menuItems.map((item) {
          final isSelected = selectedPage == item;
          return ListTile(
            title: Text(
              item,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue : Colors.black,
              ),
            ),
            selected: isSelected,
            onTap: () => onSelect(item),
          );
        }).toList(),
      ),
    );
  }
}
