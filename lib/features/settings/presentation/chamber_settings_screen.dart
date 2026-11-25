import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/mock_chamber_data.dart';
import '../../../core/models/chamber_models.dart';
import '../../../core/theme/app_theme.dart';

class ChamberSettingsScreen extends ConsumerStatefulWidget {
  const ChamberSettingsScreen({super.key});

  @override
  ConsumerState<ChamberSettingsScreen> createState() =>
      _ChamberSettingsScreenState();
}

class _ChamberSettingsScreenState extends ConsumerState<ChamberSettingsScreen> {
  late TextEditingController _chamberNameCtrl;
  late TextEditingController _hoursCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;

  @override
  void initState() {
    super.initState();
    final chamber = ref.read(chamberProvider);
    _chamberNameCtrl = TextEditingController(text: chamber.name);
    _hoursCtrl = TextEditingController(text: chamber.chamberHours);
    _phoneCtrl = TextEditingController(text: chamber.phone);
    _addressCtrl = TextEditingController(text: chamber.address);
  }

  @override
  void dispose() {
    _chamberNameCtrl.dispose();
    _hoursCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _saveChamberSettings() {
    final old = ref.read(chamberProvider);
    ref.read(chamberProvider.notifier).state = ChamberModel(
      id: old.id,
      name: _chamberNameCtrl.text.trim(),
      doctorName: old.doctorName,
      doctorDegrees: old.doctorDegrees,
      bmdcRegNo: old.bmdcRegNo,
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      chamberHours: _hoursCtrl.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chamber details updated!'),
        backgroundColor: AppTheme.royalIndigo,
      ),
    );
  }

  void _showAddAssistantDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Chamber Assistant'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Login Email *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
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
              if (nameCtrl.text.trim().isEmpty ||
                  emailCtrl.text.trim().isEmpty) return;
              final newStaff = StaffMemberModel(
                id: 'staff-${DateTime.now().millisecondsSinceEpoch}',
                fullName: nameCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                role: 'assistant',
              );
              ref
                  .read(staffProvider.notifier)
                  .update((state) => [...state, newStaff]);
              Navigator.pop(ctx);
            },
            child: const Text('Create Assistant'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDoctor = ref.watch(userRoleProvider) == 'doctor';
    final staffList = ref.watch(staffProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chamber & Staff Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chamber Information',
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.royalIndigo,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _chamberNameCtrl,
                        enabled: isDoctor,
                        decoration:
                            const InputDecoration(labelText: 'Chamber Name'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _hoursCtrl,
                        enabled: isDoctor,
                        decoration:
                            const InputDecoration(labelText: 'Visiting Hours'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneCtrl,
                        enabled: isDoctor,
                        decoration:
                            const InputDecoration(labelText: 'Serial Phone'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _addressCtrl,
                        enabled: isDoctor,
                        decoration:
                            const InputDecoration(labelText: 'Chamber Address'),
                      ),
                      if (isDoctor) ...[
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _saveChamberSettings,
                          child: const Text('Save Chamber Changes'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                            'Chamber Team & Assistants',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.royalIndigo,
                            ),
                          ),
                          if (isDoctor)
                            OutlinedButton.icon(
                              onPressed: _showAddAssistantDialog,
                              icon: const Icon(Icons.person_add_outlined,
                                  size: 18),
                              label: const Text('Add Assistant'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...staffList.map(
                        (s) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.softMint,
                            child: Icon(
                              s.role == 'doctor'
                                  ? Icons.medical_services_rounded
                                  : Icons.support_agent_rounded,
                              color: AppTheme.royalIndigo,
                            ),
                          ),
                          title: Text(s.fullName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text('${s.email} • ${s.phone}'),
                          trailing: Chip(
                            label: Text(
                              s.role.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
