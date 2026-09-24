import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class AdminConsoleScreen extends StatelessWidget {
  const AdminConsoleScreen({super.key});

  Future<void> _updateStatus(BuildContext context, String uid, String name, String status) async {
    final isAccept = status == 'approved';
    
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'status': status,
      'notificationMessage': isAccept 
          ? 'Congratulations! Your freelancer application has been accepted.' 
          : 'We regret to inform you that your freelancer application was declined.',
      'reviewedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name has been ${isAccept ? "Approved" : "Declined"}.'),
          backgroundColor: isAccept ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: const Text('Admin Oversight', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'freelancer')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No pending freelancer applications', style: TextStyle(color: textMuted)),
            );
          }

          final applicants = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: applicants.length,
            itemBuilder: (context, index) {
              final doc = applicants[index];
              final data = doc.data() as Map<String, dynamic>;
              final uid = doc.id;
              final companyName = data['companyName'] ?? data['name'] ?? 'Unnamed Applicant';
              final category = data['category'] ?? 'Trade Unspecified';
              final phone = data['phone'] ?? 'No contact';

              return Card(
                color: darkCard,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: darkCardBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(companyName, style: const TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('PENDING', style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Category: $category', style: const TextStyle(color: lightAccent, fontSize: 13)),
                      Text('Contact: $phone', style: const TextStyle(color: textMuted, fontSize: 12)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.redAccent),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => _updateStatus(context, uid, companyName, 'declined'),
                              child: const Text('Decline', style: TextStyle(color: Colors.redAccent)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => _updateStatus(context, uid, companyName, 'approved'),
                              child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}