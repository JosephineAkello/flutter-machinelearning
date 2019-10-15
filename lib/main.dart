import 'package:flutter/material.dart';

void main(){
  runApp(MLflutter());
}

class MLflutter extends StatefulWidget{
  createState(){
    return MLflutterState();
  }
}
class MLflutterState extends State<MLflutter>{
  Widget build(context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.red,
        accentColor: Colors.tealAccent
      ),
      title: 'Flutter + ML',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter + ML'),
        ),
      ),
    )
    ;
  }
}