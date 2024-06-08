class LoggingModel {
  final String? uid;
  final String picture;
  final String name;
  final String location;
  final double rating;
  final String description;

  const LoggingModel({
    this.uid,
    required this.picture,
    required this.name,
    required this.location,
    required this.rating,
    required this.description
  });

  static LoggingModel empty() => LoggingModel(uid: '', picture: '', name: '', location: '', rating: 0.0, description: '');

  Map<String, dynamic> toJson() {
    return {
      "Picture": picture,
      "Name": name,
      "Location": location,
      "Rating": rating,
      "Description": description,
    };
  }
}