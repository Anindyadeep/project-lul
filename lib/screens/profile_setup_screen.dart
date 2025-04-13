import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'verification_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutMeController = TextEditingController();
  final TextEditingController _togetherWeCouldController =
      TextEditingController();
  final TextEditingController _truth1Controller = TextEditingController();
  final TextEditingController _truth2Controller = TextEditingController();
  final TextEditingController _lieController = TextEditingController();
  final TextEditingController _bringsHereController = TextEditingController();
  final TextEditingController _datingGoalsController = TextEditingController();
  final TextEditingController _dislikesController = TextEditingController();

  List<File> _selectedPhotos = [];
  List<File> _videoAnswers = [];
  List<VideoPlayerController?> _videoControllers = [];

  @override
  void initState() {
    super.initState();
    _videoControllers = List.generate(2, (index) => null);
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
    ].request();
  }

  bool _isFormComplete() {
    print('Debug - Form Completion Status:');
    print('Name: ${_nameController.text.isNotEmpty}');
    print(
      'Photos: ${_selectedPhotos.length == 4} (${_selectedPhotos.length} photos)',
    );
    print('About Me: ${_aboutMeController.text.isNotEmpty}');
    print('Together We Could: ${_togetherWeCouldController.text.isNotEmpty}');
    print('Truth 1: ${_truth1Controller.text.isNotEmpty}');
    print('Truth 2: ${_truth2Controller.text.isNotEmpty}');
    print('Lie: ${_lieController.text.isNotEmpty}');
    print('Brings Here: ${_bringsHereController.text.isNotEmpty}');
    print('Dating Goals: ${_datingGoalsController.text.isNotEmpty}');
    print('Dislikes: ${_dislikesController.text.isNotEmpty}');
    print(
      'Videos: ${_videoAnswers.length == 2} (${_videoAnswers.length} videos)',
    );

    return _nameController.text.isNotEmpty &&
        _selectedPhotos.length == 4 &&
        _aboutMeController.text.isNotEmpty &&
        _togetherWeCouldController.text.isNotEmpty &&
        _truth1Controller.text.isNotEmpty &&
        _truth2Controller.text.isNotEmpty &&
        _lieController.text.isNotEmpty &&
        _bringsHereController.text.isNotEmpty &&
        _datingGoalsController.text.isNotEmpty &&
        _dislikesController.text.isNotEmpty &&
        _videoAnswers.length == 2;
  }

  Future<void> _pickPhotos() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        if (images.length > 4) {
          _selectedPhotos =
              images.take(4).map((image) => File(image.path)).toList();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Only the first 4 photos will be selected'),
              backgroundColor: Color(0xFFE91E63),
            ),
          );
        } else {
          _selectedPhotos = images.map((image) => File(image.path)).toList();
        }
      });
    }
  }

  Future<void> _recordVideo() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? video = await picker.pickVideo(source: ImageSource.camera);
      if (video != null) {
        setState(() {
          if (_videoAnswers.length < 2) {
            _videoAnswers.add(File(video.path));
            _initializeVideoPlayer(_videoAnswers.length - 1);
          }
        });
      }
    } catch (e) {
      print('Error recording video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error recording video. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _initializeVideoPlayer(int index) async {
    if (_videoAnswers.length > index) {
      try {
        _videoControllers[index] = VideoPlayerController.file(
          _videoAnswers[index],
        );
        await _videoControllers[index]!.initialize();
        setState(() {});
      } catch (e) {
        print('Error initializing video player: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error playing video. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildVideoThumbnail(File videoFile, int index) {
    if (_videoControllers[index] == null) {
      _initializeVideoPlayer(index);
      return const Center(child: CircularProgressIndicator());
    }

    if (!_videoControllers[index]!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_videoControllers[index]!.value.isPlaying) {
            _videoControllers[index]!.pause();
          } else {
            _videoControllers[index]!.play();
          }
        });
      },
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[200],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: AspectRatio(
                  aspectRatio: _videoControllers[index]!.value.aspectRatio,
                  child: VideoPlayer(_videoControllers[index]!),
                ),
              ),
            ),
            if (!_videoControllers[index]!.value.isPlaying)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.play_circle_filled,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            Positioned(
              right: 8,
              top: 8,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _videoControllers[index]?.dispose();
                    _videoControllers[index] = null;
                    _videoAnswers.removeAt(index);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Color(0xFFE91E63),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToVerification() {
    if (_formKey.currentState!.validate() && _isFormComplete()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const VerificationScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please complete all sections before proceeding. '
            'Photos: ${_selectedPhotos.length}/4, '
            'Videos: ${_videoAnswers.length}/2',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    required String? Function(String?) validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF1A1A1A)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE91E63), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Create Profile",
          style: GoogleFonts.inter(
            color: const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name Section
                _buildSectionTitle("Your Name"),
                _buildTextField(
                  controller: _nameController,
                  label: 'What should we call you?',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),

                // Photos Section
                _buildSectionTitle("Your Photos"),
                Text(
                  'Add 4 photos to show your best self',
                  style: GoogleFonts.inter(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: _pickPhotos,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE91E63),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 24,
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _selectedPhotos.length < 4
                                ? 'Select Photos (${_selectedPhotos.length}/4)'
                                : 'All Photos Selected',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      if (_selectedPhotos.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1,
                                ),
                            itemCount: _selectedPhotos.length,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.file(
                                        _selectedPhotos[index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedPhotos.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Color(0xFFE91E63),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // About Me Section
                _buildSectionTitle("About You"),
                _buildTextField(
                  controller: _aboutMeController,
                  label: 'Tell us about yourself',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please tell us about yourself';
                    }
                    return null;
                  },
                ),

                // Together We Could Section
                _buildSectionTitle("Together We Could"),
                _buildTextField(
                  controller: _togetherWeCouldController,
                  label: 'What would you like to do together?',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please fill this section';
                    }
                    return null;
                  },
                ),

                // Two Truths and One Lie Section
                _buildSectionTitle("Two Truths and One Lie"),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _truth1Controller,
                          label: 'First Truth',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a truth';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          controller: _truth2Controller,
                          label: 'Second Truth',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a truth';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          controller: _lieController,
                          label: 'One Lie',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a lie';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Private Questions Section
                _buildSectionTitle("Private Questions"),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _bringsHereController,
                          label: 'What brings you here?',
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please answer this question';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          controller: _datingGoalsController,
                          label: 'What are your dating goals?',
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please answer this question';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          controller: _dislikesController,
                          label:
                              'What you do not like about current dating platforms?',
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please answer this question';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Video Questions Section
                _buildSectionTitle("Video Questions"),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1. Tell me something about yourself',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_videoAnswers.length > 0)
                          _buildVideoThumbnail(_videoAnswers[0], 0)
                        else
                          ElevatedButton(
                            onPressed: _recordVideo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE91E63),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Record Video',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '2. What do you think an ideal person should be for you?',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_videoAnswers.length > 1)
                          _buildVideoThumbnail(_videoAnswers[1], 1)
                        else
                          ElevatedButton(
                            onPressed:
                                _videoAnswers.length < 1 ? null : _recordVideo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _videoAnswers.length < 1
                                      ? Colors.grey[300]
                                      : const Color(0xFFE91E63),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              _videoAnswers.length < 1
                                  ? 'Complete First Video'
                                  : 'Record Video',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Next Button
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 40),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _navigateToVerification,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor:
                          _isFormComplete()
                              ? const Color(0xFFE91E63)
                              : Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Next, verification',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            _isFormComplete() ? Colors.white : Colors.grey[600],
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

  @override
  void dispose() {
    for (var controller in _videoControllers) {
      controller?.dispose();
    }
    _nameController.dispose();
    _aboutMeController.dispose();
    _togetherWeCouldController.dispose();
    _truth1Controller.dispose();
    _truth2Controller.dispose();
    _lieController.dispose();
    _bringsHereController.dispose();
    _datingGoalsController.dispose();
    _dislikesController.dispose();
    super.dispose();
  }
}
