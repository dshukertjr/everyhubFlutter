import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:core';

// import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(new FriendlychatApp());
}

final ThemeData kIOSTheme = new ThemeData(
  // primarySwatch: Color(0xFF42A5F5),
  // primaryColor: Colors.grey[100],
  primaryColor: Color(0xFF00a99d),
  // primaryColor: Colors.green[900],
  backgroundColor: Color(0xFFFFFFFF),
  buttonColor: Color(0xFF00a99d),
  // primaryColorBrightness: Brightness.light,
  accentColor: Colors.orange[500],
);

// final ThemeData kDefaultTheme = new ThemeData(
//   primarySwatch: Colors.green[400],
//   primaryColor: Colors.grey[100],
//   accentColor: Colors.orangeAccent[400],
// );

class FriendlychatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Friendlychat",
      // theme: defaultTargetPlatform == TargetPlatform.iOS
      //     ? kIOSTheme
      //     : kDefaultTheme,
      theme: kIOSTheme,
      // home: new ChatScreen(),
      home: new LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  State createState() => new LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final FirebaseAuth firebaseUser = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Everyhubへようこそ"),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      body: new Container(
        // alignment: Alignment.center,
        // decoration: new BoxDecoration(color: Colors.white),
        child: new Center(
            child: new Padding(
          padding: new EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new TextFormField(
                  controller: _emailController,
                  decoration: new InputDecoration(
                    border: const UnderlineInputBorder(),
                    filled: true,
                    // hintText: "Email",
                    labelText: "Email",
                  ),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new TextField(
                  controller: _passwordController,
                  decoration: new InputDecoration(
                    border: const UnderlineInputBorder(),
                    filled: true,
                    // hintText: "Email",
                    labelText: " Password",
                  ),
                  textAlign: TextAlign.center,
                  obscureText: true,
                ),
              ),
              new Padding(
                padding: new EdgeInsets.all(8.0),
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                      child: new RaisedButton(
                        child: new Text("ログイン"),
                        onPressed: () => _handleLogin(_emailController.text, _passwordController.text)
                            .then((FirebaseUser user) => print(user))
                            .catchError((e) => print(e)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }

  Future<FirebaseUser> _handleLogin(String email, String password) async {
    print(email);
    print(password);
    FirebaseUser user = await firebaseUser.signInWithEmailAndPassword(
        email: email, password: password);
    print("done logging in");
    print(firebaseUser);
    return user;
  }
}

class ChatScreen extends StatefulWidget {
  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = new TextEditingController();
  bool _isComposing = false;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Friendlychat"),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      body: new Container(
          child: new Column(
            children: <Widget>[
              new Flexible(
                child: new ListView.builder(
                  padding: new EdgeInsets.all(8.0),
                  reverse: true,
                  itemBuilder: (_, int index) => _messages[index],
                  itemCount: _messages.length,
                ),
              ),
              new Divider(height: 1.0),
              new Container(
                decoration:
                    new BoxDecoration(color: Theme.of(context).cardColor),
                child: _buildTextComposer(),
              ),
            ],
          ),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
              ? new BoxDecoration(
                  border: new Border(
                    top: new BorderSide(color: Colors.grey[200]),
                  ),
                )
              : null),
    );
  }

  @override
  void dispose() {
    for (ChatMessage message in _messages)
      message.animationController.dispose();
    super.dispose();
  }

  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                controller: _textController,
                onChanged: (String text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
                onSubmitted: _handleSubmitted,
                decoration:
                    new InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),
            new Container(
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? new CupertinoButton(
                        child: new Text("Send"),
                        onPressed: _isComposing
                            ? () => _handleSubmitted(_textController.text)
                            : null,
                      )
                    : new IconButton(
                        icon: new Icon(Icons.send),
                        onPressed: _isComposing
                            ? () => _handleSubmitted(_textController.text)
                            : null,
                      )),
          ],
        ),
      ),
    );
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    ChatMessage message = new ChatMessage(
      text: text,
      animationController: new AnimationController(
        duration: new Duration(milliseconds: 200),
        vsync: this,
      ),
    );
    setState(() {
      _messages.insert(0, message);
    });
    message.animationController.forward();
  }
}

const String _name = "Your Name";

class ChatMessage extends StatelessWidget {
  ChatMessage({this.text, this.animationController});
  final String text;
  final AnimationController animationController;
  @override
  Widget build(BuildContext context) {
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(
          parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: new CircleAvatar(child: new Text(_name[0])),
            ),
            new Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(_name, style: Theme.of(context).textTheme.subhead),
                  new Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: new Text(text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
