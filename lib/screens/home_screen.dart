import 'package:flutter/material.dart';
import 'package:action_slider/action_slider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'profile_setup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _sliderKey = GlobalKey();
  final TextEditingController _inviteController = TextEditingController();

  // Add this method to verify invite code
  bool _verifyInviteCode(String code) {
    // Replace this with your actual verification logic
    return code.trim() == "123456"; // Example code
  }

  void _showErrorToast() {
    Fluttertoast.showToast(
      msg: "Invalid invite code",
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
      gravity: ToastGravity.TOP,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Welcome to DateMe",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _inviteController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter your invite code',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: ActionSlider.standard(
                    key: _sliderKey,
                    width: MediaQuery.of(context).size.width * 0.85,
                    backgroundColor: Colors.grey[100],
                    toggleColor: const Color(0xFFE91E63),
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                    successIcon: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                    ),
                    loadingIcon: const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    failureIcon: const Icon(Icons.close, color: Colors.white),
                    child: const Text(
                      'Slide to create profile',
                      style: TextStyle(
                        color: Color(0xFFE91E63),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    action: (controller) async {
                      controller.loading();
                      await Future.delayed(const Duration(milliseconds: 500));

                      if (_verifyInviteCode(_inviteController.text)) {
                        controller.success();
                        await Future.delayed(const Duration(milliseconds: 500));
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileSetupScreen(),
                            ),
                          ).then((_) {
                            setState(() {
                              controller.reset();
                              _inviteController.clear();
                            });
                          });
                        }
                      } else {
                        controller.failure();
                        _showErrorToast();
                        await Future.delayed(const Duration(seconds: 1));
                        controller.reset();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inviteController.dispose();
    _sliderKey.currentState?.dispose();
    super.dispose();
  }
}
