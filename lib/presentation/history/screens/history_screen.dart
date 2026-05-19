import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> histories = [
      {'date': '10 May 2026', 'risk': 'High Risk', 'probability': '87%'},

      {'date': '02 May 2026', 'risk': 'Medium Risk', 'probability': '56%'},

      {'date': '20 Apr 2026', 'risk': 'Low Risk', 'probability': '21%'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      //  APPBAR
      appBar: AppBar(
        centerTitle: true,

        title: const Text(
          'Prediction History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
      ),

      //  BODY
      body: ListView.builder(
        padding: const EdgeInsets.all(16),

        itemCount: histories.length,

        itemBuilder: (context, index) {
          final item = histories[index];

          return Card(
            elevation: 2,

            margin: const EdgeInsets.only(bottom: 16),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),

            child: ListTile(
              contentPadding: const EdgeInsets.all(16),

              leading: CircleAvatar(
                radius: 26,

                backgroundColor: const Color(0xFF10B981).withOpacity(0.1),

                child: const Icon(Icons.favorite, color: Color(0xFF10B981)),
              ),

              title: Text(
                item['risk'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),

                child: Text(
                  '${item['date']}\nProbability: ${item['probability']}',
                  style: const TextStyle(height: 1.5, color: Colors.grey),
                ),
              ),

              isThreeLine: true,

              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),

              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item['risk']} selected')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
