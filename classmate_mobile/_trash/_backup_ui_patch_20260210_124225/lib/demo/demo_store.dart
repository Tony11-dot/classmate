import 'dart:math';

class DemoUser {
  final String id;
  String name;
  String role; // student|teacher|admin
  int points;
  String school;
  String grade;
  DemoUser({
    required this.id,
    required this.name,
    required this.role,
    required this.points,
    required this.school,
    required this.grade,
  });
}

class DemoClassroom {
  final String id;
  final String name;
  final String teacher;
  final String room;
  DemoClassroom({
    required this.id,
    required this.name,
    required this.teacher,
    required this.room,
  });
}

class DemoScheduleItem {
  final String id;
  final String day; // Sun..Thu
  final String time; // 08:15
  final String title;
  final String room;
  final String type; // lesson|exam|event
  DemoScheduleItem({
    required this.id,
    required this.day,
    required this.time,
    required this.title,
    required this.room,
    required this.type,
  });
}

class DemoAssignment {
  final String id;
  final String classroomId;
  final String title;
  final String due;
  final int reward;
  bool submitted;
  DemoAssignment({
    required this.id,
    required this.classroomId,
    required this.title,
    required this.due,
    required this.reward,
    this.submitted = false,
  });
}

class DemoInsight {
  final String id;
  final String title;
  final String body;
  final String level; // good|warn|risk
  DemoInsight({
    required this.id,
    required this.title,
    required this.body,
    required this.level,
  });
}

class DemoNotification {
  final String id;
  final String title;
  final String body;
  final String time;
  bool seen;
  DemoNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    this.seen = false,
  });
}

class DemoStore {
  static final _rng = Random(7);

  static DemoUser user = DemoUser(
    id: 'u1',
    name: 'Tony Aboud',
    role: 'student',
    points: 180,
    school: 'Demo High School',
    grade: '10',
  );

  static final classrooms = <DemoClassroom>[
    DemoClassroom(
      id: 'c1',
      name: 'Physics 10',
      teacher: 'Ms. Hila',
      room: 'Lab 2',
    ),
    DemoClassroom(
      id: 'c2',
      name: 'Math 5 Units',
      teacher: 'Mr. Amir',
      room: 'B-14',
    ),
    DemoClassroom(
      id: 'c3',
      name: 'Computer Science',
      teacher: 'Ms. Noa',
      room: 'C-3',
    ),
  ];

  static final schedule = <DemoScheduleItem>[
    DemoScheduleItem(
      id: 's1',
      day: 'Sun',
      time: '08:15',
      title: 'Math 5 Units',
      room: 'B-14',
      type: 'lesson',
    ),
    DemoScheduleItem(
      id: 's2',
      day: 'Sun',
      time: '10:00',
      title: 'Physics 10',
      room: 'Lab 2',
      type: 'lesson',
    ),
    DemoScheduleItem(
      id: 's3',
      day: 'Mon',
      time: '12:20',
      title: 'Computer Science',
      room: 'C-3',
      type: 'lesson',
    ),
    DemoScheduleItem(
      id: 's4',
      day: 'Tue',
      time: '09:00',
      title: 'Physics Quiz',
      room: 'Lab 2',
      type: 'exam',
    ),
    DemoScheduleItem(
      id: 's5',
      day: 'Wed',
      time: '13:30',
      title: 'Project Work',
      room: 'Library',
      type: 'event',
    ),
  ];

  static final assignments = <DemoAssignment>[
    DemoAssignment(
      id: 'a1',
      classroomId: 'c1',
      title: 'Free Fall Worksheet',
      due: 'Today 23:59',
      reward: 15,
    ),
    DemoAssignment(
      id: 'a2',
      classroomId: 'c2',
      title: 'Derivatives Practice Set',
      due: 'Tomorrow 20:00',
      reward: 20,
    ),
    DemoAssignment(
      id: 'a3',
      classroomId: 'c3',
      title: 'Login UI + Validation',
      due: 'Thu 16:00',
      reward: 25,
    ),
    DemoAssignment(
      id: 'a4',
      classroomId: 'c3',
      title: 'Mini-API Integration',
      due: 'Fri 12:00',
      reward: 35,
    ),
  ];

