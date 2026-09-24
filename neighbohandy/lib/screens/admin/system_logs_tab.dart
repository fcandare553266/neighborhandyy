import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class SystemLogsTab extends StatefulWidget {
  const SystemLogsTab({super.key});

  @override
  State<SystemLogsTab> createState() => _SystemLogsTabState();
}

class _SystemLogsTabState extends State<SystemLogsTab> {
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            style: const TextStyle(color: textPrimary),
            decoration: InputDecoration(
              hintText: 'Filter by user or action...',
              hintStyle: const TextStyle(color: textMuted, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: textMuted),
              filled: true,
              fillColor: darkCard,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: darkCardBorder),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('system_logs')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                final totalPages = (docs.length / _itemsPerPage).ceil().clamp(1, 99);

                final startIndex = (_currentPage - 1) * _itemsPerPage;
                final pageDocs = docs.skip(startIndex).take(_itemsPerPage).toList();

                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: darkCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: darkCardBorder),
                      ),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(1),
                        },
                        children: [
                          const TableRow(
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: darkCardBorder)),
                            ),
                            children: [
                              Padding(padding: EdgeInsets.all(10), child: Text('Action', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 12))),
                              Padding(padding: EdgeInsets.all(10), child: Text('By', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 12))),
                              Padding(padding: EdgeInsets.all(10), child: Text('Time', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 12))),
                            ],
                          ),
                          ...pageDocs.map((doc) {
                            final data = doc.data();
                            final timeStamp = (data['timestamp'] as Timestamp?)?.toDate();
                            final timeStr = timeStamp != null ? '${timeStamp.hour}:${timeStamp.minute.toString().padLeft(2, '0')}' : 'Just now';

                            return TableRow(
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: darkCardBorder)),
                              ),
                              children: [
                                Padding(padding: const EdgeInsets.all(10), child: Text(data['action'] ?? '', style: const TextStyle(color: textPrimary, fontSize: 11))),
                                Padding(padding: const EdgeInsets.all(10), child: Text(data['by'] ?? 'System', style: const TextStyle(color: textMuted, fontSize: 11))),
                                Padding(padding: const EdgeInsets.all(10), child: Text(timeStr, style: const TextStyle(color: textMuted, fontSize: 11))),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkCard,
                            side: const BorderSide(color: darkCardBorder),
                          ),
                          onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                          icon: const Icon(Icons.arrow_left, size: 16),
                          label: const Text('Prev'),
                        ),
                        Text('Page $_currentPage of $totalPages', style: const TextStyle(color: textMuted, fontSize: 12)),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkCard,
                            side: const BorderSide(color: darkCardBorder),
                          ),
                          onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
                          icon: const Icon(Icons.arrow_right, size: 16),
                          label: const Text('Next'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}