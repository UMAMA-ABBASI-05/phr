import 'package:flutter/material.dart';
import 'show_vitals_screen.dart';

class AddVitalsScreen extends StatefulWidget {
  final String patientNic;
  const AddVitalsScreen({super.key, required this.patientNic});

  @override
  State<AddVitalsScreen> createState() => _AddVitalsScreenState();
}

class _AddVitalsScreenState extends State<AddVitalsScreen> {
  String _selectedVital = 'BP';

  final _systolicCtrl = TextEditingController();
  final _diastolicCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _sugarCtrl = TextEditingController();

  String _mealTime = 'Before Meal';
  bool _saving = false;

  static const Color primaryBlue = Color.fromARGB(255, 6, 41, 99);
  static const Color darkBlue = Color(0xFF1a1a2e);

  @override
  void dispose() {
    _systolicCtrl.dispose();
    _diastolicCtrl.dispose();
    _tempCtrl.dispose();
    _sugarCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedVital == 'BP') {
      if (_systolicCtrl.text.isEmpty || _diastolicCtrl.text.isEmpty) {
        _showSnack('Please enter both BP values');
        return;
      }
    } else if (_selectedVital == 'Temperature') {
      if (_tempCtrl.text.isEmpty) {
        _showSnack('Please enter temperature');
        return;
      }
    } else if (_selectedVital == 'Sugar') {
      if (_sugarCtrl.text.isEmpty) {
        _showSnack('Please enter sugar value');
        return;
      }
    }

    setState(() => _saving = true);

    try {
      // TODO: Replace with your actual API call
      Map<String, dynamic> data = {};
      if (_selectedVital == 'BP') {
        data = {
          'type': 'BP',
          'systolic': _systolicCtrl.text,
          'diastolic': _diastolicCtrl.text,
          'unit': 'mmHg',
          'nic': widget.patientNic,
        };
      } else if (_selectedVital == 'Temperature') {
        data = {
          'type': 'Temperature',
          'value': _tempCtrl.text,
          'unit': 'F',
          'nic': widget.patientNic,
        };
      } else {
        data = {
          'type': 'Sugar',
          'meal_time': _mealTime,
          'value': _sugarCtrl.text,
          'unit': 'mg/dL',
          'nic': widget.patientNic,
        };
      }

      print('Vitals data: $data');

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vitals saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnack('Failed to save vitals');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(8, 20, 16, 28),
              decoration: const BoxDecoration(
                color: Color(0xFFD6EAF8),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: darkBlue,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Add Vitals',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: darkBlue,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ShowVitalsScreen(patientNic: widget.patientNic),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.list_alt_rounded,
                      color: primaryBlue,
                      size: 18,
                    ),
                    label: const Text(
                      'Show Vitals',
                      style: TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: primaryBlue, width: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Patient NIC info
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFBDD5F5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.badge_outlined,
                            size: 16,
                            color: primaryBlue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Patient NIC: ${widget.patientNic}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Vital Type Selection
                    const Text(
                      'Select Vital Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: darkBlue,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: Column(
                        children: ['BP', 'Sugar', 'Temperature']
                            .map(
                              (vital) => RadioListTile<String>(
                                value: vital,
                                groupValue: _selectedVital,
                                activeColor: primaryBlue,
                                title: Text(
                                  vital,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: darkBlue,
                                  ),
                                ),
                                onChanged: (val) =>
                                    setState(() => _selectedVital = val!),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Dynamic Fields
                    if (_selectedVital == 'BP') _buildBPFields(),
                    if (_selectedVital == 'Temperature') _buildTempFields(),
                    if (_selectedVital == 'Sugar') _buildSugarFields(),

                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBPFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Blood Pressure',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: darkBlue,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                controller: _systolicCtrl,
                label: 'Systolic (High)',
                hint: 'e.g. 120',
                unit: 'mmHg',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInputField(
                controller: _diastolicCtrl,
                label: 'Diastolic (Low)',
                hint: 'e.g. 80',
                unit: 'mmHg',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTempFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Temperature',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: darkBlue,
          ),
        ),
        const SizedBox(height: 12),
        _buildInputField(
          controller: _tempCtrl,
          label: 'Temperature Value',
          hint: 'e.g. 98.6',
          unit: '°F',
        ),
      ],
    );
  }

  Widget _buildSugarFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Blood Sugar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: darkBlue,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Column(
            children: ['Before Meal', 'After Meal']
                .map(
                  (meal) => RadioListTile<String>(
                    value: meal,
                    groupValue: _mealTime,
                    activeColor: primaryBlue,
                    title: Text(
                      meal,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: darkBlue,
                      ),
                    ),
                    onChanged: (val) => setState(() => _mealTime = val!),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
        _buildInputField(
          controller: _sugarCtrl,
          label: 'Sugar Value',
          hint: 'e.g. 100',
          unit: 'mg/dL',
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String unit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF555555),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(fontSize: 14, color: darkBlue),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: Color(0xFFBBBBBB),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
