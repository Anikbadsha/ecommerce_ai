import 'package:ecommerce_ai/features/auth/controller/auth_controller.dart';
import 'package:ecommerce_ai/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 60),

              const Text(
                "Welcome Back 👋",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Login to continue shopping",
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

              // LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed: () async {
                    final error =
                        await auth.login(
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
                              // ignore: use_build_context_synchronously
                              context)
                          .showSnackBar(
                        SnackBar(
                          content:
                              Text(error),
                        ),
                      );
                    }
                  },

                  child: const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // GOOGLE LOGIN
              SizedBox(
                width: double.infinity,
                height: 55,

                child: OutlinedButton.icon(
                  onPressed: () async {
                    final error =
                        await auth
                            .signInWithGoogle();

                    if (error != null) {
                      ScaffoldMessenger.of(
                              context)
                          .showSnackBar(
                        SnackBar(
                          content:
                              Text(error),
                        ),
                      );
                    }
                  },

                  icon: const Icon(
                    Icons.g_mobiledata,
                    size: 32,
                  ),

                  label: const Text(
                    "Continue with Google",
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // REGISTER NAVIGATION
              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,

                children: [
                  const Text(
                    "Don't have an account?",
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const RegisterScreen(),
                        ),
                      );
                    },

                    child: const Text(
                      "Register",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}