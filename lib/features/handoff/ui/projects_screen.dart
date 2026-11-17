import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/handoff_controller.dart';
import '../models/handoff_models.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  Future<void> _newProjectDialog(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final repoCtrl = TextEditingController();
    final licCtrl = TextEditingController(text: 'MIT');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo traspaso OSS'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Proyecto')),
              const SizedBox(height: 10),
              TextField(
                  controller: repoCtrl,
                  decoration: const InputDecoration(
                      labelText: 'URL del repositorio (opcional)')),
              const SizedBox(height: 10),
              TextField(
                  controller: licCtrl,
                  decoration: const InputDecoration(labelText: 'Licencia')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Crear checklist')),
        ],
      ),
    );
    if (ok == true && nameCtrl.text.trim().isNotEmpty) {
      final p = await ref.read(handoffControllerProvider.notifier).createProject(
            name: nameCtrl.text,
            repoUrl: repoCtrl.text,
            license: licCtrl.text,
          );
      if (context.mounted) context.push('/projects/${p.id}');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(handoffControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('MaintainerHandoff')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _newProjectDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Proyecto'),
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (data) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  'Que tu proyecto pueda continuar sin depender de tu memoria',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            if (data.projects.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.engineering_outlined,
                            size: 52, color: theme.colorScheme.primary),
                        const SizedBox(height: 12),
                        Text('Sin proyectos en traspaso',
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(
                          'Prepara HANDOFF.md, checklist CSV y ZIP seguro excluyendo secretos.',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 92),
                sliver: SliverList.separated(
                  itemCount: data.projects.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) {
                    final proj = data.projects[i];
                    final items = data.items
                        .where((it) => it.projectId == proj.id)
                        .toList();
                    final done = items
                        .where((it) => it.status == HandoffStatus.listo)
                        .length;
                    return TweenAnimationBuilder<double>(
                      duration: AppMotion.duration(
                          context, Duration(milliseconds: 180 + (i.clamp(0, 6) * 35))),
                      curve: AppMotion.curve(context),
                      tween: Tween(begin: 0, end: 1),
                      builder: (ctx, t, child) => Opacity(
                        opacity: t,
                        child: Transform.translate(
                          offset: Offset(0, 10 * (1 - t)),
                          child: child,
                        ),
                      ),
                      child: Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.12),
                            child: Icon(Icons.code,
                                color: theme.colorScheme.primary),
                          ),
                          title: Text(proj.name,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          subtitle:
                              Text('${proj.license} · $done/${items.length} listos'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/projects/${proj.id}'),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

