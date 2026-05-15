import 'package:flutter/material.dart';

class FilterButtonList extends StatefulWidget {
  final List<String> filters;
  final Function(String) onSelected;

  const FilterButtonList({
    super.key,
    required this.filters,
    required this.onSelected,
  });

  @override
  State<FilterButtonList> createState() => _FilterButtonListState();
}

class _FilterButtonListState extends State<FilterButtonList> {
  String _selected = '';

  @override
  void initState() {
    super.initState();
    _selected = widget.filters.first; // default select first button
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.filters.map((filter) {
        final isSelected = _selected == filter;
        return TextButton(
          onPressed: () {
            setState(() => _selected = filter);
            widget.onSelected(filter);
          },
          style: TextButton.styleFrom(
            backgroundColor: isSelected ? Colors.lightGreen : Colors.grey[300],
            minimumSize: Size(50, 16),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            filter,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              letterSpacing: 2,
            ),
          ),
        );
      }).toList(),
    );
  }
}
