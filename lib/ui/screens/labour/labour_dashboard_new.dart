import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dihaadi_app/viewmodels/labour_viewmodel.dart';
import 'package:dihaadi_app/ui/screens/profile_screen.dart';
import 'package:dihaadi_app/ui/screens/labour/job_details_screen.dart';
import 'package:dihaadi_app/ui/screens/loading_screen.dart';
import 'package:dihaadi_app/constants/colors.dart';
import 'package:dihaadi_app/ui/widgets/dashboard_header.dart';
import 'package:dihaadi_app/ui/widgets/stats_grid.dart';
import 'package:dihaadi_app/ui/widgets/recent_job_tile.dart';

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
      context.read<LabourViewModel>().fetchJobs();
      context.read<LabourViewModel>().fetchDashboardStats();
      context.read<LabourViewModel>().fetchRecentApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildDashboard(),
      _buildJobs(),
      ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      // Hide AppBar for Dashboard tab
      appBar: _currentIndex == 0
          ? null
          : AppBar(
              title: const Text(
                'Find Jobs',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              elevation: 0,
              centerTitle: false,
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textMain,
            ),
      body: screens[_currentIndex],
      bottomNavigationBar: _buildModernNavigationBar(),
    );
  }

  Widget _buildModernNavigationBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
          _buildNavItem(Icons.work_outline, Icons.work, 'Jobs', 1),
          _buildNavItem(Icons.person_outline, Icons.person, 'Profile', 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      IconData outlinedIcon, IconData filledIcon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? filledIcon : outlinedIcon,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Consumer<LabourViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const LoadingScreen();
        }

        final stats = viewModel.stats;
        final statItems = [
          StatItem(
            label: 'Jobs Applied',
            value: stats['jobsApplied']!,
            icon: Icons.send_outlined,
            color: Colors.blue,
          ),
          StatItem(
            label: 'Approved',
            value: stats['approved']!,
            icon: Icons.check_circle_outline,
            color: Colors.green,
          ),
          StatItem(
            label: 'Ongoing',
            value: stats['ongoing']!,
            icon: Icons.timelapse,
            color: Colors.orange,
          ),
          StatItem(
            label: 'Total Earnings',
            value: '₹${stats['earnings']}',
            icon: Icons.account_balance_wallet_outlined,
            color: Colors.purple,
          ),
        ];

        return SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              DashboardHeader(
                userName: 'Rajesh Kumar', // TODO: Get from Auth Provider
                subtitle: 'Master Carpenter',
                isOwner: false,
                imageUrl: 'https://i.pravatar.cc/150?u=rajesh', // Mock image
                isAvailable: viewModel.isAvailable,
                onAvailabilityChanged: (value) => viewModel.toggleAvailability(value),
                onNotificationTap: () {
                   // Handle notification tap
                },
              ),

              // 2. Stats Grid
              Transform.translate(
                offset: const Offset(0, -40),
                child: StatsGrid(stats: statItems),
              ),

              // 3. Recently Applied
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recently Applied',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to full applications list (not implemented yet)
                      },
                      child: const Text('View all'),
                    ),
                  ],
                ),
              ),

              if (viewModel.recentApplications.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No applications yet'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: viewModel.recentApplications.length,
                  itemBuilder: (context, index) {
                    final job = viewModel.recentApplications[index];
                    return RecentJobTile(
                      title: job.title,
                      subtitle: job.address ?? 'Location TBD',
                      // Mocking status for applications
                      statusText: _getMockApplicationStatus(index), 
                      statusColor: _getMockApplicationColor(index),
                      footerText: 'Applied on ${_formatDate(job.date)}',
                      onTap: () {
                        // Show details
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
                const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJobs() {
    return Consumer<LabourViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const LoadingScreen();
        }

         if (viewModel.availableJobs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.work_outline,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Jobs Available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: viewModel.availableJobs.length,
          itemBuilder: (context, index) {
            final job = viewModel.availableJobs[index];
            return RecentJobTile(
               title: job.title,
               subtitle: job.address ?? 'Location TBD',
               statusText: 'New',
               statusColor: Colors.green,
               footerText: '₹${job.salary ?? "Negotiable"} / day',
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
        );
      },
    );
  }
  
  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getMockApplicationStatus(int index) {
    if (index == 0) return 'Pending';
    if (index == 1) return 'Reviewed';
    return 'Rejected';
  }

  Color _getMockApplicationColor(int index) {
     if (index == 0) return Colors.orange;
    if (index == 1) return Colors.blue;
    return Colors.red;
  }
}
