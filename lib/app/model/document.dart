class Document {
  final int? id;
  final String title;
  final int year;
  final String rack;
  final String box;
  final String filePath; // local path to PDF
  // final String? fileName; // Nama file PDF
  // final int? fileSize;

  Document({
    this.id,
    required this.title,
    required this.year,
    required this.rack,
    required this.box,
    required this.filePath,
    // this.fileName,
    // this.fileSize,
  });

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'year': year,
    'rack': rack,
    'box': box,
    'file_path': filePath,
    // 'file_name': fileName,
    // 'file_size': fileSize,
  };

  static Document fromRow(Map<String, Object?> row) => Document(
    id: row['id'] as int?,
    title: row['title'] as String,
    year: (row['year'] as num).toInt(),
    rack: row['rack'] as String,
    box: row['box'] as String,
    filePath: row['file_path'] as String,
    // fileName: row['file_name'] as String?,
    // fileSize: (row['file_size'] as num?)?.toInt(),
  );
}
