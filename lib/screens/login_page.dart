import 'package:flutter/material.dart';
import '../services/auth_service.dart';

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
  bool _obscurePassword = true;

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
    
    final authService = AuthService.instance;
    final ok = await authService.login(_emailCtrl.text.trim(), _passCtrl.text);
    
    setState(() => _loading = false);
    if (ok) {
      if (mounted) {
        Navigator.of(context)
            .pushReplacementNamed('/home', arguments: _emailCtrl.text.trim());
      }
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
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 600;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      Text('Login',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: isSmallScreen ? 20 : null,
                          )),
                      SizedBox(height: isSmallScreen ? 12 : 20),
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
                    SizedBox(height: isSmallScreen ? 8 : 10),
                    TextFormField(
                      controller: _passCtrl,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter password';
                        // If login attempt failed, show its error here.
                        if (_loginError != null) return _loginError;
                        if (v.length < 4) return 'Invalid credentials';
                        return null;
                      },
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 20),
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
      ),
    );
  }
}
