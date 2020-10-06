import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'components/country.dart';
import 'services/graphQLConf.dart';
import 'services/queryDefinition.dart';

GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();
void main() => runApp(GraphQLProvider(
      client: graphQLConfiguration.client,
      child: CacheProvider(child: MyApp()),
    ));

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GraphQLClientResult(),
    );
  }
}

class GraphQLClientResult extends StatefulWidget {
  @override
  GraphQLClientResultState createState() => new GraphQLClientResultState();
}

class GraphQLClientResultState extends State<GraphQLClientResult> {
  List<Country> listCountry = List<Country>();
  GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();
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

  void _countriesInContinent(String continentCode) async {
    QueryDefinition queryDefinition = QueryDefinition();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    _continentCode = (continentCode.length > 2
        ? continentCode.substring(0, 2).toUpperCase()
        : continentCode.toUpperCase());
    QueryResult result = await _client.query(
      QueryOptions(
          document: queryDefinition.getCountriesInContinent(),
          variables: <String, dynamic>{"code": _continentCode}),
    );
    listCountry.clear();
    if (!result.hasException) {
      for (var countryIndex = 0;
          countryIndex < result.data['continent']['countries'].length;
          countryIndex++) {
        setState(() {
          listCountry.add(Country(
            result.data['continent']['countries'][countryIndex]['name'],
            result.data['continent']['countries'][countryIndex]['native'],
            result.data['continent']['countries'][countryIndex]['emoji'],
            result.data['continent']['countries'][countryIndex]['phone'],
          ));
        });
      }
    }
  }

  Widget _buildAppBar(BuildContext context) {
    return new AppBar(centerTitle: true, title: appBarTitle, actions: <Widget>[
      new IconButton(
        icon: searchIcon,
        onPressed: () {
          setState(() {
            listCountry.clear();
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
                    hintStyle: new TextStyle(color: Colors.cyanAccent)),
                onChanged: _countriesInContinent,
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
    String resultHeader = "Countries of " +
        (_continentCode.trim().length == 0 ? "??" : _continentCode);
    return Scaffold(
        key: globalKey,
        appBar: _buildAppBar(context),
        body: Stack(children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            child: Text(
              resultHeader,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24.0),
            ),
          ),
          Container(
              padding: EdgeInsets.only(top: 30.0),
              child: ListView.builder(
                itemCount: listCountry.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      "${listCountry[index].getName()}",
                      style: Theme.of(context).textTheme.subhead,
                    ),
                    subtitle: Text(
                      "${listCountry[index].getEmoji()} ${listCountry[index].getNative()} (${listCountry[index].getPhone()})",
                    ),
                  );
                },
              ))
        ]));
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
}
