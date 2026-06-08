import 'package:flutter/material.dart';
import 'package:scratcher/scratcher.dart';
import 'package:get/get.dart';
import 'package:confetti/confetti.dart';
import '../controllers/game_controller.dart';

class ScratchCardScreen extends StatefulWidget {
  const ScratchCardScreen({super.key});

  @override
  State<ScratchCardScreen> createState() => _ScratchCardScreenState();
}

class _ScratchCardScreenState extends State<ScratchCardScreen> {
  double _opacity = 0.0;
  late ConfettiController _confettiController;
  bool _isScratched = false;
  
  // ✅ FIX: Safe initialization instance wrapper link
  final GameController controller = Get.put(GameController()); 

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    controller.resetScratchCard(); 
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _resetLocalState() {
    setState(() {
      _opacity = 0.0;
      _isScratched = false;
    });
    controller.resetScratchCard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        title: const Text('Scratch & Win', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xff15141F),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() => Text('Balance: ${controller.coins.value} Coins', style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold))),
              const SizedBox(height: 40),

              Obx(() {
                if (!controller.hasBoughtCard.value) {
                  return Column(
                    children: [
                      const Text('Buy a card to reveal a hidden prize!', style: TextStyle(color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                        onPressed: controller.isBuyingCard.value ? null : controller.buyScratchCard,
                        child: controller.isBuyingCard.value 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                          : const Text('BUY CARD (20 Coins)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ],
                  );
                }

                final reward = controller.currentScratchReward;
                final amount = reward['amount'] ?? 0;
                final type = reward['type'] ?? 'NOTHING';
                
                String prizeText = amount > 0 ? '$amount $type' : 'Better Luck Next Time!';
                String emoji = type == 'DIAMONDS' ? '💎' : (amount > 0 ? '🎉' : '😢');

                return Column(
                  children: [
                    const Text('Scratch to reveal your prize!', style: TextStyle(color: Colors.white, fontSize: 18)),
                    const SizedBox(height: 30),
                    Scratcher(
                      brushSize: 50, threshold: 50, color: Colors.grey.shade800,
                      onThreshold: () {
                        if (!_isScratched) {
                          if (amount > 0) _confettiController.play();
                          setState(() { _opacity = 1.0; _isScratched = true; });
                        }
                      },
                      child: Container(
                        height: 200, width: 300, color: const Color(0xFF15141F), alignment: Alignment.center,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 500), opacity: _opacity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(emoji, style: const TextStyle(fontSize: 50)),
                              const SizedBox(height: 10),
                              Text(prizeText, style: const TextStyle(color: Color(0xFFFF8906), fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (_isScratched)
                      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white24), onPressed: _resetLocalState, child: const Text('Play Again', style: TextStyle(color: Colors.white)))
                  ],
                );
              }),
            ],
          ),
          ConfettiWidget(confettiController: _confettiController, blastDirectionality: BlastDirectionality.explosive, shouldLoop: false, colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple]),
        ],
      ),
    );
  }
}