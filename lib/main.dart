import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() => runApp(MaterialApp(home: MyApp()));

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
      child: GraphQLClientResult(),
      client: client,
    );
  }
}

class GraphQLClientResult extends StatefulWidget {
  @override
  GraphQLClientResultState createState() => new GraphQLClientResultState();
}

class GraphQLClientResultState extends State<GraphQLClientResult> {
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

  Widget appBarTitle = new Text(
    "Flutter GraphQL Client",
    style: new TextStyle(color: Colors.white),
  );
  Icon searchIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  final globalKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _controller = new TextEditingController();
  String _continentCode = "";

  GraphQLClientResultState() {
    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        setState(() {
          _continentCode = "";
        });
      } else {
        setState(() {
          _continentCode = _controller.text;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Widget _countriesInContinent() {
    return Query(
      options: QueryOptions(
          document: query, variables: <String, dynamic>{"code": _continentCode}),
      builder: (
          QueryResult result, {
            VoidCallback refetch,
          }) {
                if (result.errors != null) {
                  return Text(result.errors.toString());
                }
                if (result.loading) {
                  return Center(child: CircularProgressIndicator());
                }
                List countriesInQueryResult = result.data['continent']['countries'];
                if (countriesInQueryResult.length == 0) {
                  return Text("No Data Found !");
                }
                return ListView.builder(
                  itemCount: countriesInQueryResult.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title:
                      Text(result.data['continent']['countries'][index]['name'], style: Theme.of(context).textTheme.headline),
                      subtitle: Text(result.data['continent']['countries'][index]['emoji']),
                    );
                  },
                );
              },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return new AppBar(centerTitle: true, title: appBarTitle, actions: <Widget>[
      new IconButton(
        icon: searchIcon,
        onPressed: () {
          setState(() {
            if (this.searchIcon.icon == Icons.search) {
              this.searchIcon = new Icon(
                Icons.close,
                color: Colors.white,
              );
              this.appBarTitle = new TextField(
                controller: _controller,
                style: new TextStyle(
                  color: Colors.white,
                ),
                decoration: new InputDecoration(
                  prefixIcon: new Icon(Icons.search, color: Colors.white),
                  hintText: "Search continents: AF, EU, OC ...",
                  hintStyle: new TextStyle(color: Colors.white)
                ),
                onChanged: searchCountriesInContinent,
              );
            } else {
              _handleSearchEnd();
            }
          });
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: _buildAppBar(context),
      body: _countriesInContinent(),
    );
  }

  void _handleSearchEnd() {
    setState(() {
      this.searchIcon = new Icon(
        Icons.search,
        color: Colors.white,
      );
      this.appBarTitle = new Text(
        "Flutter GraphQL Client",
        style: new TextStyle(color: Colors.white),
      );
      _controller.clear();
    });
  }

  void searchCountriesInContinent(String continentCode) {
    _continentCode = continentCode.toUpperCase();
    _countriesInContinent();
  }
}
