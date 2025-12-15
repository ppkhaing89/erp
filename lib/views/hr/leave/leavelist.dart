import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:erp/model/global.dart' as globals;

class Leavelist extends StatefulWidget {
  const Leavelist({super.key});

  @override
  State<Leavelist> createState() => _LeavelistState();
}

class _LeavelistState extends State<Leavelist> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          // Top header
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF00A8A8),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding:
                const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Text(
                      "Leave Application",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Icon(Icons.notifications_none, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image.network(
                      globals.profilephoto,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Welcome back,",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  globals.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Dashboard title
          Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 0, top :0), // reduced top space
              child: Container(
                margin: const EdgeInsets.all(0.0),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Dashboard",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Leave History →",
                      style: TextStyle(
                        color: Color(0xFF00A8A8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )),

              const SizedBox(height: 0),
          Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 0, top :0), // reduced top space
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  LeaveCard(count: "07", total: "14", title: "Annual"),
                  LeaveCard(count: "10", total: "14", title: "Medical"),
                  LeaveCard(count: "40", total: "60", title: "Hospitalization"),
                  LeaveCard(count: "03", total: "03", title: "Compassionate"),
                  LeaveCard(count: "05", total: "05", title: "Marriage"),
                  LeaveCard(count: "60", total: "60", title: "Maternity"),
                ],
              )),

          const SizedBox(height: 20),

          // Colleagues section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Colleague’s on leave",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Full List →",
                  style: TextStyle(
                    color: Color(0xFF00A8A8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Horizontal list of colleagues
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: const [
                ColleagueCard(name: "Elizabeth White", date: "01/01/2023"),
                ColleagueCard(name: "Marc Jacob", date: "01/01/2023"),
              ],
            ),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF00A8A8),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Apply Leave"),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt), label: "Leave Status"),
        ],
      ),
    );
  }
}

class LeaveCard extends StatelessWidget {
  final String count;
  final String total;
  final String title;

  const LeaveCard(
      {super.key,
      required this.count,
      required this.total,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      //elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(FontAwesomeIcons.calendar),
            Text(
              "$count/$total",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ColleagueCard extends StatelessWidget {
  final String name;
  final String date;

  const ColleagueCard({super.key, required this.name, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF00A8A8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
                Text(date,
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
