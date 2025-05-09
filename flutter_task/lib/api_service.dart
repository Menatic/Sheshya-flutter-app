class ApiService {
  static Future<Map<String, dynamic>> fetchCourseContent() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      'questions': [
        {
          'type': 'fill',
          'sentence': 'The capital of France is _______.',
          'answer': 'Paris',
          'hint': 'European cultural capital',
          'animation': 'assets/lottie/paris.json'
        },
        {
          'type': 'image_match',
          'images': [
            'https://images.unsplash.com/photo-1561037404-61cd46aa615b',
            'https://images.unsplash.com/photo-1558402529-d2638a7023e9',
            'https://images.unsplash.com/photo-1583512603805-3cc6b41f3edb'
          ],
          'options': ['Golden Retriever', 'Siamese Cat', 'Macaw'],
          'blurHash': ['LKO2?U%2Tw=w]~RBV@Ri000ORjfP', 'LFC#y%wc_3NG00IU%L%M00Mx%1R*', 'LGF5]+Yk^6#M@-5c,1J5@[or[Q6.'],
          'aspectRatio': 1.5
        },
        {
          'type': 'audio',
          'audioUrl': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
          'options': ['Piano', 'Guitar', 'Drums', 'Violin'],
          'waveformData': [0.2, 0.8, 0.4, 0.6, 0.9]
        },
        {
          'type': 'rearrange',
          'words': ['Hello', 'world', 'how', 'are', 'you', 'today'],
          'correctOrder': ['Hello', 'world', 'how', 'are', 'you', 'today']
        }
      ]
    };
  }
}