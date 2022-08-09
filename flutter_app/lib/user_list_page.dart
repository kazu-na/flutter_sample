import 'package:flutter/material.dart';
import 'package:graphql/client.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List _users = [];

  void _setUsers(userList) {
    setState(() {
      _users = userList;
    });
  }

  void callUserListQuery() async {
    // 接続先
    final _link = HttpLink(
      "http://serene-garden-89220.herokuapp.com/query",
    );
    // Graphqlを使用するためのクライアント
    final GraphQLClient client = GraphQLClient(
      link: _link,
      cache: GraphQLCache(),
    );

    const String getUserList = r'''
      query GetUserList {
        userList {
          name
          id
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(getUserList),
      // variables: <String, dynamic>{
      //   'nRepositories': nRepositories,
      // },
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      print(result.exception.toString());
    }

    final data = result.data;
    if (data != null) {
      _setUsers(data['userList']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UserList')),
      body: Column(
        children: [
          IconButton(
            onPressed: () {
              callUserListQuery();
            },
            icon: Icon(Icons.star),
          ),
          // ...[]で複数Widgetを条件分岐で表示できる(spread operator)
          if (_users.isNotEmpty) ...[
            SizedBox(
              height: 500,
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (_, index) {
                  return Text(_users[index]['name']);
                },
              ),
            ),
            Text('hoge'),
          ],
        ],
      ),
    );
  }
}
