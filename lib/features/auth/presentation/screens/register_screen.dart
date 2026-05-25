import 'package:ecommerce_ai/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    final auth =
        Provider.of<AuthController>(context);

    return Scaffold(
      appBar: AppBar(),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 40),

              const Text(
                "Create Account 🚀",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Register to start shopping",
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 40),

              // EMAIL
              TextField(
                controller:
                    emailController,

                decoration:
                    InputDecoration(
                  hintText: "Email",

                  prefixIcon:
                      const Icon(
                    Icons.email_outlined,
                  ),

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // PASSWORD
              TextField(
                controller:
                    passwordController,

                obscureText: obscure,

                decoration:
                    InputDecoration(
                  hintText: "Password",

                  prefixIcon:
                      const Icon(
                    Icons.lock_outline,
                  ),

                  suffixIcon:
                      IconButton(
                    onPressed: () {
                      setState(() {
                        obscure =
                            !obscure;
                      });
                    },
                    icon: Icon(
                      obscure
                          ? Icons
                              .visibility
                          : Icons
                              .visibility_off,
                    ),
                  ),

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // REGISTER BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed: () async {
                    final error =
                        await auth.register(
                      email:
                          emailController
                              .text
                              .trim(),

                      password:
                          passwordController
                              .text
                              .trim(),
                    );

                    if (error != null) {
                      ScaffoldMessenger.of(
                              context)
                          .showSnackBar(
                        SnackBar(
                          content:
                              Text(error),
                        ),
                      );
                    } else {
                      Navigator.pop(
                          context);
                    }
                  },

                  child: const Text(
                    "Register",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}