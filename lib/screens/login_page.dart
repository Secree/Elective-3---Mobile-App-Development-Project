import 'package:flutter/material.dart';
import '../db/user_db.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _loginError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _loginError = null; // reset error before checking
    });
    final db = UserDatabase.instance;
    final ok = await db.validateUser(_emailCtrl.text.trim(), _passCtrl.text);
    setState(() => _loading = false);
    if (ok) {
      Navigator.of(context)
          .pushReplacementNamed('/home', arguments: _emailCtrl.text.trim());
    } else {
      // Instead of showing a SnackBar, show an inline validation error under
      // the password field.
      setState(() {
        _loginError = 'Invalid credentials';
      });
      // Re-run validators so the password field displays the error.
      _formKey.currentState!.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/');
          },
        ),
        title: const Text('Login'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/image/bg-airplane.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    Text('Login',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Enter email' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _passCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter password';
                        // If login attempt failed, show its error here.
                        if (_loginError != null) return _loginError;
                        if (v.length < 4) return 'Invalid credentials';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _loading
                        ? const CircularProgressIndicator()
                        : Column(
                            children: [
                              FilledButton(
                                onPressed: _login,
                                child: const Text('Login'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final res = await Navigator.of(context)
                                      .pushNamed('/signup');
                                  if (res == true) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text(
                                          'Account created, please login'),
                                    ));
                                  }
                                },
                                child: const Text('Create an account'),
                              )
                            ],
                          )
                  ],
                ),
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}
