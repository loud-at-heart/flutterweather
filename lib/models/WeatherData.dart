class WeatherData {
  final int? date;
  final String name;
  final double temp;
  final String main;
  final String icon;

  WeatherData(
      {this.date,
      required this.name,
      required this.temp,
      required this.main,
      required this.icon});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      date: json['dt'],
      name: json['name'],
      temp: json['main']['temp'].toDouble(),
      main: json['weather'][0]['main'],
      icon: json['weather'][0]['icon'],
    );
  }

  Map<String, dynamic> toJson() => {
    "date" : date,
    "name" : name,
    "temp" : temp,
    "main" : main,
    "icon" : icon,
  };
}
