import 'package:flutter/material.dart';

import '../models/philippine_cities.dart';

class CityPickerSheet extends StatefulWidget {
  final String activeCity;
  const CityPickerSheet({super.key, required this.activeCity});

  @override
  State<CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<CityPickerSheet> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final cities = philippineCities
        .where((c) => c.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Operating/Saved City',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (val) => setState(() => query = val),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search city...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: cities.length,
                  itemBuilder: (context, index) {
                    final city = cities[index];
                    return ListTile(
                      title: Text(city),
                      trailing: city == widget.activeCity
                          ? const Icon(Icons.check_circle, color: Colors.blue)
                          : null,
                      onTap: () => Navigator.pop(context, city),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
