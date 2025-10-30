import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../services/user_storage_service.dart';
import '../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final UserStorageService _userService = UserStorageService();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Initialize user service
      await _userService.initializeUsers();
      
      // Check if username already exists
      final existingUser = _userService.getUserByUsername(_usernameController.text.trim());
      if (existingUser != null) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tên đăng nhập đã tồn tại. Vui lòng chọn tên khác.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create new user
      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: _usernameController.text.trim(),
        email: '', // Empty for simplicity
        password: _passwordController.text,
        role: 'user', // Default role
        fullName: _usernameController.text.trim(), // Use username as full name
        phone: '', // Empty for simplicity
        avatar: '',
        isActive: true,
        isLocked: false,
        createdAt: DateTime.now().toIso8601String(),
        lastLogin: null,
        loginCount: 0,
        notes: 'Người dùng mới đăng ký',
      );

      // Add user to service
      final success = await _userService.addUser(newUser);
      
      setState(() {
        _isLoading = false;
      });

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký thành công! Bạn có thể đăng nhập ngay.'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to login
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi khi lưu tài khoản. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi đăng ký: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng Ký'),
  backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Quay lại',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Section
                Card(
                  elevation: 4,
                  color: const Color(0xFF2196F3),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_add,
                          size: 60,
                          color: const Color(0xFF2196F3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tạo tài khoản mới',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: const Color(0xFF2196F3),
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Đăng ký đơn giản chỉ với tên đăng nhập và mật khẩu',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Username Field
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên đăng nhập *',
                    hintText: 'Nhập tên đăng nhập của bạn',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên đăng nhập';
                    }
                    if (value.trim().length < 3) {
                      return 'Tên đăng nhập phải có ít nhất 3 ký tự';
                    }
                    if (value.trim().length > 20) {
                      return 'Tên đăng nhập không được quá 20 ký tự';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
                      return 'Tên đăng nhập chỉ được chứa chữ cái, số và dấu gạch dưới';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu *',
                    hintText: 'Nhập mật khẩu của bạn',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    if (value.length > 50) {
                      return 'Mật khẩu không được quá 50 ký tự';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Xác nhận mật khẩu *',
                    hintText: 'Nhập lại mật khẩu',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng xác nhận mật khẩu';
                    }
                    if (value != _passwordController.text) {
                      return 'Mật khẩu xác nhận không khớp';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Register Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Đăng Ký'),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Help Text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2196F3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: const Color(0xFF2196F3), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Hướng dẫn đăng ký:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2196F3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Tên đăng nhập: 3-20 ký tự, chỉ chữ cái, số và dấu gạch dưới\n'
                        '• Mật khẩu: ít nhất 6 ký tự\n'
                        '• Đơn giản và dễ nhớ cho người lớn tuổi',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Back to Login
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Quay lại đăng nhập'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2196F3),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}