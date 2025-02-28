import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onChanged;

  const SearchField(this.searchController, this.onChanged, {super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchController,
      autofocus: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Search...",
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        border: InputBorder.none,
      ),
      onChanged: onChanged,
    );
  }
}
