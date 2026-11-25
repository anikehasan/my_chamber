import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/chamber_onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/patients/presentation/add_patient_screen.dart';
import '../../features/patients/presentation/patient_detail_screen.dart';
import '../../features/prescriptions/presentation/prescription_preview_screen.dart';
import '../../features/patients/presentation/write_prescription_screen.dart';
import '../../features/settings/presentation/chamber_settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const ChamberOnboardingScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/patients',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/patients/add',
      builder: (context, state) => const AddPatientScreen(),
    ),
    GoRoute(
      path: '/patients/:id',
      builder: (context, state) => PatientDetailScreen(
        patientId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/patients/:id/prescribe',
      builder: (context, state) => WritePrescriptionScreen(
        patientId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/visits/:visitId/preview',
      builder: (context, state) => PrescriptionPreviewScreen(
        visitId: state.pathParameters['visitId']!,
      ),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const ChamberSettingsScreen(),
    ),
  ],
);
