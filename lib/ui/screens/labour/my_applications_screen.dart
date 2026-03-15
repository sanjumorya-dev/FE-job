import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dihaadi_app/constants/colors.dart';
import 'package:dihaadi_app/viewmodels/labour_viewmodel.dart';
import 'package:dihaadi_app/ui/widgets/status_badge.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = ['Pending', 'Accepted', 'Rejected', 'Completed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<dynamic> _filterByTab(List<dynamic> items, String tab) {
    return items.where((job) {
      final status = (job.status ?? 0) as int;
      switch (tab) {
        case 'Pending':
          return status == 0;
        case 'Accepted':
          return status == 1;
        case 'Rejected':
          return status == 2;
        case 'Completed':
          return status == 3;
        default:
          return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: _tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
        Expanded(
          child: Consumer<LabourViewModel>(
            builder: (context, vm, child) {
              if (vm.isLoading) return const Center(child: CircularProgressIndicator());

              return RefreshIndicator(
                onRefresh: () => vm.fetchRecentApplications(),
                child: TabBarView(
                  controller: _tabController,
                  children: _tabs.map((tab) {
                    final data = _filterByTab(vm.recentApplications, tab);
                    if (data.isEmpty) {
                      return ListView(
                        children: [
                          const SizedBox(height: 180),
                          Center(child: Text('No $tab applications')),
                        ],
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final job = data[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderLight),
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
                                  StatusBadge(status: tab),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(job.address ?? 'Location TBD'),
                              const SizedBox(height: 4),
                              Text(
                                'Applied: ${job.date != null ? DateFormat('dd MMM yyyy').format(job.date!.toLocal()) : 'N/A'}',
                                style: const TextStyle(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
