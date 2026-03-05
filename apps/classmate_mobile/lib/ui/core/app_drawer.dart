import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: const [
          DrawerHeader(
            child: Text(
              "ClassMate",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          ListTile(title: Text("Schedule")),
          ListTile(title: Text("Classrooms")),
          ListTile(title: Text("AI Tutor")),
          ListTile(title: Text("Insights")),
          ListTile(title: Text("Solutions")),

          Divider(),

          ListTile(title: Text("Attendance")),
          ListTile(title: Text("Grades")),
          ListTile(title: Text("Alerts")),
          ListTile(title: Text("Notifications")),

          Divider(),

          ListTile(title: Text("Profile")),
          ListTile(title: Text("Settings")),
          ListTile(title: Text("Customization")),
          ListTile(title: Text("Logout")),
        ],
      ),
    );
  }
}
