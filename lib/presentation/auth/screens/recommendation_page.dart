import 'package:flutter/material.dart';

class RecommendationPage extends StatelessWidget {
  const RecommendationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> recommendations = [
      'Maintain a low-salt and low-fat diet.',
      'Exercise at least 30 minutes per day.',
      'Monitor blood pressure regularly.',
      'Avoid smoking and alcohol.',
      'Consult a cardiologist for further evaluation.',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      //  APPBAR 
      appBar: AppBar(
        centerTitle: true,

        title: const Text(
          'Recommendations',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
      ),

      //  BODY 
      body: ListView.builder(
        padding: const EdgeInsets.all(16),

        itemCount: recommendations.length,

        itemBuilder: (context, index) {
          return Card(
            elevation: 2,

            margin: const EdgeInsets.only(
              bottom: 14,
            ),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),

            child: ListTile(
              contentPadding: const EdgeInsets.all(16),

              leading: Container(
                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: const Color(0xFF10B981)
                      .withOpacity(0.1),

                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                ),
              ),

              title: Text(
                recommendations[index],

                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          );
        },
      ),

      //  BUTTON 
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),

        child: SizedBox(
          width: double.infinity,
          height: 56,

          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),

            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                '/',
              );
            },

            child: const Text(
              'Back to Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}