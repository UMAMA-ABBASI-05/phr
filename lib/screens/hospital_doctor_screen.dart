import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'doctor_detail_screen.dart';

class HospitalDoctorsScreen extends StatefulWidget {
  final String hospitalId;
  final String hospitalName;

  const HospitalDoctorsScreen({
    super.key,
    required this.hospitalId,
    required this.hospitalName,
  });

  @override
  State<HospitalDoctorsScreen> createState() => _HospitalDoctorsScreenState();
}

class _HospitalDoctorsScreenState extends State<HospitalDoctorsScreen> {
  List<dynamic> _doctors = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final data = await ApiService.getDoctorsByHospital(widget.hospitalId);
      setState(() {
        _doctors = data;
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top bar with back + hospital name ──────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 20,
                      color: Color(0xFF1a1a2e),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // ── Hospital name ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.hospitalName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1a1a2e),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                height: 24,
                thickness: 1,
                color: Color(0xFFE0E0E0),
              ),
            ),

            // ── "Doctors" heading ──────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Doctors',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1a1a2e),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── List ───────────────────────────────────────────────────
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
                            onPressed: _fetchDoctors,
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
                  : _doctors.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off_outlined,
                            color: Color(0xFFBBBBBB),
                            size: 56,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No doctors found\nfor this hospital',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchDoctors,
                      color: const Color(0xFF072263),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        itemCount: _doctors.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final doctor = _doctors[index];
                          return _DoctorCard(
                            doctor: doctor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DoctorDetailScreen(
                                    doctorId:
                                        doctor['id']?.toString() ??
                                        doctor['doctor_id']?.toString() ??
                                        '',
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
    );
  }
}

// ── Doctor Card ───────────────────────────────────────────────────────────────
class _DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback onTap;

  const _DoctorCard({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = doctor['name'] ?? doctor['doctor_name'] ?? 'Doctor';
    final specialization =
        doctor['specialization'] ?? doctor['specialty'] ?? '';
    final lastVisit = doctor['last_visit'] ?? doctor['last_visit_date'] ?? '';

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
              // ── Circular avatar ──────────────────────────────────────
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: Color(0xFFD0D0D0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 32),
              ),

              const SizedBox(width: 14),

              // ── Name + info ──────────────────────────────────────────
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
                      const SizedBox(height: 4),
                      Text(
                        'Last Visit: $lastVisit',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                    if (specialization.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Specialization: ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF555555),
                              ),
                            ),
                            TextSpan(
                              text: specialization,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF777777),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Chevron ──────────────────────────────────────────────
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
