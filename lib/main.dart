import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/services.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:url_launcher/url_launcher.dart';
import 'books.dart';

final Map<String, int> bookNumbers = BooksData.bookNumbers;

void main() {
  runApp(const BibleApp());
}

class BibleApp extends StatelessWidget {
  const BibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme.of(context).copyWith(
          appBarTheme: const AppBarTheme(
              titleTextStyle:
                  TextStyle(color: Colors.deepPurple, fontSize: 20)),
          textTheme: TextTheme(
            bodyMedium: TextStyle(color: Colors.deepPurple.shade700),
          )),
      darkTheme: ThemeData.dark().copyWith(
          appBarTheme: AppBarTheme(
              titleTextStyle:
                  TextStyle(color: Colors.deepPurple.shade100, fontSize: 20)),
          textTheme: TextTheme(
              bodyMedium: TextStyle(color: Colors.deepPurple.shade100))),
      title: 'Fast Bible App',
      home: const BibleHomePage(),
    );
  }
}

class BibleHomePage extends StatefulWidget {
  const BibleHomePage({super.key});

  @override
  State<BibleHomePage> createState() => _BibleHomePageState();
}

@immutable
class User {
  const User({
    required this.email,
    required this.name,
  });

  final String email;
  final String name;

  @override
  String toString() {
    return '$name, $email';
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is User && other.name == name && other.email == email;
  }

  @override
  int get hashCode => Object.hash(email, name);
}

