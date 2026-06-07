import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/frame_controller.dart';
import '../../../shared/widgets/avatar_with_frame.dart';

class FrameStoreScreen extends StatelessWidget {
  final FrameController controller = Get.put(FrameController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Avatar Frames Store'), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) return Center(child: CircularProgressIndicator());

        return GridView.builder(
          padding: EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.75
          ),
          itemCount: controller.frames.length,
          itemBuilder: (context, index) {
            final frame = controller.frames[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Frame preview around a dummy avatar
                  AvatarWithFrame(
                    avatarUrl: 'https://via.placeholder.com/150', // Dummy avatar for preview
                    frameUrl: frame.imageUrl,
                    radius: 40,
                  ),
                  SizedBox(height: 12),
                  Text(frame.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.monetization_on, color: Colors.yellow, size: 18),
                      SizedBox(width: 4),
                      Text('${frame.priceCoins} Coins / ${frame.validityDays}d'),
                    ],
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                    onPressed: () => controller.buyFrame(frame.id),
                    child: Text('Buy & Equip'),
                  )
                ],
              ),
            );
          },
        );
      }),
    );
  }
}