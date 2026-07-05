// lib/pages/register_page.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _contactController = TextEditingController(); 
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  
  // Tasker fields
  final _categoryController = TextEditingController();
  final _rateController = TextEditingController();
  final _experienceController = TextEditingController();

  String _selectedRole = 'customer';
  bool _otpSent = false;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  bool _isPhoneNumber(String text) => text.length == 10 && int.tryParse(text) != null;
  bool _isEmail(String text) => RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(text);

  void _sendVerification() async {
    final contactText = _contactController.text.trim();
    if (!_isPhoneNumber(contactText) && !_isEmail(contactText)) {
      _showSnack('Please enter a valid 10-digit mobile number OR email address.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _apiService.sendVerificationCode(contactText);
      setState(() { _otpSent = true; _isLoading = false; });
      _showSnack('Verification code sent to $contactText!');
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack(e.toString(), isError: true);
    }
  }

  void _completeRegistration() async {
    if (_otpController.text.length != 4) {
      _showSnack('Please enter the 4-digit verification code.', isError: true);
      return;
    }

    final contactText = _contactController.text.trim();
    final isPhone = _isPhoneNumber(contactText);
    setState(() => _isLoading = true);

    try {
      await _apiService.registerUser(
        name: _nameController.text.trim(),
        email: isPhone ? "" : contactText,
        phone: isPhone ? contactText : "",
        password: _passwordController.text,
        role: _selectedRole,
        otp: _otpController.text.trim(),
        category: _selectedRole == 'tasker' ? _categoryController.text.trim() : null,
        rate: _selectedRole == 'tasker' ? _rateController.text.trim() : null,
        experience: _selectedRole == 'tasker' ? _experienceController.text.trim() : null,
      );

      if (mounted) {
        _showSnack('Account created successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack(e.toString(), isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: const Text('Create Account', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Join TaskGhar',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1A1D1E)),
              ),
              const SizedBox(height: 6),
              Text(
                'Connect with trusted local experts or start earning today.',
                style: TextStyle(color: Colors.grey[600], fontSize: 15),
              ),
              const SizedBox(height: 24),

              if (!_otpSent) ...[
                const Text('I want to:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        title: 'Hire Experts',
                        subtitle: 'Customer',
                        icon: Icons.person_search_rounded,
                        isSelected: _selectedRole == 'customer',
                        onTap: () => setState(() => _selectedRole = 'customer'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoleCard(
                        title: 'Offer Services',
                        subtitle: 'Tasker',
                        icon: Icons.handyman_rounded,
                        isSelected: _selectedRole == 'tasker',
                        onTap: () => setState(() => _selectedRole = 'tasker'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Account Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),

                    _ModernInput(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Kamal Bhattarai',
                      icon: Icons.person_outline_rounded,
                      enabled: !_otpSent,
                    ),
                    const SizedBox(height: 16),

                    _ModernInput(
                      controller: _contactController,
                      label: 'Mobile Number OR Email',
                      hint: '98XXXXXXXX or name@email.com',
                      icon: Icons.alternate_email_rounded,
                      enabled: !_otpSent,
                    ),
                    const SizedBox(height: 16),

                    _ModernInput(
                      controller: _passwordController,
                      label: 'Create Password',
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      enabled: !_otpSent,
                    ),

                    if (_selectedRole == 'tasker' && !_otpSent) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(height: 1),
                      ),
                      const Text('Professional Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),
                      _ModernInput(
                        controller: _categoryController,
                        label: 'Service Category',
                        hint: 'e.g., Plumbing, Electrician',
                        icon: Icons.category_outlined,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _ModernInput(
                              controller: _rateController,
                              label: 'Rate / Hour',
                              hint: 'Rs. 500',
                              icon: Icons.payments_outlined,
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ModernInput(
                              controller: _experienceController,
                              label: 'Experience',
                              hint: 'e.g. 3 Years',
                              icon: Icons.work_history_outlined,
                              isNumber: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (!_otpSent)
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E35B1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Continue to Verify', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                )
              else ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF7ED),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF81C784)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.mark_email_read_rounded, size: 40, color: Color(0xFF2E7D32)),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter Verification Code',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1B5E20)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'We sent a 4-digit code to confirm your contact info.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.green[800], fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 26, letterSpacing: 12, fontWeight: FontWeight.w800),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _completeRegistration,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                              : const Text('Complete Registration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => setState(() { _otpSent = false; _otpController.clear(); }),
                        child: Text('Wrong info? Go back', style: TextStyle(color: Colors.green[900], fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEDE7F6) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF5E35B1) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF5E35B1) : Colors.grey[600], size: 28),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: isSelected ? const Color(0xFF5E35B1) : Colors.black87)),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class _ModernInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final bool isNumber;
  final bool enabled;

  const _ModernInput({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.isNumber = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: isPassword,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(icon, size: 20, color: Colors.grey[600]),
            filled: true,
            fillColor: enabled ? const Color(0xFFF9FAFB) : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF5E35B1), width: 1.5)),
          ),
        ),
      ],
    );
  }
}