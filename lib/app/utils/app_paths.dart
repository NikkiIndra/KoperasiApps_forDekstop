import 'dart:io';
import 'package:path/path.dart' as p;

class AppPaths {
  static Future<String> appDirectory() async {
    // Tentukan folder aplikasi secara manual untuk desktop
    final base = Directory.current.path; // folder tempat exe dijalankan
    final dir = Directory(p.join(base, 'koperasi_desktop'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  static Future<String> dbPath(String name) async {
    final dir = await appDirectory();
    return p.join(dir, name);
  }

  static Future<String> ensureSubdir(String sub) async {
    final dir = await appDirectory();
    final d = Directory(p.join(dir, sub));
    if (!await d.exists()) await d.create(recursive: true);
    return d.path;
  }
}
