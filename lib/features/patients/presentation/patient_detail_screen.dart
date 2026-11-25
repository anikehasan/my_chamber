import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/data/mock_chamber_data.dart';
import '../../../core/models/chamber_models.dart';
import '../../../core/theme/app_theme.dart';

class PatientDetailScreen extends ConsumerStatefulWidget {
  final String patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  ConsumerState<PatientDetailScreen> createState() =>
      _PatientDetailScreenState();
}

class _PatientDetailScreenState extends ConsumerState<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showUploadReportDialog() {
    final titleCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String selectedType = 'Lab Report';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Upload Medical Report'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Report Title (e.g., CBC, Serum Creatinine) *',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Report Category'),
                  items: ['Lab Report', 'X-Ray / USG', 'ECG / Echo', 'Old Prescription']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => selectedType = v ?? 'Lab Report'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Key Findings / Notes (Optional)',
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.softMint,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.royalIndigo.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.cloud_upload_outlined,
                          color: AppTheme.royalIndigo),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Image / PDF file picker connects to Supabase Storage in backend phase.',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.deepIndigo),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style:
                  FilledButton.styleFrom(backgroundColor: AppTheme.royalIndigo),
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                final role = ref.read(userRoleProvider);
                final newRep = MedicalReportModel(
                  id: 'rep-${DateTime.now().millisecondsSinceEpoch}',
                  patientId: widget.patientId,
                  reportTitle: titleCtrl.text.trim(),
                  fileType: selectedType,
                  uploadedByRole: role,
                  createdAt: DateTime.now(),
                  notes: notesCtrl.text.trim(),
                );
                ref
                    .read(reportsProvider.notifier)
                    .update((state) => [newRep, ...state]);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Report added to patient vault!'),
                    backgroundColor: AppTheme.royalIndigo,
                  ),
                );
              },
              child: const Text('Save Report'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patients = ref.watch(patientsProvider);
    final visits = ref
        .watch(visitsProvider)
        .where((v) => v.patientId == widget.patientId)
        .toList();
    final reports = ref
        .watch(reportsProvider)
        .where((r) => r.patientId == widget.patientId)
        .toList();
    final isDoctor = ref.watch(userRoleProvider) == 'doctor';

    final patient = patients.firstWhere(
      (p) => p.id == widget.patientId,
      orElse: () => patients.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${patient.manualRecordNo} • ${patient.fullName}'),
        actions: [
          TextButton.icon(
            onPressed: _showUploadReportDialog,
            icon: const Icon(Icons.upload_file_rounded, size: 19),
            label: const Text('Upload Report'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: isDoctor
          ? FloatingActionButton.extended(
              backgroundColor: AppTheme.royalIndigo,
              foregroundColor: Colors.white,
              onPressed: () =>
                  context.push('/patients/${patient.id}/prescribe'),
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('Write Prescription'),
            )
          : null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Column(
            children: [
              // Patient Summary Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppTheme.softMint,
                          child: Text(
                            patient.fullName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.royalIndigo,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patient.fullName,
                                style: const TextStyle(
                                  fontSize: 18.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Record: ${patient.manualRecordNo}  |  ${patient.age} yrs, ${patient.gender}  |  Blood: ${patient.bloodGroup}',
                                style: const TextStyle(
                                    color: AppTheme.textMuted, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Phone: ${patient.phone} • ${patient.address}',
                                style: const TextStyle(
                                    color: AppTheme.textMuted, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.royalIndigo,
                indicatorColor: AppTheme.royalIndigo,
                tabs: [
                  Tab(text: 'Visits & Rx (${visits.length})'),
                  Tab(text: 'Medical Reports (${reports.length})'),
                ],
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Visits & Prescriptions
                    _buildVisitsTab(visits),
                    // Tab 2: Medical Report Vault
                    _buildReportsTab(reports, isDoctor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisitsTab(List<VisitModel> visits) {
    if (visits.isEmpty) {
      return const Center(
        child: Text('No prescriptions recorded yet.',
            style: TextStyle(color: AppTheme.textMuted)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: visits.length,
      itemBuilder: (context, index) {
        final visit = visits[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.softMint,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        DateFormat('dd MMM yyyy • hh:mm a')
                            .format(visit.visitDate),
                        style: const TextStyle(
                          color: AppTheme.royalIndigo,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      'Dx: ${visit.diagnosis}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Text('C/C: ${visit.chiefComplaints}',
                    style: const TextStyle(fontSize: 13.5)),
                const SizedBox(height: 4),
                Text('O/E: ${visit.onExamination}',
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textMuted)),
                const SizedBox(height: 10),
                ...visit.medicines.map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 6),
                    child: Text(
                      '• ${m.name} — ${m.dosage} (${m.duration})',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () =>
                        context.push('/visits/${visit.id}/preview'),
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('View / Print Rx'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportsTab(List<MedicalReportModel> reports, bool isDoctor) {
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_rounded,
                size: 46, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            const Text('No medical reports uploaded yet',
                style: TextStyle(color: AppTheme.textMuted)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _showUploadReportDialog,
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Upload First Report'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final rep = reports[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.softMint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.description_rounded,
                  color: AppTheme.royalIndigo),
            ),
            title: Text(rep.reportTitle,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  '${rep.fileType} • Uploaded by ${rep.uploadedByRole.toUpperCase()} • ${DateFormat('dd MMM yyyy').format(rep.createdAt)}',
                  style: const TextStyle(fontSize: 12),
                ),
                if (rep.notes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      rep.notes,
                      style: const TextStyle(
                          fontSize: 12.5, color: AppTheme.textDark),
                    ),
                  ),
              ],
            ),
            trailing: isDoctor
                ? IconButton(
                    tooltip: 'Delete Report (Doctor Only)',
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Colors.redAccent),
                    onPressed: () {
                      ref.read(reportsProvider.notifier).update(
                            (state) =>
                                state.where((r) => r.id != rep.id).toList(),
                          );
                    },
                  )
                : null,
          ),
        );
      },
    );
  }
}
