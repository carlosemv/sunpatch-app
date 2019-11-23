import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:scoped_model/scoped_model.dart';

class DataSample {
  num data;
  DateTime timestamp;

  DataSample.fromData(this.data);
  DataSample({this.data, this.timestamp});
}

class BackgroundCollectingTask extends Model
{
  static BackgroundCollectingTask of(BuildContext context, {bool rebuildOnChange = false}) =>
      ScopedModel.of<BackgroundCollectingTask>(context, rebuildOnChange: rebuildOnChange);
  
  final _location = Location();
  Timer _updateExposure;
  Timer _updateUVI;
  Future<String> _apiKey = rootBundle.loadString('assets/api_key');

  final _avgSamples = 10;

  num currUVI = 0;
  num totalExposure = 0; // mJ/cm2
  var _samples = new List<DataSample>();

  BackgroundCollectingTask() {
    startAll();
  }

  void collectData() {
    var now = DateTime.now();
    var data = currUVI * 0.025;
    final sample = DataSample(
      data: data,
      timestamp: now
    );
    _samples.add(sample);
    totalExposure += sample.data;

    var minDate = now.subtract(Duration(hours: 24));
    while (!_samples.isEmpty && _samples.first.timestamp.isBefore(minDate)) {
      totalExposure -= _samples.first.data;
      _samples.removeAt(0);
    }

    notifyListeners();
  }

  void loadUVI() async {
    LocationData loc;
    try {
      loc = await _location.getLocation();
    } on PlatformException catch (e) {
      print(e);
      return;
    }

    String key = (await _apiKey).replaceAll("\n", " ");
    String req = "https://api.openweathermap.org/data/2.5/uvi?";
    req += "lat=${loc.latitude}&lon=${loc.longitude}";
    req += "&appid=${key}";
    print(req);
    http.Response response = await http.get(req);
    var data = json.decode(response.body);
    currUVI = data["value"];

    notifyListeners();
  }

  void startAll() async {
    _samples.clear();
    _updateUVI = Timer.periodic(
      Duration(seconds: 10),
      (Timer timer) async => loadUVI()
    );
    Timer.run(loadUVI);
    notifyListeners();
  }

  void override() {
    if (_updateUVI != null && _updateUVI.isActive) {
      _updateUVI.cancel();
    }
    currUVI = 500;
    notifyListeners();
  }

  void startMonitoring() {
    _updateExposure = Timer.periodic(
      Duration(seconds: 1),
      (Timer timer) async => collectData()
    );
  }

  void pause() {
    _updateExposure.cancel();
    notifyListeners();
  }

  void resume() {
    startMonitoring();
    notifyListeners();
  }

  void cancel() {
    _updateExposure.cancel();
    _updateUVI.cancel();
    notifyListeners();
  }
}