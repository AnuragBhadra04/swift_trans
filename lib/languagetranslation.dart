import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class LanguagetraslationPage extends StatefulWidget {
  const LanguagetraslationPage({super.key});

  @override
  State<LanguagetraslationPage> createState() => _LanguagetraslationPageState();
}

class _LanguagetraslationPageState extends State<LanguagetraslationPage> {
  final GoogleTranslator _translator = GoogleTranslator();
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();

  String _output = '';
  String _originLanguage = 'Auto';
  String _destinationLanguage = 'English';
  bool _isLoading = false;

  /// Voice input
  late stt.SpeechToText _speech;
  bool _isListening = false;

  /// Reviews
  final List<Map<String, dynamic>> _reviews = [];
  double _currentRating = 3.0;

  final Map<String, String> _languageCodes = const {
    'Auto': 'auto',
    'English': 'en',
    'Hindi': 'hi',
    'Arabic': 'ar',
    'Odia': 'or',
    'Spanish': 'es',
    'French': 'fr',
    'German': 'de',
    'Japanese': 'ja',
    'Russian': 'ru',
    'Chinese (Simplified)': 'zh-cn',
    'Bengali': 'bn',
    'Portuguese': 'pt',
    'Korean': 'ko',
    'Italian': 'it',
    'Turkish': 'tr',
    'Vietnamese': 'vi',
    'Thai': 'th',
    'Swahili': 'sw',
    'Dutch': 'nl',
    'Greek': 'el',
    'Hebrew': 'he',
    'Polish': 'pl',
    'Swedish': 'sv',
    'Finnish': 'fi',
    'Norwegian': 'no',
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  /// Translation
  void _translate() async {
    final String srcCode = _languageCodes[_originLanguage] ?? 'auto';
    final String destCode = _languageCodes[_destinationLanguage] ?? 'en';
    final String inputText = _languageController.text;

    if (inputText.isEmpty) {
      setState(() => _output = 'Please enter text to translate.');
      return;
    }

    if (srcCode == destCode) {
      setState(
        () => _output = 'Source and destination languages cannot be the same.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _output = '';
    });

    try {
      final translation = await _translator.translate(
        inputText,
        from: srcCode,
        to: destCode,
      );
      setState(() => _output = translation.text);
    } catch (e) {
      setState(
        () => _output =
            'Failed to translate. Please check your internet connection.',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Swap languages
  void _swapLanguages() {
    setState(() {
      if (_originLanguage == 'Auto') {
        _output = 'Cannot swap "Auto" language.';
        return;
      }
      final temp = _originLanguage;
      _originLanguage = _destinationLanguage;
      _destinationLanguage = temp;
    });
  }

  /// Start/Stop Voice Input
  Future<void> _listen() async {
    // ✅ ask for mic permission first
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Microphone permission required")),
      );
      return;
    }

    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _languageController.text = val.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  /// Add a review
  void _addReview() {
    if (_reviewController.text.isEmpty) return;

    setState(() {
      _reviews.add({'rating': _currentRating, 'text': _reviewController.text});
      _reviewController.clear();
      _currentRating = 3.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      appBar: AppBar(
        title: const Text(
          "Swift Translator",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Language Selection UI
              Row(
                children: [
                  Expanded(
                    child: _buildLanguageDropdown(
                      value: _originLanguage,
                      onChanged: (String? newValue) {
                        setState(() => _originLanguage = newValue!);
                      },
                      languages: _languageCodes.keys.toList(),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: IconButton(
                      icon: const Icon(
                        Icons.swap_horiz,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: _swapLanguages,
                      tooltip: 'Swap languages',
                    ),
                  ),
                  Expanded(
                    child: _buildLanguageDropdown(
                      value: _destinationLanguage,
                      onChanged: (String? newValue) {
                        setState(() => _destinationLanguage = newValue!);
                      },
                      languages: _languageCodes.keys
                          .where((lang) => lang != 'Auto')
                          .toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Input Text Field + Voice Button
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: const Color(0xFF333333),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _languageController,
                          maxLines: 5,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter text or use voice...',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: _listen,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Translate Button
              ElevatedButton.icon(
                onPressed: _translate,
                icon: const Icon(
                  Icons.g_translate_outlined,
                  color: Colors.white,
                ),
                label: const Text(
                  'Translate',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF673AB7),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Output Display
              if (_isLoading)
                const CircularProgressIndicator(color: Color(0xFF673AB7))
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    _output.isEmpty
                        ? 'Translation will appear here...'
                        : _output,
                    style: TextStyle(
                      color: _output.isEmpty ? Colors.white54 : Colors.white,
                      fontSize: 20,
                      fontStyle: _output.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 40),

              // Review Section
              const Text(
                "User Reviews",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Review Input
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _currentRating,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: _currentRating.toString(),
                      onChanged: (val) => setState(() => _currentRating = val),
                    ),
                  ),
                  Text(
                    "${_currentRating.toStringAsFixed(1)} ★",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
              TextField(
                controller: _reviewController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Write a review...",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: const Color(0xFF333333),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF333333),
                ),
                child: const Text("Submit Review"),
              ),

              const SizedBox(height: 20),

              // Display Reviews
              ..._reviews.map((review) {
                return Card(
                  color: const Color(0xFF333333),
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    title: Text(
                      "${review['rating']} ★",
                      style: const TextStyle(color: Colors.amber),
                    ),
                    subtitle: Text(
                      review['text'],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  /// Dropdown builder
  Widget _buildLanguageDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
    required List<String> languages,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF673AB7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          isExpanded: true,
          dropdownColor: const Color(0xFF673AB7),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          items: languages.map((String lang) {
            return DropdownMenuItem<String>(
              value: lang,
              child: Text(lang, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
        ),
      ),
    );
  }
}
