# Worker (Job Seeker) Complete Flow Documentation

## 📱 Worker Main Navigation (Bottom Tabs)

The worker dashboard has **4 bottom navigation tabs**:

1. **Home** - Job feed with available opportunities
2. **Applications** - Track applied jobs and status
3. **Chat** - Messages with employers/owners
4. **Profile** - Worker profile, ratings, and work history

---

## 🔄 Complete User Flows

### Flow 1: Job Feed → Apply for Job

```
Home Feed Screen (Job Feed)
├── Available Jobs List
│   ├── Job cards showing:
│   │   ├── Job Title
│   │   ├── Salary/Wage
│   │   ├── Location
│   │   └── Posted Date
│   └── Tap any job
│       ↓
│   Job Details Screen
│   ├── Job Title & Description
│   ├── Salary/Wage
│   ├── Workers Needed
│   ├── Location
│   ├── Duty Time
│   └── Apply Now Button
│       ↓
│   Application Submitted
│   └── Success notification
│       ↓
│   Returns to Home Feed
```

---

### Flow 2: Applications Tracking

```
Applications Tab
├── Tab Filter:
│   ├── Pending
│   ├── Accepted
│   ├── Rejected
│   └── Completed
│
├── Each job shows:
│   ├── Job Title
│   ├── Location
│   ├── Applied Date
│   └── Status Badge
│
└── IF Status = Accepted
    ├── Chat with employer enabled
    └── Can view employer details
```

---

### Flow 3: After Application Accepted

```
Application Status: Accepted
├── Notification received: "You are accepted"
│   ↓
├── Chat Tab shows new conversation
│   ↓
├── Open Chat with Employer
│   ├── Employer info header
│   ├── Job info banner
│   ├── Message history
│   ├── Message input
│   └── Call button
│       ↓
│   Job Completion
│       ↓
│   Rate Employer Screen
│   ├── Star Rating (1-5)
│   ├── Quick Feedback Tags
│   │   ├── Good communication
│   │   ├── Fair payment
│   │   ├── Professional behavior
│   │   ├── Clear instructions
│   │   ├── Safe working conditions
│   │   └── Would work again
│   ├── Detailed Feedback (Optional)
│   └── Submit Rating
│       ↓
│   Success Confirmation
```

---

### Flow 4: Chat System

```
Chat Tab (Bottom Navigation)
├── Chat List Screen
│   ├── Search functionality
│   ├── Conversation list
│   │   ├── Employer avatar & name
│   │   ├── Job title
│   │   ├── Last message preview
│   │   ├── Timestamp
│   │   ├── Unread count badge
│   │   └── Online status indicator
│   └── Tap conversation
│       ↓
│   Chat Detail Screen
│   ├── Employer header (Online/Offline)
│   ├── Phone icon for calls
│   ├── Job info banner
│   ├── Message bubbles
│   │   ├── Sent messages (Right, Blue)
│   │   └── Received messages (Left, White)
│   ├── Message status indicators
│   │   ✓ Sent
│   │   ✓✓ Delivered
│   │   ✓✓ Blue - Read
│   └── Message input
│       ├── Text field
│       └── Send button
│
└── More Options (⋮)
    ├── Mark Job as Completed
    └── Report Issue
```

---

### Flow 5: Profile Management

```
Profile Tab
├── Worker Information
│   ├── Name
│   ├── Profile Photo
│   ├── Mobile Number
│   ├── Email
│   └── Address
│
├── Edit Profile
│   └── Update information
│
├── Ratings & Reviews
│   ├── Average rating from employers
│   ├── Total reviews count
│   └── Individual reviews
│
└── Work History
    ├── Completed jobs list
    ├── Earnings summary
    └── Ratings given to employers
```

---

## 📂 Screens Implemented

### 1. **labour_dashboard_new.dart** (Updated)
- Main navigation container
- 4 tabs: Home, Applications, Chat, Profile
- Job feed display

### 2. **worker_chat_list_screen.dart** ⭐ NEW
- List of all conversations with employers
- Search functionality
- Online status indicators
- Unread message badges
- Last message preview

### 3. **worker_chat_detail_screen.dart** ⭐ NEW
- Real-time messaging UI
- Message status (Sent/Delivered/Read)
- Phone call integration
- Job info banner
- Mark job as completed option
- Rate employer after completion

### 4. **worker_rate_owner_screen.dart** ⭐ NEW
- 5-star rating system for employers
- Quick feedback tags
  - Good communication
  - Fair payment
  - Professional behavior
  - Clear instructions
  - Safe working conditions
  - Would work again
- Detailed feedback option
- Success confirmation

