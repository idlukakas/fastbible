import 'dart:io';

void main() {
  String inputFilePath = 'livros.csv';
  String outputFilePath = 'converted_to_map.txt';

  // Read the contents of the CSV file
  String csvString = File(inputFilePath).readAsStringSync();

  // Convert CSV string to Map
  Map<String, Map<int, int>> result = convertCsvToMap(csvString);

  // Write the result to a new file
  writeResultToFile(result, outputFilePath);
}

Map<String, Map<int, int>> convertCsvToMap(String csvString) {
  List<String> lines = csvString.split('\n');
  Map<String, Map<int, int>> result = {};

  for (int i = 1; i < lines.length; i++) {
    List<String> fields = lines[i].split(';');

    if (fields.length == 3) {
      String book = fields[0].trim();
      int chapter = int.tryParse(fields[1].trim()) ?? 0;
      int verse = int.tryParse(fields[2].trim()) ?? 0;

      if (!result.containsKey(book)) {
        result[book] = {};
      }

      result[book]![chapter] = verse;
    }
  }

  return result;
}

void writeResultToFile(Map<String, Map<int, int>> result, String filePath) {
  StringBuffer buffer = StringBuffer();

  for (var entry in result.entries) {
    buffer.write("'${entry.key}': {\n");
    for (var chapterVerseEntry in entry.value.entries) {
      buffer.write("  ${chapterVerseEntry.key}: ${chapterVerseEntry.value},\n");
    }
    buffer.write("},\n");
  }

  File(filePath).writeAsStringSync(buffer.toString());
}
