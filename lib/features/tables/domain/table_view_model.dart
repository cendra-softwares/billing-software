class TableViewModel {
  final String id;
  final String name;
  final String status;
  final String? section;
  final double totalAmount;
  final Duration duration;

  TableViewModel({
    required this.id,
    required this.name,
    required this.status,
    this.section,
    required this.totalAmount,
    required this.duration,
  });
}