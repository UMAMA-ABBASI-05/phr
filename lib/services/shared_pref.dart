class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  Map<String, dynamic>? _patient;

  void savePatient(Map<String, dynamic> data) => _patient = data;
  Map<String, dynamic>? get patient => _patient;

  String get mpi => _patient?['mpi']?.toString() ?? '';
  String get name => _patient?['name'] ?? '';
  String get nic => _patient?['nic'] ?? '';
  String get gender => _patient?['gender'] ?? '';
  String get phone => _patient?['phone_no'] ?? '';
  String get address => _patient?['address'] ?? '';
  String get dob => _patient?['date_of_birth'] ?? '';

  int get age {
    if (dob.isEmpty) return 0;
    try {
      final birth = DateTime.parse(dob);
      final now = DateTime.now();
      int age = now.year - birth.year;
      if (now.month < birth.month ||
          (now.month == birth.month && now.day < birth.day))
        age--;
      return age;
    } catch (_) {
      return 0;
    }
  }

  void clear() => _patient = null;
}
