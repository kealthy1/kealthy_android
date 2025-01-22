import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Services/FeedbackAPI.dart';

final isLoadingProvider = StateProvider<bool>((ref) => false);

final feedbackProvider = StateNotifierProvider<FeedbackNotifier, FeedbackState>(
  (ref) => FeedbackNotifier(),
);

class FeedbackState {
  final int deliveryRating;
  final int websiteRating;
  final String additionalFeedback;
  final String satisfactionText;
  final bool showDeliveryRatingError;
  final bool showWebsiteRatingError;
  final bool showSatisfactionTextError;
  final bool showAdditionalFeedbackError;

  FeedbackState({
    this.deliveryRating = 0,
    this.websiteRating = 0,
    this.additionalFeedback = '',
    this.satisfactionText = '',
    this.showDeliveryRatingError = false,
    this.showWebsiteRatingError = false,
    this.showSatisfactionTextError = false,
    this.showAdditionalFeedbackError = false,
  });

  FeedbackState copyWith({
    int? deliveryRating,
    int? websiteRating,
    String? additionalFeedback,
    String? satisfactionText,
    bool? showDeliveryRatingError,
    bool? showWebsiteRatingError,
    bool? showSatisfactionTextError,
    bool? showAdditionalFeedbackError,
  }) {
    return FeedbackState(
      deliveryRating: deliveryRating ?? this.deliveryRating,
      websiteRating: websiteRating ?? this.websiteRating,
      additionalFeedback: additionalFeedback ?? this.additionalFeedback,
      satisfactionText: satisfactionText ?? this.satisfactionText,
      showDeliveryRatingError:
          showDeliveryRatingError ?? this.showDeliveryRatingError,
      showWebsiteRatingError:
          showWebsiteRatingError ?? this.showWebsiteRatingError,
      showSatisfactionTextError:
          showSatisfactionTextError ?? this.showSatisfactionTextError,
      showAdditionalFeedbackError:
          showAdditionalFeedbackError ?? this.showAdditionalFeedbackError,
    );
  }
}

class FeedbackNotifier extends StateNotifier<FeedbackState> {
  FeedbackNotifier() : super(FeedbackState());

  void setDeliveryRating(int rating) {
    state =
        state.copyWith(deliveryRating: rating, showDeliveryRatingError: false);
  }

  void setWebsiteRating(int rating) {
    state =
        state.copyWith(websiteRating: rating, showWebsiteRatingError: false);
  }

  void setAdditionalFeedback(String feedback) {
    state = state.copyWith(
        additionalFeedback: feedback, showAdditionalFeedbackError: false);
  }

  void setSatisfactionText(String text) {
    state = state.copyWith(
        satisfactionText: text, showSatisfactionTextError: false);
  }

  bool validateFields() {
    bool isValid = true;

    if (state.deliveryRating == 0) {
      state = state.copyWith(showDeliveryRatingError: true);
      isValid = false;
    }

    if (state.websiteRating == 0) {
      state = state.copyWith(showWebsiteRatingError: true);
      isValid = false;
    }

    if (state.satisfactionText.isEmpty) {
      state = state.copyWith(showSatisfactionTextError: true);
      isValid = false;
    }

    if (state.additionalFeedback.isEmpty) {
      state = state.copyWith(showAdditionalFeedbackError: true);
      isValid = false;
    }

    return isValid;
  }

