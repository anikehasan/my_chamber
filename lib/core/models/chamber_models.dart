class ChamberModel {
  final String id;
  final String name;
  final String doctorName;
  final String doctorDegrees;
  final String bmdcRegNo;
  final String phone;
  final String address;
  final String chamberHours;

  const ChamberModel({
    required this.id,
    required this.name,
    required this.doctorName,
    required this.doctorDegrees,
    required this.bmdcRegNo,
    required this.phone,
    required this.address,
    required this.chamberHours,
  });
}

class PatientModel {
  final String id;
  final String chamberId;
  final String manualRecordNo;
  final String fullName;
  final int age;
  final String gender;
  final String phone;
  final String bloodGroup;
  final String address;
  final DateTime createdAt;

  const PatientModel({
    required this.id,
    required this.chamberId,
    required this.manualRecordNo,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.phone,
    required this.bloodGroup,
    required this.address,
    required this.createdAt,
  });
}

class MedicineItem {
  final String name;
  final String dosage;
  final String duration;
  final String instruction;

  const MedicineItem({
    required this.name,
    required this.dosage,
    required this.duration,
    required this.instruction,
  });
}

class VisitModel {
  final String id;
  final String patientId;
  final DateTime visitDate;
  final String chiefComplaints;
  final String onExamination;
  final String diagnosis;
  final List<MedicineItem> medicines;
  final String advice;
  final DateTime? nextVisitDate;
  final String doctorPrivateNote;

  const VisitModel({
    required this.id,
    required this.patientId,
    required this.visitDate,
    required this.chiefComplaints,
    required this.onExamination,
    required this.diagnosis,
    required this.medicines,
    required this.advice,
    this.nextVisitDate,
    this.doctorPrivateNote = '',
  });
}

class MedicalReportModel {
  final String id;
  final String patientId;
  final String reportTitle;
  final String fileType; // 'Lab Report', 'X-Ray / USG', 'Old Prescription'
  final String uploadedByRole;
  final DateTime createdAt;
  final String notes;

  const MedicalReportModel({
    required this.id,
    required this.patientId,
    required this.reportTitle,
    required this.fileType,
    required this.uploadedByRole,
    required this.createdAt,
    this.notes = '',
  });
}

class StaffMemberModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role; // 'doctor' or 'assistant'
  final bool isActive;

  const StaffMemberModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.isActive = true,
  });
}

