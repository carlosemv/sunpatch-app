import 'package:flutter/material.dart';

class SkinWidget extends StatelessWidget {
  final entries = <String>[
    'Always burns, peels, never tans',
    'Burns easily, peels, tans minimally',
    'Burns moderately, average tanning facility',
    'Burns minimally, tans easily',
    'Rarely burns, tans easily and substantially',
    'Almost never burns, tans readily and profusely'
  ];

  final _skinColors = [0xF1EDD8, 0xF3DFCC, 0xECC099, 0xC79465,
    0x70442A, 0x482D19].map((c) => Color(c).withOpacity(1)).toList();
  final _skinFactors = <num>[1.4, 1, 0.7, 0.6, 0.5, 0.4];
  List<int> maxExposures;

  SkinWidget() {
    maxExposures = List<int>.generate(
      _skinFactors.length,
      (int idx) => (300 / _skinFactors[idx]).ceil()
      // (int idx) => (19740 / _skinFactors[idx]).ceil()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sunpatch"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: entries.length+1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'What is your skin type?',
                textAlign: TextAlign.center,
                style: DefaultTextStyle.of(
                  context).style.apply(fontSizeFactor: 2.0),
              ),
            );
          } else {
            return Card(
              child: ListTile(
                leading: SkinIcon(_skinColors[index-1]),
                title: Text(entries[index-1]),
                onTap: () {
                  var s = Skin(index-1,
                    maxExposures[index-1]);
                  Navigator.pop(context, s);
                },
              ),
            );
          }
        }
      ),
    );
  }
}

class SkinIcon extends StatelessWidget {
  Color skin;
  SkinIcon(this.skin);

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        width: 40.0,
        decoration: new BoxDecoration(
          color: skin,
          shape: BoxShape.circle,
        )
      ),
    );
  }
}

class Skin {
  int type;
  int maxExposure;
  Skin(this.type, this.maxExposure);
  Skin.fromDB(Map<String, dynamic> data) {
    this.type = data['skinType'];
    this.maxExposure = data['maxExposure'];
  }
}