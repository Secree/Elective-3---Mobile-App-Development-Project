import 'package:flutter/material.dart';
import '../db/user_db.dart';
import '../utils/security_helper.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _middleInitialCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _middleInitialCtrl.dispose();
    _addressCtrl.dispose();
    _ageCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final db = UserDatabase.instance;
    final existing = await db.getUserByEmail(_emailCtrl.text.trim());
    if (existing != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email already registered')));
      setState(() => _loading = false);
      return;
    }
    
    try {
      // Hash the password before storing
      final hashedPassword = SecurityHelper.hashPassword(_passCtrl.text);
      
      await db.createUser(
        User(
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          middleInitial: _middleInitialCtrl.text.trim().isEmpty 
              ? null 
              : _middleInitialCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          age: int.parse(_ageCtrl.text.trim()),
          email: _emailCtrl.text.trim(),
          password: hashedPassword,
        ),
      );
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
        Navigator.of(context).pop(true); // return to login
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating account: $e')),
        );
      }
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
        title: const Text('Sign Up'),
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
                    Text('Create Account',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 20),
                    // First Name
                    TextFormField(
                      controller: _firstNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Enter first name' : null,
                    ),
                    const SizedBox(height: 10),
                    // Last Name
                    TextFormField(
                      controller: _lastNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Enter last name' : null,
                    ),
                    const SizedBox(height: 10),
                    // Middle Initial (Optional)
                    TextFormField(
                      controller: _middleInitialCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Middle Initial (Optional)',
                        prefixIcon: Icon(Icons.text_fields),
                        border: OutlineInputBorder(),
                      ),
                      maxLength: 1,
                    ),
                    const SizedBox(height: 10),
                    // Address
                    TextFormField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        prefixIcon: Icon(Icons.home),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Enter address' : null,
                    ),
                    const SizedBox(height: 10),
                    // Age
                    TextFormField(
                      controller: _ageCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                        helperText: 'Must be 18 or older',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Enter age';
                        }
                        final age = int.tryParse(v.trim());
                        if (age == null) {
                          return 'Enter a valid number';
                        }
                        if (age < 18) {
                          return 'Must be at least 18 years old';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Enter email';
                        }
                        if (!v.contains('@') || !v.contains('.')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    // Password
                    TextFormField(
                      controller: _passCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (v) => (v == null || v.length < 4)
                          ? 'Password must be at least 4 characters'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    // Confirm Password
                    TextFormField(
                      controller: _confirmPassCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Confirm your password';
                        }
                        if (v != _passCtrl.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _loading
                        ? const CircularProgressIndicator()
                        : FilledButton(
                            onPressed: _signup,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text('Create account'),
                          ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Already have an account? Login'),
                    ),
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
