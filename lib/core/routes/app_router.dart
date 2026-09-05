import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/onboarding/presentation/pages/onboarding_screen.dart';
import '../../features/authentication/login/presentation/pages/login_screen.dart';
import '../../features/authentication/register/presentation/pages/register_screen.dart';
import '../../features/authentication/forgot_password/presentation/pages/forgot_password_screen.dart';
import '../../features/student/home/presentation/pages/home_screen.dart';
import '../../features/student/events/presentation/pages/events_screen.dart';
import '../../features/student/event_detail/presentation/pages/event_detail_screen.dart';
import '../../features/student/calendar/presentation/pages/calendar_screen.dart';
import '../../features/student/my_events/presentation/pages/my_events_screen.dart';
import '../../features/student/news/presentation/pages/news_screen.dart';
import '../../features/student/news/presentation/pages/news_detail_screen.dart';
import '../../features/student/messages/presentation/pages/student_messages_screen.dart';
import '../../features/student/gallery/presentation/pages/gallery_screen.dart';
import '../../features/student/certificate/presentation/pages/certificate_screen.dart';
import '../../features/student/profile/presentation/pages/profile_screen.dart';
import '../../features/student/notification/presentation/pages/notification_screen.dart';
import '../../features/admin/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/admin/event_management/presentation/pages/events_list_screen.dart';
import '../../features/admin/event_management/presentation/pages/create_event_screen.dart';
import '../../features/admin/event_management/presentation/pages/edit_event_screen.dart';
import '../../features/admin/announcement/presentation/pages/announcement_screen.dart';
import '../../features/admin/participants/presentation/pages/participants_screen.dart';
import '../../features/admin/gallery/presentation/pages/admin_gallery_screen.dart';
import '../../features/admin/report/presentation/pages/reports_screen.dart';
import '../../features/admin/profile/presentation/pages/admin_profile_screen.dart';
import '../../features/admin/certificate/presentation/pages/certificate_screen.dart' as admin_cert;
import '../../features/admin/certificate/presentation/pages/create_template_screen.dart';
import '../../features/admin/certificate/presentation/pages/template_preview_screen.dart';
import '../../features/admin/certificate/presentation/pages/select_event_screen.dart';
import '../../features/admin/certificate/presentation/pages/certificate_list_screen.dart';
import '../../features/admin/documentation/presentation/pages/documentation_screen.dart';
import '../../features/admin/messages/presentation/pages/messages_screen.dart';
import '../../features/admin/messages/presentation/pages/admin_message_detail_screen.dart';
import '../../features/shared/profile/presentation/pages/edit_profile_screen.dart';
import '../../features/shared/profile/presentation/pages/change_password_screen.dart';
import '../../features/shared/profile/presentation/pages/settings_screen.dart';
import '../../features/shared/profile/presentation/pages/help_support_screen.dart';
import '../../features/shared/profile/presentation/pages/about_screen.dart';
import '../../features/shared/widgets/student_shell.dart';
import '../../features/shared/widgets/admin_shell.dart';
import 'route_names.dart';
import '../services/auth_service.dart';

/// App Router Configuration
class AppRouter {
  final AuthService authService;

  AppRouter(this.authService);

  late final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    redirect: _redirect,
    routes: [
      // Splash
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Student Routes with Shell
      ShellRoute(
        builder: (context, state, child) => StudentShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: RouteNames.events,
            builder: (context, state) => const EventsScreen(),
          ),
          GoRoute(
            path: RouteNames.news,
            builder: (context, state) => const NewsScreen(),
          ),
          GoRoute(
            path: RouteNames.certificate,
            builder: (context, state) => const CertificateScreen(),
          ),
          GoRoute(
            path: RouteNames.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Messages - Outside Shell to prevent navbar from moving with keyboard
      GoRoute(
        path: RouteNames.messages,
        builder: (context, state) => const StudentMessagesScreen(),
      ),

      // Student Routes without Shell
      GoRoute(
        path: RouteNames.calendar,
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: RouteNames.eventDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EventDetailScreen(eventId: id);
        },
      ),
      GoRoute(
        path: RouteNames.newsDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return NewsDetailScreen(newsId: id);
        },
      ),
      GoRoute(
        path: RouteNames.myEvents,
        builder: (context, state) => const MyEventsScreen(),
      ),
      GoRoute(
        path: RouteNames.notification,
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: RouteNames.gallery,
        builder: (context, state) => const GalleryScreen(),
      ),

