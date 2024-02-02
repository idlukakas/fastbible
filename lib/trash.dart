Autocomplete<int>
(
optionsViewOpenDirection: OptionsViewOpenDirection.up,
optionsBuilder: (TextEditingValue textEditingValue) {
// Implemente a lógica para fornecer sugestões aqui
return validNumbers
    .where((int option) =>
option.toString().startsWith(textEditingValue.text))
    .toList();
}