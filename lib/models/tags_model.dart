class TagsModel {
  static final List<String> tags = [
    'Chinese',
    'Korean',
    'Japanese'
  ];

  static List<String> getSuggestions(String query) {
    List<String> matches = [];
    matches.addAll(tags);
    matches.retainWhere((c) => c.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }
}