class _BibleHomePageState extends State<BibleHomePage> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ScrollOffsetController _scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  final ScrollOffsetListener _scrollOffsetListener =
      ScrollOffsetListener.create();

  Map<String, Map<int, int>> versesByChapter = {};

  List<double> letterPositions = [];

  Map<String, List<String>> groupedBooks = {};

  List<String> validLetters = [];

  List<String> alphabet = [];

  List<String> sortedBooks = [];

  int selectedLetter = -1;

  @override
  void initState() {
    super.initState();

    // Initialize the list only once
    versesByChapter = BooksData.versesByChapter;

    alphabet = List.generate(
        26, (index) => String.fromCharCode('A'.codeUnitAt(0) + index));

    sortedBooks = versesByChapter.keys.toList()
      ..sort((a, b) => removeDiacritics(a).compareTo(removeDiacritics(b)));

    // Group books by the first letter
    for (var book in sortedBooks) {
      String firstLetter = book[0].toUpperCase();
      groupedBooks[removeDiacritics(firstLetter)] ??= [];
      groupedBooks[removeDiacritics(firstLetter)]!.add(book);
    }

    validLetters =
        alphabet.where((letter) => groupedBooks.containsKey(letter)).toList();

    validLetters = ['1', '2', '3'] + validLetters;
  }

  final List<int> validNumbers = List.generate(151, (index) => index + 1);

  @override
  Widget build(BuildContext context) {
    bool isWhiteTheme = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Livros da Bíblia',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ScrollablePositionedList.builder(
              itemScrollController: _itemScrollController,
              scrollOffsetController: _scrollOffsetController,
              itemPositionsListener: _itemPositionsListener,
              scrollOffsetListener: _scrollOffsetListener,
              itemCount: groupedBooks.length,
              itemBuilder: (context, letterIndex) {
                String letter = groupedBooks.keys.elementAt(letterIndex);
                List<String> booksForLetter = groupedBooks[letter]!;

                return InkWell(
                  key: Key(letter),
                  onTap: () {},
                  child: Container(
                    color: letterIndex == selectedLetter
                        ? (isWhiteTheme
                            ? Colors.deepPurple
                            : Colors.deepPurpleAccent)
                        : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            letter,
                            style: TextStyle(
                                color: getNumberColor(isWhiteTheme,
                                    letterIndex == selectedLetter),
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        GridView.builder(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6, // Define o número de colunas
                          ),
                          itemCount: booksForLetter.length,
                          itemBuilder: (context, index) {
                            String book = booksForLetter[index];

                            return Card(
                              clipBehavior: Clip.hardEdge,
                              child: InkWell(
                                hoverColor: Colors.deepPurpleAccent[50],
                                highlightColor: Colors.deepPurple[100],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookChaptersPage(
                                        book,
                                        versesByChapter[book]!.keys.toList(),
                                        versesByChapter,
                                      ),
                                    ),
                                  );
                                },
                                child: Center(
                                  child: Text(
                                    book.length > 5
                                        ? book.substring(0, 5)
                                        : book,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        // color: Colors.deepPurple.shade900,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Adicione os botões de letras
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8.0,
            children: validLetters.map((letter) {
              return ElevatedButton(
                onPressed: () {
                  // Navegar para a seção correspondente
                  if (groupedBooks.containsKey(letter)) {
                    scrollToSection(validLetters.indexOf(letter));
                    setState(() {
                      selectedLetter = validLetters.indexOf(letter);
                    });
                  }
                },
                child: Text(
                  letter,
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RawAutocomplete<String>(
                    optionsViewOpenDirection: OptionsViewOpenDirection.up,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      // Implemente a lógica para fornecer sugestões aqui
                      return bookNumbers.keys
                          .where((String option) => option
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()))
                          .toList();
                    },
                    onSelected: (String selection) {
                      print('Selecionado: $selection');
                    },
                  ),
                ),
              ),
              SizedBox(width: 8.0),
              // Adiciona espaçamento entre os Autocompletes
              Expanded(
                child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: const InputDecoration(hintText: 'Cap'),
                      enabled: false,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3)
                      ],
                    )),
              ),
              const Text(':', style: TextStyle(fontSize: 30)),
              // Adiciona espaçamento entre os Autocompletes
              Expanded(
                child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: TextField(
                      decoration: const InputDecoration(hintText: 'Ver'),
                      enabled: false,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void scrollToSection(int index) {
    _itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic);
  }

  Color? getNumberColor(bool isWhiteTheme, bool selectedItem) {
    if (selectedItem && isWhiteTheme) {
      return Colors.white;
    }

    return null;
  }
}

class BookChaptersPage extends StatelessWidget {
  final String book;
  final List<int> chapters;
  final Map<String, Map<int, int>> versesByChapter;

  const BookChaptersPage(this.book, this.chapters, this.versesByChapter,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        '$book - Capítulos',
      )),
      body: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          // mainAxisSpacing: 8.0,
          crossAxisCount: 6, // Number of columns
        ),
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          int chapter = chapters[index];
          return Card(
            clipBehavior: Clip.hardEdge,
            child: InkWell(
                highlightColor: Colors.deepPurple[100],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChapterVersesPage(
                        book,
                        chapter,
                        versesByChapter[book]![chapter]!,
                      ),
                    ),
                  );
                },
                child: Center(
                    child: Text(
                  '$chapter',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w500),
                ))),
          );
        },
      ),
    );
  }
}

class ChapterVersesPage extends StatelessWidget {
  final String book;
  final int chapter;
  final int versesCount;

  const ChapterVersesPage(this.book, this.chapter, this.versesCount,
      {super.key});

  String getBookNumber(String bookName) {
    final int number = bookNumbers[bookName] ?? -1;
    return number != -1 ? number.toString().padLeft(2, '0') : '-1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$book $chapter',
        ),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6, // Number of columns
        ),
        itemCount: versesCount,
        itemBuilder: (context, index) {
          int verse = index + 1;
          return Card(
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              highlightColor: Colors.deepPurple[100],
              onTap: () async {
                String bookNumber = getBookNumber(book);
                String chapterPad = chapter.toString().padLeft(3, '0');
                String versePad = verse.toString().padLeft(3, '0');

                if (kDebugMode) {
                  print(
                      "https://www.jw.org/finder?bible=$bookNumber$chapterPad$versePad");
                }

                Uri url = Uri.parse(
                    "https://www.jw.org/finder?bible=$bookNumber$chapterPad$versePad");
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: Center(
                child: Text('$verse',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w500)),
              ),
            ),
          );
        },
      ),
    );
  }
}
