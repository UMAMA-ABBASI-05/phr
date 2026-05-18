import 'package:flutter/material.dart';
import 'package:phr/screens/add_vitals_screen.dart';
import 'package:phr/screens/hospital_doctor_screen.dart';
import '../services/api_services.dart';
import '../services/shared_pref.dart';
//import 'hospital_doctors_screen.dart';
import 'profile_screen.dart';

class HospitalsScreen extends StatefulWidget {
  const HospitalsScreen({super.key});

  @override
  State<HospitalsScreen> createState() => _HospitalsScreenState();
}

class _HospitalsScreenState extends State<HospitalsScreen> {
  List<dynamic> _hospitals = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  String _error = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchHospitals();
    _searchCtrl.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _hospitals
          : _hospitals.where((h) {
              final name = (h['name'] ?? h['hospital_name'] ?? '')
                  .toLowerCase();
              return name.contains(q);
            }).toList();
    });
  }

  Future<void> _fetchHospitals() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final data = await ApiService.getAllHospitals();
      setState(() {
        _hospitals = data;
        _filtered = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientName = SessionService().name;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // ── Welcome Header ──────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFDEEAF7),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'welcome !',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1a1a2e),
                          ),
                        ),
                        Text(
                          patientName.isNotEmpty ? patientName : 'Patient',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1a1a2e),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/images/logo.png',
                    width: 110,
                    height: 110,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Search Bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE0E0E0),
                    width: 1.2,
                  ),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search Hospitals...',
                    hintStyle: const TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade400,
                      size: 22,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Hospitals heading ───────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Hospitals',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1a1a2e),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── List ────────────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF072263),
                      ),
                    )
                  : _error.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Color(0xFFE24B4A),
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _error,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFE24B4A),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchHospitals,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF072263),
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No hospitals found',
                        style: TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 15,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchHospitals,
                      color: const Color(0xFF072263),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final hospital = _filtered[index];
                          return _HospitalCard(
                            hospital: hospital,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HospitalDoctorsScreen(
                                    hospitalId:
                                        hospital['id']?.toString() ??
                                        hospital['hospital_id']?.toString() ??
                                        '',
                                    hospitalName:
                                        hospital['name'] ??
                                        hospital['hospital_name'] ??
                                        'Hospital',
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),

      // ── Bottom Nav Bar ──────────────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                // Home (active)
                Expanded(
                  child: InkWell(
                    onTap: () {},
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home, color: Color(0xFF4285F4), size: 26),
                        SizedBox(height: 3),
                        Text(
                          'Home',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF4285F4),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddVitalsScreen(),
                        ),
                      );
                    },
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.monitor_heart_outlined,
                          color: Color(0xFF888888),
                          size: 26,
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Vitals',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF888888),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Profile
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: Color(0xFF888888),
                          size: 26,
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF888888),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hospital Card ─────────────────────────────────────────────────────────────
class _HospitalCard extends StatelessWidget {
  final Map<String, dynamic> hospital;
  final VoidCallback onTap;

  const _HospitalCard({required this.hospital, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = hospital['name'] ?? hospital['hospital_name'] ?? 'Hospital';
    final lastVisit =
        hospital['last_visit'] ?? hospital['last_visit_date'] ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              // Hospital icon box
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFDEEAF7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_hospital,
                  color: Color(0xFF1C4BB4),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1a1a2e),
                      ),
                    ),
                    if (lastVisit.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        'Last visit: $lastVisit',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF888888),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
