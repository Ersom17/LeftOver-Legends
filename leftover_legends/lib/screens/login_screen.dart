import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoginMode = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
  if (_emailController.text.trim().isEmpty ||
      _passwordController.text.trim().isEmpty) {
    return;
  }

  if (isLoginMode) {
    await ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
    ref.invalidate(itemsProvider);
  } else {
    if (_nameController.text.trim().isEmpty) return;

    await ref.read(authProvider.notifier).register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
    ref.invalidate(itemsProvider);
  }
}

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (_, next) {
      if (next.hasValue && next.value != null) {
        context.go('/fridge');
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF1A1F1C),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3D7A56), Color(0xFF5C9E6E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text('🌱', style: TextStyle(fontSize: 36)),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Leftover Legends',
                  style: TextStyle(
                    color: Color(0xFF7FAF8A),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your fridge, your legacy.',
                  style: TextStyle(
                    color: Color(0xFFF5EFE0),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                if (!isLoginMode) ...[
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Color(0xFFF5EFE0)),
                    decoration: _inputDecoration('Name'),
                  ),
                  const SizedBox(height: 12),
                ],

                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Color(0xFFF5EFE0)),
                  decoration: _inputDecoration('Email'),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Color(0xFFF5EFE0)),
                  decoration: _inputDecoration('Password'),
                ),
                const SizedBox(height: 20),

                if (authState.hasError) ...[
                  Text(
                    authState.error.toString(),
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: authState.isLoading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF5C9E6E),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isLoginMode ? 'Sign in' : 'Register',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: authState.isLoading
                        ? null
                        : () {
                            setState(() {
                              isLoginMode = !isLoginMode;
                            });
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF7FAF8A),
                      side: const BorderSide(color: Color(0xFF7FAF8A)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      isLoginMode
                          ? 'No account? Register'
                          : 'Already have an account? Sign in',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF6E7D74)),
        filled: true,
        fillColor: const Color(0xFF232B25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E3830)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E3830)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5C9E6E)),
        ),
      );
}