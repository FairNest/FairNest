import 'package:fairnestui/auth/login_page.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LifestyleQuizPage extends StatefulWidget {
  const LifestyleQuizPage({super.key, this.onTapLogin});

  final VoidCallback? onTapLogin;

  @override
  State<LifestyleQuizPage> createState() => _LifestyleQuizPageState();
}

class _LifestyleQuizPageState extends State<LifestyleQuizPage> {
  final Map<int, int> answers = {};

  void setAnswer(int questionIndex, int score) {
    setState(() {
      answers[questionIndex] = score; // stores 1..5
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEEEA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                "Lifestyle &\nPreference Quiz",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF645A80),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "This short quiz helps us understand your lifestyle preferences so we can match you with roommates who share similar habits and values.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              // ===== Questions =====
              QuestionWidget(
                question:
                    "Q1 - How often do you clean shared spaces (kitchen, living room)?",
                startLabel: "Never",
                endLabel: "Daily",
                onChanged: (score) => setAnswer(1, score),
              ),
              QuestionWidget(
                question: "Q2 - How tidy do you like your surroundings to be?",
                startLabel: "I don't mind clutter",
                endLabel: "I keep everything spotless",
                onChanged: (score) => setAnswer(2, score),
              ),
              QuestionWidget(
                question:
                    "Q3 - How noisy are you in your personal time (e.g., music, TV, gaming)?",
                startLabel: "Very quiet",
                endLabel: "Loud & lively",
                onChanged: (score) => setAnswer(3, score),
              ),
              QuestionWidget(
                question:
                    "Q4 - How much noise are you okay with in shared spaces?",
                startLabel: "Prefer silence",
                endLabel: "I don't mind",
                onChanged: (score) => setAnswer(4, score),
              ),
              QuestionWidget(
                question: "Q5 - What time do you usually go to bed?",
                startLabel: "Before 9 PM",
                endLabel: "After 2 AM",
                onChanged: (score) => setAnswer(5, score),
              ),
              QuestionWidget(
                question: "Q6 - Are you more of a morning or night person?",
                startLabel: "Early bird",
                endLabel: "Night owl",
                onChanged: (score) => setAnswer(6, score),
              ),
              QuestionWidget(
                question: "Q7 - How often do you host guests (friends, dates)?",
                startLabel: "Never",
                endLabel: "Daily",
                onChanged: (score) => setAnswer(7, score),
              ),
              QuestionWidget(
                question:
                    "Q8 - How comfortable are you with roommates bringing guests home?",
                startLabel: "Not okay at all",
                endLabel: "Always okay",
                onChanged: (score) => setAnswer(8, score),
              ),
              QuestionWidget(
                question:
                    "Q9 - Do you prefer structured chore assignments or casual responsibility?",
                startLabel: "Casual",
                endLabel: "Structured rotation system",
                onChanged: (score) => setAnswer(9, score),
              ),
              QuestionWidget(
                question:
                    "Q10 - How likely are you to voluntarily help with others’ tasks?",
                startLabel: "Only if I must",
                endLabel: "I always jump in",
                onChanged: (score) => setAnswer(10, score),
              ),
              QuestionWidget(
                question:
                    "Q11 - How important is strict equal splitting of all expenses to you?",
                startLabel: "Flexible",
                endLabel: "Strict 50/50",
                onChanged: (score) => setAnswer(11, score),
              ),
              QuestionWidget(
                question:
                    "Q12 - If someone covers a shared bill, how soon should others repay it?",
                startLabel: "Within a week",
                endLabel: "ASAP",
                onChanged: (score) => setAnswer(12, score),
              ),

              const SizedBox(height: 20),

              // ===== Sign Up Button (black) =====
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 2,
                  ),
                  onPressed: () {
                    debugPrint("User answers (1–5): $answers");
                    // TODO: handle submit
                  },
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ===== Already have an account? Log in here =====
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      "Log in here",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9A3E00),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestionWidget extends StatefulWidget {
  final String question;
  final String startLabel;
  final String endLabel;
  final ValueChanged<int> onChanged;
  final int initialValue;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.startLabel,
    required this.endLabel,
    required this.onChanged,
    this.initialValue = 0,
  });

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    const int dotCount = 5;
    const double gap = 8.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF645A80), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 4),
              Expanded(
                flex: 3,
                child: Text(
                  widget.startLabel,
                  style: const TextStyle(fontSize: 12),
                  softWrap: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: LayoutBuilder(
                  builder: (context, c) {
                    final double area = c.maxWidth;
                    final double raw = (area - gap * (dotCount - 1)) / dotCount;
                    final double circleSize = raw.clamp(20.0, 44.0);

                    return SizedBox(
                      height: circleSize,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(dotCount, (i) {
                          final isSelected = selectedIndex == i + 1; // 1..5
                          return GestureDetector(
                            onTap: () {
                              setState(() => selectedIndex = i + 1);
                              widget.onChanged(selectedIndex);
                            },
                            child: Container(
                              width: circleSize,
                              height: circleSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? const Color(0xFF645A80)
                                    : Colors.grey[300],
                                border: isSelected
                                    ? null
                                    : Border.all(color: Colors.black12),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Text(
                  widget.endLabel,
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.right,
                  softWrap: true,
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
