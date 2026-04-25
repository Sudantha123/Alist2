import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../data/repositories/alist_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController(text: 'http://');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  
  @override
  void dispose() {
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final repo = ref.read(alistRepositoryProvider);
      await repo.login(
        baseUrl: _urlController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      
      if (mounted) {
        context.go('/home/files?path=/');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.background,
              const Color(0xFF1A1A3E),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  
                  // Header
                  _buildHeader(theme)
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.3),
                  
                  const SizedBox(height: 48),
                  
                  // Form fields
                  _buildFormFields(theme)
                      .animate(delay: 200.ms)
                      .fadeIn()
                      .slideY(begin: 0.3),
                  
                  const SizedBox(height: 16),
                  
                  // Error message
                  if (_errorMessage != null)
                    _buildError()
                        .animate()
                        .shake()
                        .fadeIn(),
                  
                  const SizedBox(height: 24),
                  
                  // Login button
                  _buildLoginButton(theme)
                      .animate(delay: 400.ms)
                      .fadeIn()
                      .scale(begin: const Offset(0.9, 0.9)),
                  
                  const SizedBox(height: 24),
                  
                  // Guest login
                  TextButton(
                    onPressed: () {
                      _usernameController.text = 'guest';
                      _passwordController.text = 'guest';
                      _login();
                    },
                    child: Text(
                      'Login as Guest',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  )
                  .animate(delay: 600.ms)
                  .fadeIn(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF3F51B5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.cloud_rounded,
            size: 45,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Welcome Back',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Connect to your Alist server',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
  
  Widget _buildFormFields(ThemeData theme) {
    return Column(
      children: [
        // Server URL
        TextFormField(
          controller: _urlController,
          keyboardType: TextInputType.url,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Server URL',
            labelStyle: const TextStyle(color: Colors.white54),
            hintText: 'https://your-server.com',
            hintStyle: const TextStyle(color: Colors.white24),
            prefixIcon: const Icon(Iconsax.global, color: Color(0xFF6C63FF)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter server URL';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Username
        TextFormField(
          controller: _usernameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Username',
            labelStyle: const TextStyle(color: Colors.white54),
            prefixIcon: const Icon(Iconsax.user, color: Color(0xFF6C63FF)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter username';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Password
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: const TextStyle(color: Colors.white54),
            prefixIcon: const Icon(Iconsax.lock, color: Color(0xFF6C63FF)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                color: Colors.white54,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter password';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFCF6679).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFCF6679).withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFCF6679), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Color(0xFFCF6679), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoginButton(ThemeData theme) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF6C63FF).withOpacity(0.5),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.login, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Connect',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
