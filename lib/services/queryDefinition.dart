class QueryDefinition {
  String getCountriesInContinent() {
    return r"""
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
  }
}