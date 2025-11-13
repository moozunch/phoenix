import 'package:flutter/material.dart';

class RoutineSelection extends StatefulWidget{
  const RoutineSelection ({Key? key}) : super (key: key);

  @override
  State<RoutineSelection> createState() => _RoutineSelectionState();
}

class _RoutineSelectionState extends State<RoutineSelection>{
  String? selectedOption;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          //arrow
          // Positioned(
          //   top: 60,
          //   left: 20,
          //   child: IconButton(
          //     icon: const Icon(Icons.arrow_back_ios, size: 22, color: Colors.black87),
          //     onPressed: () {
          //       Navigator.pop(context);
          //     },
          //   ),
          // ),

          //Bottom rounded container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height*0.55,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  const Text(
                  "Personalize Your Check–In Routine",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Choose the rhythm that feels right to you.",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
                    const SizedBox(height: 30),

                    // Option Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: selectedOption == "Daily"
                                    ? Colors.deepOrange
                                    : Colors.grey.shade400,
                              ),
                              backgroundColor: selectedOption == "Daily"
                                  ? Colors.deepOrange.withOpacity(0.1)
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              setState(() {
                                selectedOption = "Daily";
                              });
                            },
                            child: Text(
                              "Daily",
                              style: TextStyle(
                                color: selectedOption == "Daily"
                                    ? Colors.deepOrange
                                    : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: selectedOption == "Weekly"
                                    ? Colors.deepOrange
                                    : Colors.grey.shade400,
                              ),
                              backgroundColor: selectedOption == "Weekly"
                                  ? Colors.deepOrange.withOpacity(0.1)
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              setState(() {
                                selectedOption = "Weekly";
                              });
                            },
                            child: Text(
                              "Weekly",
                              style: TextStyle(
                                color: selectedOption == "Weekly"
                                    ? Colors.deepOrange
                                    : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Progress dots + Skip + Next button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Skip
                        TextButton(
                          onPressed: () {
                            // skip action
                          },
                          child: const Text(
                            "Skip",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black45,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),

                        // Dots
                        Row(
                          children: [
                            _buildDot(true),
                            const SizedBox(width: 6),
                            _buildDot(false),
                            const SizedBox(width: 6),
                            _buildDot(false),
                          ],
                        ),

                        // Next
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            // go to next page
                          },
                          child: const Text(
                            "Next",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }

  // dot widget
  Widget _buildDot(bool isActive) {
    return Container(
      height: 8,
      width: isActive ? 20 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.deepOrange : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}