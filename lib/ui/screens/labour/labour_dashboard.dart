import 'package:dihaadi_app/constants/colors.dart';
import 'package:dihaadi_app/ui/screens/labour/job_details_screen.dart';
import 'package:dihaadi_app/ui/screens/labour/my_applications_screen.dart';
import 'package:dihaadi_app/ui/screens/labour/worker_chat_list_screen.dart';
import 'package:dihaadi_app/ui/screens/loading_screen.dart';
import 'package:dihaadi_app/ui/screens/profile_screen.dart';
import 'package:dihaadi_app/ui/widgets/worker_dashboard_header.dart';
import 'package:dihaadi_app/ui/widgets/worker_stats_grid.dart';
import 'package:dihaadi_app/ui/widgets/worker_status_banner.dart';
import 'package:dihaadi_app/ui/widgets/job_search_header.dart';
import 'package:dihaadi_app/ui/widgets/worker_job_card.dart';
import 'package:dihaadi_app/ui/screens/labour/worker_find_job_screen.dart';
import 'package:dihaadi_app/viewmodels/auth_viewmodel.dart';
import 'package:dihaadi_app/viewmodels/labour_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LabourDashboard extends StatefulWidget {
  const LabourDashboard({super.key});

  @override
  State<LabourDashboard> createState() => _LabourDashboardState();
}

class _LabourDashboardState extends State<LabourDashboard> {
  int _currentIndex = 0;
  int _selectedFilterIndex = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<LabourViewModel>();
      vm.fetchJobs();
      vm.fetchDashboardStats();
      vm.fetchRecentApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeFeed(),
      const WorkerFindJobScreen(),
      const MyApplicationsScreen(),
      const WorkerChatListScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: screens[_currentIndex],
      bottomNavigationBar: _buildModernNavigationBar(),
    );
  }

  Widget _buildModernNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: AppColors.primary.withValues(alpha: 0.1),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  );
                }
                return const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textHint,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(color: AppColors.primary, size: 24);
                }
                return const IconThemeData(color: AppColors.textHint, size: 24);
              }),
            ),
            child: NavigationBar(
              height: 65,
              elevation: 0,
              backgroundColor: Colors.transparent,
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) => setState(() => _currentIndex = index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.search_rounded),
                  label: 'Jobs',
                ),
                NavigationDestination(
                  icon: Icon(Icons.assignment_rounded),
                  label: 'Applied',
                ),
                NavigationDestination(
                  icon: Icon(Icons.chat_bubble_rounded),
                  label: 'Chat',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeFeed() {
    return Consumer<LabourViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const LoadingScreen();
        }

        final stats = viewModel.stats;

        return RefreshIndicator(
          onRefresh: () async {
            await viewModel.fetchJobs();
            await viewModel.fetchDashboardStats();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<AuthViewModel>(
                  builder: (context, authVm, child) {
                    final user = authVm.currentUser;
                    return WorkerDashboardHeader(
                      userName: user?.name ?? 'Rahul',
                      location: user?.addresses?.isNotEmpty == true
                          ? '${user!.addresses![0]['city']}, ${user.addresses![0]['state']}'
                          : 'Mumbai, Maharashtra',
                      onNotificationTap: () {},
                      onProfileTap: () => setState(() => _currentIndex = 3),
                    );
                  },
                ),

                WorkerStatsGrid(
                  tasksCompleted: int.tryParse(stats['approved'] ?? '0') ?? 0,
                  requestedJobs: int.tryParse(stats['jobsApplied'] ?? '0') ?? 0,
                  monthlyEarnings:
                      double.tryParse(stats['earnings'] ?? '0') ?? 0,
                  averageRating: viewModel.averageRating > 0
                      ? viewModel.averageRating
                      : 0.0,
                ),

                WorkerStatusBanner(
                  activeApplications: viewModel.recentApplications.length,
                  isAvailable: viewModel.isAvailable,
                  onAvailabilityChanged: (val) =>
                      viewModel.toggleAvailability(val),
                ),

                JobSearchHeader(
                  title: 'Find Jobs',
                  selectedIndex: _selectedFilterIndex,
                  filterTabs: [
                    'Available',
                    'Applied (${viewModel.recentApplications.length})',
                    'In Progress (${stats['ongoing'] ?? '0'})',
                    'Completed (${stats['completed'] ?? '0'})'
                  ],
                  onTabChanged: (index) => setState(() => _selectedFilterIndex = index),
                  onSearchChanged: (val) => setState(() => _searchQuery = val),
                  onFilterTap: () {},
                ),

                if (viewModel.availableJobs.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(60.0),
                      child: Column(
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: AppColors.textHint),
                          SizedBox(height: 16),
                          Text(
                            'No jobs available right now',
                            style: TextStyle(color: AppColors.textHint, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: viewModel.availableJobs.length,
                    itemBuilder: (context, index) {
                      final job = viewModel.availableJobs[index];
                      return WorkerJobCard(
                        requirement: job,
                        isApplied: viewModel.recentApplications
                            .any((a) => a.id == job.id),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    JobDetailsScreen(job: job)),
                          );
                        },
                      );
                    },
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}

