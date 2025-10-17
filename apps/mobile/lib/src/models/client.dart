class Client {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;

  Client({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
  });
}
