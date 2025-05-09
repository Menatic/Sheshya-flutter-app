class CourseContent {
  final List<Question> questions;

  CourseContent({required this.questions});

  factory CourseContent.fromJson(Map<String, dynamic> json) {
    return CourseContent(
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
    );
  }
}

class Question {
  final String type;
  final String? sentence;
  final String? answer;
  final String? hint;
  final String? animation;
  final List<String>? images;
  final List<String>? options;
  final List<String>? blurHash;
  final double? aspectRatio;
  final String? audioUrl;
  final List<double>? waveformData;
  final List<String>? words; // Add this for rearrange question type

  Question({
    required this.type,
    this.sentence,
    this.answer,
    this.hint,
    this.animation,
    this.images,
    this.options,
    this.blurHash,
    this.aspectRatio,
    this.audioUrl,
    this.waveformData,
    this.words, // Add this
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      type: json['type'],
      sentence: json['sentence'],
      answer: json['answer'],
      hint: json['hint'],
      animation: json['animation'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      options: json['options'] != null ? List<String>.from(json['options']) : null,
      blurHash: json['blurHash'] != null ? List<String>.from(json['blurHash']) : null,
      aspectRatio: json['aspectRatio'],
      audioUrl: json['audioUrl'],
      waveformData: json['waveformData'] != null ? List<double>.from(json['waveformData']) : null,
      words: json['words'] != null ? List<String>.from(json['words']) : null, // Add this
    );
  }
}