import 'package:flutter/material.dart';
import 'models/word.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logging/logging.dart';

final Logger _logger = Logger('MyAppLogger');

//APIから類似する単語を取得
Future<List<String>> fetchSimilarWords(String word) async {
  _logger.info('Fetching similar words for: $word');
  final response = await http.get(Uri.parse('https://api.datamuse.com/words?ml=$word'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    _logger.info('Fetched similar words: $data');
    return data.take(3).map((item) => item['word'].toString()).toList();
  } else {
    _logger.severe('Failed to load similar words');
    throw Exception('Failed to load similar words');
  }
}


void main() {
    runApp(const MyApp());
}


//ホーム画面設定
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Learning App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WordListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

//単語リスト表示画面
class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key});
  @override
  _WordListScreenState createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final List<Word> _words = [];
  final List<Word> _learnedWords = [];
  String _selectedPartOfSpeech = '名詞';
  List<bool> _isMeaningVisible = [];

  void _addWord(String word, String meaning, String partOfSpeech) {
    setState(() {
      _words.add(Word(word: word, meaning: meaning, partOfSpeech: partOfSpeech));
      _isMeaningVisible.add(false);
    });
  }

  void _markAsLearned(int index) {
    setState(() {
      _learnedWords.add(_words[index]);
      _words.removeAt(index);
      _isMeaningVisible.removeAt(index);
    });
  }

  void _navigateToLearnedWordsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LearnedWordsScreen(learnedWords: _learnedWords),
      ),
    );
  }

  void _showAddWordDialog(BuildContext context) async {
    final TextEditingController wordController = TextEditingController();
    final TextEditingController meaningController = TextEditingController();
    List<String> similarWords = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Word'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: wordController,
                    decoration: const InputDecoration(labelText: 'Word'),
                    onChanged: (text) async {
                      if (text.isNotEmpty) {
                        try {
                          final words = await fetchSimilarWords(text);
                          setState(() {
                            similarWords = words;
                          });
                        } catch (e) {
                          _logger.severe('Error fetching similar words: $e');
                        }
                      } else {
                        setState(() {
                          similarWords = [];
                        });
                      }
                    },
                  ),
                  TextField(
                    controller: meaningController,
                    decoration: const InputDecoration(labelText: 'Meaning'),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 10),
                  const Text('Parts of Speech:'),
                  Wrap(
                    spacing: 10,
                    children: [
                      ChoiceChip(
                        label: const Text('名'),
                        selected: _selectedPartOfSpeech == '名',
                        onSelected: (selected) {
                          setState(() {
                            _selectedPartOfSpeech = '名';
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('動'),
                        selected: _selectedPartOfSpeech == '動',
                        onSelected: (selected) {
                          setState(() {
                            _selectedPartOfSpeech = '動';
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('形'),
                        selected: _selectedPartOfSpeech == '形',
                        onSelected: (selected) {
                          setState(() {
                            _selectedPartOfSpeech = '形';
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('副'),
                        selected: _selectedPartOfSpeech == '副',
                        onSelected: (selected) {
                          setState(() {
                            _selectedPartOfSpeech = '副';
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _addWord(wordController.text, meaningController.text, _selectedPartOfSpeech);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showWordDetailDialog(BuildContext context, Word word, int index) async {
    final TextEditingController wordController = TextEditingController(text: word.word);
    final TextEditingController meaningController = TextEditingController(text: word.meaning);
    bool isEditing = false;
    List<String> similarWords = [];
    String selectedPartOfSpeech = word.partOfSpeech;

    _logger.info('Fetching similar words for: ${word.word}');

    try {
      similarWords = await fetchSimilarWords(word.word);
      _logger.info('Fetched similar words: $similarWords');
    } catch (e) {
      _logger.severe('Error fetching similar words: $e');
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: AlertDialog(
                title: isEditing
                    ? TextField(
                  controller: wordController,
                  decoration: const InputDecoration(
                    labelText: 'Word',
                    border: OutlineInputBorder(),
                  ),
                )
                    : Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: word.word,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      TextSpan(
                        text: ' (${word.partOfSpeech})',
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                content: Container(
                  width: 400,
                  height: 300,
                  child: isEditing
                      ? Column(
                    children: [
                      TextField(
                        controller: meaningController,
                        decoration: const InputDecoration(
                          labelText: 'Meaning',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: null,
                      ),
                      const SizedBox(height: 10),
                      const Text('Parts of Speech:'),
                      Wrap(
                        spacing: 10,
                        children: [
                          ChoiceChip(
                            label: const Text('名'),
                            selected: selectedPartOfSpeech == '名',
                            onSelected: (selected) {
                              setState(() {
                                selectedPartOfSpeech = '名';
                              });
                            },
                          ),
                          ChoiceChip(
                            label: const Text('動'),
                            selected: selectedPartOfSpeech == '動',
                            onSelected: (selected) {
                              setState(() {
                                selectedPartOfSpeech = '動';
                              });
                            },
                          ),
                          ChoiceChip(
                            label: const Text('形'),
                            selected: selectedPartOfSpeech == '形',
                            onSelected: (selected) {
                              setState(() {
                                selectedPartOfSpeech = '形';
                              });
                            },
                          ),
                          ChoiceChip(
                            label: const Text('副'),
                            selected: selectedPartOfSpeech == '副',
                            onSelected: (selected) {
                              setState(() {
                                selectedPartOfSpeech = '副';
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _words[index] = Word(
                              word: wordController.text,
                              meaning: meaningController.text,
                              partOfSpeech: selectedPartOfSpeech,
                            );
                            isEditing = false;
                          });
                          Navigator.of(context).pop();
                          setState(() {});
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  )
                      : Column(
                    children: [
                      Text(
                        word.meaning,
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 25,
                          shadows: [
                            Shadow(
                              blurRadius: 7.0,
                              color: Colors.black45,
                              offset: Offset(1.0, 1.0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('Similar Words:'),
                      for (var similarWord in similarWords)
                        Text(similarWord),
                    ],
                  ),
                ),
                actions: [
                  if (!isEditing)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        setState(() {
                          isEditing = true;
                        });
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '～ Word List ～',
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Colors.greenAccent,
            shadows: [
              Shadow(
                blurRadius: 2.0,
                color: Colors.black45,
                offset: Offset(3.0, 3.0),
              )
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _navigateToLearnedWordsScreen,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: () => _showAddWordDialog(context),
              child: const Text('Add Word'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _words.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _showWordDetailDialog(context, _words[index], index);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: _words[index].word,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            TextSpan(
                              text: ' (${_words[index].partOfSpeech})',
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () => _markAsLearned(index),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


//正解した単語を表示
class LearnedWordsScreen extends StatelessWidget {
  final List<Word> learnedWords;
  const LearnedWordsScreen({super.key, required this.learnedWords});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '～ LearnedWords ～',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.orangeAccent,
            shadows: [
              Shadow(
                blurRadius: 2.0,
                color: Colors.black45,
                offset: Offset(3.0, 3.0),
              )
            ],
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: learnedWords.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(learnedWords[index].word),
            subtitle: Text(learnedWords[index].meaning),
          );
        },
      ),
    );
  }
}