  static final notifications = <DemoNotification>[
    DemoNotification(
      id: 'n1',
      title: 'Attendance streak!',
      body: 'You got +8 points for showing up on time.',
      time: '5m ago',
    ),
    DemoNotification(
      id: 'n2',
      title: 'New assignment',
      body: 'Physics 10: Free Fall Worksheet.',
      time: '1h ago',
    ),
    DemoNotification(
      id: 'n3',
      title: 'Leaderboard update',
      body: 'You’re now #2 this week.',
      time: 'Yesterday',
    ),
  ];

  static List<DemoInsight> generateInsights() {
    // looks AI-ish but safe + demo friendly
    final p = user.points;
    final done = assignments.where((a) => a.submitted).length;
    final total = assignments.length;

    return [
      DemoInsight(
        id: 'i1',
        title: 'Momentum',
        body: done >= 2
            ? 'Great pace: you completed $done/$total tasks. Keep the streak today.'
            : 'You’re at $done/$total tasks. One quick submission today will boost your week.',
        level: done >= 2 ? 'good' : 'warn',
      ),
      DemoInsight(
        id: 'i2',
        title: 'Risk',
        body:
            'Physics Quiz Tuesday 09:00. Recommendation: 12 minutes review on Free Fall + 6 practice questions.',
        level: 'warn',
      ),
      DemoInsight(
        id: 'i3',
        title: 'Personalized plan',
        body:
            'Based on your recent activity, focus next: (1) Submit “Derivatives”, (2) Review Physics formulas, (3) Start CS mini-API.',
        level: p > 200 ? 'good' : 'good',
      ),
    ];
  }

  static String fakeTutorReply(String msg) {
    final m = msg.toLowerCase();
    if (m.contains('physics') || m.contains('free fall')) {
      return "Let’s do it Bagrut-style:\n1) Identify knowns (v0, a=g, t).\n2) Pick equation: v=v0+gt or y=y0+v0t+½gt².\nTell me: do we know time or height?";
    }
    if (m.contains('math') || m.contains('derivative')) {
      return "Quick plan:\n• If it’s a polynomial: power rule.\n• If it’s product/quotient: choose rule.\nSend me the exact function and I’ll walk you through step-by-step.";
    }
    if (m.contains('schedule') || m.contains('today')) {
      return "Today: Math 08:15, Physics 10:00.\nIf you do 1 task submission, you likely gain +15–25 points and move up the leaderboard.";
    }
    return "I’m your Classmate AI Tutor.\nTell me what subject + what you’re stuck on, and I’ll guide you with small steps and a quick quiz at the end.";
  }

  static int importFromGoogleClassroomMock() {
    // “import” 3 items + 2 assignments (mock)
    schedule.addAll([
      DemoScheduleItem(
        id: 'sx${_rng.nextInt(999)}',
        day: 'Thu',
        time: '11:00',
        title: 'Homeroom',
        room: 'A-1',
        type: 'event',
      ),
      DemoScheduleItem(
        id: 'sx${_rng.nextInt(999)}',
        day: 'Thu',
        time: '12:20',
        title: 'Computer Science',
        room: 'C-3',
        type: 'lesson',
      ),
      DemoScheduleItem(
        id: 'sx${_rng.nextInt(999)}',
        day: 'Thu',
        time: '14:00',
        title: 'Parent Notes',
        room: 'Online',
        type: 'event',
      ),
    ]);
    assignments.addAll([
      DemoAssignment(
        id: 'ax${_rng.nextInt(999)}',
        classroomId: 'c2',
        title: 'Limits practice (imported)',
        due: 'Sun 20:00',
        reward: 18,
      ),
      DemoAssignment(
        id: 'ax${_rng.nextInt(999)}',
        classroomId: 'c1',
        title: 'Kinematics set (imported)',
        due: 'Mon 20:00',
        reward: 22,
      ),
    ]);
    notifications.insert(
      0,
      DemoNotification(
        id: 'ni${_rng.nextInt(999)}',
        title: 'Imported!',
        body: 'Google Classroom sync imported schedule + tasks.',
        time: 'now',
      ),
    );
    return 5;
  }

  static void reset() {
    user = DemoUser(
      id: 'u1',
      name: 'Tony Aboud',
      role: 'student',
      points: 180,
      school: 'Demo High School',
      grade: '10',
    );
    for (final a in assignments) {
      a.submitted = false;
    }
    for (final n in notifications) {
      n.seen = false;
    }
  }
}
