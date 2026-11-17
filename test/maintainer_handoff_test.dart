import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maintainer_handoff/core/theme/app_theme.dart';
import 'package:maintainer_handoff/features/handoff/controllers/handoff_controller.dart';
import 'package:maintainer_handoff/features/handoff/data/handoff_repository.dart';
import 'package:maintainer_handoff/features/handoff/models/handoff_models.dart';
import 'package:maintainer_handoff/features/handoff/services/handoff_exporter.dart';
import 'package:maintainer_handoff/features/handoff/ui/projects_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfiNoIsolate;

  test('HandoffExporter blocks path traversal & secrets and builds safe ZIP', () {
    expect(HandoffExporter.isSafeArchivePath('../../etc/passwd'), isFalse);
    expect(HandoffExporter.isSafeArchivePath('/abs/path.txt'), isFalse);
    expect(HandoffExporter.isSafeArchivePath('.env'), isFalse);
    expect(HandoffExporter.isSafeArchivePath('keys/prod.pem'), isFalse);
    expect(HandoffExporter.isSafeArchivePath('docs/HANDOFF.md'), isTrue);

    final proj = Proyecto(
      id: 'p1',
      name: 'ciclio-oss',
      license: 'MIT',
      createdAt: DateTime(2026, 11, 17),
    );
    const items = [
      HandoffItem(
        id: 'i1',
        projectId: 'p1',
        category: 'CI',
        title: 'Release workflow',
        status: HandoffStatus.listo,
      ),
    ];

    final zip = HandoffExporter.buildSafeZip(project: proj, items: items);
    final decoded = ZipDecoder().decodeBytes(zip);
    expect(
      decoded.files.map((f) => f.name),
      containsAll(['HANDOFF.md', 'checklist.csv', 'manifest.sha256']),
    );
  });

  testWidgets('ProjectsScreen renders without overflow at 320px and 200% TextScaler', (tester) async {
    final db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: HandoffRepository.createSchema,
    );
    final repo = HandoffRepository(testDb: db);
    await repo.saveProjectWithItems(
      project: Proyecto(
        id: 'p_long',
        name: 'Repo_${'O' * 100}',
        createdAt: DateTime(2026, 11, 17),
      ),
      items: const [],
    );

    await tester.binding.setSurfaceSize(const Size(320, 568));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [handoffRepositoryProvider.overrideWithValue(repo)],
        child: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2.0),
          ),
          child: MaterialApp(
            theme: AppTheme.light(accent: const Color(0xFF1D4ED8)),
            home: const ProjectsScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
    await db.close();
  });
}

