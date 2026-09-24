import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class PendingApprovalsTab extends StatelessWidget {
  const PendingApprovalsTab({super.key});

  Future<void> _approveUser(String docId, String userName) async {
    await FirebaseFirestore.instance.collection('users').doc(docId).update({
      'status': 'Verified',
      'approvalStatus': 'Approved',
    });
    await FirebaseFirestore.instance.collection('system_logs').add({
      'action': 'Approved $userName',
      'by': 'You',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('pending_approvals')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(
            child: Text('No pending approvals or disputes.', style: TextStyle(color: textMuted)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            final isDispute = data['type'] == 'dispute';
            final title = data['title'] ?? data['name'] ?? 'Pending Item';
            final subtitle = data['subtitle'] ?? '';
            final note = data['note'] ?? '';
            final statusLabel = data['statusLabel'] ?? 'Awaiting review';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: darkCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: darkCardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: darkCardBorder,
                        child: Icon(isDispute ? Icons.gavel : Icons.person, color: textPrimary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                            if (subtitle.isNotEmpty) Text(subtitle, style: const TextStyle(color: textMuted, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (note.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(note, style: const TextStyle(color: textMuted, fontSize: 12)),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusLabel.contains('Missing') ? const Color(0xFF3D1E1E) : const Color(0xFF3D2D1E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusLabel.contains('Missing') ? coralDestructive : const Color(0xFFFFB067),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (!isDispute)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: darkCardBorder),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {},
                            child: const Text('View docs', style: TextStyle(color: textPrimary)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF62D2A2),
                              foregroundColor: darkBackground,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => _approveUser(doc.id, title),
                            child: const Text('Approve', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}