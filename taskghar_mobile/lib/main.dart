// lib/main.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';
import 'models/user_model.dart';
import 'pages/providers_page.dart';
import 'pages/login_page.dart'; 

// ==========================================
// 🚀 THE MEMORY BOOT ENGINE
// ==========================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final String? userRole = prefs.getString('userRole');
  final String? userName = prefs.getString('userName');
  final String? userPhone = prefs.getString('userPhone');

  Widget initialScreen = const LoginPage();

  if (userRole != null && userName != null) {
    UserModel savedUser = UserModel(name: userName, email: userPhone ?? '', role: userRole);
    if (userRole == 'tasker') {
      initialScreen = TaskerDashboard(user: savedUser);
    } else {
      initialScreen = DashboardPage(user: savedUser);
    }
  }

  runApp(TaskGharApp(initialScreen: initialScreen));
}

class TaskGharApp extends StatelessWidget {
  final Widget initialScreen;
  const TaskGharApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskGhar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: initialScreen, 
    );
  }
}

// ==========================================
// 🚀 THE LOGOUT FUNCTION
// ==========================================
Future<void> logoutUser(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); 
  
  if (context.mounted) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false, 
    );
  }
}

// ==========================================
// 🏠 CUSTOMER DASHBOARD
// ==========================================
class DashboardPage extends StatelessWidget {
  final UserModel user;
  const DashboardPage({super.key, required this.user});

  final List<Map<String, dynamic>> services = const [
    {'name': 'Home Cleaning', 'icon': Icons.cleaning_services, 'color': Colors.blue},
    {'name': 'Plumbing', 'icon': Icons.plumbing, 'color': Colors.orange},
    {'name': 'Electrical', 'icon': Icons.electrical_services, 'color': Colors.amber},
    {'name': 'Carpentry', 'icon': Icons.construction, 'color': Colors.brown},
    {'name': 'Appliance Repair', 'icon': Icons.home_repair_service, 'color': Colors.red},
    {'name': 'Painting', 'icon': Icons.format_paint, 'color': Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskGhar Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => logoutUser(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 0,
              color: Colors.deepPurple.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      radius: 24,
                      child: Text(
                        user.name.isNotEmpty ? user.name.substring(0, 1).toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Namaste, ${user.name}!',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'What service do you need today?',
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Our Services',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), 
              itemCount: services.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2, 
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1, 
              ),
              itemBuilder: (context, index) {
                final service = services[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProvidersPage(serviceName: service['name']),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Card(
                    elevation: 3,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: service['color'].withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            service['icon'],
                            size: 32,
                            color: service['color'],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          service['name'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 🛠️ TASKER DASHBOARD (STEP 3 HAPPENS HERE!)
// ==========================================
class TaskerDashboard extends StatefulWidget {
  final UserModel user;
  const TaskerDashboard({super.key, required this.user});

  @override
  State<TaskerDashboard> createState() => _TaskerDashboardState();
}

class _TaskerDashboardState extends State<TaskerDashboard> {
  final ApiService _apiService = ApiService();

  // 🚀 STEP 3: The function that talks to Python to update the status
  void _changeJobStatus(String bookingId, String newStatus) async {
    try {
      await _apiService.updateBookingStatus(bookingId, newStatus);
      setState(() {}); // Refreshes the list to show the new badge
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Job $newStatus!'), 
            backgroundColor: newStatus == 'Accepted' ? Colors.green : Colors.red
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Tasker Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700], 
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => logoutUser(context),
          )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _apiService.getExpertBookings(widget.user.name),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading jobs. ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No new jobs yet!', style: TextStyle(fontSize: 22, color: Colors.grey[800], fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('When customers book you, they will appear here.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final bookings = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final job = bookings[index];
              final isPending = job['status'] == 'Pending'; // 🚀 STEP 3: Checks if action is needed

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(job['service_type'] ?? 'Service Request', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Chip(
                            label: Text(job['status'] ?? 'Pending', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            // 🚀 STEP 3: Dynamic Badge Colors
                            backgroundColor: job['status'] == 'Accepted' ? Colors.green : (job['status'] == 'Declined' ? Colors.red : Colors.orange),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, color: Colors.grey, size: 20),
                          const SizedBox(width: 8),
                          Text(job['date'].toString().split(' ')[0], style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.grey, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(job['address'] ?? 'No address provided', style: const TextStyle(fontSize: 16))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Job Description:', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(job['description'] ?? 'No details provided.', style: const TextStyle(fontSize: 15)),
                      
                      // 🚀 STEP 3: THE ACCEPT / DECLINE BUTTONS
                      if (isPending) ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _changeJobStatus(job['_id'], 'Declined'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Decline'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _changeJobStatus(job['_id'], 'Accepted'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Accept Job', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        )
                      ]
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}