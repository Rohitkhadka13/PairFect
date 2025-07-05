// quiz_matching_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pairfect/quiz_mood/quiz_profile_screen.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class QuizMatchingScreen extends StatefulWidget {
  @override
  _QuizMatchingScreenState createState() => _QuizMatchingScreenState();
}

class _QuizMatchingScreenState extends State<QuizMatchingScreen> {
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _showResults = false;
  Map<String, String> _answers = {};
  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> _matches = [];

  @override
  void initState() {
    super.initState();
    _resetQuiz();
    _loadQuestions();
  }

  void _resetQuiz() {
    setState(() {
      _currentIndex = 0;
      _showResults = false;
      _answers = {};
    });
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);

    final questionQuery = QueryBuilder<ParseObject>(ParseObject('QuizQuestion'))
      ..orderByAscending('createdAt')
      ..setLimit(5);

    final questionResponse = await questionQuery.query();

    if (questionResponse.success && questionResponse.results != null) {
      setState(() {
        _questions = questionResponse.results!
            .map((q) => {
          'id': q.objectId,
          'question': q.get<String>('questionText'),
          'options': List<String>.from(q.get<List<dynamic>>('options') ?? []),
        })
            .toList();
      });
    }

    setState(() => _isLoading = false);
  }

  void _onOptionSelected(String questionId, String answer) {
    setState(() => _answers[questionId] = answer);

    Future.delayed(Duration(milliseconds: 300), () {
      if (_currentIndex < _questions.length - 1) {
        setState(() => _currentIndex++);
      } else {
        _submitAnswers();
      }
    });
  }

  Future<void> _submitAnswers() async {
    setState(() => _isLoading = true);
    final currentUser = await ParseUser.currentUser() as ParseUser?;

    if (currentUser != null) {
      final answerArray = _answers.entries
          .map((e) => {'questionId': e.key, 'answer': e.value})
          .toList();

      final answerQuery = QueryBuilder<ParseObject>(ParseObject('UserQuizAnswer'))
        ..whereEqualTo('userPointer', currentUser.toPointer());

      final answerResponse = await answerQuery.query();
      final obj = ParseObject('UserQuizAnswer');

      if (answerResponse.success &&
          answerResponse.results != null &&
          answerResponse.results!.isNotEmpty) {
        obj.objectId = answerResponse.results!.first.objectId;
      }

      obj
        ..set('userPointer', currentUser.toPointer())
        ..set('answers', answerArray);

      await obj.save();
      await _findMatches(currentUser);
    }

    setState(() {
      _isLoading = false;
      _showResults = true;
    });
  }

  Future<void> _findMatches(ParseUser currentUser) async {
    final interactionQuery = QueryBuilder<ParseObject>(ParseObject('UserInteractions'))
      ..whereEqualTo('fromUser', currentUser.toPointer());

    final interactionResponse = await interactionQuery.query();
    final interactedUserIds = <String>{};

    if (interactionResponse.success && interactionResponse.results != null) {
      for (final interaction in interactionResponse.results!) {
        final toUser = interaction.get<ParseUser>('toUser');
        if (toUser != null && toUser.objectId != null) {
          interactedUserIds.add(toUser.objectId!);
        }
      }
    }

    final query = QueryBuilder<ParseObject>(ParseObject('UserQuizAnswer'))
      ..includeObject(['userPointer'])
      ..whereNotEqualTo('userPointer', currentUser.toPointer());

    if (interactedUserIds.isNotEmpty) {
      query.whereNotContainedIn(
        'userPointer',
        interactedUserIds
            .map((id) => ParseUser(null, null, null)..objectId = id)
            .toList(),
      );
    }

    final response = await query.query();
    final List<Map<String, dynamic>> matches = [];

    if (response.success && response.results != null) {
      for (final result in response.results!) {
        final user = result.get<ParseUser>('userPointer');
        final answers = result.get<List<dynamic>>('answers') ?? [];

        if (user != null) {
          int matched = 0;
          for (final item in answers) {
            final qid = item['questionId'];
            final ans = item['answer'];
            if (_answers[qid] == ans) matched++;
          }
          final percent = ((matched / _answers.length) * 100).round();
          final profile = await _fetchUserData(user);
          matches.add({...profile, 'score': percent});
        }
      }
    }

    setState(() {
      _matches = matches
        ..sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    });
  }

  Future<Map<String, dynamic>> _fetchUserData(ParseUser user) async {
    final query = QueryBuilder<ParseObject>(ParseObject('UserLogin'))
      ..whereEqualTo('userPointer', user);

    final response = await query.query();

    if (response.success && response.results?.isNotEmpty == true) {
      final u = response.results!.first;
      return {
        'user': user,
        'name': u.get<String>('name') ?? 'Unknown',
        'imageUrl': u.get<ParseFile>('imageProfile')?.url ?? '',
      };
    }
    return {'user': user, 'name': 'Unknown', 'imageUrl': ''};
  }

  Widget _buildQuestion() {
    final q = _questions[_currentIndex];
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions.length,
            backgroundColor: Colors.white38,
            color: Colors.pink,
            minHeight: 6,
          ),
          const SizedBox(height: 40),
          Text(
            'Q${_currentIndex + 1}. ${q['question']}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade700,
            ),
          ),
          const SizedBox(height: 30),
          ...List.generate((q['options'] as List<String>).length, (i) {
            final opt = q['options'][i];
            final selected = _answers[q['id']] == opt;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: selected
                      ? LinearGradient(colors: [Colors.pink, Colors.purple])
                      : LinearGradient(colors: [Colors.white, Colors.white]),
                  boxShadow: selected
                      ? [BoxShadow(color: Colors.pinkAccent, blurRadius: 10)]
                      : [],
                ),
                child: ListTile(
                  title: Center(
                    child: Text(
                      opt,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  onTap: () => _onOptionSelected(q['id'], opt),
                ),
              ),
            );
          }),
          if (_currentIndex > 0)
            Align(
              alignment: Alignment.bottomLeft,
              child: TextButton(
                onPressed: () => setState(() => _currentIndex--),
                child: Text('Back', style: TextStyle(color: Colors.pink)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Your Romantic Matches 💘',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade700,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _matches.isEmpty
                ? Center(
              child: Text('No matches found yet 💔', style: TextStyle(fontSize: 18)),
            )
                : ListView.builder(
              itemCount: _matches.length,
              itemBuilder: (context, index) {
                final m = _matches[index];
                return GestureDetector(
                  onTap: () => Get.to(() => QuizProfileScreen(user: m['user'])),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.shade100.withOpacity(0.5),
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          AspectRatio(
                            aspectRatio: 4 / 5,
                            child: Image.network(
                              m['imageUrl'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) =>
                                  Container(color: Colors.grey),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.pink.shade400, Colors.purple.shade400],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  m['name'],
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 2)],
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Matching ${m['score']}%',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: _resetQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Text('Retake Quiz', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personality Quiz'),
        backgroundColor: Colors.pink,
      ),
      body: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade100, Colors.purple.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.pink))
              : _questions.isEmpty
              ? Center(child: Text('No questions available'))
              : _showResults
              ? _buildResults()
              : _buildQuestion(),
        ),
      ),
    );
  }
}
