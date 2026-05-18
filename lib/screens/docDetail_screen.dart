// import 'package:flutter/material.dart';
// import '../services/api_services.dart';
// import '../services/shared_pref.dart';
// import 'visit_note_detail_screen.dart';
// import 'profile_screen.dart';

// class DoctorDetailScreen extends StatefulWidget {
//   final Map<String, dynamic> doctor;
//   const DoctorDetailScreen({super.key, required this.doctor});
//   @override
//   State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
// }

// class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
//   List<dynamic> _notes = [];
//   bool _loading = true;
//   String _error = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadNotes();
//   }

//   Future<void> _loadNotes() async {
//     try {
//       final mpi = SessionService().mpi;
//       final doctorId = widget.doctor['doctor_id']?.toString() ?? '';
//       final notes = await ApiService.getVisitNotes(mpi, doctorId);

//       final finalNotes = notes.isNotEmpty ? notes : _hardcodedNotes();

//       setState(() {
//         _notes = finalNotes;
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _notes = _hardcodedNotes();
//         _loading = false;
//       });
//     }
//   }

//   List<Map<String, dynamic>> _hardcodedNotes() {
//     return [
//       {
//         'note_id': '14',
//         'note_title': 'Initial Consultation',
//         'visit_date': '2026-04-25 10:45 AM',
//       },
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     final doc = widget.doctor;
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // ── AppBar ─────────────────────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.arrow_back_ios_new, size: 18),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                   Text(
//                     doc['name'] ?? '',
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFF1a1a2e),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // ── Doctor Info Card ──────────────────────────────────────
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: const Color(0xFFEEEEEE)),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _infoRow('Phone no:', doc['phone_no'] ?? 'N/A'),
//                           const SizedBox(height: 8),
//                           _infoRow(
//                             'Specialization:',
//                             doc['specialization'] ?? 'N/A',
//                           ),
//                           const SizedBox(height: 8),
//                           RichText(
//                             text: TextSpan(
//                               style: const TextStyle(
//                                 fontSize: 13,
//                                 color: Color(0xFF333333),
//                               ),
//                               children: [
//                                 const TextSpan(
//                                   text: 'About: ',
//                                   style: TextStyle(fontWeight: FontWeight.w600),
//                                 ),
//                                 TextSpan(
//                                   text:
//                                       doc['about'] ??
//                                       'No description available.',
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 24),

//                     const Text(
//                       'Visiting Notes',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF1a1a2e),
//                       ),
//                     ),
//                     const SizedBox(height: 12),

//                     // ── Notes List ────────────────────────────────────────────
//                     if (_loading)
//                       const Center(
//                         child: CircularProgressIndicator(
//                           color: Color(0xFF4285F4),
//                         ),
//                       )
//                     else if (_error.isNotEmpty)
//                       Text(
//                         _error,
//                         style: const TextStyle(color: Color(0xFFE24B4A)),
//                       )
//                     else if (_notes.isEmpty)
//                       const Text(
//                         'No visiting notes found.',
//                         style: TextStyle(color: Color(0xFF888888)),
//                       )
//                     else
//                       ..._notes.map(
//                         (note) => _NoteCard(
//                           note: note,
//                           onTap: () => Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => VisitNoteDetailScreen(
//                                 noteId: note['note_id']?.toString() ?? '',
//                                 noteTitle: note['note_title'] ?? 'Visit Note',
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),

//             // ── Bottom Nav ─────────────────────────────────────────────────
//             Container(
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: InkWell(
//                       onTap: () =>
//                           Navigator.popUntil(context, (r) => r.isFirst),
//                       child: const Padding(
//                         padding: EdgeInsets.symmetric(vertical: 10),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               Icons.home_outlined,
//                               color: Color(0xFF888888),
//                               size: 24,
//                             ),
//                             SizedBox(height: 2),
//                             Text(
//                               'Home',
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 color: Color(0xFF888888),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: InkWell(
//                       onTap: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const ProfileScreen(),
//                         ),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 10),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               Icons.person_outline,
//                               color: Colors.grey.shade400,
//                               size: 24,
//                             ),
//                             const SizedBox(height: 2),
//                             Text(
//                               'Profile',
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 color: Colors.grey.shade400,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _infoRow(String label, String value) {
//     return RichText(
//       text: TextSpan(
//         style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
//         children: [
//           TextSpan(
//             text: '$label ',
//             style: const TextStyle(fontWeight: FontWeight.w600),
//           ),
//           TextSpan(text: value),
//         ],
//       ),
//     );
//   }
// }

// // ─── Note Card ────────────────────────────────────────────────────────────────
// class _NoteCard extends StatelessWidget {
//   final Map<String, dynamic> note;
//   final VoidCallback onTap;
//   const _NoteCard({required this.note, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: const Color(0xFFEEEEEE)),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 38,
//               height: 38,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFEAF2FF),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Icon(
//                 Icons.description_outlined,
//                 color: Color(0xFF4285F4),
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     note['note_title'] ?? 'Visit Note',
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF1a1a2e),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     note['visit_date']?.toString() ?? '',
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Color(0xFF888888),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC), size: 22),
//           ],
//         ),
//       ),
//     );
//   }
// }