      // Admin Routes with Shell
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.adminDashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: RouteNames.adminEvents,
            builder: (context, state) => const EventsListScreen(),
          ),
          GoRoute(
            path: RouteNames.adminAnnouncement,
            builder: (context, state) => const AnnouncementScreen(),
          ),
          GoRoute(
            path: RouteNames.adminParticipants,
            builder: (context, state) => const ParticipantsScreen(),
          ),
          GoRoute(
            path: RouteNames.adminProfile,
            builder: (context, state) => const AdminProfileScreen(),
          ),
        ],
      ),

      // Admin Routes without Shell
      GoRoute(
        path: RouteNames.adminCreateEvent,
        builder: (context, state) => const CreateEventScreen(),
      ),
      GoRoute(
        path: RouteNames.adminEditEvent,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EditEventScreen(eventId: id);
        },
      ),
      GoRoute(
        path: RouteNames.adminGallery,
        builder: (context, state) => const AdminGalleryScreen(),
      ),
      GoRoute(
        path: RouteNames.adminReports,
        builder: (context, state) => const ReportsScreen(),
      ),

      // Admin Certificate Routes
      GoRoute(
        path: RouteNames.adminCertificate,
        builder: (context, state) => const admin_cert.CertificateScreen(),
      ),
      GoRoute(
        path: RouteNames.adminCreateTemplate,
        builder: (context, state) => const CreateTemplateScreen(),
      ),
      GoRoute(
        path: RouteNames.adminPreviewTemplate,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TemplatePreviewScreen(templateId: id);
        },
      ),
      GoRoute(
        path: RouteNames.adminSelectEventForCertificate,
        builder: (context, state) {
          final templateId = state.pathParameters['templateId']!;
          return SelectEventScreen(templateId: templateId);
        },
      ),
      GoRoute(
        path: RouteNames.adminCertificateList,
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return CertificateListScreen(eventId: eventId);
        },
      ),

      // Admin Documentation Routes
      GoRoute(
        path: RouteNames.adminDocumentation,
        builder: (context, state) {
          final eventId = state.uri.queryParameters['eventId'] ?? '1';
          return DocumentationScreen(eventId: eventId);
        },
      ),

      // Admin Messages Routes
      GoRoute(
        path: RouteNames.adminMessages,
        builder: (context, state) => const MessagesScreen(),
      ),
      GoRoute(
        path: RouteNames.adminMessageDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AdminMessageDetailScreen(conversationId: id);
        },
      ),

      // Shared Profile Routes (accessible by both admin and student)
      GoRoute(
        path: RouteNames.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.helpSupport,
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: RouteNames.about,
        builder: (context, state) => const AboutScreen(),
      ),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final isLoggedIn = authService.isLoggedIn;
    final isAdmin = authService.isAdmin;
    final isSplash = state.matchedLocation == RouteNames.splash;
    final isOnboarding = state.matchedLocation == RouteNames.onboarding;
    final isLoginRoute = state.matchedLocation == RouteNames.login;

    // If on splash or onboarding screen, allow it
    if (isSplash || isOnboarding) {
      return null;
    }

    // If not logged in and not on login/register/forgot password, redirect to login
    if (!isLoggedIn &&
        !isLoginRoute &&
        state.matchedLocation != RouteNames.register &&
        state.matchedLocation != RouteNames.forgotPassword) {
      return RouteNames.login;
    }

    // If logged in and on auth pages, redirect to appropriate home
    if (isLoggedIn && (isLoginRoute || state.matchedLocation == RouteNames.register)) {
      return isAdmin ? RouteNames.adminDashboard : RouteNames.home;
    }

    // If student trying to access admin routes
    if (isLoggedIn && !isAdmin && state.matchedLocation.startsWith('/admin')) {
      return RouteNames.home;
    }

    // If admin trying to access student routes (except profile which might be shared)
    if (isLoggedIn &&
        isAdmin &&
        !state.matchedLocation.startsWith('/admin') &&
        !state.matchedLocation.startsWith('/login') &&
        !state.matchedLocation.startsWith('/register')) {
      return RouteNames.adminDashboard;
    }

    return null;
  }
}
