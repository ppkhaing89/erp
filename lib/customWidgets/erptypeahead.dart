import 'package:flutter/cupertino.dart';

class ERPTypeahead extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool disabled;
  final String value;
  final dynamic options;

  const ERPTypeahead({
    super.key,
    required this.label,
    required this.controller,
    required this.disabled,
    required this.value,
    required this.options,
  });

  @override
  State<ERPTypeahead> createState() => _ERPTypeaheadState();
}

class _ERPTypeaheadState extends State<ERPTypeahead> {
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _updateSuggestions('');
  }

  void _updateSuggestions(String query) {
    setState(() {
      _suggestions = widget.options
          .where((option) =>
              option[widget.value].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: CupertinoColors.black,
            fontSize: 14.0,
          ),
        ),
        CupertinoTextField(
          controller: widget.controller,
          onChanged: _updateSuggestions,
          placeholder: 'Type here',
        ),
        CupertinoPopupSurface(
          child: Column(
            children: _suggestions.map((suggestion) {
              return GestureDetector(
                onTap: () {
                  widget.controller.text = suggestion;
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(suggestion),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
