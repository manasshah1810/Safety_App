import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'main.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enhanced Login Signup',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SafetyApp(),
    );
  }
}

class LoginSignupPage extends StatefulWidget {
  @override
  _LoginSignupPageState createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  bool isLogin = true;

  // Controllers for text fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLogin ? 'Login Form' : 'Signup Form',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: emailController,
                  label: 'Email Address',
                  icon: Icons.email,
                ),
                SizedBox(height: 15),
                _buildTextField(
                  controller: passwordController,
                  label: 'Password',
                  icon: Icons.lock,
                  isObscure: true,
                ),
                if (!isLogin) ...[
                  SizedBox(height: 15),
                  _buildTextField(
                    controller: confirmPasswordController,
                    label: 'Confirm Password',
                    icon: Icons.lock,
                    isObscure: true,
                  ),
                ],
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    String email = emailController.text;
                    String password = passwordController.text;
                    if (isLogin) {
                      // Simulate login
                      if (email == 'test@example.com' &&
                          password == 'password123') {
                        // Successfully logged in
                        print('Login successful!');
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                        );
                        // Here you can navigate to ProfileInputPage after login if needed
                      } else {
                        // Failed login
                        print('Invalid email or password.');
                      }
                    } else {
                      // Simulate signup
                      if (password == confirmPasswordController.text) {
                        _signup(context);
                      } else {
                        print('Passwords do not match.');
                      }
                    }
                  },
                  child: Text(isLogin ? 'Login' : 'Signup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin; // Toggle between login and signup
                    });
                  },
                  child: Text(
                    isLogin
                        ? 'Not a member? Signup now'
                        : 'Already a member? Login',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
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

  void _signup(BuildContext context) async {
    String email = emailController.text; // Get email from the input
    String password = passwordController.text; // Get password from the input

    // Simulate a signup process
    bool signupSuccess =
        await _createUser(email, password); // Replace with your signup logic

    if (signupSuccess) {
      // Navigate to the ProfileInputPage upon successful signup
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => ProfileInputPage()),
      );
    } else {
      // Handle signup failure
      _showErrorDialog(context, 'Signup failed. Please try again.');
    }
  }

  Future<bool> _createUser(String email, String password) async {
    // Simulate a delay for signup (replace with actual signup logic)
    await Future.delayed(Duration(seconds: 1));
    return true; // Simulate success
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isObscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.blueGrey, width: 1),
        ),
      ),
    );
  }
}

class ProfileInputPage extends StatefulWidget {
  @override
  _ProfileInputPageState createState() => _ProfileInputPageState();
}

class _ProfileInputPageState extends State<ProfileInputPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _emergencyContact1NameController =
      TextEditingController();
  final TextEditingController _emergencyContact1PhoneController =
      TextEditingController();
  final TextEditingController _emergencyContact2NameController =
      TextEditingController();
  final TextEditingController _emergencyContact2PhoneController =
      TextEditingController();

  String? _chronicDisease;
  String? _gender;

  // Remove this function entirely
  // Future<bool> _saveDataToJsonFile() async { ... }

  void _submitData() {
    // Validate the form inputs
    if (_formKey.currentState!.validate()) {
      // Instead of saving data, just navigate to the login page
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginSignupPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Input'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Text(
                      'Please Fill Your Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Name',
                      icon: Icons.person,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      validator: (value) {
                        if (value!.isEmpty ||
                            !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _emergencyContact1NameController,
                      label: 'Emergency Contact 1 Name',
                      icon: Icons.person,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _emergencyContact1PhoneController,
                      label: 'Emergency Contact 1 Phone',
                      icon: Icons.phone,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _emergencyContact2NameController,
                      label: 'Emergency Contact 2 Name',
                      icon: Icons.person,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _emergencyContact2PhoneController,
                      label: 'Emergency Contact 2 Phone',
                      icon: Icons.phone,
                    ),
                    SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Gender',
                      items: ['Male', 'Female', 'Other'],
                      onChanged: (newValue) {
                        setState(() {
                          _gender = newValue;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Do you have any chronic disease?',
                      items: ['Yes', 'No'],
                      onChanged: (newValue) {
                        setState(() {
                          _chronicDisease = newValue;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitData,
                      child: Text('Submit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      value: null,
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}