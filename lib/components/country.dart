class Country {
  Country(this.name, this.native, this.emoji, this.phone);

  final String name;
  final String native;
  final String emoji;
  final String phone;

  getName()   => this.name;
  getNative() => this.native;
  getEmoji()  => this.emoji;
  getPhone()  => this.phone;
}