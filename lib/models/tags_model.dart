class TagsModel {
  static final List<String> tags = [
    '🇨🇳 Chinese',
    '🇰🇷 Korean',
    '🇯🇵 Japanese',
    '🇹🇭 Thai',
    '🇺🇸 American',
    '🇻🇳 Vietnamese',
    '🇫🇷 French',
    '🇮🇳 Indian',
    '🇲🇽 Mexican',
    '🇹🇷 Turkish',
    '🇪🇸 Spanish',
    '🇬🇷 Greek'
  ];

  // get a list of tags that matches the query for logging page
  static List<String> getSuggestions(String query) {
    List<String> matches = [];
    matches.addAll(tags);
    matches.retainWhere((c) => c.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }
}