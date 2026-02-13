import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dihaadi_app/viewmodels/labour_viewmodel.dart';
import 'package:dihaadi_app/viewmodels/auth_viewmodel.dart';
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
      extendBody: true,
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
      floatingActionButton: _buildCenterFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildModernNavigationBar(),
    );
  }

  Widget _buildModernNavigationBar() {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildNavItem(Icons.home_outlined, Icons.home_rounded, 0),
            _buildNavItem(Icons.work_outline_rounded, Icons.work_rounded, 1),
            const SizedBox(width: 56),
            _buildNavItem(Icons.calendar_today_outlined, Icons.calendar_month_rounded, 0),
            _buildNavItem(Icons.person_outline_rounded, Icons.person_rounded, 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData outlinedIcon, IconData filledIcon, int index) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => setState(() => _currentIndex = index),
        child: SizedBox(
          height: 34,
          child: Icon(
            isSelected ? filledIcon : outlinedIcon,
            color: isSelected ? AppColors.textMain : AppColors.inactive,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildCenterFab() {
    return Container(
      width: 62,
      height: 62,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2C313A),
        border: Border.all(color: Colors.white, width: 5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () => setState(() => _currentIndex = 1),
        icon: const Icon(Icons.add, color: Colors.white, size: 24),
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
              Consumer<AuthViewModel>(
                builder: (context, authVM, _) {
                  final user = authVM.currentUser;
                  return DashboardHeader(
                    userName: user?.name ?? 'Labour',
                    subtitle: 'Skilled worker', // Could be dynamic based on work type if available
                    isOwner: false,
                    imageUrl: 'https://ui-avatars.com/api/?name=${user?.name ?? "User"}&background=random',
                    isAvailable: viewModel.isAvailable,
                    onAvailabilityChanged: (value) =>
                        viewModel.toggleAvailability(value),
                    onNotificationTap: () {
                      // Handle notification tap
                    },
                  );
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
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              appBar: AppBar(title: const Text('My Applications')),
                              body: Consumer<LabourViewModel>(
                                builder: (context, vm, _) {
                                  if (vm.recentApplications.isEmpty) {
                                    return const Center(child: Text('No applications found'));
                                  }
                                  return ListView.builder(
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
                                              MaterialPageRoute(
                                                builder: (context) => JobDetailsScreen(job: job),
                                              ),
                                            );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        );
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
                      // Use real status from job
                      statusText: _getStatusText(job.status ?? 0), 
                      statusColor: _getStatusColor(job.status ?? 0),
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
    return DateFormat('dd MMM yyyy').format(date.toLocal());
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Active';
      case 2:
        return 'Completed';
      case 3:
        return 'Cancelled';
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
        return Colors.blue;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
