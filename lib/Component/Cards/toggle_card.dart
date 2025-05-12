import 'package:flutter/material.dart';
import 'package:insta_attend/Constant/constant_color.dart';

class ToggleCard extends StatefulWidget {
  final List<String> items;
  final Function(int index) onSelected;

  const ToggleCard({
    super.key,
    required this.items,
    required this.onSelected,
  });

  @override
  State<ToggleCard> createState() => _ToggleCardState();
}

class _ToggleCardState extends State<ToggleCard> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: List.generate(widget.items.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
                widget.onSelected(index);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Color(0xFF7C3AED) : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Text(
                    widget.items[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : kcGrey600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
