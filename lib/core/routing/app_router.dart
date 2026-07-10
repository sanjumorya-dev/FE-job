import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../data/models/user_model.dart';
import '../../data/models/requirement_model.dart';
import '../../data/models/chat_model.dart' as chat;
import '../../ui/screens/splash_screen.dart';
import '../../ui/screens/role_selection_screen.dart';
import '../../ui/screens/auth/login_screen.dart';
import '../../ui/screens/auth/register/register_screen.dart';
import '../../ui/screens/auth/otp_verify_screen.dart';
import '../../ui/screens/auth/forgot_password_screen.dart';
import '../../ui/screens/auth/reset_password_screen.dart';
import '../../ui/screens/profile_screen.dart';
import '../../ui/screens/edit_profile_screen.dart';
import '../../ui/screens/notifications_screen.dart';
import '../../ui/screens/owner/owner_dashboard.dart';
import '../../ui/screens/owner/create_requirement_screen.dart';
import '../../ui/screens/owner/edit_requirement_screen.dart';
import '../../ui/screens/owner/owner_requirement_detail_screen.dart';
import '../../ui/screens/owner/owner_applications_screen.dart';
import '../../ui/screens/owner/applicant_profile_screen.dart';
import '../../ui/screens/owner/owner_chat_list_screen.dart';
import '../../ui/screens/owner/owner_chat_detail_screen.dart';
import '../../ui/screens/owner/worker_rating_screen.dart';
import '../../ui/screens/labour/labour_dashboard.dart';
import '../../ui/screens/labour/worker_find_job_screen.dart';
import '../../ui/screens/labour/job_details_screen.dart';
import '../../ui/screens/labour/my_applications_screen.dart';
import '../../ui/screens/labour/worker_chat_list_screen.dart';
import '../../ui/screens/labour/worker_chat_detail_screen.dart';
import '../../ui/screens/labour/worker_rate_owner_screen.dart';

// ─── Route Names ───────────────────────────────────────────

enum AppRoute {
  splash,
  roleSelection,
  login,
  register,
  otpVerify,
  forgotPassword,
  resetPassword,
  // Owner
  ownerHome,
  ownerJobs,
  ownerChat,
  ownerAlerts,
  ownerProfile,
  ownerCreateRequirement,
  ownerEditRequirement,
  ownerRequirementDetail,
  ownerApplications,
  ownerApplicantProfile,
  ownerChatDetail,
  ownerRateWorker,
  // Worker
  workerHome,
  workerFindJobs,
  workerApplied,
  workerChat,
  workerProfile,
  workerJobDetail,
  workerChatDetail,
  workerRateOwner,
  // Shared
  profile,
  profileEdit,
  notifications,
}

// ─── Navigator Keys ────────────────────────────────────────

final rootNavigatorKey = GlobalKey<NavigatorState>();
final ownerShellKey = GlobalKey<NavigatorState>();
final workerShellKey = GlobalKey<NavigatorState>();

// ─── Router Factory ────────────────────────────────────────

GoRouter createRouter(AuthViewModel authViewModel) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: _buildRoutes(authViewModel),
    redirect: (context, state) => _redirect(state, authViewModel),
  );
}

// ─── Redirect Guard ────────────────────────────────────────

String? _redirect(GoRouterState state, AuthViewModel auth) {
  final loggedIn = auth.currentUser != null;
  final location = state.matchedLocation;

  // Splash manages its own timing — don't interfere
  if (location == '/splash') return null;

  final isAuthRoute = {
    '/role-selection',
    '/login',
    '/register',
    '/otp',
    '/forgot-password',
    '/reset-password',
  }.contains(location);

  // Not logged in → force to role selection (unless already on auth route)
  if (!loggedIn && !isAuthRoute) return '/role-selection';

  // Logged in but on an auth route → send to dashboard
  if (loggedIn && isAuthRoute) return _dashboardPath(auth);

  return null;
}

String _dashboardPath(AuthViewModel auth) {
  final user = auth.currentUser;
  if (user == null) return '/role-selection';
  final isOwner =
      user.roleName?.toLowerCase() == 'owner' || user.role == UserRole.owner;
  return isOwner ? '/owner/home' : '/worker/home';
}

// ─── Route Definitions ─────────────────────────────────────

