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

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final db = UserDatabase.instance;
    final ok = await db.validateUser(_emailCtrl.text.trim(), _passCtrl.text);
    setState(() => _loading = false);
    if (ok) {
      Navigator.of(context).pushReplacementNamed('/home', arguments: _emailCtrl.text.trim());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => (v == null || v.isEmpty) ? 'Enter email' : null,
              ),
              TextFormField(
                controller: _passCtrl,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => (v == null || v.length < 4) ? 'Password min 4 chars' : null,
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        ElevatedButton(onPressed: _login, child: const Text('Login')),
                        TextButton(
                          onPressed: () async {
                            final res = await Navigator.of(context).pushNamed('/signup');
                            if (res == true) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created, please login')));
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
    );
  }
}
