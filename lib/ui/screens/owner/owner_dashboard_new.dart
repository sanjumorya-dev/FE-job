import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dihaadi_app/viewmodels/owner_viewmodel.dart';
import 'package:dihaadi_app/viewmodels/auth_viewmodel.dart';
import 'package:dihaadi_app/ui/screens/profile_screen.dart';
import 'package:dihaadi_app/ui/screens/notifications_screen.dart';
import 'package:dihaadi_app/ui/screens/owner/create_requirement_screen.dart';
import 'package:dihaadi_app/ui/screens/loading_screen.dart';
import 'package:dihaadi_app/constants/colors.dart';
import 'package:dihaadi_app/ui/widgets/owner_dashboard_header.dart';
import 'package:dihaadi_app/ui/widgets/owner_stats_row.dart';
import 'package:dihaadi_app/ui/widgets/owner_job_card.dart';
import 'package:dihaadi_app/ui/screens/owner/owner_requirement_detail_screen.dart';
import 'package:dihaadi_app/ui/screens/owner/owner_chat_list_screen.dart';
import 'package:dihaadi_app/ui/widgets/job_search_header.dart';

class OwnerDashboardNew extends StatefulWidget {
  const OwnerDashboardNew({super.key});

  @override
  State<OwnerDashboardNew> createState() => _OwnerDashboardNewState();
}

class _OwnerDashboardNewState extends State<OwnerDashboardNew> {
  int _currentIndex = 0;
  int _selectedFilterIndex = 0;
  String _searchQuery = '';

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
      const OwnerChatListScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: screens[_currentIndex],
      floatingActionButton: _currentIndex == 1 ? _buildFloatingButton() : null,
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
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
                if (index == 1) {
                  context.read<OwnerViewModel>().fetchMyRequirements();
                }
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.grid_view_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.assignment_rounded),
                  label: 'Jobs',
                ),
                NavigationDestination(
                  icon: Icon(Icons.chat_bubble_rounded),
                  label: 'Chat',
                ),
                NavigationDestination(
                  icon: Icon(Icons.notifications_rounded),
                  label: 'Alerts',
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

  Widget _buildFloatingButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CreateRequirementScreen(),
          ),
        ).then((_) {
          if (!mounted) return;
          context.read<OwnerViewModel>().fetchMyRequirements();
        });
      },
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
    );
  }

  Widget _buildDashboard() {
    return Consumer<OwnerViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const LoadingScreen();
        }

        final stats = viewModel.stats;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<AuthViewModel>(
                builder: (context, authVm, child) {
                  final user = authVm.currentUser;
                  return OwnerDashboardHeader(
                    userName: user?.name ?? 'Rahul Sharma',
                    notificationCount: 3,
                    onNotificationTap: () => setState(() => _currentIndex = 3),
                    onProfileTap: () => setState(() => _currentIndex = 4),
                  );
                },
              ),

              OwnerDashboardStats(
                activeJobs: int.tryParse(stats['activeReq'] ?? '0') ?? 0,
                pendingApps: int.tryParse(stats['totalApplicants'] ?? '0') ?? 0,
                completedJobs: int.tryParse(stats['completedJobs'] ?? '0') ?? 0,
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Jobs',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your recently posted requirements',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => setState(() => _currentIndex = 1),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),

              if (viewModel.myRequirements.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(60.0),
                    child: Column(
                      children: [
                        Icon(Icons.assignment_late_rounded, size: 48, color: AppColors.textHint),
                        SizedBox(height: 16),
                        Text(
                          'No active jobs found',
                          style: TextStyle(color: AppColors.textHint, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: viewModel.myRequirements.take(3).length,
                  itemBuilder: (context, index) {
                    final req = viewModel.myRequirements[index];
                    return OwnerJobCard(
                      requirement: req,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OwnerRequirementDetailScreen(requirement: req),
                          ),
                        );
                      },
                    );
                  },
                ),
              const SizedBox(height: 120),
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

        final activeCount = viewModel.myRequirements.where((r) => r.status == 0).length;
        final onHoldCount = viewModel.myRequirements.where((r) => r.status == 1).length;
        final closedCount = viewModel.myRequirements.where((r) => r.status == 2).length;

        return Column(
          children: [
            JobSearchHeader(
              title: 'Find Requirements',
              selectedIndex: _selectedFilterIndex,
              filterTabs: [
                'Active ($activeCount)',
                'On Hold ($onHoldCount)',
                'Closed ($closedCount)'
              ],
              onTabChanged: (index) => setState(() => _selectedFilterIndex = index),
              onSearchChanged: (val) => setState(() => _searchQuery = val),
              onFilterTap: () {},
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedFilterIndex,
                children: [
                  _buildRequirementList(viewModel, status: 0),
                  _buildRequirementList(viewModel, status: 1),
                  _buildRequirementList(viewModel, status: 2),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRequirementList(OwnerViewModel viewModel,
      {required int status}) {
    final filtered = viewModel.myRequirements.where((req) {
      final matchesStatus = req.status == status;
      final matchesSearch = _searchQuery.isEmpty || 
          req.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (req.address?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesStatus && matchesSearch;
    }).toList();

    if (filtered.isEmpty) {
      String message = 'No active requirements';
      if (status == 1) message = 'No requirements on hold';
      if (status == 2) message = 'No closed requirements';
      
      return Center(child: Text(message, style: const TextStyle(color: AppColors.textHint)));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 130),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final req = filtered[index];
        return OwnerJobCard(
          requirement: req,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    OwnerRequirementDetailScreen(requirement: req),
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