List<RouteBase> _buildRoutes(AuthViewModel auth) => [
      // ── Splash ────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        name: AppRoute.splash.name,
        builder: (_, __) => const SplashScreen(),
      ),

      // ── Auth (no shell) ───────────────────────────────────
      GoRoute(
        path: '/role-selection',
        name: AppRoute.roleSelection.name,
        builder: (_, __) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/login',
        name: AppRoute.login.name,
        builder: (_, state) {
          final role = state.extra as UserRole? ?? UserRole.worker;
          return LoginScreen(role: role);
        },
      ),
      GoRoute(
        path: '/register',
        name: AppRoute.register.name,
        builder: (_, state) {
          final role = state.extra as UserRole? ?? UserRole.worker;
          return RegisterScreen(role: role);
        },
      ),
      GoRoute(
        path: '/otp',
        name: AppRoute.otpVerify.name,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return OtpVerifyScreen(
            mobileNumber: extra['mobileNumber'] as String? ?? '',
            countryCode: extra['countryCode'] as String? ?? '+91',
            onVerified: (token) {
              // After OTP verification, router redirect will handle navigation
            },
          );
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: AppRoute.forgotPassword.name,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        name: AppRoute.resetPassword.name,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ResetPasswordScreen(
            mobileNumber: extra['mobileNumber'] as String? ?? '',
            token: extra['token'] as String?,
          );
        },
      ),

      // ── Shared (no shell) ─────────────────────────────────
      GoRoute(
        path: '/profile',
        name: AppRoute.profile.name,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        name: AppRoute.profileEdit.name,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) {
          final user = state.extra as User;
          return EditProfileScreen(user: user);
        },
      ),
      GoRoute(
        path: '/notifications',
        name: AppRoute.notifications.name,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => const NotificationsScreen(),
      ),

      // ════════════════════════════════════════════════════════
      // OWNER DASHBOARD — StatefulShellRoute
      // ════════════════════════════════════════════════════════
      //
      // NOTE: Each branch renders a full-screen widget that is
      // the *content* of that tab (no bottom nav). The shell
      // (_OwnerDashboardShell) provides the single NavigationBar.
      //
      // TODO: When Navigator.push calls are replaced, extract the
      // actual tab content from OwnerDashboard into separate
      // widgets (e.g. _OwnerHomeContent, _OwnerJobsContent).
      // For now each branch shows the full OwnerDashboard
      // which has its own internal tab — this results in a
      // temporary double-nav until the extraction is done.
      // ════════════════════════════════════════════════════════
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _OwnerDashboardShell(navigationShell: navigationShell),
        branches: [
          _shellBranch(AppRoute.ownerHome, '/owner/home',
              (_) => const OwnerDashboard()),
          _shellBranch(AppRoute.ownerJobs, '/owner/jobs',
              (_) => const OwnerDashboard()),
          _shellBranch(AppRoute.ownerChat, '/owner/chat',
              (_) => const OwnerChatListScreen()),
          _shellBranch(AppRoute.ownerAlerts, '/owner/alerts',
              (_) => const NotificationsScreen()),
          _shellBranch(
              AppRoute.ownerProfile, '/owner/profile', (_) => const ProfileScreen()),
        ],
      ),

      // ── Owner sub-routes (root navigator) ─────────────────
      GoRoute(
        path: '/owner/create-requirement',
        name: AppRoute.ownerCreateRequirement.name,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => const CreateRequirementScreen(),
      ),
      GoRoute(
        path: '/owner/edit-requirement',
        name: AppRoute.ownerEditRequirement.name,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) =>
            EditRequirementScreen(requirement: state.extra as Requirement),
      ),
      GoRoute(
        path: '/owner/requirement/:id',
        name: AppRoute.ownerRequirementDetail.name,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) =>
            OwnerRequirementDetailScreen(requirement: state.extra as Requirement),
      ),
      GoRoute(
        path: '/owner/applications',
        name: AppRoute.ownerApplications.name,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) =>
            OwnerApplicationsScreen(requirement: state.extra as Requirement),
      ),
      GoRoute(
        path: '/owner/applicant-profile',
        name: AppRoute.ownerApplicantProfile.name,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ApplicantProfileScreen(
            applicant: extra['applicant'],
            requirementId: extra['requirementId'] as String,
            jobTitle: extra['jobTitle'] as String,
          );
        },
      ),
      GoRoute(
        path: '/owner/chat/:chatId',
        name: AppRoute.ownerChatDetail.name,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) =>
            OwnerChatDetailScreen(conversation: state.extra as chat.ChatConversation),
      ),
      GoRoute(
        path: '/owner/rate-worker',
        name: AppRoute.ownerRateWorker.name,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>;
          return WorkerRatingScreen(
            workerName: extra['workerName'] as String,
            jobTitle: extra['jobTitle'] as String,
            workerId: extra['workerId'] as String?,
            requirementId: extra['requirementId'] as String?,
          );
        },
      ),

      // ════════════════════════════════════════════════════════
      // WORKER DASHBOARD — StatefulShellRoute
      // ════════════════════════════════════════════════════════
      //
      // Same TODO as owner: extract tab content from
      // LabourDashboard into standalone widgets.
      // ════════════════════════════════════════════════════════
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _WorkerDashboardShell(navigationShell: navigationShell),
        branches: [
          _shellBranch(AppRoute.workerHome, '/worker/home',
              (_) => const LabourDashboard()),
          _shellBranch(AppRoute.workerFindJobs, '/worker/jobs',
              (_) => const WorkerFindJobScreen()),
          _shellBranch(AppRoute.workerApplied, '/worker/applied',
              (_) => const MyApplicationsScreen()),
          _shellBranch(AppRoute.workerChat, '/worker/chat',
              (_) => const WorkerChatListScreen()),
          _shellBranch(
              AppRoute.workerProfile, '/worker/profile', (_) => const ProfileScreen()),
        ],
      ),

      // ── Worker sub-routes (root navigator) ────────────────
      GoRoute(
        path: '/worker/job/:id',
        name: AppRoute.workerJobDetail.name,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => JobDetailsScreen(job: state.extra as Requirement),
      ),
      GoRoute(
        path: '/worker/chat/:chatId',
        name: AppRoute.workerChatDetail.name,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) =>
            WorkerChatDetailScreen(conversation: state.extra as chat.ChatConversation),
      ),
      GoRoute(
        path: '/worker/rate-owner',
        name: AppRoute.workerRateOwner.name,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>;
          return WorkerRateOwnerScreen(
            ownerName: extra['ownerName'] as String,
            jobTitle: extra['jobTitle'] as String,
            ownerId: extra['ownerId'] as String?,
            requirementId: extra['requirementId'] as String?,
          );
        },
      ),
    ];

