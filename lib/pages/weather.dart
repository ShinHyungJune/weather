import 'package:flutter/material.dart';
import '../utils/utils.dart' as util;
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Weather extends StatefulWidget {
  @override
  _WeatherState createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  String _city = util.defaultCity;

  Future _goToNextScreen(BuildContext context) async {
    Map results = await Navigator.of(context)
        .push(MaterialPageRoute<Map>(builder: (BuildContext context) {
      return ChangeCity();
    }));

    if (results != null && results.containsKey("city")) {
      _city = results["city"].toString();
    }
  }

  void showStuff() async {
    Map data = await getWeather(util.appId, util.defaultCity);
    print(data.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("날씨앱"),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              _goToNextScreen(context);
            },
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          Center(
              child: Image.asset('images/umbrella.png',
                  height: 1200.0, width: 490.0, fit: BoxFit.fill)),
          Container(
            alignment: Alignment.topRight,
            margin: EdgeInsets.fromLTRB(0.0, 10.9, 20.9, 0.0),
            child: Text(
              "$_city",
              style: cityStyle(),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Image.asset('images/light_rain.png'),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(30.0, 250.0, 0.0, 0.0),
            child: updateTempWidget(_city),
          ),
          new Container(
            alignment: Alignment.center,
            child: Image.asset('images/light_rain.png'),
          ),
        ],
      ),
    );
  }

  Future<Map> getWeather(String appId, String city) async {
    String apiUrl =
        'http://api.openweathermap.org/data/2.5/weather?q=$city&appid=${appId}&units=metric';

    http.Response response = await http.get(apiUrl);

    return json.decode(response.body);
  }

  Widget updateTempWidget(String city) {
    return FutureBuilder(
        future: getWeather(util.appId, city == null ? util.defaultCity : city),
        builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
          if (snapshot.hasData) {
            Map content = snapshot.data;

            return Container(
              margin: EdgeInsets.fromLTRB(10.0, 120.0, 0.0, 0.0),
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      "${content['main']['temp'].toString()} ℃",
                      style: tempStyle(),
                    ),
                    subtitle: ListTile(
                      title: Text(
                        "습도: ${content["main"]["humidity"]}\n"
                        "최저: ${content["main"]["temp_min"]} ℃\n"
                        "최고: ${content["main"]["temp_max"]} ℃\n",
                        style: TextStyle(color:Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Center(child: CircularProgressIndicator());
        });
  }
}

class ChangeCity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _cityFieldController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('도시 선택'),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.asset(
              "images/white_snow.png",
              height: 1200.0,
              fit: BoxFit.cover,
            ),
          ),
          ListView(
            children: <Widget>[
              ListTile(
                title: TextField(
                  decoration: InputDecoration(
                    hintText: '도시를 입력해주세요.',
                  ),
                  controller: _cityFieldController,
                  keyboardType: TextInputType.text,
                ),
              ),
              ListTile(
                title: FlatButton(
                    color: Colors.deepOrange,
                    onPressed: () {
                      Navigator.pop(
                          context, {'city': _cityFieldController.text});
                    },
                    child: Text(
                      "날씨정보 보기",
                      style: TextStyle(color: Colors.white),
                    )),
              )
            ],
          )
        ],
      ),
    );
  }
}

TextStyle cityStyle() {
  return TextStyle(fontSize: 22.4, color: Colors.white);
}

TextStyle tempStyle() {
  return TextStyle(
    color: Colors.white,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w500,
    fontSize: 49.9,
  );
}
