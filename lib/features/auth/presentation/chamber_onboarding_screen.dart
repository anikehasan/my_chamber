import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/mock_chamber_data.dart';
import '../../../core/models/chamber_models.dart';

class ChamberOnboardingScreen extends ConsumerStatefulWidget {
  const ChamberOnboardingScreen({super.key});

  @override
  ConsumerState<ChamberOnboardingScreen> createState() =>
      _ChamberOnboardingScreenState();
}

class _ChamberOnboardingScreenState
    extends ConsumerState<ChamberOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _doctorNameCtrl = TextEditingController();
  final _degreesCtrl = TextEditingController();
  final _bmdcCtrl = TextEditingController();
  final _chamberNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController(text: 'Sat - Thu: 5:00 PM - 9:00 PM');

  @override
  void dispose() {
    _doctorNameCtrl.dispose();
    _degreesCtrl.dispose();
    _bmdcCtrl.dispose();
    _chamberNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _hoursCtrl.dispose();
    super.dispose();
  }

  void _completeSetup() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(chamberProvider.notifier).state = ChamberModel(
      id: 'chamber-new',
      name: _chamberNameCtrl.text.trim(),
      doctorName: _doctorNameCtrl.text.trim(),
      doctorDegrees: _degreesCtrl.text.trim(),
      bmdcRegNo: _bmdcCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      chamberHours: _hoursCtrl.text.trim(),
    );
    ref.read(userRoleProvider.notifier).state = 'doctor';

    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Your Medical Chamber')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Doctor Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _doctorNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Doctor Full Name (e.g., Dr. Anike Hasan)',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _degreesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Degrees & Specialty (e.g., MBBS, FCPS)',
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bmdcCtrl,
                    decoration: const InputDecoration(
                      labelText: 'BMDC Registration No.',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Chamber Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _chamberNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Chamber / Clinic Name',
                      prefixIcon: Icon(Icons.local_hospital_outlined),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Chamber Contact Number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Chamber Address',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _hoursCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Visiting Hours',
                      prefixIcon: Icon(Icons.access_time),
                    ),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _completeSetup,
                    child: const Text('Create Chamber & Open Dashboard'),
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