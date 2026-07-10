import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../../../viewmodels/labour_viewmodel.dart';
import '../../widgets/job_search_header.dart';
import '../../widgets/worker_job_card.dart';
import '../loading_screen.dart';
import 'job_details_screen.dart';

class WorkerFindJobScreen extends StatefulWidget {
  const WorkerFindJobScreen({super.key});

  @override
  State<WorkerFindJobScreen> createState() => _WorkerFindJobScreenState();
}

class _WorkerFindJobScreenState extends State<WorkerFindJobScreen> {
  int _selectedFilterIndex = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LabourViewModel>().fetchJobs();
      context.read<LabourViewModel>().fetchRecentApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Subtle off-white background from design
      body: SafeArea(
        child: Consumer<LabourViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.availableJobs.isEmpty) {
              return const LoadingScreen();
            }

            // Local filtering based on tabs
            final filteredJobs = viewModel.recentApplications.where((job) {
              final matchesSearch = _searchQuery.isEmpty ||
                  job.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  (job.address?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

              final status = (job.status ?? 0) as int;
              switch (_selectedFilterIndex) {
                case 1: // Pending applications
                  return status == 0 && matchesSearch;
                case 2: // In Progress (Accepted)
                  return status == 1 && matchesSearch;
                case 3: // Completed
                  return status == 3 && matchesSearch;
                default: // Available (not yet applied)
                  return !viewModel.recentApplications.any((a) => a.id == job.id) && matchesSearch;
              }
            }).toList();

            return Column(
              children: [
                JobSearchHeader(
                  title: 'Find Jobs',
                  selectedIndex: _selectedFilterIndex,
                  filterTabs: [
                    'Available',
                    'Applied (${viewModel.recentApplications.length})',
                    'In Progress (${viewModel.stats['ongoing'] ?? '0'})',
                    'Completed (${viewModel.stats['completed'] ?? '0'})'
                  ],
                  onTabChanged: (index) => setState(() => _selectedFilterIndex = index),
                  onSearchChanged: (val) => setState(() => _searchQuery = val),
                  onFilterTap: () {
                    // Show filter bottom sheet or dialog
                  },
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await viewModel.fetchJobs();
                      await viewModel.fetchRecentApplications();
                    },
                    child: filteredJobs.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            itemCount: filteredJobs.length,
                            itemBuilder: (context, index) {
                              final job = filteredJobs[index];
                              return WorkerJobCard(
                                requirement: job,
                                isApplied: viewModel.recentApplications
                                    .any((a) => a.id == job.id),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => JobDetailsScreen(job: job),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(60.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No jobs found',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Try adjusting your search or filters',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
