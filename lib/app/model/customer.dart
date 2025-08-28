class Customer {
  final int? id;
  final String name;
  final String nik;
  final String address;
  final String status;
  final String? phone;

  Customer({
    this.id,
    required this.name,
    required this.nik,
    required this.address,
    required this.status,
    this.phone,
  });

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'nik': nik,
    'address': address,
    'status': status,
    'phone': phone,
  };

  static Customer fromRow(Map<String, Object?> row) => Customer(
    id: row['id'] as int?,
    name: row['name'] as String,
    nik: row['nik'] as String,
    address: row['address'] as String,
    status: row['status'] as String,
    phone: row['phone'] as String?,
  );

  Customer copyWith({
    int? id,
    String? name,
    String? nik,
    String? address,
    String? status,
    String? phone,
  }) => Customer(
    id: id ?? this.id,
    name: name ?? this.name,
    nik: nik ?? this.nik,
    address: address ?? this.address,
    status: status ?? this.status,
    phone: phone ?? this.phone,
  );
}
