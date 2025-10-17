class Job {
  final String id;
  final String name;   // e.g., "Kitchen refurb - Smith"
  final String? clientId;

  const Job({required this.id, required this.name, this.clientId});
}
