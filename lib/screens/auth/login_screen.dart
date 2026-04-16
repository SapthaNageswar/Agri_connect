// screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:agriconnect/providers/auth_provider.dart';
import 'package:agriconnect/utils/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobileCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _mobileCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      mobile: _mobileCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (mounted && success) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo
                Container(
                  width: 72, height: 72,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.eco, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 16),
                const Text('AgriConnect',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.primaryDark)),
                const SizedBox(height: 4),
                const Text('Smart Farming Made Simple',
                    style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                const SizedBox(height: 40),

                // Mobile field
                Align(alignment: Alignment.centerLeft,
                    child: Text('Mobile Number',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[800]))),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _mobileCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(hintText: 'Enter your mobile number'),
                  validator: (v) => v == null || v.isEmpty ? 'Enter mobile number' : null,
                ),
                const SizedBox(height: 16),

                // Password field
                Align(alignment: Alignment.centerLeft,
                    child: Text('Password',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[800]))),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 24),

                // Login button
                Consumer<AuthProvider>(
                  builder: (_, auth, __) => ElevatedButton(
                    onPressed: auth.isLoading ? null : _login,
                    child: auth.isLoading
                        ? const SizedBox(height: 20, width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Login'),
                  ),
                ),

                // Error message
                Consumer<AuthProvider>(
                  builder: (_, auth, __) => auth.error != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(auth.error!,
                              style: const TextStyle(color: AppTheme.error, fontSize: 13)),
                        )
                      : const SizedBox(),
                ),
                const SizedBox(height: 12),

                // Register button
                OutlinedButton(
                  onPressed: () => context.push('/register'),
                  child: const Text('Register'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {},
                  child: const Text('Forgot Password?',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
