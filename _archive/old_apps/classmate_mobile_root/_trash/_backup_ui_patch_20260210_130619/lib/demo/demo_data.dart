class DemoUser {
  final String id;
  final String name;
  final String role; // student|teacher
  int points;
  DemoUser({
    required this.id,
    required this.name,
    required this.role,
    required this.points,
  });
}

class DemoClassroom {
  final String id;
  final String name;
  final String teacher;
  final String room;
  final String time;
  DemoClassroom({
    required this.id,
    required this.name,
    required this.teacher,
    required this.room,
    required this.time,
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
  static DemoUser user = DemoUser(
    id: "u1",
    name: "Tony Aboud",
    role: "student",
    points: 120,
  );

  static final classrooms = <DemoClassroom>[
    DemoClassroom(
      id: "c1",
      name: "Physics 10",
      teacher: "Ms. Hila",
      room: "Lab 2",
      time: "Sun 10:00",
    ),
    DemoClassroom(
      id: "c2",
      name: "Math 5 Units",
      teacher: "Mr. Amir",
      room: "B-14",
      time: "Mon 08:15",
    ),
    DemoClassroom(
      id: "c3",
      name: "Computer Science",
      teacher: "Ms. Noa",
      room: "C-3",
      time: "Wed 12:20",
    ),
  ];

  static final assignments = <DemoAssignment>[
    DemoAssignment(
      id: "a1",
      classroomId: "c1",
      title: "Free Fall Worksheet",
      due: "Today 23:59",
      reward: 15,
    ),
    DemoAssignment(
      id: "a2",
      classroomId: "c2",
      title: "Derivatives Practice Set",
      due: "Tomorrow 20:00",
      reward: 20,
    ),
    DemoAssignment(
      id: "a3",
      classroomId: "c3",
      title: "Build a Login UI",
      due: "Fri 16:00",
      reward: 30,
    ),
  ];

  static final notifications = <DemoNotification>[
    DemoNotification(
      id: "n1",
      title: "Points awarded!",
      body: "You earned +10 for attendance.",
      time: "2m ago",
    ),
    DemoNotification(
      id: "n2",
      title: "New assignment",
      body: "Physics 10: Free Fall Worksheet.",
      time: "1h ago",
    ),
    DemoNotification(
      id: "n3",
      title: "Leaderboard",
      body: "You moved to #2 this week.",
      time: "Yesterday",
    ),
  ];

  static void reset() {
    user = DemoUser(id: "u1", name: "Tony Aboud", role: "student", points: 120);
    for (final a in assignments) {
      a.submitted = false;
    }
    for (final n in notifications) {
      n.seen = false;
    }
  }
}
