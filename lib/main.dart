import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
void main() {
  runApp(MaterialApp(
    title: 'Named Routes Demo',
    // Start the app with the "/" named route. In this case, the app starts
    // on the FirstScreen widget.
    initialRoute: '/',
    routes: {
      // When navigating to the "/" route, build the FirstScreen widget.
      '/': (context) => AuthApp(),
      // When navigating to the "/second" route, build the SecondScreen widget.
      '/second': (context) => MyApp(),
    },
  ));
}

class AuthApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyLoginPage(),
    );
  }
}

class MyLoginPage extends StatefulWidget {
  @override
  _MyLoginPageState createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage>{ 
  final _formKey = GlobalKey<FormState>();
  String password;
  String email;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Please login or Signup to get Started"),
      ),
      body: Container(
    padding: EdgeInsets.all(20.0),
    child: Form(          // <= NEW
    key: _formKey,
    child: Column(
      children: <Widget>[
        SizedBox(height: 20.0),
        Text(
          'Login Information',
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(height: 20.0),
        TextFormField(
            onSaved: (value) => email = value, 
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: "Email Address")),
        TextFormField(
            onSaved: (value) => password = value,
            obscureText: true,
            decoration: InputDecoration(labelText: "Password")),
            SizedBox(height: 20.0),
        RaisedButton(child: Text("Log In"), onPressed: ()=>onSubmit(context)),
        RaisedButton(child: Text("Sign Up"), onPressed: ()=>onSignUP(context)),
      ],
    ),
  ),
  )
    );
  }

  bool validate() {
    final form = _formKey.currentState;
    form.save();
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void onSubmit(BuildContext context) async {
      if(validate()){
        if(email.isEmpty){
        showDialogBox("Inputfield for email is Empty!","Please provide email");
          return;
        }
        if(password.isEmpty){
          showDialogBox("Inputfield for password is Empty!","Please provide password");
          return;
        }
      var map = new Map<String, dynamic>();
      map['username'] = email;
      map['password'] = password;
      var url = 'http://192.168.0.101/reportapp/login.php';
      http.post(url, body: map).then((http.Response response) {
      final int statusCode = response.statusCode;
      if(statusCode == 200){
        showDialogBox("Success", "You are successfully Logged In!");
            Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyApp(text:email)),
          );
      }else if(statusCode == 404){
        showDialogBox("Failure", "No user found with the given username");
      }else if(statusCode == 409){
        showDialogBox("Failure", "Wrong passord");
      }else{
        showDialogBox("Failure", "Some issues with server or your connection is bad");
      }
      
      });
      }     
  }

  Future<void> showDialogBox(String title, String content) async{
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(content),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onSignUP(BuildContext context){
  if(validate()){     
      if(email.isEmpty){
        showDialogBox("Inputfield for email is Empty!","Please provide email");
          return;
        }
        if(password.isEmpty){
          showDialogBox("Inputfield for password is Empty!","Please provide password");
          return;
        }
        var map = new Map<String, dynamic>();
      map['username'] = email;
      map['password'] = password;
      var url = 'http://192.168.0.101/reportapp/signup.php';
      http.post(url, body: map).then((http.Response response) {
      final int statusCode = response.statusCode;
      if(statusCode == 200){
        showDialogBox("Success", "You are successfully registered!");
      }else{
        showDialogBox("Failure", "Some issues with server or your connection is bad");
      }
      });
      }     
    }
}

class MyApp extends StatelessWidget {
  final String text;
  MyApp({Key key, @required this.text}) : super(key: key);
 @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(text),
    );
  }
}
class MyHomePage extends StatefulWidget {
  final String text;
  MyHomePage(this.text);
  @override
  _MyHomePageState createState() => _MyHomePageState(text);
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Marker> allMarkers = [];
  final String text;
  GoogleMapController _controller;
  _MyHomePageState(this.text);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchPost();
  }

void fetchPost() async {
  final response =
      await http.get('http://192.168.0.101/reportapp/viewmarker.php');
  
  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    Iterable list = json.decode(response.body);
      for(int i = 0; i < list.length; i++){
      setState(() {
      allMarkers.add(Marker(
                markerId: MarkerId(list.elementAt(i)['id']),
                position: new LatLng(double.parse(list.elementAt(i)['latitude']),double.parse(list.elementAt(i)['longitude'])),
                infoWindow: InfoWindow(
                  title: list.elementAt(i)['name'],
                ),
                icon:
                    BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
              ));
    });
    }    
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

Future<String> showMarkerDialog(BuildContext context){
  TextEditingController customController = TextEditingController();
  return showDialog(context: context,
  builder: (context){
    return AlertDialog(
      title: Text("Please provide subject for the report"),
      content: TextField(
        controller: customController,
      ),
      actions:<Widget>[
        MaterialButton(
          elevation: 0.5,
          child: Text("Report Now!"),
          onPressed: (){
            Navigator.of(context).pop(customController.text.toString());
          },
        ),
        MaterialButton(
          elevation: 0.5,
          child: Text("Cancel"),
          onPressed: (){
            Navigator.of(context).pop();
          },
        ),
      ]
    );
  });
}

Future<void> showDialogBox(String title, String content) async{
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(content),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maps'),
      ),
      body: Stack(
        children: [Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: GoogleMap(
            initialCameraPosition:
                CameraPosition(target: LatLng(27.7172, 85.3240), zoom: 12.0),
            markers: Set.from(allMarkers),
            onMapCreated: mapCreated,
            onTap: (LatLng point){
              showMarkerDialog(context).then((onValue){
              String title = onValue;
              _addMarker(point,title);
              sendMarker(point,title);
              sendEmail();
              });
            },
          ),
        ),
        ]
      ),
    );
  }

sendEmail(){
      var map = new Map<String, dynamic>();
      map['email'] = text;
      var url = 'http://192.168.0.101/reportapp/view.php';
      http.post(url, body: map).then((http.Response response) {
         Iterable list = json.decode(response.body);
        for(int i = 0; i < list.length; i++){
          String email = list.elementAt(i)['username'];
          var data = new Map<String,dynamic>();
          data['email'] = email;
          http.post("http://192.168.0.101:5000/mail",body:data).then((http.Response response){
            print("email Sent");
          });
        }
      });
}

sendMarker(LatLng point, String title){
  var map = new Map<String, dynamic>();
      map['name'] = title;
      map['latitude'] = point.latitude.toString();
      map['longitude'] = point.longitude.toString();
      print(point.latitude.toString());
      print(point.longitude.toString());
      var url = 'http://192.168.0.101/reportapp/addmarker.php';
      http.post(url, body: map).then((http.Response response) {
      final int statusCode = response.statusCode;
      print(response.body);
      if(statusCode == 200){
        showDialogBox("Success", "Your report is recorded and message is sent.");
      }else{
        showDialogBox("Failure", "Some issues with server or your connection is bad");
      }
      });
}

_addMarker(LatLng point, String title) {
    Marker marker = Marker(
        markerId: MarkerId(title),
        draggable: true,
        onTap: () {
          print(title);
        },
        infoWindow: InfoWindow(
                  title: title,
                ),
        position: point);
    setState(() {
      allMarkers.add(marker);
    });
  }
  void mapCreated(controller) {
    setState(() {
      _controller = controller;
    });
  }
}




