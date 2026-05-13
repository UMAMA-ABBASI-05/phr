import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../services/shared_pref.dart';
import 'docDetail_screen.dart';
import 'profile_screen.dart';
import 'add_vitals_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _allDoctors = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  String _error = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDoctors();
    _searchCtrl.addListener(_onSearch);
  }

  Future<void> _loadDoctors() async {
    try {
      final session = SessionService();
      final mpi = session.mpi;

      if (mpi.isEmpty) {
        setState(() {
          _error = 'Patient MPI not found. Please login again.';
          _loading = false;
        });
        return;
      }

      final docs = await ApiService.getDoctorsEncounteredByPatient(
        mpi: int.parse(mpi),
      );

      // Agar API empty return kare toh hardcoded data use karo
      final finalDocs = docs.isNotEmpty ? docs : _hardcodedDoctors();

      setState(() {
        _allDoctors = finalDocs;
        _filtered = finalDocs;
        _loading = false;
      });
    } catch (e) {
      // Error pe bhi hardcoded data dikhao
      setState(() {
        _allDoctors = _hardcodedDoctors();
        _filtered = _hardcodedDoctors();
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> _hardcodedDoctors() {
    return [
      {
        'doctor_id': '3',
        'name': 'Dr. Ahmad Khan',
        'phone_no': '+923001234567',
        'specialization': 'Cardiology',
        'about': 'Heart Specialist',
        'last_visit': '2026-04-25',
      },
    ];
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _allDoctors.where((d) {
        final name = (d['name'] ?? '').toString().toLowerCase();
        final spec = (d['specialization'] ?? '').toString().toLowerCase();
        return name.contains(q) || spec.contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionService();
    final patientName = session.name.isNotEmpty ? session.name : 'Patient';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Header (Updated with Logo) ──────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              decoration: const BoxDecoration(
                color: Color(0xFFD6EAF8), // Light blue from Figma
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'welcome !',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF555555),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        patientName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1a1a2e),
                        ),
                      ),
                    ],
                  ),
                  // Added Logo Widget
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: Image.asset(
                      'assets/images/logo.png', // Logo path
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.favorite,
                          color: Color(0xFF4285F4),
                          size: 40,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Search bar ──────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search Doctors...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Doctor Visits',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1a1a2e),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Doctor List ─────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4285F4),
                      ),
                    )
                  : _error.isNotEmpty
                  ? Center(
                      child: Text(
                        _error,
                        style: const TextStyle(color: Color(0xFFE24B4A)),
                      ),
                    )
                  : _filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No doctors found',
                        style: TextStyle(color: Color(0xFF888888)),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadDoctors,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filtered.length,
                        itemBuilder: (ctx, i) => _DoctorCard(
                          doctor: _filtered[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DoctorDetailScreen(doctor: _filtered[i]),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),

            // ── Bottom Nav ──────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: Row(
                children: [
                  _navItem(Icons.home_filled, 'Home', true, () {}),
                  _navItem(Icons.person_outline, 'Profile', false, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  }),
                  // Bottom Nav mein add karo:
                  _navItem(Icons.monitor_heart_outlined, 'Vitals', false, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddVitalsScreen(),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    final color = isActive ? const Color(0xFF4285F4) : Colors.grey.shade400;
    return Expanded(
      child: TextButton(
        onPressed: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}

// ─── Doctor Card Widget ───────────────────────────────────────────────────────
class _DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback onTap;

  const _DoctorCard({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFFEAF2FF),
              child: const Icon(
                Icons.person,
                color: Color(0xFF4285F4),
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1a1a2e),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    doctor['phone_no'] ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Specialization: ${doctor['specialization'] ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC), size: 22),
          ],
        ),
      ),
    );
  }
}
