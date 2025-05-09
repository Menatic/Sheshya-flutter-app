import 'package:flutter/material.dart';
import 'api_service.dart';
import 'models.dart';  // Ensure this import exists
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learning App Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF9D923)),
        scaffoldBackgroundColor: const Color(0xFF22223B),
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF22223B),
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFFF9D923)),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF2E9E4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF9D923),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            elevation: 4,
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFF2E9E4),
          selectedColor: const Color(0xFFF9D923),
          labelStyle: const TextStyle(
            color: Color(0xFF22223B),
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xFFF9D923),
        ),
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
  CourseContent? _content;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDemoContent();
  }

  Future<void> _loadDemoContent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final content = await ApiService.fetchCourseContent();
      setState(() {
        _content = CourseContent.fromJson(content);
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load content. Please try again.';
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/vectors/placeholder.svg', height: 100),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question.sentence ?? '',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF22223B),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Type your answer...',
              prefixIcon: const Icon(Icons.edit, color: Color(0xFFF9D923)),
            ),
          ),
          const SizedBox(height: 16),
          SubmitButton(onPressed: () {}),
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
          if (question.images != null) ImageGrid(images: question.images!),
          const SizedBox(height: 24),
          if (question.options != null) OptionGrid(options: question.options!),
          const SizedBox(height: 16),
          SubmitButton(onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildAudioQuestion(Question question) {
    return QuestionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionTitle('Listen and choose:'),
          const SizedBox(height: 16),
          Center(
            child: Lottie.asset('assets/lottie/placeholder.json', height: 80),
          ),
          const SizedBox(height: 16),
          AudioPlayerWidget(onPlay: () {}),
          const SizedBox(height: 16),
          if (question.options != null)
            OptionList(
              options: question.options!,
              onSelected: (_) {},
            ),
          const SizedBox(height: 16),
          SubmitButton(onPressed: () {}),
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
              onReorder: (oldIndex, newIndex) {},
            ),
          const SizedBox(height: 16),
          const SubmitButton(onPressed: null),
        ],
      ),
    );
  }

  // Added rearrange question builder
  Widget _buildRearrangeQuestion(Question question) {
    return RearrangeWordsQuestion(
      words: question.words ?? [],
      correctOrder: question.options ?? [],
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
      case 'rearrange': // new case for rearrange type
        return _buildRearrangeQuestion(question);
      default:
        return const UnknownQuestionType();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning App - Demo Mode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDemoContent,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _content == null
                  ? const Center(child: Text('No content available'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _content!.questions.length,
                      itemBuilder: (context, index) {
                        final question = _content!.questions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildQuestion(question),
                        );
                      },
                    ),
    );
  }
}

class RearrangeWordsQuestion extends StatefulWidget {
  final List<String> words;
  final List<String> correctOrder;

  const RearrangeWordsQuestion({
    super.key,
    required this.words,
    required this.correctOrder,
  });

  @override
  State<RearrangeWordsQuestion> createState() => _RearrangeWordsQuestionState();
}

class _RearrangeWordsQuestionState extends State<RearrangeWordsQuestion> {
  late List<String> _currentOrder;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    // Shuffle the words initially
    _currentOrder = List.from(widget.words)..shuffle();
  }

  void _checkAnswer() {
    final isCorrect = _currentOrder.join(' ') == widget.correctOrder.join(' ');
    setState(() {
      _isCorrect = isCorrect;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? 'Correct!' : 'Try again'),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
      ),
    );
  }

  void _reorderItems(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final String item = _currentOrder.removeAt(oldIndex);
      _currentOrder.insert(newIndex, item);
      _isCorrect = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return QuestionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionTitle('Rearrange the words to form a sentence:'),
          const SizedBox(height: 16),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _currentOrder.length,
            onReorder: _reorderItems,
            itemBuilder: (context, index) {
              return Card(
                key: ValueKey(_currentOrder[index]),
                color: _isCorrect ? Colors.green.shade100 : Colors.white,
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(
                    _currentOrder[index],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF22223B),
                    ),
                  ),
                  trailing: const Icon(Icons.drag_handle),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          SubmitButton(
            onPressed: _checkAnswer,
          ),
        ],
      ),
    );
  }
}

class QuestionCard extends StatelessWidget {
  const QuestionCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
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

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key, required this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF9D923),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text('Continue'),
        ),
      ),
    );
  }
}

class ImageGrid extends StatelessWidget {
  final List<String> images;

  const ImageGrid({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            images[index],
            fit: BoxFit.cover,
            height: 80,
            width: 80,
          ),
        );
      },
    );
  }
}

class OptionGrid extends StatelessWidget {
  final List<String> options;

  const OptionGrid({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options
          .map((option) => ChoiceChip(
                label: Text(option),
                selected: false,
                onSelected: (_) {},
                backgroundColor: const Color(0xFFF2E9E4),
                selectedColor: const Color(0xFFF9D923),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF22223B),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ))
          .toList(),
    );
  }
}

class AudioPlayerWidget extends StatelessWidget {
  final VoidCallback? onPlay;

  const AudioPlayerWidget({super.key, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(
            Icons.play_circle_fill,
            size: 48,
            color: Color(0xFFF9D923),
          ),
          onPressed: onPlay,
        ),
        const SizedBox(width: 16),
        const Text(
          'Play Audio',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF22223B),
          ),
        ),
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
          .map(
            (option) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: RadioListTile<String>(
                title: Text(
                  option,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF22223B),
                  ),
                ),
                value: option,
                groupValue: null,
                onChanged: (value) => onSelected(value ?? ''),
                activeColor: const Color(0xFFF9D923),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          )
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
          .map(
            (word) => ListTile(
              key: ValueKey(word),
              title: Text(word),
              trailing: const Icon(Icons.drag_handle),
            ),
          )
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