### 5. **job_details_screen.dart** (Enhanced)
- Complete job information display
- Salary, location, duty time
- Workers needed
- Enhanced UI with cards
- Apply button with feedback

### 6. **my_applications_screen.dart** (Existing)
- Tab-based filtering (Pending/Accepted/Rejected/Completed)
- Application status tracking
- Applied date display

### 7. **work_history_screen.dart** (Existing)
- Past jobs display
- Work history tracking

---

## 🔗 Complete Navigation Map

```
LabourDashboardNew
├── [Tab 0] Home (Job Feed)
│   └── Job List
│       └── Tap Job → JobDetailsScreen
│           └── Apply Now → Success
│               └── Returns to Home
│
├── [Tab 1] Applications
│   └── MyApplicationsScreen
│       ├── Pending Tab
│       ├── Accepted Tab → Enables Chat
│       ├── Rejected Tab
│       └── Completed Tab
│           └── Work History Button
│
├── [Tab 2] Chat ⭐ NEW
│   └── WorkerChatListScreen
│       ├── Search conversations
│       └── Tap Conversation → WorkerChatDetailScreen
│           ├── Call employer
│           ├── View job info
│           ├── Send messages
│           └── Mark Complete → WorkerRateOwnerScreen ⭐
│
└── [Tab 3] Profile
    └── ProfileScreen
        ├── Edit Profile
        ├── Ratings & Reviews
        └── Work History
```

---

## ✨ Features Implemented

### Chat System
- ✅ Conversation list with employers
- ✅ Search functionality
- ✅ Real-time messaging UI
- ✅ Online/offline status
- ✅ Unread message badges
- ✅ Message status indicators
- ✅ Phone call integration

### Application Management
- ✅ Apply for jobs
- ✅ Track application status
- ✅ Filter by status (Pending/Accepted/Rejected/Completed)
- ✅ Chat enabled after acceptance

### Job Completion & Rating
- ✅ Mark job as completed from chat
- ✅ Rate employer (1-5 stars)
- ✅ Quick feedback tags
- ✅ Detailed feedback option
- ✅ Success confirmation

### Job Feed
- ✅ Browse available jobs
- ✅ Enhanced job details screen
- ✅ Salary, location, time display
- ✅ One-click apply

### Profile
- ✅ View/edit profile
- ✅ Ratings from employers
- ✅ Work history
- ✅ Completed jobs tracking

---

## 📊 Status Summary

### ✅ Implemented
1. Bottom navigation (4 tabs)
2. Chat list screen
3. Chat detail screen
4. Employer rating screen
5. Enhanced job details
6. Application tracking
7. Work history

### 🔧 Ready for Backend Integration
- Real-time messaging (WebSocket)
- Chat history storage
- Rating submission API
- Push notifications
- Application status updates

### 🎨 UI/UX Features
- Modern material design
- Consistent color scheme (AppColors)
- Status badges and indicators
- Smooth navigation transitions
- Confirmation dialogs
- Loading states
- Empty states

---

## 🚀 Comparison: Owner vs Worker

| Feature | Owner | Worker |
|---------|-------|--------|
| **Navigation Tabs** | 5 (Dashboard, Jobs, Chat, Notifications, Profile) | 4 (Home, Applications, Chat, Profile) |
| **Chat** | ✅ With hired workers | ✅ With employers |
| **Rating** | Rate workers | Rate employers |
| **Job Creation** | ✅ Create jobs | ❌ (Browse only) |
| **Applications** | Manage applicants | Track applications |
| **Call** | ✅ Call workers | ✅ Call employers |
| **Mark Complete** | ✅ Mark & rate | ✅ Mark & rate |

---

## 📝 Next Steps (Future Enhancements)

1. **Backend Integration**
   - Connect chat to WebSocket
   - Implement real-time notifications
   - Store ratings in database
   - Add voice/video calling

2. **Advanced Features**
   - Job recommendations based on skills
   - Salary insights
   - Location-based job search
   - Advanced filters (date, wage, distance)

3. **Worker Profile Enhancement**
   - Skill verification
   - Portfolio/photos of work
   - Availability calendar
   - Earnings dashboard

4. **Safety & Trust**
   - Employer verification badges
   - Worker safety tips
   - Report/Block functionality
   - Dispute resolution

---

## 🎯 Key Differences from Owner Flow

1. **Simpler Navigation** - 4 tabs instead of 5
2. **No Job Creation** - Workers browse, not create
3. **Application-Based** - Apply and wait for acceptance
4. **Rating Direction** - Workers rate employers (reverse of owner)
5. **Focus on Opportunities** - Home feed shows available jobs

---

**Last Updated:** April 8, 2026  
**Status:** ✅ Complete and Functional  
**Total Screens Created:** 3 new screens + 2 enhanced screens
