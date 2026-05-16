import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Android emulator → 10.0.2.2  |  real device → your PC IP e.g. 192.168.1.x
  static const String baseUrl = 'http://192.168.51.14:8004';
  static Future<List<dynamic>> getAllHospitals() async {
    final response = await http.get(
      Uri.parse('$baseUrl/all_hospitals'),
      headers: {'Content-Type': 'application/json'},
    );
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return body is List ? body : (body['data'] ?? body['hospitals'] ?? []);
    }
    throw Exception(body['detail'] ?? 'Failed to load hospitals');
  }

  static Future<List<dynamic>> getDoctorsByHospital(String hospitalId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/get-doctors/hosptial/$hospitalId'),
      headers: {'Content-Type': 'application/json'},
    );
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return body is List ? body : (body['data'] ?? body['doctors'] ?? []);
    }
    throw Exception(body['detail'] ?? 'Failed to load doctors');
  }

  static Future<Map<String, dynamic>> getDoctorById(String doctorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/single-doctor/$doctorId'),
      headers: {'Content-Type': 'application/json'},
    );
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return body is Map<String, dynamic>
          ? body
          : (body['data'] ?? body['doctor'] ?? {});
    }
    throw Exception(body['detail'] ?? 'Failed to load doctor details');
  }

  // ── Auth ─────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(String nic, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nic': nic, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return data;
    throw Exception(data['detail'] ?? 'Login failed');
  }

  static Future<String> signup(String nic, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nic': nic, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return data['message'] ?? 'Sign Up successful';
    throw Exception(data['detail'] ?? 'Signup failed');
  }

  // ── Doctors ───────────────────────────────────────────────────────────────
  // lib/services/api_services.dart

  static Future<List<dynamic>> getDoctorsEncounteredByPatient({
    required int mpi,
  }) async {
    try {
      // Swagger ke mutabiq GET request aur path parameter
      final response = await http.get(
        Uri.parse('$baseUrl/doctor-encountered-by-patient/$mpi'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body); // List of DoctorBase objects
      } else if (response.statusCode == 400) {
        print("Bad Request: Check database/server logs");
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print("Exception in getDoctorsEncounteredByPatient: $e");
      return [];
    }
  }

  // ── Visit Notes ───────────────────────────────────────────────────────────
  // GET /doctor-visit-notes/{mpi}/{doctor_id}
  // Returns: list of { note_id, visit_date, note_title }
  static Future<List<dynamic>> getVisitNotes(
    String mpi,
    String doctorId,
  ) async {
    final res = await http.get(
      Uri.parse('$baseUrl/doctor-visit-notes/$mpi/$doctorId'),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load visit notes');
  }

  // ── Visit Note Detail ─────────────────────────────────────────────────────
  // GET /visit-note-details/{note_id}
  // Returns: note_id, note_title, patient_complaint, diagnosis, note_details,
  //          consultation_bill, payment_status, lab_name?, lab_tests?, test_bill?
  static Future<Map<String, dynamic>> getVisitNoteDetail(String noteId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/visit-note-details/$noteId'),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load note details');
  }

  // ── Lab Reports Base ──────────────────────────────────────────────────────
  // GET /lab-reports-base/{note_id}
  // Returns: list of { report_id, test_name, updated_at, test_status }
  static Future<List<dynamic>> getLabReportsBase(String noteId) async {
    final res = await http.get(Uri.parse('$baseUrl/lab-reports-base/$noteId'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load lab reports');
  }

  // ── Lab Results ───────────────────────────────────────────────────────────
  // GET /lab-results/{report_id}
  // Returns: report_id, test_name, description, mini_test_results[]
  //          each mini: mini_test_id, test_name, normal_range, result_value
  static Future<Map<String, dynamic>> getLabResults(int reportId) async {
    final res = await http.get(Uri.parse('$baseUrl/lab-results/$reportId'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load lab results');
  }
}
