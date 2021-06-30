import 'package:flutter/material.dart';
import 'dart:async';

class ProgressDialog extends StatelessWidget {
  final Stream<double> stream;

  const ProgressDialog({Key? key,required this.stream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.blue, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(3.0)),
        ),
        height: 100,
        child: StreamBuilder(
          stream: stream,
          builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
            String title="";
            if(snapshot.data != null){
              title = '已下载 ${(snapshot.data!*100).toInt()}%';
            }
            return Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 35, 10, 10),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      child: LinearProgressIndicator(
                        value: snapshot.data,
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation(Colors.blue.shade200),
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 12),
                  child: Text(
                    "$title",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}
