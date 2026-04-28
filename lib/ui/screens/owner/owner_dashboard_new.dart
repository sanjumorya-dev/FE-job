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
import 'package:dihaadi_app/ui/screens/owner/edit_requirement_screen.dart';
import 'package:dihaadi_app/ui/screens/owner/owner_requirement_detail_screen.dart';
import 'package:dihaadi_app/ui/screens/owner/owner_chat_list_screen.dart';

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
        final pendingCount = viewModel.myRequirements.where((r) => r.status == 1).length;
        final draftCount = viewModel.myRequirements.where((r) => r.status == 2).length;

        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Owner requirements',
                                style: TextStyle(
                                  color: Color(0xFF7A8394),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'My Jobs',
                                style: TextStyle(
                                  color: Color(0xFF171A22),
                                  fontSize: 24,
                                  height: 1,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _CircleHeaderButton(
                          icon: Icons.tune_rounded,
                          onTap: () {},
                        ),
                        const SizedBox(width: 10),
                        _CircleHeaderButton(
                          icon: Icons.search_rounded,
                          onTap: () => _showJobsSearch(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _CountCard(label: 'Active', value: activeCount),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _CountCard(label: 'Pending', value: pendingCount),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _CountCard(label: 'Drafts', value: draftCount),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _FilterChipButton(
                          label: 'Active',
                          selected: _selectedFilterIndex == 0,
                          onTap: () => setState(() => _selectedFilterIndex = 0),
                        ),
                        const SizedBox(width: 8),
                        _FilterChipButton(
                          label: 'Completed',
                          selected: _selectedFilterIndex == 1,
                          onTap: () => setState(() => _selectedFilterIndex = 1),
                        ),
                        const SizedBox(width: 8),
                        _FilterChipButton(
                          label: 'Drafts',
                          selected: _selectedFilterIndex == 2,
                          onTap: () => setState(() => _selectedFilterIndex = 2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: const Color(0xFFF1F4F8),
                  child: IndexedStack(
                    index: _selectedFilterIndex,
                    children: [
                      _buildRequirementList(viewModel, status: 0),
                      _buildRequirementList(viewModel, status: 1),
                      _buildRequirementList(viewModel, status: 2),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
      String message = 'No active jobs';
      if (status == 1) message = 'No completed jobs';
      if (status == 2) message = 'No drafts';
      
      return Center(child: Text(message, style: const TextStyle(color: AppColors.textHint)));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 130),
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
          onEdit: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditRequirementScreen(requirement: req),
              ),
            ).then((_) {
              if (!mounted) return;
              context.read<OwnerViewModel>().fetchMyRequirements();
            });
          },
        );
      },
    );
  }

  Future<void> _showJobsSearch(BuildContext context) async {
    final controller = TextEditingController(text: _searchQuery);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            18,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search jobs',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: const Color(0xFFF1F4F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        );
      },
    );
    controller.dispose();
  }
}

class _CircleHeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleHeaderButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE9EDF3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF171A22)),
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  final String label;
  final int value;

  const _CountCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE9EDF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7A8394),
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Text(
            '$value',
            style: const TextStyle(
              color: Color(0xFF171A22),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF171A22) : const Color(0xFFEFF3F7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF7A8394),
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