  Future<bool> submitFeedback(BuildContext context) async {
    if (!validateFields()) return false;

    final feedbackService = FeedbackService();

    try {
      await feedbackService.saveFeedbackToServer(
        deliveryRating: state.deliveryRating.toDouble(),
        websiteRating: state.websiteRating.toDouble(),
        satisfactionText: state.satisfactionText,
        additionalFeedback: state.additionalFeedback,
      );

      Fluttertoast.showToast(
        msg: "Feedback submitted successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      return true;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to submit feedback: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }
  }
}

class FeedbackPage extends ConsumerWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbackState = ref.watch(feedbackProvider);
    final feedbackNotifier = ref.read(feedbackProvider.notifier);
    final isLoading = ref.watch(isLoadingProvider);

    return WillPopScope(
      onWillPop: () async {
        // ignore: unused_result
        ref.refresh(feedbackProvider);
        // ignore: unused_result
        ref.refresh(isLoadingProvider);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: Text(
            'Share Your Feedback',
            style: GoogleFonts.poppins(
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "How satisfied are you with the delivery process?",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        Icons.star,
                        color: feedbackState.deliveryRating > index
                            ? Colors.amber
                            : Colors.black45,
                        size: 30,
                      ),
                      onPressed: () {
                        feedbackNotifier.setDeliveryRating(index + 1);
                      },
                    );
                  }),
                ),
                if (feedbackState.showDeliveryRatingError)
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      "Please provide a delivery rating",
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const Divider(
                  thickness: 2,
                ),
                Text(
                  "How satisfied are you with the usability of the App?",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        Icons.star,
                        color: feedbackState.websiteRating > index
                            ? Colors.amber
                            : Colors.grey,
                        size: 30,
                      ),
                      onPressed: () {
                        feedbackNotifier.setWebsiteRating(index + 1);
                      },
                    );
                  }),
                ),
                if (feedbackState.showWebsiteRatingError)
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      "Please provide a website rating",
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const Divider(
                  thickness: 2,
                ),
                Text(
                  "How would you describe your satisfaction?",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    {
                      "icon": Icons.sentiment_very_dissatisfied,
                      "text": "Very Dissatisfied",
                      "color": Colors.red,
                      "iconsize": 30
                    },
                    {
                      "icon": Icons.sentiment_dissatisfied,
                      "text": "Dissatisfied",
                      "color": Colors.orange,
                    },
                    {
                      "icon": Icons.sentiment_neutral,
                      "text": "Neutral",
                      "color": Colors.grey,
                    },
                    {
                      "icon": Icons.sentiment_satisfied,
                      "text": "Satisfied",
                      "color": Colors.lightGreen,
                    },
                    {
                      "icon": Icons.sentiment_very_satisfied,
                      "text": "Very Satisfied",
                      "color": Colors.green,
                    },
                  ].map((smiley) {
                    return Column(
                      children: [
                        if (feedbackState.satisfactionText == smiley['text'])
                          Text(
                            smiley['text'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: smiley['color'] as Color,
                            ),
                          ),
                        const SizedBox(height: 5),
                        IconButton(
                          icon: Icon(
                            smiley['icon'] as IconData,
                            color:
                                feedbackState.satisfactionText == smiley['text']
                                    ? smiley['color'] as Color
                                    : Colors.grey,
                            size: 30,
                          ),
                          onPressed: () {
                            feedbackNotifier
                                .setSatisfactionText(smiley['text'] as String);
                          },
                        ),
                      ],
                    );
                  }).toList(),
                ),
                if (feedbackState.showSatisfactionTextError)
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      "Please select a satisfaction level",
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const Divider(
                  thickness: 2,
                ),
                Text(
                  "Do you have any thoughts you'd like to share?",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  cursorColor: Colors.black,
                  maxLines: 4,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: const Color(0xFF273847)),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: const Color(0xFF273847)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: const Color(0xFF273847)),
                    ),
                    border: const OutlineInputBorder(),
                    hintText: "Type your feedback here...",
                    hintStyle: GoogleFonts.poppins(),
                    errorText: feedbackState.showAdditionalFeedbackError
                        ? "This field cannot be empty"
                        : null,
                  ),
                  onChanged: (value) {
                    feedbackNotifier.setAdditionalFeedback(value);
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isLoading
                        ? LoadingAnimationWidget.inkDrop(
                            color: const Color(0xFF273847),
                            size: 30,
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              backgroundColor: const Color(0xFF273847),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                            ),
                            onPressed: () async {
                              ref.read(isLoadingProvider.notifier).state = true;

                              try {
                                final isSuccess = await feedbackNotifier
                                    .submitFeedback(context);
                                if (isSuccess) {
                                  Navigator.pop(context);
                                  // ignore: unused_result
                                  ref.refresh(feedbackProvider);
                                  // ignore: unused_result
                                  ref.refresh(isLoadingProvider);
                                } else {
                                  print('Feedback submission failed.');
                                }
                              } finally {
                                ref.read(isLoadingProvider.notifier).state =
                                    false;
                              }
                              final prefs =
                                  await SharedPreferences.getInstance();
                              prefs.remove('Rate');
                              prefs.remove('RateTimestamp');
                            },
                            child: Text(
                              'Submit',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
