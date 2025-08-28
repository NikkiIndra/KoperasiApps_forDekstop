String SanitizeFileName(String input) {
  return input.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
}
