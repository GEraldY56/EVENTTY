/// Route Names for the Application
class RouteNames {
  RouteNames._();

  // Auth Routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Student Routes
  static const String home = '/home';
  static const String events = '/events';
  static const String eventDetail = '/events/:id';
  static const String calendar = '/calendar';
  static const String news = '/news';
  static const String newsDetail = '/news/:id';
  static const String messages = '/messages';
  static const String messageDetail = '/messages/:id';
  static const String gallery = '/gallery';
  static const String certificate = '/certificate';
  static const String profile = '/profile';
  static const String notification = '/notification';
  static const String myEvents = '/my-events';

  // Admin Routes
  static const String adminDashboard = '/admin';
  static const String adminEvents = '/admin/events';
  static const String adminCreateEvent = '/admin/events/create';
  static const String adminEditEvent = '/admin/events/edit/:id';
  static const String adminAnnouncement = '/admin/announcement';
  static const String adminParticipants = '/admin/participants';
  static const String adminGallery = '/admin/gallery';
  static const String adminReports = '/admin/reports';
  static const String adminProfile = '/admin/profile';
  
  // Admin Certificate Routes
  static const String adminCertificate = '/admin/certificate';
  static const String adminCreateTemplate = '/admin/certificate/template/create';
  static const String adminPreviewTemplate = '/admin/certificate/template/:id';
  static const String adminSelectEventForCertificate = '/admin/certificate/generate/:templateId';
  static const String adminCertificateList = '/admin/certificate/event/:eventId';
  
  // Admin Documentation Routes
  static const String adminDocumentation = '/admin/documentation';
  static const String adminCreateDocumentation = '/admin/documentation/create';
  static const String adminEditDocumentation = '/admin/documentation/edit/:id';
  
  // Admin Messages Routes
  static const String adminMessages = '/admin/messages';
  static const String adminMessageDetail = '/admin/messages/:id';

  // Shared Profile Routes (accessible by both admin and student)
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';
  static const String settings = '/settings';
  static const String helpSupport = '/help-support';
  static const String about = '/about';
}
