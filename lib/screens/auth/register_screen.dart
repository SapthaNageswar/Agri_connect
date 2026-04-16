// screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:agriconnect/providers/auth_provider.dart';
import 'package:agriconnect/utils/app_theme.dart';
import 'package:agriconnect/services/location_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _role = 'farmer';
  bool _isLocating = false;

  Future<void> _fetchLocation() async {
    setState(() => _isLocating = true);
    try {
      final loc = await LocationService.getCurrentLocation();
      if (loc != null) {
        setState(() {
          _cityCtrl.text = loc['city'] ?? '';
          _stateCtrl.text = loc['state'] ?? '';
          _locationCtrl.text = loc['location'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name: _nameCtrl.text.trim(),
      mobile: _mobileCtrl.text.trim(),
      password: _passCtrl.text,
      role: _role,
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
    );
    if (mounted && success) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryDark),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create account',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.primaryDark)),
              const SizedBox(height: 4),
              const Text('Join AgriConnect to start farming smarter',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
              const SizedBox(height: 28),

              _label('Full Name'),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(hintText: 'Ramesh Kumar'),
                validator: (v) => v == null || v.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),

              _label('Mobile Number'),
              TextFormField(
                controller: _mobileCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: '9876543210'),
                validator: (v) => v == null || v.length < 10 ? 'Enter valid mobile number' : null,
              ),
              const SizedBox(height: 16),

              _label('Password'),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Minimum 6 characters'),
                validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('City'),
                        TextFormField(
                          controller: _cityCtrl,
                          decoration: const InputDecoration(hintText: 'Nashik'),
                          validator: (v) => v == null || v.isEmpty ? 'City is needed' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('State'),
                        TextFormField(
                          controller: _stateCtrl,
                          decoration: const InputDecoration(hintText: 'Maharashtra'),
                          validator: (v) => v == null || v.isEmpty ? 'State is needed' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _label('Detailed Location (Village/Landmark)'),
              TextFormField(
                controller: _locationCtrl,
                decoration: InputDecoration(
                  hintText: 'e.g. Near Kaluram High School',
                  suffixIcon: _isLocating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.my_location, color: AppTheme.primary),
                          onPressed: _fetchLocation,
                        ),
                ),
              ),
              const SizedBox(height: 16),

              _label('I am a'),
              Row(
                children: [
                  _roleChip('Farmer', '🌾', 'farmer'),
                  const SizedBox(width: 12),
                  _roleChip('Buyer', '🛒', 'buyer'),
                ],
              ),
              const SizedBox(height: 28),

              Consumer<AuthProvider>(
                builder: (_, auth, __) => Column(
                  children: [
                    ElevatedButton(
                      onPressed: auth.isLoading ? null : _register,
                      child: auth.isLoading
                          ? const SizedBox(height: 20, width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Create Account'),
                    ),
                    if (auth.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(auth.error!,
                            style: const TextStyle(color: AppTheme.error, fontSize: 13)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Already have an account? Login',
                      style: TextStyle(color: AppTheme.primary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[800])),
      );

  Widget _roleChip(String label, String emoji, String value) => GestureDetector(
        onTap: () => setState(() => _role = value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: _role == value ? AppTheme.primaryLight : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _role == value ? AppTheme.primary : AppTheme.border,
              width: _role == value ? 1.5 : 1,
            ),
          ),
          child: Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _role == value ? AppTheme.primary : AppTheme.textPrimary,
            )),
          ]),
        ),
      );
}
