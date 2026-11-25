import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/data/mock_chamber_data.dart';
import '../../../core/models/chamber_models.dart';
import '../../../core/theme/app_theme.dart';

class WritePrescriptionScreen extends ConsumerStatefulWidget {
  final String patientId;

  const WritePrescriptionScreen({super.key, required this.patientId});

  @override
  ConsumerState<WritePrescriptionScreen> createState() =>
      _WritePrescriptionScreenState();
}

class _WritePrescriptionScreenState
    extends ConsumerState<WritePrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ccCtrl = TextEditingController();
  final _oeCtrl = TextEditingController(text: 'BP: 120/80 mmHg, Pulse: 78 bpm, Temp: 98.4°F');
  final _diagnosisCtrl = TextEditingController();
  final _adviceCtrl = TextEditingController(
      text: 'Drink plenty of water. Take medicines regularly as advised.');
  final _privateNoteCtrl = TextEditingController();

  DateTime? _nextVisitDate;
  final List<_MedicineDraft> _medicines = [_MedicineDraft()];

  @override
  void dispose() {
    _ccCtrl.dispose();
    _oeCtrl.dispose();
    _diagnosisCtrl.dispose();
    _adviceCtrl.dispose();
    _privateNoteCtrl.dispose();
    for (final m in _medicines) {
      m.dispose();
    }
    super.dispose();
  }

  Future<void> _pickNextVisitDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _nextVisitDate = picked);
    }
  }

  void _savePrescription() {
    if (!_formKey.currentState!.validate()) return;

    final validMeds = _medicines
        .where((m) => m.nameCtrl.text.trim().isNotEmpty)
        .map(
          (m) => MedicineItem(
        name: m.nameCtrl.text.trim(),
        dosage: m.dosage,
        duration: m.duration,
        instruction: m.instruction,
      ),
    )
        .toList();

    if (validMeds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one medicine.')),
      );
      return;
    }

    final newVisit = VisitModel(
      id: 'vis-${DateTime.now().millisecondsSinceEpoch}',
      patientId: widget.patientId,
      visitDate: DateTime.now(),
      chiefComplaints: _ccCtrl.text.trim(),
      onExamination: _oeCtrl.text.trim(),
      diagnosis: _diagnosisCtrl.text.trim(),
      medicines: validMeds,
      advice: _adviceCtrl.text.trim(),
      nextVisitDate: _nextVisitDate,
      doctorPrivateNote: _privateNoteCtrl.text.trim(),
    );

    ref.read(visitsProvider.notifier).update((state) => [newVisit, ...state]);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Prescription saved successfully!'),
        backgroundColor: AppTheme.royalIndigo,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final patients = ref.watch(patientsProvider);
    final patient = patients.firstWhere(
          (p) => p.id == widget.patientId,
      orElse: () => patients.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New Digital Prescription',
                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800)),
            Text(
              '${patient.fullName} (${patient.manualRecordNo}) • ${patient.age}y,${patient.gender}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _savePrescription,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.royalIndigo,
              ),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Save Rx'),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 1. Clinical Assessment Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '1. Clinical Assessment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.royalIndigo,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _ccCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Chief Complaints (C/C) *',
                            hintText: 'e.g., Fever for 3 days, dry cough, weakness',
                          ),
                          validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _oeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'On Examination (O/E)',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _diagnosisCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Diagnosis (Dx) *',
                            hintText: 'e.g., Acute Viral Upper Respiratory Infection',
                          ),
                          validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Rx Medicines Builder Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '2. Rx (Medicines)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.royalIndigo,
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() => _medicines.add(_MedicineDraft()));
                              },
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Add Medicine'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(_medicines.length, (index) {
                          final med = _medicines[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.iceSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 13,
                                      backgroundColor: AppTheme.royalIndigo,
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextFormField(
                                        controller: med.nameCtrl,
                                        decoration: const InputDecoration(
                                          labelText:
                                          'Medicine Name (e.g., Tab. Napa Extend 665mg)',
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                    if (_medicines.length > 1)
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.redAccent),
                                        onPressed: () {
                                          setState(() {
                                            med.dispose();
                                            _medicines.removeAt(index);
                                          });
                                        },
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: med.dosage,
                                        isExpanded: true,
                                        decoration: const InputDecoration(
                                          labelText: 'Dosage',
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                        ),
                                        items: [
                                          '1 + 0 + 1',
                                          '1 + 1 + 1',
                                          '1 + 0 + 0',
                                          '0 + 0 + 1',
                                          '0 + 1 + 0',
                                          'SOS (When needed)',
                                        ]
                                            .map((d) => DropdownMenuItem(
                                                value: d,
                                                child: Text(d,
                                                    overflow:
                                                        TextOverflow.ellipsis)))
                                            .toList(),
                                        onChanged: (v) => setState(
                                            () => med.dosage = v ?? '1 + 0 + 1'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: med.duration,
                                        isExpanded: true,
                                        decoration: const InputDecoration(
                                          labelText: 'Duration',
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                        ),
                                        items: [
                                          '3 Days',
                                          '5 Days',
                                          '7 Days',
                                          '10 Days',
                                          '14 Days',
                                          '1 Month',
                                          'Continue',
                                        ]
                                            .map((d) => DropdownMenuItem(
                                                value: d,
                                                child: Text(d,
                                                    overflow:
                                                        TextOverflow.ellipsis)))
                                            .toList(),
                                        onChanged: (v) => setState(
                                            () => med.duration = v ?? '5 Days'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                DropdownButtonFormField<String>(
                                  value: med.instruction,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Instruction',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                  ),
                                  items: [
                                    'After meal',
                                    'Before meal',
                                    '30 mins before meal',
                                    'At bedtime',
                                  ]
                                      .map((i) => DropdownMenuItem(
                                          value: i,
                                          child: Text(i,
                                              overflow:
                                                  TextOverflow.ellipsis)))
                                      .toList(),
                                  onChanged: (v) => setState(() =>
                                      med.instruction = v ?? 'After meal'),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Advice, Follow-Up & Private Note
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '3. Advice & Follow-up',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.royalIndigo,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _adviceCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Patient Advice (Bangla / English)',
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _pickNextVisitDate,
                          borderRadius: BorderRadius.circular(12),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Next Follow-up Visit Date',
                              prefixIcon: Icon(Icons.calendar_today_rounded),
                            ),
                            child: Text(
                              _nextVisitDate == null
                                  ? 'Tap to select follow-up date (Optional)'
                                  : DateFormat('dd MMM yyyy')
                                  .format(_nextVisitDate!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _privateNoteCtrl,
                          decoration: const InputDecoration(
                            labelText:
                            'Doctor Private Note (Hidden from Prescription Print)',
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _savePrescription,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Save & Complete Prescription'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MedicineDraft {
  final TextEditingController nameCtrl = TextEditingController();
  String dosage = '1 + 0 + 1';
  String duration = '5 Days';
  String instruction = 'After meal';

  void dispose() {
    nameCtrl.dispose();
  }
}