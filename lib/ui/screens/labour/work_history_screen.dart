import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dihaadi_app/viewmodels/labour_viewmodel.dart';
import 'package:dihaadi_app/ui/widgets/status_badge.dart';

class WorkHistoryScreen extends StatelessWidget {
  const WorkHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Work History')),
      body: Consumer<LabourViewModel>(
        builder: (context, vm, child) {
          final completed = vm.recentApplications.where((e) => (e.status ?? 0) == 3).toList();
          if (completed.isEmpty) {
            return const Center(child: Text('No completed jobs yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: completed.length,
            itemBuilder: (context, index) {
              final job = completed[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            job.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const StatusBadge(status: 'Completed'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(job.address ?? 'Location not available'),
                    const SizedBox(height: 6),
                    Text('Date: ${job.date != null ? DateFormat('dd MMM yyyy').format(job.date!.toLocal()) : 'N/A'}'),
                    const SizedBox(height: 6),
                    Text('Wage: ₹${job.salary?.toStringAsFixed(0) ?? 'N/A'}'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
