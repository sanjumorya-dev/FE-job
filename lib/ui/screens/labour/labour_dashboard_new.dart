import 'package:dihaadi_app/constants/colors.dart';
import 'package:dihaadi_app/ui/screens/labour/job_details_screen.dart';
import 'package:dihaadi_app/ui/screens/labour/my_applications_screen.dart';
import 'package:dihaadi_app/ui/screens/labour/work_history_screen.dart';
import 'package:dihaadi_app/ui/screens/loading_screen.dart';
import 'package:dihaadi_app/ui/screens/notifications_screen.dart';
import 'package:dihaadi_app/ui/screens/profile_screen.dart';
import 'package:dihaadi_app/ui/widgets/recent_job_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dihaadi_app/viewmodels/labour_viewmodel.dart';

class LabourDashboardNew extends StatefulWidget {
  const LabourDashboardNew({super.key});

  @override
  State<LabourDashboardNew> createState() => _LabourDashboardNewState();
}

class _LabourDashboardNewState extends State<LabourDashboardNew> {
  int _currentIndex = 0;

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
      const MyApplicationsScreen(),
      const NotificationsScreen(),
      ProfileScreen(),
    ];

    final titles = ['Home', 'Applications', 'Notifications', 'Profile'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        actions: _currentIndex == 1
            ? [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WorkHistoryScreen()),
                    );
                  },
                  icon: const Icon(Icons.history_rounded),
                  tooltip: 'Work History',
                ),
              ]
            : null,
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline_rounded),
            selectedIcon: Icon(Icons.work_rounded),
            label: 'Applications',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeFeed() {
    return Consumer<LabourViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const LoadingScreen();
        }

        if (viewModel.availableJobs.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => context.read<LabourViewModel>().fetchJobs(),
            child: ListView(
              children: const [
                SizedBox(height: 160),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.work_outline, size: 64, color: AppColors.textSecondary),
                      SizedBox(height: 12),
                      Text('No jobs available right now'),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<LabourViewModel>().fetchJobs(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.availableJobs.length,
            itemBuilder: (context, index) {
              final job = viewModel.availableJobs[index];
              return RecentJobTile(
                title: job.title,
                subtitle: job.address ?? 'Location TBD',
                statusText: 'Open',
                statusColor: Colors.green,
                footerText: '₹${job.salary ?? 'Negotiable'} / day',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => JobDetailsScreen(job: job)),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
