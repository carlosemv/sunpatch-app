import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sunpatch/signin_page.dart';
import 'package:sunpatch/skin_widget.dart';
import 'package:sunpatch/background_collecting.dart';
import 'package:sunpatch/uv_chart_widget.dart';

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _overriding = false;
  bool _monitoring = false;
  Skin skin = null;
  FirebaseUser user = null;

  BackgroundCollectingTask _collector = null;
  Timer _upload_data;

  // callback for SignInPage when signed in
  void signedIn(FirebaseUser user, bool register) {
    setState(() {this.user = user;});
    if (register) {
      setSkin();
    } else {
      loadSkin();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return SignInPage(signedIn);
    } else {
      if (_collector == null) {
        _collector = BackgroundCollectingTask();
      }

      return buildHome(context);
    }
  }

  void loadSkin() async {
    var doc = await Firestore.instance.collection('users')
      .document(user.uid).get();
    setState((){skin = Skin.fromDB(doc.data);});
  }

  void setSkin() async {
    Skin newSkin = await Navigator.push(context, 
      MaterialPageRoute(builder: (context) =>
        SkinWidget()
      )
    );

    if (newSkin == null) {
      setState(() {
        user = null;
      });
      return;
    }

    setState(() {
      skin = newSkin;
    });

    Firestore.instance.collection('users')
        .document(user.uid).setData({
      'skinType': skin.type,
      'maxExposure': skin.maxExposure,
    });
  }

  void signOut() {
    setState(() {
      user = null;
      skin = null;
      _collector = null;
      auth.signOut();
    });
  }

  Widget buildUVI(num uv) {
    if (uv == null || uv == 0) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 50, vertical: 10),
        child: Container(
          padding: EdgeInsets.all(5.0),
          child: Text(
            "UVI: Loading...",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.title,
          ),
        ),
      );
    }

    final uvMap = [0x4eb400, 0xa0ce00, 0xf7e400, 0xf8b600,
      0xf88700, 0xf85900, 0xe82c0e, 0xd8001d, 0xff0099,
      0xb54cff, 0x998cff].map((c) => Color(c).withOpacity(1)).toList();
    int uvIdx = uv.ceil() - 1;
    if (uvIdx >= uvMap.length) {
      uvIdx = uvMap.length-1;
    }
    var uvColor = uvMap[uvIdx];
    var textColor = uvColor.computeLuminance() > 0.5 ?
      Colors.black : Colors.white;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 50, vertical: 10),
      child: Container(
        padding: EdgeInsets.all(5.0),
        child: Text(
          "UVI: ${uv.toStringAsFixed(2)}",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.title.copyWith(
            color: textColor),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0), color: uvColor),
      ),
    );
  }

  Widget buildHome(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: signOut,
          )
        ],
      ),
      body: (skin == null) ?
        Center(
          child: Text(
          "Loading user data...",
          textAlign: TextAlign.center,
        )) :
        Center(
          child: new ScopedModel<BackgroundCollectingTask>(
            model: _collector,
            child: ListView(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(top: 20)),
                ScopedModelDescendant<BackgroundCollectingTask>(
                  builder : (context, child, model) =>
                  new Text(
                  '(type ${skin.type}): ${model.totalExposure.toStringAsFixed(2)} / ${skin.maxExposure}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.title,
                  ),
                ),
                ScopedModelDescendant<BackgroundCollectingTask>(
                  builder : (context, child, model) => buildUVI(model.currUVI)
                ),
                ScopedModelDescendant<BackgroundCollectingTask>(
                  builder : (context, child, model) => ( 
                    UVChartWidget(100 * model.totalExposure ~/ skin.maxExposure)
                  )
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Percentage of maximum recomended exposure received in the last 24h',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.subhead,
                  ),
                ),
                Divider(),
                ListTile(
                  title: RaisedButton(
                    child: Text((_monitoring ? 'Stop' : 'Start')+' monitoring'),
                    onPressed: () {
                      if (_monitoring) {
                        _collector.pause();
                      } else {
                        _collector.resume();
                      }

                      setState((){_monitoring = !_monitoring;});
                    },
                  ),
                ),
                Divider(),
                ListTile(
                  title: RaisedButton(
                    child: Text(!_overriding ? 'Go to sun' : 'Come back'),
                    onPressed: () {
                      if (!_overriding) {
                        _collector.override();
                      } else {
                        _collector.startAll();
                      }

                      setState((){_overriding = !_overriding;});
                    },
                  ),
                ),
              ],
            )
          ),
        ),
    );
  }
}
