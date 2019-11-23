import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth auth = FirebaseAuth.instance;

class SignInPage extends StatefulWidget {
  bool register = false;

  Function(FirebaseUser, bool) signIn;
  SignInPage(this.signIn);

  @override
  State<StatefulWidget> createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _success;
  String _userEmail;
  String _errorMsg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sunpatch - ' +
          (widget.register ? 'Register' : 'Sign in')),
      ),
      body: Container(
        padding: EdgeInsets.all(30), 
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Container(
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/sunpatch.png'),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    icon: Icon(Icons.mail),
                  ),
                  validator: (value) => value.isEmpty ?
                    'Please enter email' : null,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 25),
                child: TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    icon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) => value.isEmpty ?
                    'Please enter password' : null,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 45.0),
                child: SizedBox(
                  height: 40,
                  child: RaisedButton(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        _signIn();
                      }
                    },
                    child: Text(
                      widget.register ? 'Register' : 'Sign in'
                    ),
                  ),
                ),
              ),
              FlatButton(
                child: Text(
                  widget.register ? 'Have an account? Sign in' : 'Create an account',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)
                ),
                onPressed: () {
                  setState(() {
                    widget.register = !widget.register;
                  });
                },
              ),
              Container(
                alignment: Alignment.center,
                child: Text(getSigninMsg()),
              ),
              Padding(
                padding: EdgeInsets.only(top: 30.0, bottom: 20),
                child: SizedBox(
                  height: 30,
                  child: RaisedButton.icon(
                    color: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                    onPressed: () async {
                      _anonSignIn();
                    },
                    icon: Icon(Icons.person_outline),
                    label: Text("Sign in anonymously"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getSigninMsg() {
    if (_success == null) {
      return '';
    }

    if (!_success) {
      return (widget.register ?
        'Registration failed' : 'Sign in failed')
        + ': ${_errorMsg}';
    }

    final verb = (widget.register) ? 'registered' : 'signed in';
    return 'Successfully ${verb} ${_userEmail}';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _anonSignIn() async {
    FirebaseUser user;
    try {
      user = (await auth.signInAnonymously()).user;
    } on PlatformException catch(e) {
      _errorMsg = e.message;
      user = null;
    }

    if (user != null) {
      setState(() {
        _success = true;
        _userEmail = "anonymously";
      });

      widget.signIn(user, true);
    } else {
      _success = false;
    }
  }

  void _signIn() async {
    FirebaseUser user;
    try {
      if (false) {
        user = (await auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        )).user;
      } else {
        user = (await auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        )).user;
      }
    } on PlatformException catch(e) {
      _errorMsg = e.message;
      user = null;
    }

    if (user != null) {
      setState(() {
        _success = true;
        _userEmail = user.email;
      });

      widget.signIn(user, widget.register);
    } else {
      _success = false;
    }
  }
}