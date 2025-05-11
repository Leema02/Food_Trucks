import 'package:flutter/material.dart';
import 'package:myapp/screens/auth/login/login.dart';
import 'package:myapp/screens/auth/widgets/auth_background.dart';
import 'package:myapp/screens/auth/widgets/auth_card.dart';
import 'package:myapp/screens/auth/widgets/auth_buttons.dart';
import 'package:myapp/screens/auth/widgets/sign_up_bar.dart';
import 'package:myapp/screens/auth/widgets/responsive.dart';
import 'package:myapp/core/services/auth_service.dart';
import 'package:easy_localization/easy_localization.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _showPassword = false;
  String _selectedRole = 'customer';

  Widget buildStyledTextField({
    required String hint,
    TextInputType? type,
    bool obscure = false,
    TextEditingController? controller,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.deepOrange),
        ),
        suffixIcon: suffixIcon,
      ),
      validator: validator ??
          (value) =>
              value == null || value.isEmpty ? 'This field is required' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: Responsive(
          mobile: _buildForm(context, 20, double.infinity, true, true),
          tablet: _buildForm(context, 40, 500, true, false),
          desktop: _buildForm(context, 80, 600, false, false),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, double horizontalPadding,
      double formWidth, bool isMobile, bool scrollEnabled) {
    final formContent = Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        mainAxisAlignment:
            isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if (!isMobile)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 150),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Image.asset('assets/image/truckLogo.png', height: 300),
                ),
              ),
            ),
          Expanded(
            flex: isMobile ? 1 : 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMobile)
                  Image.asset('assets/image/truckLogo.png', height: 120),
                SizedBox(
                  width: formWidth,
                  child: AuthCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SignUpBar(isLoginPage: false),
                          const SizedBox(height: 13),
                          buildStyledTextField(
                              hint: 'fname'.tr(),
                              controller: _firstNameController),
                          const SizedBox(height: 8),
                          buildStyledTextField(
                              hint: 'lname'.tr(),
                              controller: _lastNameController),
                          const SizedBox(height: 8),
                          buildStyledTextField(
                            hint: 'email'.tr(),
                            controller: _emailController,
                            type: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'pleaseentervalidemail'.tr();
                              if (!value.contains('@'))
                                return 'invalidemailformat'.tr();
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          buildStyledTextField(
                            hint: "username".tr(),
                            controller: _usernameController,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'pleaseenterausername'.tr();
                              if (value.contains(' '))
                                return 'usernameshouldnotcontainspaces'.tr();
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          buildStyledTextField(
                              hint: 'phone'.tr(),
                              controller: _phoneController,
                              type: TextInputType.phone),
                          const SizedBox(height: 8),
                          buildStyledTextField(
                              hint: 'city'.tr(), controller: _cityController),
                          const SizedBox(height: 8),
                          buildStyledTextField(
                              hint: 'address'.tr(),
                              controller: _addressController),
                          const SizedBox(height: 10),

                          /// Role Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            decoration: InputDecoration(
                              labelText: 'selectrole'.tr(),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.deepOrange),
                              ),
                            ),
                            items: [
                              DropdownMenuItem(
                                  value: 'customer',
                                  child: Text('customer'.tr())),
                              DropdownMenuItem(
                                  value: 'truck owner',
                                  child: Text('truckowner'.tr())),
                            ],
                            onChanged: (value) =>
                                setState(() => _selectedRole = value!),
                          ),

                          const SizedBox(height: 8),
                          buildStyledTextField(
                            hint: 'password'.tr(),
                            obscure: !_showPassword,
                            controller: _passwordController,
                            suffixIcon: IconButton(
                              icon: Icon(_showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () => setState(
                                  () => _showPassword = !_showPassword),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'pleaseenterpassword'.tr()
                                : null,
                          ),
                          const SizedBox(height: 15),
                          AuthButton(
                            text: 'signup'.tr(),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final userData = {
                                  "F_name": _firstNameController.text.trim(),
                                  "L_name": _lastNameController.text.trim(),
                                  "email_address": _emailController.text.trim(),
                                  "username": _usernameController.text.trim(),
                                  "phone_num": _phoneController.text.trim(),
                                  "city": _cityController.text.trim(),
                                  "address": _addressController.text.trim(),
                                  "password": _passwordController.text.trim(),
                                  "role_id": _selectedRole,
                                };

                                final response =
                                    await AuthService.signup(userData);

                                if (response.statusCode == 200) {
                                  _firstNameController.clear();
                                  _lastNameController.clear();
                                  _emailController.clear();
                                  _usernameController.clear();
                                  _phoneController.clear();
                                  _cityController.clear();
                                  _addressController.clear();
                                  _passwordController.clear();

                                  await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      content: const Text(
                                          "✅ Verification email sent!",
                                          textAlign: TextAlign.center),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                        "❌ Signup failed: ${response.body}"),
                                  ));
                                }
                              } else {
                                print("❌ Form has errors");
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          AuthSwitchButton(
                            text: "alreadyhaveanaccount".tr(),
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage())),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ],
      ),
    );

    return scrollEnabled
        ? SingleChildScrollView(child: formContent)
        : formContent;
  }
}
