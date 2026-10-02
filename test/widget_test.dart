import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/core/constants/app_constants.dart';
import 'package:todo_app/core/providers/theme_provider.dart';
import 'package:todo_app/core/services/storage_service.dart';
import 'package:todo_app/features/auth/providers/auth_provider.dart';
import 'package:todo_app/features/tasks/providers/task_provider.dart';
import 'package:todo_app/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('App renders correctly and displays SplashScreen with title',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = StorageService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ThemeProvider(storageService),
          ),
          ChangeNotifierProvider(
            create: (_) => AuthProvider(storageService),
          ),
          ChangeNotifierProvider(
            create: (_) => TaskProvider(storageService),
          ),
        ],
        child: const TodoApp(),
      ),
    );

    // Initial pump (Splash screen is visible)
    await tester.pump();
    expect(find.text(AppConstants.appName), findsOneWidget);

    // Advance timer past splash duration (2.2s)
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
