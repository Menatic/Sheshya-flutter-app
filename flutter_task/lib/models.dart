class CourseContent {
  final List<Question> questions;

  CourseContent({required this.questions});

  factory CourseContent.fromJson(Map<String, dynamic> json) {
    final questions = (json['questions'] as List)
        .map((questionJson) => Question.fromJson(questionJson))
        .toList();
    return CourseContent(questions: questions);
  }
}

class Question {
  final String type;
  final String? sentence;
  final List<String>? options;
  final List<String>? images;
  final String? audioUrl;
  final String? answer;

  Question({
    required this.type,
    this.sentence,
    this.options,
    this.images,
    this.audioUrl,
    this.answer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      type: json['type'],
      sentence: json['sentence'],
      options: json['options'] != null ? List<String>.from(json['options']) : null,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      audioUrl: json['audioUrl'],
      answer: json['answer'],
    );
  }
}

enum QuestionType {
  fill,
  image_match,
  audio,
  sentence,
}