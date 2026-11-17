import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';

import '../models/handoff_models.dart';

class HandoffExporter {
  static bool isSafeArchivePath(String rawPath) {
    final normalized = rawPath.replaceAll('\\', '/').trim();
    if (normalized.isEmpty) return false;
    if (normalized.startsWith('/') || normalized.contains(':')) return false;
    final segments = normalized.split('/');
    if (segments.any((s) => s == '..' || s.isEmpty)) return false;

    final lower = normalized.toLowerCase();
    if (lower.endsWith('.env') ||
        lower.contains('/.env') ||
        lower.endsWith('.pem') ||
        lower.endsWith('.key') ||
        lower.endsWith('id_rsa') ||
        lower.contains('secrets.')) {
      return false;
    }
    return true;
  }

  static String buildHandoffMarkdown({
    required Proyecto project,
    required List<HandoffItem> items,
  }) {
    final buf = StringBuffer()
      ..writeln('# HANDOFF — ${project.name}')
      ..writeln()
      ..writeln('- **Repositorio:** ${project.repoUrl.isEmpty ? "No indicado" : project.repoUrl}')
      ..writeln('- **Licencia:** ${project.license}')
      ..writeln();

    final categories = items.map((i) => i.category).toSet();
    for (final cat in categories) {
      buf.writeln('## $cat');
      for (final item in items.where((i) => i.category == cat)) {
        final mark = item.status == HandoffStatus.listo ? 'x' : ' ';
        buf.writeln('- [$mark] **${item.title}** (${item.status.name})');
        if (item.notes.isNotEmpty) buf.writeln('  - Notas: ${item.notes}');
        if (item.evidence.isNotEmpty) {
          buf.writeln('  - Evidencia: `${item.evidence}`');
        }
      }
      buf.writeln();
    }
    return buf.toString();
  }

  static String buildCsv({required List<HandoffItem> items}) {
    final buf = StringBuffer()..writeln('category,title,status,notes,evidence');
    for (final item in items) {
      buf.writeln(
        '${_csv(item.category)},${_csv(item.title)},${_csv(item.status.name)},${_csv(item.notes)},${_csv(item.evidence)}',
      );
    }
    return buf.toString();
  }

  static Uint8List buildSafeZip({
    required Proyecto project,
    required List<HandoffItem> items,
  }) {
    final md = utf8.encode(buildHandoffMarkdown(project: project, items: items));
    final csv = utf8.encode(buildCsv(items: items));
    final manifest = utf8.encode(
      'HANDOFF.md  sha256:${sha256.convert(md)}\n'
      'checklist.csv  sha256:${sha256.convert(csv)}\n',
    );
    final archive = Archive()
      ..addFile(ArchiveFile('HANDOFF.md', md.length, md))
      ..addFile(ArchiveFile('checklist.csv', csv.length, csv))
      ..addFile(ArchiveFile('manifest.sha256', manifest.length, manifest));
    return Uint8List.fromList(ZipEncoder().encode(archive));
  }

  static String _csv(String v) => '"${v.replaceAll('"', '""')}"';
}

