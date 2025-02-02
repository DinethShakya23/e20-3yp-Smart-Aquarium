import 'package:flutter/material.dart';

class SearchButton extends StatelessWidget {
  final bool isSearching;
  final VoidCallback onPressed;

  const SearchButton(this.isSearching, this.onPressed, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isSearching ? Icons.close : Icons.search, color: Colors.white),
      onPressed: onPressed,
    );
  }
}
