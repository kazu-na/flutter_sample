import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:uuid/uuid.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class WordlePage extends StatelessWidget {
  const WordlePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Wordle'),
      ),
      body: const Wordle(),
    );
  }
}

// 回答結果クラス
class AnswerResult {
  final String char; // 文字
  final String judge; // 合ってるのか間違ってるのかなどの結果
  final int position; // 何文字目か

  const AnswerResult({
    required this.char,
    required this.judge,
    required this.position,
  });
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

  final FocusNode _nodeText1 = FocusNode();

  // 正解ワード
  Map correctWord = {};

  // 回答ワード
  String _answerWord = '';

  // 挑戦回数ごとの回答チェック
  List _checkAnswerWords = [];

  // 挑戦回数
  int _challengeCount = 1;

  // 判定
  final String JUDGE_CORRECT = 'CORRECT';
  final String JUDGE_EXISTING = 'EXISTING';
  final String JUDGE_NOTHING = 'NOTHING';
  final String NO_ANSWER = 'NO_ANSWER';

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

  void _setCheckAnswer(chars) {
    setState(() {
      _checkAnswerWords[_challengeCount - 1] = chars;
    });
  }

  void _refreshAnswer() {
    setState(() {
      _checkAnswerWords = [];
    });
  }

  void _incrementCounter() {
    setState(() {
      _challengeCount++;
    });
  }

  // 解答欄の初期化
  void initAnswerState() {
    List<AnswerResult> _chars = List.generate(4, (i) {
      return AnswerResult(
        char: '',
        judge: NO_ANSWER,
        position: i,
      );
    });
    // 挑戦回数は5回まで
    for (var i = 0; i < 5; i++) {
      setState(() {
        _checkAnswerWords.add(_chars);
      });
    }
  }

  // 正解ワード取得
  void getCorrectWord() async {
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
    }

    loading = false;
  }

  // 回答ワードチェック
  void checkAnswerWord() async {
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
      final answerResult = data['action']['chars'];
      List<AnswerResult> _chars = List.generate(answerResult.length, (int i) {
        return AnswerResult(
          char: answerResult[i]['char'],
          judge: answerResult[i]['judge'],
          position: answerResult[i]['position'],
        );
      });
      _setCheckAnswer(_chars);
      _incrementCounter();
    }

    loading = false;
  }

  // 初期処理
  @override
  void initState() {
    getCorrectWord();
    initAnswerState();
  }

  // キーボードコンフィグ
  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.black,
      nextFocus: false,
      actions: [
        KeyboardActionsItem(
          focusNode: _nodeText1,
          toolbarAlignment: MainAxisAlignment.start,
          displayArrows: false,
          toolbarButtons: [
            (node) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 330),
                      child: GestureDetector(
                        onTap: () => node.unfocus(),
                        child: Text(
                          "完了",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          ],
        ),
      ],
    );
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
          // キーボード入力
          Container(
            height: 70,
            child: KeyboardActions(
              config: _buildConfig(context),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextField(
                        onChanged: ((value) {
                          _setAnswerWord(value);
                        }),
                        maxLength: 4,
                        keyboardType: TextInputType.text,
                        focusNode: _nodeText1,
                        decoration: InputDecoration(
                          hintText: "4文字の英単語を入力",
                          counterText: '',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: (() {
              checkAnswerWord();

              // 5回挑戦後、正解を表示
              if (_challengeCount == 5) {
                _correctAnswerDialog(correctWord['word'], correctWord['mean']);
              }
            }),
            child: const Text(
              '回答する',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
            ),
          ),
          // 回答結果表示
          SizedBox(
            height: 550,
            child: GridView.count(crossAxisCount: 4, children: [
              for (List answers in _checkAnswerWords)
                for (AnswerResult chars in answers)
                  // for (Map word in chars)
                  Column(
                    children: [
                      _answerCheck(chars),
                    ],
                  ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _answerCheck(AnswerResult chars) {
    // 判定色
    Color color = Colors.transparent;
    if (chars.judge == JUDGE_CORRECT) {
      color = Colors.blue;
    } else if (chars.judge == JUDGE_EXISTING) {
      color = Colors.yellow;
    } else if (chars.judge == JUDGE_NOTHING) {
      color = Colors.grey;
    } else {
      color = Colors.white;
    }

    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        chars.char,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 70,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _correctAnswerDialog(String word, String mean) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('答え'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('単語 : $word'),
              Text('意味 : $mean'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
