import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() => runApp(MaterialApp(title: "Demo Flutter GraphQL Client App", home: MyApp()));

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink =
    HttpLink(uri: "https://countries.trevorblades.com/");
    final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        link: httpLink as Link,
        cache: OptimisticCache(
          dataIdFromObject: typenameDataIdFromObject,
        ),
      ),
    );
    return GraphQLProvider(
      child: HomePage(),
      client: client,
    );
  }
}

class HomePage extends StatelessWidget {
  final String query = r"""
                    query GetContinent($code : String!){
                      continent(code:$code){
                        name
                        countries{
                          name
                          native
                          emoji
                          phone
                          languages{
                            name
                            native
                          }
                        }
                      }
                    }
                  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter GraphlQL Client"),
      ),
      body: Query(
        options: QueryOptions(
            document: query, variables: <String, dynamic>{"code": "US"}),
        builder: (
            QueryResult result, {
              VoidCallback refetch,
            }) {
          if (result.loading) {
            return Center(child: CircularProgressIndicator());
          }
          if (result.data == null) {
            return Text("No Data Found !");
          }
          return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title:
                Text(result.data['continent']['countries'][index]['name']),
              );
            },
            itemCount: result.data['continent']['countries'].length,
          );
        },
      ),
    );
  }
}
