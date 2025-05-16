import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoggingIn = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Please enter both username and password', true);
      return;
    }

    setState(() {
      _isLoggingIn = true;
    });

    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() {
      _isLoggingIn = false;
    });

    if (success) {
      _showSnackBar('Login successful!', false);
      if (mounted) {
        context.go('/home');
      }
    } else {
      final error = ref.read(authProvider).error ?? 'Login failed';
      _showSnackBar(error, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (previous?.error != next.error && next.error != null) {
        _showSnackBar(next.error!, true);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg_tb.webp'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: const Color.fromRGBO(0, 0, 0, 0.4),
          ),
          Center(
            child: SizedBox(
              width: 380,
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/logo_tb.webp', height: 100),
                      const SizedBox(height: 10),
                      const Text(
                        "Sisfo Sarpras",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Sistem Informasi Sarana dan Prasarana Sekolah",
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _usernameController,
                        obscureText: false,
                        cursorColor: Colors.blue,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(
                                // ignore: deprecated_member_use
                                color: Colors.black.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(
                                // ignore: deprecated_member_use
                                color: Colors.black.withOpacity(0.3)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(color: Colors.blue)),
                          labelText: "Username",
                          labelStyle: const TextStyle(color: Colors.black87),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        cursorColor: Colors.blue,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(
                                // ignore: deprecated_member_use
                                color: Colors.black.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(
                                // ignore: deprecated_member_use
                                color: Colors.black.withOpacity(0.3)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(color: Colors.blue)),
                          labelText: "Password",
                          labelStyle: const TextStyle(color: Colors.black87),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoggingIn ? null : _login,
                        style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            backgroundColor: Colors.blue),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 64, vertical: 8),
                          child: _isLoggingIn
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Login",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Copyright 2025 SMK Taruna Bhakti",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
