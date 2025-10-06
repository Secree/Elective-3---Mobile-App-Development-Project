import 'package:flutter/material.dart';
import '../db/user_db.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
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

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final db = UserDatabase.instance;
    final existing = await db.getUserByEmail(_emailCtrl.text.trim());
    if (existing != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email already registered')));
      setState(() => _loading = false);
      return;
    }
    await db.createUser(User(email: _emailCtrl.text.trim(), password: _passCtrl.text));
    setState(() => _loading = false);
    Navigator.of(context).pop(true); // return to login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
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
                  : ElevatedButton(onPressed: _signup, child: const Text('Create account'))
            ],
          ),
        ),
      ),
    );
  }
}
