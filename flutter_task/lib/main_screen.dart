import 'package:flutter/material.dart';
import 'api_service.dart';
import 'models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sheshya Learning Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _emailController = TextEditingController(text: 'testStudent@sheshya.in');
  final _otpController = TextEditingController(text: '123456');
  String? _token;
  CourseContent? _content;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _loginAndFetch() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await ApiService.login(
        email: _emailController.text.trim(),
        otp: _otpController.text.trim(),
      );

      final content = await ApiService.fetchCourseContent(
        token: token!,
        className: 'KG1',
      );

      setState(() {
        _token = token;
        _content = CourseContent.fromJson(content);
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildFillQuestion(Question question) {
    return QuestionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionTitle('Fill in the blank:'),
          const SizedBox(height: 8),
          Text(
            question.sentence ?? '',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Your answer',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SubmitButton(
            onPressed: () => _checkAnswer(question),
          ),
        ],
      ),
    );
  }

  Widget _buildImageMatchQuestion(Question question) {
    return QuestionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionTitle('Match the images:'),
          const SizedBox(height: 16),
          if (question.images != null)
            ImageGrid(images: question.images!),
          const SizedBox(height: 24),
          if (question.options != null)
            OptionGrid(options: question.options!),
        ],
      ),
    );
  }

  Widget _buildAudioQuestion(Question question) {
    return QuestionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionTitle('Listen and select:'),
          const SizedBox(height: 16),
          AudioPlayerWidget(
            onPlay: () => _playAudio(question.audioUrl),
          ),
          const SizedBox(height: 16),
          if (question.options != null)
            OptionList(
              options: question.options!,
              onSelected: (value) => _selectOption(question, value),
            ),
        ],
      ),
    );
  }

  Widget _buildSentenceQuestion(Question question) {
    return QuestionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionTitle('Construct the sentence:'),
          const SizedBox(height: 16),
          if (question.options != null)
            SentenceBuilder(
              words: question.options!,
              onReorder: (oldIndex, newIndex) => _reorderWords(oldIndex, newIndex),
            ),
          const SizedBox(height: 16),
          SubmitButton(
            onPressed: () => _checkSentence(question),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(Question question) {
    switch (question.type) {
      case 'fill':
        return _buildFillQuestion(question);
      case 'image_match':
        return _buildImageMatchQuestion(question);
      case 'audio':
        return _buildAudioQuestion(question);
      case 'sentence':
        return _buildSentenceQuestion(question);
      default:
        return const UnknownQuestionType();
    }
  }

  Widget _buildLoginForm() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogo(),
            const SizedBox(height: 32),
            EmailInput(controller: _emailController),
            const SizedBox(height: 16),
            OtpInput(controller: _otpController),
            const SizedBox(height: 24),
            if (_error != null) ErrorMessage(_error!),
            LoginButton(
              isLoading: _isLoading,
              onPressed: _loginAndFetch,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_content == null || _content!.questions.isEmpty) {
      return const Center(child: Text('No questions available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _content!.questions.length,
      itemBuilder: (context, index) {
        final question = _content!.questions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildQuestion(question),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sheshya Learning'),
        actions: _token != null
            ? [RefreshButton(onRefresh: _loginAndFetch)]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _token == null
              ? _buildLoginForm()
              : _buildContent(),
    );
  }

  // Helper methods for question interactions
  void _checkAnswer(Question question) {}
  void _playAudio(String? url) {}
  void _selectOption(Question question, String value) {}
  void _reorderWords(int oldIndex, int newIndex) {}
  void _checkSentence(Question question) {}
}

// Reusable Widgets
class QuestionCard extends StatelessWidget {
  final Widget child;

  const QuestionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class QuestionTitle extends StatelessWidget {
  final String text;

  const QuestionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const FlutterLogo(size: 100);
  }
}

class EmailInput extends StatelessWidget {
  final TextEditingController controller;

  const EmailInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }
}

class OtpInput extends StatelessWidget {
  final TextEditingController controller;

  const OtpInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'OTP',
        border: OutlineInputBorder(),
      ),
      obscureText: true,
    );
  }
}

class ErrorMessage extends StatelessWidget {
  final String message;

  const ErrorMessage(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const LoginButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
      child: isLoading
          ? const CircularProgressIndicator()
          : const Text('Login & Start Learning'),
    );
  }
}

class RefreshButton extends StatelessWidget {
  final VoidCallback onRefresh;

  const RefreshButton({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: onRefresh,
    );
  }
}

class SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SubmitButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: const Text('Submit'),
      ),
    );
  }
}

class ImageGrid extends StatelessWidget {
  final List<String> images;

  const ImageGrid({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: images.map((url) => Image.network(url, width: 80, height: 80)).toList(),
    );
  }
}

class OptionGrid extends StatelessWidget {
  final List<String> options;

  const OptionGrid({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) => Chip(label: Text(opt))).toList(),
    );
  }
}

class AudioPlayerWidget extends StatelessWidget {
  final VoidCallback onPlay;

  const AudioPlayerWidget({super.key, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.play_circle_fill, size: 48),
          onPressed: onPlay,
        ),
        const SizedBox(width: 16),
        const Text('Play Audio'),
      ],
    );
  }
}

class OptionList extends StatelessWidget {
  final List<String> options;
  final ValueChanged<String> onSelected;

  const OptionList({
    super.key,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options
          .map((opt) => RadioListTile<String>(
                title: Text(opt),
                value: opt,
                groupValue: null,
                onChanged: (value) => onSelected(value!),
              ))
          .toList(),
    );
  }
}

class SentenceBuilder extends StatelessWidget {
  final List<String> words;
  final ReorderCallback onReorder;

  const SentenceBuilder({
    super.key,
    required this.words,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      onReorder: onReorder,
      children: words
          .map((word) => ListTile(
                key: ValueKey(word),
                title: Text(word),
                trailing: const Icon(Icons.drag_handle),
              ))
          .toList(),
    );
  }
}

class UnknownQuestionType extends StatelessWidget {
  const UnknownQuestionType({super.key});

  @override
  Widget build(BuildContext context) {
    return const QuestionCard(
      child: Text('Unknown question type'),
    );
  }
}