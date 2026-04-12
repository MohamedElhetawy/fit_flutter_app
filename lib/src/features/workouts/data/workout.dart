class Workout {
  Workout({
    required this.id,
    required this.title,
    required this.coach,
    required this.image,
    required this.price,
    this.discountPercent,
  });

  final String id;
  final String title;
  final String coach;
  final String image;
  final double price;
  final int? discountPercent;

  factory Workout.fromMap(String id, Map<String, dynamic> map) {
    return Workout(
      id: id,
      title: (map['title'] as String?) ?? 'Workout Plan',
      coach: (map['coach'] as String?) ?? 'FitX Coach',
      image: (map['image'] as String?) ?? 'https://i.imgur.com/CGCyp1d.png',
      price: ((map['price'] as num?) ?? 0).toDouble(),
      discountPercent: (map['discountPercent'] as num?)?.toInt(),
    );
  }
}
