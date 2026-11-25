import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/data/mock_chamber_data.dart';
import '../../../core/theme/app_theme.dart';

class PrescriptionPreviewScreen extends ConsumerWidget {
  final String visitId;

  const PrescriptionPreviewScreen({super.key, required this.visitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chamber = ref.watch(chamberProvider);
    final visits = ref.watch(visitsProvider);
    final patients = ref.watch(patientsProvider);

    final visit = visits.firstWhere(
      (v) => v.id == visitId,
      orElse: () => visits.first,
    );
    final patient = patients.firstWhere(
      (p) => p.id == visit.patientId,
      orElse: () => patients.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Preview'),
        actions: [
          IconButton(
            tooltip: 'Print / Export PDF',
            icon: const Icon(Icons.print_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Print / PDF export ready for clinical printer!'),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chamber & Doctor Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chamber.doctorName,
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.royalIndigo,
                              ),
                            ),
                            Text(
                              chamber.doctorDegrees,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'BMDC Reg: ${chamber.bmdcRegNo}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            chamber.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            chamber.address,
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textMuted),
                          ),
                          Text(
                            'Serial: ${chamber.phone}',
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24, thickness: 1.5),

                  // Patient Meta Bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.iceSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Wrap(
                      spacing: 24,
                      runSpacing: 6,
                      children: [
                        Text('Name: ${patient.fullName}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        Text('ID: ${patient.manualRecordNo}'),
                        Text('Age/Sex: ${patient.age}y / ${patient.gender}'),
                        Text(
                            'Date: ${DateFormat('dd MMM yyyy').format(visit.visitDate)}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Body Split: Left Clinical Notes | Right Rx
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: C/C, O/E, Dx
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Chief Complaints:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700)),
                              Text(visit.chiefComplaints,
                                  style: const TextStyle(fontSize: 13)),
                              const SizedBox(height: 16),
                              const Text('On Examination:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700)),
                              Text(visit.onExamination,
                                  style: const TextStyle(fontSize: 13)),
                              const SizedBox(height: 16),
                              const Text('Diagnosis:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700)),
                              Text(
                                visit.diagnosis,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.royalIndigo,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Right Column: Rx Medicines
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Rx',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  fontStyle: FontStyle.italic,
                                  color: AppTheme.royalIndigo,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...List.generate(visit.medicines.length, (i) {
                                final m = visit.medicines[i];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${i + 1}. ${m.name}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14.5,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16),
                                        child: Text(
                                          '${m.dosage}  —  ${m.duration}  (${m.instruction})',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.textMuted,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const Divider(height: 24),
                              if (visit.advice.isNotEmpty) ...[
                                const Text('Advice:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700)),
                                Text(visit.advice,
                                    style: const TextStyle(fontSize: 13)),
                                const SizedBox(height: 12),
                              ],
                              if (visit.nextVisitDate != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.softMint,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Next Visit: ${DateFormat('dd MMM yyyy').format(visit.nextVisitDate!)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.royalIndigo,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