// ─── Helper: create a StatefulShellBranch ──────────────────

StatefulShellBranch _shellBranch(
  AppRoute route,
  String path,
  Widget Function(BuildContext) builder,
) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        name: route.name,
        pageBuilder: (context, state) =>
            NoTransitionPage(child: builder(context)),
      ),
    ],
  );
}

// ════════════════════════════════════════════════════════════
// OWNER DASHBOARD SHELL
// ════════════════════════════════════════════════════════════

class _OwnerDashboardShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const _OwnerDashboardShell({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return _DashboardShell(
      navigationShell: navigationShell,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.assignment_rounded), label: 'Jobs'),
        NavigationDestination(icon: Icon(Icons.chat_bubble_rounded), label: 'Chat'),
        NavigationDestination(icon: Icon(Icons.notifications_rounded), label: 'Alerts'),
        NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════
// WORKER DASHBOARD SHELL
// ════════════════════════════════════════════════════════════

class _WorkerDashboardShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const _WorkerDashboardShell({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return _DashboardShell(
      navigationShell: navigationShell,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.search_rounded), label: 'Jobs'),
        NavigationDestination(icon: Icon(Icons.assignment_rounded), label: 'Applied'),
        NavigationDestination(icon: Icon(Icons.chat_bubble_rounded), label: 'Chat'),
        NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════
// GENERIC DASHBOARD SHELL (shared bottom nav)
// ════════════════════════════════════════════════════════════

class _DashboardShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final List<NavigationDestination> destinations;

  const _DashboardShell({
    required this.navigationShell,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
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
                indicatorColor: primary.withValues(alpha: 0.1),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold, color: primary);
                  }
                  return const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF9CA3AF));
                }),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return IconThemeData(color: primary, size: 24);
                  }
                  return const IconThemeData(color: Color(0xFF9CA3AF), size: 24);
                }),
              ),
              child: NavigationBar(
                height: 65,
                elevation: 0,
                backgroundColor: Colors.transparent,
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: (index) {
                  navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  );
                },
                destinations: destinations,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
