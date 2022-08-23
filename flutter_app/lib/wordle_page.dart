import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:uuid/uuid.dart';

class WordlePage extends StatelessWidget {
  const WordlePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wordle'),
      ),
      body: const Wordle(),
    );
  }
}

// 接続先
final _link = HttpLink(
  "http://serene-garden-89220.herokuapp.com/query",
);
// Graphqlを使用するためのクライアント
final GraphQLClient client = GraphQLClient(
  link: _link,
  cache: GraphQLCache(),
);

// ローディングフラグ
bool loading = false;

class Wordle extends StatefulWidget {
  const Wordle({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WordleState();
}

class _WordleState extends State<Wordle> {
  // ユーザー
  final String userId = 'nakamuu';

  final Uuid _uuid = Uuid();
  String wordId = '';

  // 正解ワード
  Map correctWord = {};

  // 回答ワード
  String _answerWord = '';

  // 回答チェック
  List _checkAnswerWords = [];

  void _generateWordId() {
    wordId = _uuid.v4();
  }

  void _setCorrectWord(value) {
    setState(() {
      correctWord = value;
    });
  }

  void _setAnswerWord(value) {
    setState(() {
      _answerWord = value;
    });
  }

  void _setCheckAnswer(value) {
    setState(() {
      _checkAnswerWords = value;
    });
  }

  // 正解ワード取得
  void getCorrectWord() async {
    print('getCorrectWord start');

    loading = true;

    // 既に正解wordを発行していたら処理をしない
    if (!correctWord.isEmpty) {
      return;
    }
    _generateWordId();

    const String getCorrectWord = r'''
      query GetCorrectWord($wordId: String!) {
        correctWord(wordId: $wordId) {
          mean
          word
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(getCorrectWord),
      variables: <String, dynamic>{
        'wordId': wordId,
      },
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      print(result.exception.toString());
    }

    final data = result.data;
    if (data != null) {
      _setCorrectWord(data['correctWord']);
      print(correctWord['word']);
    }

    loading = false;

    print('getCorrectWord end');
  }

  // 回答ワードチェック
  void checkAnswerWord() async {
    print('checkAnswerWord start');

    loading = true;

    const String answerWord = r'''
      mutation AnswerWord($word: String!, $wordId: String!, $userId: String!) {
        action: answerWord(word: $word, wordId: $wordId, userId: $userId) {
          chars {
            char
            judge
            position
          }
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(answerWord),
      variables: <String, dynamic>{
        'word': _answerWord,
        'wordId': wordId,
        'userId': userId,
      },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      print(result.exception.toString());
      return;
    }

    final data = result.data;
    if (data != null) {
      final answerResult = data['action'];
      _setCheckAnswer(answerResult['chars']);
      // _checkAnswerWords.forEach((word) {
      //   print(word['char']);
      // });
    }

    loading = false;

    print('checkAnswerWord end');
  }

  // 初期処理
  @override
  void initState() {
    getCorrectWord();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          // もしローディングフラグが立ってたら『ローディング中…』のテキスト表示
          if (loading) ...[
            const Text(
              "loading...",
              style: TextStyle(color: Colors.blue),
            ),
          ],
          TextButton(
            onPressed: () {
              getCorrectWord();
            },
            child: Text(
              '送信',
              style: TextStyle(color: Colors.white),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
            ),
          ),
          Text(correctWord['word'] == null ? '' : correctWord['word']),
          TextField(
            onChanged: (value) => _setAnswerWord(value),
          ),
          TextButton(
            onPressed: (() {
              checkAnswerWord();
            }),
            child: const Text(
              '回答する',
              style: TextStyle(color: Colors.white),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
            ),
          ),
          // 回答結果表示
          if (_checkAnswerWords.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (Map word in _checkAnswerWords)
                  Column(
                    children: [
                      Text(
                        word['char'],
                        style: const TextStyle(
                          fontSize: 70,
                        ),
                      ),
                      Text(
                        word['judge'],
                      )
                    ],
                  ),
              ],
            )
          ]
        ],
      ),
    );
  }
}
