import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dihaadi_app/viewmodels/owner_viewmodel.dart';
import 'package:dihaadi_app/ui/screens/profile_screen.dart';
import 'package:dihaadi_app/ui/screens/loading_screen.dart';
import 'package:dihaadi_app/constants/colors.dart';
import 'package:dihaadi_app/ui/widgets/dashboard_header.dart';
import 'package:dihaadi_app/ui/widgets/stats_grid.dart';
import 'package:dihaadi_app/ui/widgets/recent_job_tile.dart';
import 'package:dihaadi_app/ui/screens/owner/edit_requirement_screen.dart';

class OwnerDashboardNew extends StatefulWidget {
  const OwnerDashboardNew({super.key});

  @override
  State<OwnerDashboardNew> createState() => _OwnerDashboardNewState();
}

class _OwnerDashboardNewState extends State<OwnerDashboardNew> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OwnerViewModel>().fetchMyRequirements();
      context.read<OwnerViewModel>().fetchDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildDashboard(),
      _buildRequirements(),
      ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      // Hide AppBar for Dashboard tab as it has a custom header
      appBar: _currentIndex == 0
          ? null
          : AppBar(
              title: Text(_currentIndex == 1 ? 'My Requirements' : 'Profile'),
              elevation: 0,
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
            _buildNavItem(Icons.list_alt_outlined, Icons.list_alt_rounded, 1),
            const SizedBox(width: 56),
            _buildGhostItem(Icons.notifications_none_rounded),
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
        onTap: () {
          setState(() => _currentIndex = index);
          if (index == 1) {
            context.read<OwnerViewModel>().fetchMyRequirements();
          }
        },
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

  Widget _buildGhostItem(IconData icon) {
    return Expanded(
      child: SizedBox(
        height: 34,
        child: Icon(icon, color: AppColors.inactive, size: 20),
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
        onPressed: () {
          setState(() => _currentIndex = 1);
          context.read<OwnerViewModel>().fetchMyRequirements();
        },
        icon: const Icon(Icons.add, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildDashboard() {
    return Consumer<OwnerViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const LoadingScreen();
        }

        final stats = viewModel.stats;
        final statItems = [
          StatItem(
            label: 'Active Req.',
            value: stats['activeReq']!,
            icon: Icons.campaign_outlined,
            color: Colors.blue,
          ),
          StatItem(
            label: 'Total Applicants',
            value: stats['totalApplicants']!,
            icon: Icons.people_outline,
            color: Colors.orange,
          ),
          StatItem(
            label: 'Hired Labour',
            value: stats['hiredLabour']!,
            icon: Icons.handshake_outlined,
            color: Colors.green,
          ),
          StatItem(
            label: 'Completed Jobs',
            value: stats['completedJobs']!,
            icon: Icons.check_circle_outline,
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
                userName: 'James Sterling', // TODO: Get from Auth Provider
                subtitle: 'Sterling Construction',
                location: 'Seattle, WA',
                isOwner: true,
                imageUrl: 'https://i.pravatar.cc/150?u=james', // Mock image
                onNotificationTap: () {
                  // Handle notification tap
                },
              ),

              // 2. Stats Grid
              Transform.translate(
                offset: const Offset(0, -40), // Overlap with header
                child: StatsGrid(stats: statItems),
              ),

              // 3. Recent Requirements (List)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Jobs Created',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (viewModel.myRequirements.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'No requirements posted yet',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: viewModel.myRequirements.take(3).length,
                        itemBuilder: (context, index) {
                          final req = viewModel.myRequirements[index];
                          // Determine status color/text based on req.status
                          // Assuming 0: Open, 1: Hold, 2: Closed
                          String statusText = 'Open';
                          Color statusColor = Colors.green;
                          if (req.status == 1) {
                            statusText = 'On Hold';
                            statusColor = Colors.orange;
                          } else if (req.status == 2) {
                            statusText = 'Closed';
                            statusColor = Colors.red;
                          }

                          return RecentJobTile(
                            title: req.title,
                            subtitle: req.address ?? 'No Location',
                            statusText: statusText,
                            statusColor: statusColor,
                            footerText: '₹${req.salary ?? "Negotiable"}',
                            onTap: () {
                              // Navigate to details or edit
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditRequirementScreen(requirement: req),
                                ),
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequirements() {
    // This can reuse the list logic or be a separate screen
    // For now, implementing a clean list view
    return Consumer<OwnerViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) return const LoadingScreen();

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: const [
                    Tab(text: 'Active'),
                    Tab(text: 'Closed'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildRequirementList(viewModel, isActive: true),
                    _buildRequirementList(viewModel, isActive: false),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequirementList(OwnerViewModel viewModel,
      {required bool isActive}) {
    // Filter logic: Active = status 0 or 1? Closed = 2?
    // Start with all for now or simplified filter
    final filtered = viewModel.myRequirements.where((req) {
      if (isActive) return req.status != 2;
      return req.status == 2;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
          child: Text(
              isActive ? 'No active requirements' : 'No closed requirements'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final req = filtered[index];
        return RecentJobTile(
          title: req.title,
          subtitle: req.address ?? 'No Location',
          statusText: isActive ? (req.status == 1 ? 'Hold' : 'Open') : 'Closed',
          statusColor: isActive
              ? (req.status == 1 ? Colors.orange : Colors.green)
              : Colors.red,
          footerText: 'Posted on ${_formatDate(req.date)}',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditRequirementScreen(requirement: req),
              ),
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
}
