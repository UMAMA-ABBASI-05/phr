import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../services/shared_pref.dart';
import 'visit_note_detail_screen.dart';

class DoctorDetailScreen extends StatefulWidget {
  final String doctorId;

  const DoctorDetailScreen({super.key, required this.doctorId});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  Map<String, dynamic>? _doctor;
  List<dynamic> _visitNotes = [];
  bool _loadingDoctor = true;
  bool _loadingNotes = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    await _fetchDoctor();
    await _fetchVisitNotes();
  }

  Future<void> _fetchDoctor() async {
    setState(() {
      _loadingDoctor = true;
      _error = '';
    });
    try {
      final data = await ApiService.getDoctorById(widget.doctorId);
      setState(() {
        _doctor = data;
        _loadingDoctor = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loadingDoctor = false;
      });
    }
  }

  Future<void> _fetchVisitNotes() async {
    setState(() => _loadingNotes = true);
    try {
      final nic = SessionService().nic;
      if (nic.isEmpty) {
        setState(() => _loadingNotes = false);
        return;
      }
      final notes = await ApiService.getVisitNotes(nic, widget.doctorId);
      setState(() {
        _visitNotes = notes;
        _loadingNotes = false;
      });
    } catch (e) {
      setState(() => _loadingNotes = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorName = _doctor?['name'] ?? _doctor?['doctor_name'] ?? 'Doctor';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _loadingDoctor
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF072263)),
              )
            : _error.isNotEmpty
            ? _ErrorView(error: _error, onRetry: _fetchAll)
            : _doctor == null
            ? const Center(child: Text('No data found'))
            : RefreshIndicator(
                onRefresh: _fetchAll,
                color: const Color(0xFF072263),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // ── Back button ───────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 8,
                          top: 8,
                          right: 8,
                        ),
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
                    ),

                    // ── Doctor Name ───────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          doctorName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1a1a2e),
                          ),
                        ),
                      ),
                    ),

                    // ── Divider ───────────────────────────────
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Divider(
                          height: 28,
                          thickness: 1,
                          color: Color(0xFFE0E0E0),
                        ),
                      ),
                    ),

                    // ── Doctor Info Card ──────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _DoctorInfoCard(doctor: _doctor!),
                      ),
                    ),

                    // ── Divider before notes ──────────────────
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Divider(
                          height: 36,
                          thickness: 1,
                          color: Color(0xFFE0E0E0),
                        ),
                      ),
                    ),

                    // ── Visiting Notes heading ────────────────
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Visiting Notes',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1a1a2e),
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 12)),

                    // ── Notes list ────────────────────────────
                    _loadingNotes
                        ? const SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: CircularProgressIndicator(
                                  color: Color(0xFF072263),
                                ),
                              ),
                            ),
                          )
                        : _visitNotes.isEmpty
                        ? SliverToBoxAdapter(child: _EmptyNotes())
                        : SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final note = _visitNotes[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _VisitNoteCard(
                                    note: note,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => VisitNoteDetailScreen(
                                            noteId: note['note_id'].toString(),
                                            noteTitle:
                                                note['note_title']
                                                    ?.toString() ??
                                                'Visit Note',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }, childCount: _visitNotes.length),
                            ),
                          ),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),
      ),
    );
  }
}

// ── Doctor Info Card ──────────────────────────────────────────────────────────
class _DoctorInfoCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  const _DoctorInfoCard({required this.doctor});

  static const _skipKeys = {'id', 'doctor_id', 'name', 'doctor_name'};

  String _label(String key) {
    const map = {
      'phone_no': 'Phone no',
      'phone': 'Phone no',
      'contact': 'Phone no',
      'specialization': 'Specialization',
      'specialty': 'Specialization',
      'about': 'About',
      'bio': 'About',
      'description': 'About',
      'experience': 'Experience',
      'years_of_experience': 'Experience',
      'qualification': 'Qualification',
      'degree': 'Qualification',
      'department': 'Department',
      'hospital': 'Hospital',
      'hospital_name': 'Hospital',
      'last_visit': 'Last Visit',
      'email': 'Email',
      'gender': 'Gender',
    };
    return map[key] ??
        key
            .replaceAll('_', ' ')
            .split(' ')
            .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
            .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final entries = doctor.entries.where((e) {
      if (_skipKeys.contains(e.key)) return false;
      final v = e.value;
      if (v == null) return false;
      final str = v.toString().trim();
      return str.isNotEmpty && str != 'null';
    }).toList();

    if (entries.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: entries.asMap().entries.map((mapEntry) {
          final i = mapEntry.key;
          final e = mapEntry.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (i != 0) const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${_label(e.key)}: ',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1a1a2e),
                      ),
                    ),
                    TextSpan(
                      text: e.value.toString().trim(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF444444),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Visit Note Card ───────────────────────────────────────────────────────────
class _VisitNoteCard extends StatelessWidget {
  final Map<String, dynamic> note;
  final VoidCallback onTap;
  const _VisitNoteCard({required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final title = note['note_title'] ?? 'Visit';
    final date = note['visit_date'] ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8E8E8), width: 1.2),
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
              // Blue icon box
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF4285F4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Color(0xFF4285F4),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a1a2e),
                      ),
                    ),
                    if (date.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        date,
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

// ── Empty Notes ───────────────────────────────────────────────────────────────
class _EmptyNotes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: const Column(
          children: [
            Icon(Icons.note_alt_outlined, color: Color(0xFFBBBBBB), size: 48),
            SizedBox(height: 10),
            Text(
              'No visit notes found',
              style: TextStyle(color: Color(0xFF888888), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error View ────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFE24B4A), size: 48),
          const SizedBox(height: 12),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFE24B4A), fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF072263),
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
