import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dihaadi_app/viewmodels/owner_viewmodel.dart';
import 'package:dihaadi_app/ui/screens/profile_screen.dart';
import 'package:dihaadi_app/ui/screens/owner/create_requirement_screen.dart';
import 'package:dihaadi_app/ui/screens/loading_screen.dart';
import 'package:dihaadi_app/constants/colors.dart';
import 'package:dihaadi_app/ui/widgets/dashboard_header.dart';
import 'package:dihaadi_app/ui/widgets/stats_grid.dart';
import 'package:dihaadi_app/ui/widgets/recent_job_tile.dart';
import 'package:dihaadi_app/ui/screens/owner/edit_requirement_screen.dart';
import 'package:dihaadi_app/ui/screens/owner/owner_requirement_detail_screen.dart';

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
      _buildNotifications(),
      ProfileScreen(),
    ];
    final titles = ['Dashboard', 'Jobs', 'Notifications', 'Profile'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(titles[_currentIndex])),
      body: screens[_currentIndex],
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1 ? _buildCenterFab() : null,
      bottomNavigationBar: _buildModernNavigationBar(),
    );
  }

  Widget _buildModernNavigationBar() {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        setState(() => _currentIndex = index);
        if (index == 1) {
          context.read<OwnerViewModel>().fetchMyRequirements();
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment_rounded),
          label: 'Jobs',
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
    );
  }

  Widget _buildCenterFab() {
    return FloatingActionButton.extended(
      onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateRequirementScreen(),
            ),
          ).then((_) {
            if (!mounted) return;
            setState(() => _currentIndex = 1);
            context.read<OwnerViewModel>().fetchMyRequirements();
          });
        },
      icon: const Icon(Icons.add),
      label: const Text('Create Job'),
    );
  }

  Widget _buildNotifications() {
    return const Center(
      child: Text(
        'Notifications coming soon',
        style: TextStyle(color: AppColors.textSecondary),
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
    return Consumer<OwnerViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) return const LoadingScreen();

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Requirement',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4DAE4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: const Color(0xFF2F3A50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  indicatorPadding: const EdgeInsets.all(4),
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF6D7487),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                  tabs: const [
                    Tab(text: 'Active'),
                    Tab(text: 'Closed'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
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
    final filtered = viewModel.myRequirements.where((req) {
      if (isActive) return req.status != 2;
      return req.status == 2;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(isActive ? 'No active requirements' : 'No closed requirements'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 130),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final req = filtered[index];
        final bool open = req.status == 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.business_center_outlined,
                        color: Color(0xFF657189), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          req.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMain,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          req.address ?? 'No location',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Posted on ${_formatDate(req.date)}',
                          style: const TextStyle(
                            color: Color(0xFF9AA1B4),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: open
                          ? const Color(0xFFDFF5ED)
                          : const Color(0xFFE8EAF0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      open ? 'OPEN' : 'CLOSED',
                      style: TextStyle(
                        color: open
                            ? const Color(0xFF208F67)
                            : const Color(0xFF56607A),
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F5FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Salary / Wage',
                              style: TextStyle(
                                  color: Color(0xFF8A92A5), fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            '₹ ${(req.salary ?? 0).toStringAsFixed(0)}/day',
                            style: const TextStyle(
                                color: AppColors.textMain,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('People Needed',
                              style: TextStyle(
                                  color: Color(0xFF8A92A5), fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            '${req.personNeed ?? 0} Workers',
                            style: const TextStyle(
                                color: AppColors.textMain,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OwnerRequirementDetailScreen(requirement: req),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF515B73),
                        side: const BorderSide(color: Color(0xFFD2D8E4)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('View Details'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditRequirementScreen(requirement: req),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F3A50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Edit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}
