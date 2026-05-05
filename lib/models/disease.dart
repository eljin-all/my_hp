class Disease {
  final String id;
  final String name;
  final int hp;
  final String system;

  Disease({
    required this.id,
    required this.name,
    required this.hp,
    required this.system,
  });

  factory Disease.fromCsv(String line) {
    final cleanLine = line.replaceAll('\uFEFF', '');
    final parts = cleanLine.split(';');

    if (parts.length < 4) {
      print("Плохая строка: $line");
      return Disease(
        id: "invalid",
        name: "invalid",
        hp: 0,
        system: "",
      );
    }

    return Disease(
      id: parts[0].trim(),
      name: parts[1].trim(),
      hp: int.tryParse(parts[2].trim()) ?? 0,
      system: parts[3].trim(),
    );
  }
}