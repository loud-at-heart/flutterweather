import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterweather/provider/db_provider.dart';
import 'package:flutterweather/widgets/Weather.dart';
import 'package:flutterweather/widgets/WeatherItem.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:flutter/services.dart';

import 'models/ForecastData.dart';
import 'models/WeatherData.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  bool isLoading = false;
  WeatherData? weatherData;
  ForecastData? forecastData;
  Location _location = new Location();
  String? error;
  String appId = '82f222e0183fd53e4b0659126b2db31b';
  final DBProvider dbProvider=DBProvider.db;
  bool isInternet=true;

  @override
  void initState() {
    super.initState();
    internetConnectivity();
    // isInternet?loadWeather():loadOfflineWeather();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          backgroundColor: Colors.blueGrey,
          appBar: AppBar(
            title: Text('Flutter Weather App'),
          ),
          body: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: weatherData != null
                        ? Weather(weather: weatherData!)
                        : Container(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: isLoading
                        ? CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor:
                                new AlwaysStoppedAnimation(Colors.white),
                          )
                        : IconButton(
                            icon: new Icon(Icons.refresh),
                            tooltip: 'Refresh',
                            onPressed: internetConnectivity,
                            color: Colors.white,
                          ),
                  ),
                ],
              ),
            ),
            // SafeArea(
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: Container(
            //       height: 200.0,
            //       child: forecastData != null
            //           ? ListView.builder(
            //               itemCount: forecastData!.list.length,
            //               scrollDirection: Axis.horizontal,
            //               itemBuilder: (context, index) => WeatherItem(
            //                   weather: forecastData!.list.elementAt(index)))
            //           : Container(),
            //     ),
            //   ),
            // )
          ]))),
    );
  }

  loadWeather() async {
    setState(() {
      isLoading = true;
    });

    LocationData location;

    location = await _location.getLocation();

    error = null;

    if (location != null) {
      final lat = location.latitude;
      final lon = location.longitude;

      final weatherResponse = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?APPID=${appId}&lat=${lat.toString()}&lon=${lon.toString()}'));
      final forecastResponse = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?APPID=${appId}&lat=${lat.toString()}&lon=${lon.toString()}'));

      if (weatherResponse.statusCode == 200 &&
          forecastResponse.statusCode == 200) {
        return setState(() {
          weatherData =
              new WeatherData.fromJson(jsonDecode(weatherResponse.body));
          dbProvider.createWeather(weatherData!);
          forecastData =
              new ForecastData.fromJson(jsonDecode(forecastResponse.body));
          isLoading = false;
        });
      }
    }

    setState(() {
      isLoading = false;
    });
  }
  internetConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // setState(() {
        //   isInternet = true;
        // });
        print('connected');
        loadWeather();
      }
    } on SocketException catch (_) {
      setState(() {
        isInternet = false;
      });
      print('not connected');
      loadOfflineWeather();
    }
  }

  loadOfflineWeather() async {
    List<WeatherData> res = await dbProvider.getAllWeather();
    res.forEach((element) {
      setState(() {
        weatherData = element;
      });
    });
  }
}
