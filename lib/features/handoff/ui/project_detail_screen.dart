import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/handoff_controller.dart';
import '../models/handoff_models.dart';
import '../services/handoff_exporter.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.projectId});
  final String projectId;

  Future<void> _exportZip(
    BuildContext context,
    Proyecto project,
    List<HandoffItem> items,
  ) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File(p.join(dir.path, 'handoff_${project.id}.zip'));
      await file.writeAsBytes(
          HandoffExporter.buildSafeZip(project: project, items: items));
      await Share.shareXFiles([XFile(file.path)],
          subject: 'HANDOFF ${project.name}');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al exportar: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(handoffControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Checklist de traspaso')),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (data) {
          final project =
              data.projects.where((p) => p.id == projectId).firstOrNull;
          if (project == null) {
            return const Center(child: Text('Proyecto no encontrado.'));
          }
          final items =
              data.items.where((i) => i.projectId == project.id).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(project.name, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () => _exportZip(context, project, items),
                    icon: const Icon(Icons.folder_zip_outlined),
                    label: const Text('Exportar HANDOFF.md + ZIP'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: CheckboxListTile(
                        value: item.status == HandoffStatus.listo,
                        onChanged: (checked) => ref
                            .read(handoffControllerProvider.notifier)
                            .updateItem(item.copyWith(
                              status: checked == true
                                  ? HandoffStatus.listo
                                  : HandoffStatus.pendiente,
                            )),
                        title: Text(item.title),
                        subtitle: Text(item.category),
                      ),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}

