import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chamber_models.dart';

class MockChamberData {
  static const ChamberModel demoChamber = ChamberModel(
    id: 'chamber-001',
    name: 'City Care Medical Chamber',
    doctorName: 'Dr. Mahmudul Hasan',
    doctorDegrees: 'MBBS (DMC), BCS (Health), FCPS (Medicine)',
    bmdcRegNo: 'A-64821',
    phone: '+880 1711-000000',
    address: 'House 24, Road 7, Dhanmondi, Dhaka',
    chamberHours: 'Sat - Thu: 5:00 PM - 9:30 PM',
  );

  static final List<PatientModel> initialPatients = [
    PatientModel(
      id: 'pat-1',
      chamberId: 'chamber-001',
      manualRecordNo: 'MC-1001',
      fullName: 'Abdur Rahman',
      age: 48,
      gender: 'Male',
      phone: '01712-345678',
      bloodGroup: 'B+',
      address: 'Mirpur-10, Dhaka',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    PatientModel(
      id: 'pat-2',
      chamberId: 'chamber-001',
      manualRecordNo: 'MC-1002',
      fullName: 'Fatema Begum',
      age: 34,
      gender: 'Female',
      phone: '01819-876543',
      bloodGroup: 'O+',
      address: 'Uttara Sector-7, Dhaka',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    PatientModel(
      id: 'pat-3',
      chamberId: 'chamber-001',
      manualRecordNo: 'MC-1003',
      fullName: 'Tanvir Ahmed',
      age: 27,
      gender: 'Male',
      phone: '01911-223344',
      bloodGroup: 'A+',
      address: 'Mohammadpur, Dhaka',
      createdAt: DateTime.now(),
    ),
  ];

  static final List<VisitModel> initialVisits = [
    VisitModel(
      id: 'vis-1',
      patientId: 'pat-1',
      visitDate: DateTime.now().subtract(const Duration(days: 2)),
      chiefComplaints: 'Fever for 3 days, mild headache, body ache',
      onExamination: 'Temp: 101.2°F, BP: 125/80 mmHg, Pulse: 86 bpm',
      diagnosis: 'Viral Fever',
      medicines: const [
        MedicineItem(
          name: 'Tab. Napa Extend 665mg',
          dosage: '1 + 0 + 1',
          duration: '5 Days',
          instruction: 'After meal (if fever > 100°F)',
        ),
        MedicineItem(
          name: 'Cap. Seclo 20mg',
          dosage: '1 + 0 + 1',
          duration: '7 Days',
          instruction: '30 mins before meal',
        ),
      ],
      advice: 'Drink plenty of water and oral saline. Take complete rest.',
      nextVisitDate: DateTime.now().add(const Duration(days: 5)),
      doctorPrivateNote: 'Check CBC if fever persists beyond day 5.',
    ),
  ];
}

// State Providers for Interactive Frontend Prototype
final chamberProvider = StateProvider<ChamberModel>((ref) => MockChamberData.demoChamber);
final userRoleProvider = StateProvider<String>((ref) => 'doctor'); // 'doctor' or 'assistant'
final patientsProvider = StateProvider<List<PatientModel>>((ref) => MockChamberData.initialPatients);
final visitsProvider = StateProvider<List<VisitModel>>((ref) => MockChamberData.initialVisits);

final reportsProvider = StateProvider<List<MedicalReportModel>>((ref) => [
      MedicalReportModel(
        id: 'rep-1',
        patientId: 'pat-1',
        reportTitle: 'CBC & Dengue NS1 Antigen',
        fileType: 'Lab Report',
        uploadedByRole: 'assistant',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        notes: 'Platelet count 210,000/cumm. Dengue NS1 Negative.',
      ),
      MedicalReportModel(
        id: 'rep-2',
        patientId: 'pat-2',
        reportTitle: 'Chest X-Ray PA View',
        fileType: 'X-Ray / USG',
        uploadedByRole: 'doctor',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        notes: 'Clear lung fields, normal cardiac silhouette.',
      ),
    ]);

final staffProvider = StateProvider<List<StaffMemberModel>>((ref) => const [
      StaffMemberModel(
        id: 'staff-1',
        fullName: 'Dr. Mahmudul Hasan',
        email: 'doctor@mychamber.com',
        phone: '01711-000000',
        role: 'doctor',
      ),
      StaffMemberModel(
        id: 'staff-2',
        fullName: 'Sajib Hossain',
        email: 'assistant@mychamber.com',
        phone: '01811-556677',
        role: 'assistant',
      ),
    ]);
