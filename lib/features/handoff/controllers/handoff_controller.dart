import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/handoff_repository.dart';
import '../models/handoff_models.dart';

final handoffRepositoryProvider = Provider<HandoffRepository>(
  (ref) => HandoffRepository(),
);

class HandoffState {
  const HandoffState({this.projects = const [], this.items = const []});
  final List<Proyecto> projects;
  final List<HandoffItem> items;
}

class HandoffController extends AsyncNotifier<HandoffState> {
  @override
  Future<HandoffState> build() async => _loadAll();

  HandoffRepository get _repo => ref.read(handoffRepositoryProvider);

  Future<HandoffState> _loadAll() async => HandoffState(
        projects: await _repo.listProjects(),
        items: await _repo.listItems(),
      );

  Future<Proyecto> createProject({
    required String name,
    String repoUrl = '',
    String license = 'MIT',
  }) async {
    final now = DateTime.now();
    final id = 'proj_${now.microsecondsSinceEpoch}';
    final project = Proyecto(
      id: id,
      name: name.trim(),
      repoUrl: repoUrl.trim(),
      license: license.trim().isEmpty ? 'MIT' : license.trim(),
      createdAt: now,
    );

    final starter = [
      HandoffItem(
        id: '${id}_1',
        projectId: id,
        category: 'Repositorio y ramas',
        title: 'Documentar rama principal y flujo de releases',
      ),
      HandoffItem(
        id: '${id}_2',
        projectId: id,
        category: 'Builds y CI',
        title: 'Verificar compilación reproducible desde cero',
      ),
      HandoffItem(
        id: '${id}_3',
        projectId: id,
        category: 'Accesos y secretos (sin guardar claves)',
        title: 'Listar qué cuentas/tokens existen y quién los custodia',
      ),
      HandoffItem(
        id: '${id}_4',
        projectId: id,
        category: 'Gobernanza y comunidad',
        title: 'Dejar guía de mantenimiento y criterios de triage',
      ),
    ];

    await _repo.saveProjectWithItems(project: project, items: starter);
    state = AsyncData(await _loadAll());
    return project;
  }

  Future<void> updateItem(HandoffItem item) async {
    await _repo.upsertItem(item);
    state = AsyncData(await _loadAll());
  }

  Future<void> addItem({
    required String projectId,
    required String category,
    required String title,
    String notes = '',
  }) async {
    await _repo.upsertItem(
      HandoffItem(
        id: 'item_${DateTime.now().microsecondsSinceEpoch}',
        projectId: projectId,
        category: category.trim().isEmpty ? 'General' : category.trim(),
        title: title.trim(),
        notes: notes.trim(),
      ),
    );
    state = AsyncData(await _loadAll());
  }
}

final handoffControllerProvider =
    AsyncNotifierProvider<HandoffController, HandoffState>(
  HandoffController.new,
);

