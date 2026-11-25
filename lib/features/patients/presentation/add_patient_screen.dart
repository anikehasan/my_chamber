import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/mock_chamber_data.dart';
import '../../../core/models/chamber_models.dart';
import '../../../core/theme/app_theme.dart';

class AddPatientScreen extends ConsumerStatefulWidget {
  const AddPatientScreen({super.key});

  @override
  ConsumerState<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends ConsumerState<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recordNoCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String _gender = 'Male';
  String _bloodGroup = 'O+';
  String? _duplicateWarning;

  @override
  void initState() {
    super.initState();
    // Auto-suggest next record number based on current count
    final count = ref.read(patientsProvider).length + 1001;
    _recordNoCtrl.text = 'MC-$count';
  }

  @override
  void dispose() {
    _recordNoCtrl.dispose();
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _checkDuplicateRecord(String val) {
    final patients = ref.read(patientsProvider);
    final exists = patients.any(
      (p) => p.manualRecordNo.trim().toLowerCase() == val.trim().toLowerCase(),
    );
    setState(() {
      _duplicateWarning = exists
          ? 'Record number "$val" already exists in this chamber!'
          : null;
    });
  }

  void _savePatient() {
    if (_duplicateWarning != null) return;
    if (!_formKey.currentState!.validate()) return;

    final chamber = ref.read(chamberProvider);
    final newPatient = PatientModel(
      id: 'pat-${DateTime.now().millisecondsSinceEpoch}',
      chamberId: chamber.id,
      manualRecordNo: _recordNoCtrl.text.trim(),
      fullName: _nameCtrl.text.trim(),
      age: int.tryParse(_ageCtrl.text.trim()) ?? 0,
      gender: _gender,
      phone: _phoneCtrl.text.trim(),
      bloodGroup: _bloodGroup,
      address: _addressCtrl.text.trim(),
      createdAt: DateTime.now(),
    );

    ref.read(patientsProvider.notifier).update((state) => [newPatient, ...state]);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Patient ${newPatient.fullName} (${newPatient.manualRecordNo}) registered!'),
        backgroundColor: AppTheme.royalIndigo,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register New Patient')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _recordNoCtrl,
                        onChanged: _checkDuplicateRecord,
                        decoration: InputDecoration(
                          labelText: 'Chamber Record / Serial No. *',
                          prefixIcon: const Icon(Icons.tag_rounded),
                          errorText: _duplicateWarning,
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Patient Full Name *',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ageCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Age (Years) *',
                                prefixIcon: Icon(Icons.cake_outlined),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _bloodGroup,
                              decoration: const InputDecoration(
                                labelText: 'Blood Group',
                                prefixIcon: Icon(Icons.bloodtype_outlined),
                              ),
                              items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                                  .map((bg) => DropdownMenuItem(
                                      value: bg, child: Text(bg)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _bloodGroup = v ?? 'O+'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: Icon(Icons.wc_rounded),
                        ),
                        items: ['Male', 'Female', 'Other']
                            .map((g) =>
                                DropdownMenuItem(value: g, child: Text(g)))
                            .toList(),
                        onChanged: (v) => setState(() => _gender = v ?? 'Male'),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Mobile Number *',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _addressCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Address / Area',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed:
                            _duplicateWarning != null ? null : _savePatient,
                        icon: const Icon(Icons.check_circle_outline_rounded),
                        label: const Text('Save Patient Record'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}