# EVENTTY - Mobile Event Management System

> Aplikasi Mobile Flutter untuk manajemen event OSIS

---

## 📋 Daftar Isi

1. [Informasi Project](#informasi-project)
2. [Arsitektur Aplikasi](#arsitektur-aplikasi)
3. [Authentication & Authorization](#authentication--authorization)
4. [Fitur Admin](#fitur-admin)
5. [Fitur Student](#fitur-student)
6. [Event Management](#event-management)
7. [Registration System](#registration-system)
8. [Certificate System](#certificate-system)
9. [Hybrid Chat System](#hybrid-chat-system)
10. [News & Announcement](#news--announcement)
11. [Database & Models](#database--models)
12. [Setup & Installation](#setup--installation)

---

## 📱 Informasi Project

### Tech Stack
- **Framework:** Flutter 3.x
- **State Management:** Riverpod
- **Routing:** Go Router
- **UI Components:** Material Design 3
- **Local Storage:** SharedPreferences (planned)
- **Database:** In-memory (development) → Firebase/Supabase (production)

### Project Structure
```
lib/
├── core/
│   ├── constants/        # Colors, text styles, themes
│   ├── data/            # Mock data & constants
│   ├── models/          # Data models
│   ├── providers/       # Riverpod providers
│   ├── routes/          # App routing
│   └── services/        # Business logic services
├── features/
│   ├── admin/           # Admin features
│   │   ├── announcement/
│   │   ├── events/
│   │   ├── messages/
│   │   └── profile/
│   ├── student/         # Student features
│   │   ├── certificate/
│   │   ├── event_detail/
│   │   ├── events/
│   │   ├── home/
│   │   ├── messages/
│   │   ├── news/
│   │   └── profile/
│   └── auth/            # Authentication
└── main.dart            # Entry point
```

---

## 🏗️ Arsitektur Aplikasi

### Clean Architecture Pattern
```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (Pages, Widgets, UI Components)        │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Provider Layer                  │
│  (Riverpod State Management)            │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Service Layer                   │
│  (Business Logic, API Calls)            │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Data Layer                      │
│  (Models, Repositories, Storage)        │
└─────────────────────────────────────────┘
```

### State Management Flow
```
Widget → ConsumerWidget → ref.watch(provider) → Service → Model → UI Update
```

---

## 🔐 Authentication & Authorization

### Auth Service
**Location:** `lib/core/services/auth_service.dart`

### User Roles
1. **Admin** - Manage events, view registrations, send announcements
2. **Student** - Browse events, register, view certificates

### Login Flow
```dart
// Mock Login
Email: admin@eventty.com | Password: admin123  → Admin Dashboard
Email: john@student.com  | Password: john123   → Student Home
```

### Auth Implementation
```dart
class AuthService {
  String? _userId;
  String? _userName;
  UserRole _userRole = UserRole.guest;
  
  // Login
  Future<bool> login(String email, String password);
  
  // Logout
  Future<void> logout();
  
  // Check auth status
  bool get isLoggedIn;
  UserRole get userRole;
}
```

### Protected Routes
```dart
// Admin-only routes
/admin/dashboard
/admin/events
/admin/messages
/admin/announcements

// Student-only routes
/home
/events
/certificates
/messages
/profile
```

### Session Management
- ✅ In-memory session (current)
- 🔄 SharedPreferences persistence (planned)
- 🔄 Secure token storage (planned)

---

## 👨‍💼 Fitur Admin

### 1. Dashboard
**Location:** `lib/features/admin/dashboard/`

**Features:**
- Total events overview
- Active registrations count
- Participant statistics
- Quick actions

### 2. Event Management
**Location:** `lib/features/admin/events/`

**CRUD Operations:**
- ✅ Create new event
- ✅ Edit event details
- ✅ Delete event
- ✅ View registrations per event
- ✅ Export participant data

**Event Properties:**
- Basic info (title, description, category)
- Date, time, location
- Capacity & quota management
- Registration type (individual/team)
- Certificate settings
- Documentation upload
- Status (open/closed)

### 3. Participant Management
**Location:** `lib/features/admin/events/presentation/pages/event_participants_screen.dart`

**Features:**
- View all registrations
- Filter by status (pending/approved/rejected)
- Approve/reject registrations
- View participant details
- Export to CSV/Excel

**Participant Card:**
```dart
- Name & Student ID
- Registration date
- Team info (if team registration)
- Status badge
- Action buttons (approve/reject)
```

### 4. Messages & Chat
**Location:** `lib/features/admin/messages/`

**Features:**
- View all conversations
- Real-time message updates
- Unread count badge
- Reply to students
- See conversation mode (bot/admin)
- View event context

### 5. Announcements
**Location:** `lib/features/admin/announcement/`

**Features:**
- Create announcements
- Edit announcements
- Delete announcements
- Pin important announcements
- Target specific events or all students

---

## 👨‍🎓 Fitur Student

### 1. Home Screen
**Location:** `lib/features/student/home/`

**Components:**
```dart
├── Header (Welcome + Profile)
├── Statistics Card (Events, Certificates, Registrations)
├── Featured Event Carousel
├── Upcoming Events List
└── Latest News Section
```

**Features:**
- Personalized greeting
- Quick stats overview
- Featured events slider
- Upcoming events list
- Latest news

### 2. Events Browse
**Location:** `lib/features/student/events/`

**Features:**
- View all events
- Filter by category
- Search events
- Sort by date/popularity
- Event cards with:
  - Event image
  - Title & category
  - Date & time
  - Location
  - Capacity indicator
  - Registration status

### 3. Event Detail
**Location:** `lib/features/student/event_detail/`

**Sections:**
1. **Hero Image**
2. **Basic Info** (date, time, location, organizer)
3. **Description**
4. **Highlight Cards:**
   - 🏆 Hadiah
   - 👥 Peserta
   - 🎁 Benefit
5. **Action Cards:**
   - 📸 Dokumentasi
   - 🎓 Sertifikat
   - 💬 Tanya Admin
6. **Aturan & Persyaratan** (navigate to rules screen)
7. **Timeline Event** (navigate to timeline screen)
8. **Registration Button** (bottom sticky)

**Actions:**
- Share event
- Bookmark event
- View documentation
- View certificate info
- Ask admin
- View rules
- View timeline
- Register

### 4. Event Registration
**Location:** `lib/features/student/event_detail/widgets/registration_dialog.dart`

**Flow:**
```
1. Check eligibility
2. Select registration type (individual/team)
3. Fill form:
   - Individual: Name, Student ID, Class, Email, Phone
   - Team: Team name + Members
4. Accept terms & conditions
5. Submit
6. Confirmation
```

**Validation:**
- All fields required
- Valid email format
- Valid phone format
- Team must have 2-5 members
- Cannot register twice

### 5. My Certificates
**Location:** `lib/features/student/certificate/`

**Features:**
- View all earned certificates
- Filter by event category
- Certificate card shows:
  - Event name
  - Certificate type (participation/winner)
  - Issue date
  - Certificate number
- Download certificate (PDF)
- Share certificate

### 6. Profile
**Location:** `lib/features/student/profile/`

**Sections:**
- Personal info
- Registration history
- Certificates earned
- Bookmarked events
- Settings
- Logout

---

## 🎯 Event Management

### Event Model
**Location:** `lib/core/models/event_model.dart`

```dart
class EventModel {
  String id;
  String title;
  String description;
  String category;
  DateTime date;
  String time;
  String location;
  String organizer;
  int capacity;
  int registered;
  String status; // 'open' or 'closed'
  RegistrationType registrationType; // individual or team
  bool certificateEnabled;
  CertificateType certificateType;
  String imageUrl;
  List<String> documentation;
  List<String> highlights;
  DateTime createdAt;
  DateTime updatedAt;
}
```

### Event Categories
- 🏀 Sport (Basketball, Football, Volleyball)
- 🎓 Education (Seminar, Workshop, Training)
- 🎨 Art & Culture (Music, Dance, Theater)
- 🔬 Science & Technology
- 🎉 Social (Gathering, Charity)

### Event Status
- **open** - Accepting registrations
- **closed** - Registration closed
- **ongoing** - Event in progress
- **completed** - Event finished

### Event Service
**Location:** `lib/core/services/event_service.dart`

**Methods:**
```dart
Future<List<EventModel>> getAllEvents()
Future<EventModel?> getEventById(String id)
Future<List<EventModel>> getEventsByCategory(String category)
Future<List<EventModel>> searchEvents(String query)
Future<bool> createEvent(EventModel event)
Future<bool> updateEvent(EventModel event)
Future<bool> deleteEvent(String id)
```

---

## 📝 Registration System

### Registration Model
**Location:** `lib/core/models/registration_model.dart`

```dart
class RegistrationModel {
  String id;
  String eventId;
  String studentId;
  String studentName;
  RegistrationType type; // individual or team
  String? teamName;
  List<TeamMember>? teamMembers;
  RegistrationStatus status; // pending, approved, rejected
  DateTime registrationDate;
  Map<String, dynamic>? additionalData;
}

class TeamMember {
  String name;
  String studentId;
  String classInfo;
  String email;
  String phone;
}
```

### Registration Status
- **pending** - Waiting admin approval
- **approved** - Registration approved
- **rejected** - Registration rejected
- **cancelled** - Cancelled by student

### Registration Flow
```
1. Student opens event detail
2. Clicks "Daftar Sekarang"
3. Dialog opens with registration form
4. Student fills form:
   - Individual: personal info
   - Team: team name + members info
5. Submit registration
6. Registration saved with status "pending"
7. Admin receives notification
8. Admin approves/rejects
9. Student receives notification
```

### Registration Service
**Location:** `lib/core/services/registration_service.dart`

**Methods:**
```dart
Future<bool> registerForEvent(RegistrationModel registration)
Future<List<RegistrationModel>> getRegistrationsByEvent(String eventId)
Future<List<RegistrationModel>> getRegistrationsByStudent(String studentId)
Future<bool> updateRegistrationStatus(String id, RegistrationStatus status)
Future<bool> cancelRegistration(String id)
bool isStudentRegistered(String eventId, String studentId)
```

### Validation Rules
- ✅ Student can only register once per event
- ✅ Cannot register if event is full
- ✅ Cannot register if event is closed
- ✅ Team registration requires 2-5 members
- ✅ All fields must be valid

---

## 🎓 Certificate System

### Certificate Model
**Location:** `lib/core/models/certificate_model.dart`

```dart
class CertificateModel {
  String id;
  String eventId;
  String eventTitle;
  String studentId;
  String studentName;
  CertificateType type; // participation, winner, speaker
  DateTime issueDate;
  String certificateNumber;
  String? winnerPosition; // 1st, 2nd, 3rd for winners
}
```

### Certificate Types
```dart
enum CertificateType {
  none,              // No certificate
  allParticipants,   // All participants get certificate
  winners,           // Only winners get certificate
}
```

### Certificate Generation Flow
```
1. Event completed
2. Admin goes to Event → Settings
3. Admin selects winners (if certificateType = winners)
4. Admin clicks "Generate Certificates"
5. System creates certificates for eligible students:
   - allParticipants: All approved registrations
   - winners: Only selected winners
6. Certificates appear in student's certificate page
```

### Certificate Service
**Location:** `lib/core/services/certificate_service.dart`

**Methods:**
```dart
Future<List<CertificateModel>> getCertificatesByStudent(String studentId)
Future<CertificateModel?> getCertificateById(String id)
Future<bool> generateCertificates(String eventId, List<String> eligibleStudentIds)
Future<String> downloadCertificate(String certificateId) // Returns PDF path
```

### Certificate Display
- Certificate card shows:
  - Event name
  - Certificate type badge
  - Issue date
  - Certificate number
- Actions:
  - View full certificate
  - Download PDF
  - Share

---

## 💬 Hybrid Chat System

### Overview
**Single conversation** dengan **2 mode** dalam satu chat:
- 🤖 **Bot Mode** - Eventty Bot menjawab otomatis
- 👤 **Admin Mode** - Admin OSIS menjawab manual

### Chat Service
**Location:** `lib/core/services/chat_service.dart`

```dart
class ChatService {
  // Conversation management
  String getOrCreateConversation({String userId, String userName});
  String getConversationMode(String conversationId);
  Future<bool> setConversationMode(String conversationId, String mode);
  
  // Message management
  Future<bool> sendMessage({
    String conversationId,
    String senderId,
    String senderName,
    String senderRole, // 'student', 'admin', 'bot', 'system'
    String message,
  });
  
  List<ChatMessage> getMessages(String conversationId);
  Stream<List<ChatMessage>> getMessagesStream(String conversationId);
}
```

### Eventty Bot Service
**Location:** `lib/core/services/eventty_bot_service.dart`

**Bot Capabilities:**
- ✅ Jawab pertanyaan tentang event:
  - Tanggal & waktu
  - Lokasi
  - Kuota peserta
  - Status pendaftaran
  - Sertifikat
  - Dokumentasi
  - Aturan (redirect to rules screen)
- ✅ List available events
- ✅ Suggest admin jika tidak bisa jawab

**Bot Response:**
```dart
class BotResponse {
  bool canAnswer;
  String message;
  bool suggestAdmin; // true = show "Hubungi Admin" button
}
```

### Chat Flow

#### BOT MODE 🤖
```
1. Student kirim pesan
2. Cek: conversationMode == 'bot'
3. EventtyBotService.processMessage()
4. Bot analisis & generate response
5. Jika bisa jawab → Bot balas
6. Jika tidak bisa → Bot suggest admin + show button
```

#### ADMIN MODE 👤
```
1. Student kirim pesan
2. Cek: conversationMode == 'admin'
3. SKIP bot processing
4. Message saved untuk admin
5. Admin menerima notifikasi
6. Admin balas manual
7. Student menerima balasan
```

#### MODE SWITCHING
```
BOT → ADMIN:
- Student klik [Hubungi Admin OSIS]
- setConversationMode('admin')
- System message: "📢 Student meminta bantuan Admin"

ADMIN → BOT:
- Student klik [🤖 Tanya Eventty Bot]
- setConversationMode('bot')
- System message: "🤖 Eventty Bot kembali aktif"
```

### Anti Auto-Reply Logic ⚠️ CRITICAL
```dart
void _sendMessage() async {
  // Save student message
  await _chatService.sendMessage(/* student message */);
  
  // CHECK MODE BEFORE CALLING BOT
  if (_conversationMode == 'bot') {
    // Bot mode: process with bot
    final botResponse = await _botService.processMessage(message);
    await _chatService.sendMessage(/* bot response */);
  } else {
    // Admin mode: DO NOT call bot
    // Just save message, wait for admin reply
  }
}
```

### Chat UI Components

**Mode Indicator:**
- Banner at top of messages
- 🤖 "Eventty Bot aktif" (purple bg) - bot mode
- 👤 "Terhubung dengan Admin OSIS" (red bg) - admin mode

**Toggle Buttons:**
- [🤖 Tanya Eventty Bot] - purple button (shown when mode='admin')
- [👤 Hubungi Admin OSIS] - red button (shown when mode='bot' AND bot suggests)

**Message Bubbles:**
- **Student** - Blue gradient (right)
- **Bot 🤖** - Light purple (left)
- **Admin 👤** - Light red (left)
- **System 📢** - Light green (center)

### Event Context Integration
```dart
// From Event Detail → Messages
Event Detail Screen → "Tanya Admin" card
→ Set MessageContext(eventId, eventTitle, initialMessage)
→ Navigate to Messages
→ Pre-fill message: "Saya ingin bertanya tentang {eventTitle}"
→ Bot uses eventId to answer specific event questions
```

---

## 📰 News & Announcement

### News Model
**Location:** `lib/core/models/news_model.dart`

```dart
class NewsModel {
  String id;
  String title;
  String content;
  String category;
  String author;
  DateTime publishDate;
  String imageUrl;
  int views;
  bool isPinned;
}
```

### Announcement Model
**Location:** `lib/core/models/announcement_model.dart`

```dart
class AnnouncementModel {
  String id;
  String title;
  String content;
  String? eventId; // null = for all students
  DateTime createdAt;
  bool isPinned;
  String author; // Admin name
}
```

### News Features (Student)
- View all news
- Read full article
- Filter by category
- Search news
- View trending news

### Announcement Features (Admin)
- Create announcement
- Target specific event or all students
- Pin important announcements
- Edit/delete announcements

---

## 🗄️ Database & Models

### Core Models

#### 1. User Model
```dart
class UserModel {
  String id;
  String name;
  String email;
  UserRole role; // admin or student
  String? phone;
  String? studentId; // for students
  String? classInfo; // for students
}
```

#### 2. Event Model
```dart
class EventModel {
  String id;
  String title;
  String description;
  String category;
  DateTime date;
  String time;
  String location;
  int capacity;
  int registered;
  String status;
  RegistrationType registrationType;
  bool certificateEnabled;
  CertificateType certificateType;
}
```

#### 3. Registration Model
```dart
class RegistrationModel {
  String id;
  String eventId;
  String studentId;
  RegistrationType type;
  String? teamName;
  List<TeamMember>? teamMembers;
  RegistrationStatus status;
  DateTime registrationDate;
}
```

#### 4. Certificate Model
```dart
class CertificateModel {
  String id;
  String eventId;
  String studentId;
  CertificateType type;
  DateTime issueDate;
  String certificateNumber;
}
```

#### 5. Message Models
```dart
class ChatMessage {
  String id;
  String conversationId;
  String senderId;
  String senderName;
  String senderRole; // 'student', 'admin', 'bot', 'system'
  String message;
  DateTime timestamp;
  bool isRead;
}

class ConversationInfo {
  String conversationId;
  String userId;
  String userName;
  String mode; // 'bot' or 'admin'
  String lastMessage;
  DateTime lastMessageTime;
  int unreadCount;
}
```

### Data Storage

**Current (Development):**
- In-memory storage
- Mock data for testing
- Data lost on app restart

**Planned (Production):**
```dart
// Option 1: Firebase
- Firestore for database
- Firebase Auth for authentication
- Firebase Storage for images
- Cloud Functions for backend logic

// Option 2: Supabase
- PostgreSQL database
- Supabase Auth
- Storage for images
- Edge Functions

// Option 3: Local + API
- SQLite for local storage
- REST API for backend
- SharedPreferences for cache
```

---

## ⚙️ Setup & Installation

### Prerequisites
```bash
flutter --version  # Flutter 3.x or higher
dart --version     # Dart 3.x or higher
```

### Installation Steps

1. **Clone Repository**
```bash
git clone <repository-url>
cd eventty
```

2. **Install Dependencies**
```bash
flutter pub get
```

3. **Run Application**
```bash
flutter run
```

4. **Build for Platform**
```bash
# Android
flutter build apk

# iOS
flutter build ios

# Windows
flutter build windows
```

### Mock Login Credentials

**Admin:**
- Email: `admin@eventty.com`
- Password: `admin123`

**Students:**
- Email: `john@student.com` | Password: `john123`
- Email: `sarah@student.com` | Password: `sarah123`
- Email: `mike@student.com` | Password: `mike123`

### Mock Events
Ada 5 event sample:
1. Classmeet 2024 (Education)
2. Basket Competition (Sport)
3. Career Day (Education)
4. Seminar AI (Technology)
5. Music Festival (Art & Culture)

---

## 🔧 Configuration

### Environment Variables
Create `.env` file (planned):
```env
API_URL=https://api.eventty.com
FIREBASE_API_KEY=xxx
FIREBASE_PROJECT_ID=xxx
```

### App Constants
**Location:** `lib/core/constants/`

```dart
// colors.dart
class AppColors {
  static const primary = Color(0xFF6366F1);
  static const secondary = Color(0xFF8B5CF6);
  // ...
}

// text_styles.dart
class AppTextStyles {
  static const heading1 = TextStyle(...);
  static const body1 = TextStyle(...);
  // ...
}
```

---

## 🚀 Features Roadmap

### ✅ Completed
- [x] Authentication system
- [x] Event management (CRUD)
- [x] Registration system (individual & team)
- [x] Certificate system
- [x] Hybrid chat (bot + admin)
- [x] News & announcements
- [x] Student profile
- [x] Admin dashboard

### 🔄 In Progress
- [ ] Database integration
- [ ] Real-time notifications
- [ ] File upload (images, documents)

### 📋 Planned
- [ ] Push notifications (FCM)
- [ ] QR code attendance
- [ ] Event analytics & reports
- [ ] Payment integration
- [ ] Email notifications
- [ ] Social media sharing
- [ ] Dark mode
- [ ] Multi-language support

---

## 📞 Support

Untuk pertanyaan atau bantuan:
- 📧 Email: support@eventty.com
- 💬 Messages: Gunakan fitur chat dalam app

---

## 📄 License

Copyright © 2024 Eventty OSIS Management System

---

**Last Updated:** 2026-08-30  
**Version:** 1.0.0  
**Status:** Development
