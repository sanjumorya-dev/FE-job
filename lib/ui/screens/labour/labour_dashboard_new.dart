import 'package:dihaadi_app/constants/colors.dart';
import 'package:dihaadi_app/ui/screens/labour/job_details_screen.dart';
import 'package:dihaadi_app/ui/screens/loading_screen.dart';
import 'package:dihaadi_app/ui/screens/profile_screen.dart';
import 'package:dihaadi_app/ui/widgets/recent_job_tile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      _buildMyApplications(),
      _buildNotifications(),
      ProfileScreen(),
    ];

    final titles = ['Home', 'Applications', 'Notifications', 'Profile'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        centerTitle: false,
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.work_outline_rounded), selectedIcon: Icon(Icons.work_rounded), label: 'Applications'),
          NavigationDestination(icon: Icon(Icons.notifications_none_rounded), selectedIcon: Icon(Icons.notifications_rounded), label: 'Notifications'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
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

  Widget _buildMyApplications() {
    return Consumer<LabourViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const LoadingScreen();
        }

        if (vm.recentApplications.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => context.read<LabourViewModel>().fetchRecentApplications(),
            child: ListView(
              children: const [
                SizedBox(height: 160),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.assignment_late_outlined, size: 64, color: AppColors.textSecondary),
                      SizedBox(height: 12),
                      Text('No applications yet'),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<LabourViewModel>().fetchRecentApplications(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vm.recentApplications.length,
            itemBuilder: (context, index) {
              final job = vm.recentApplications[index];
              return RecentJobTile(
                title: job.title,
                subtitle: job.address ?? 'Location TBD',
                statusText: _getStatusText(job.status ?? 0),
                statusColor: _getStatusColor(job.status ?? 0),
                footerText: 'Applied on ${_formatDate(job.date)}',
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

  Widget _buildNotifications() {
    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _NotificationTile(
            title: 'Application Accepted',
            message: 'Your application for CCTV Technician has been accepted.',
          ),
          _NotificationTile(
            title: 'Application Rejected',
            message: 'Owner rejected your application for Electrician job.',
          ),
          _NotificationTile(
            title: 'New nearby job',
            message: 'A new job has been posted near your location.',
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(date.toLocal());
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Accepted';
      case 2:
        return 'Rejected';
      case 3:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      case 3:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final String title;
  final String message;
  const _NotificationTile({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(message, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
