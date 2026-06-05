import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/family_event_model.dart';

class FamilyEventCard extends StatelessWidget {
  final FamilyEventModel event;

  const FamilyEventCard({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xff15141F),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Visual Frame
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14), topRight: Radius.circular(14)),
            child: SizedBox(
              height: 100,
              width: double.infinity,
              child: Image.network(event.banner, fit: BoxFit.cover),
            ),
          ),

          // Text content metadata tracking blocks
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text("LIVE TARGET",
                          style: TextStyle(
                              color: Colors.amber.shade400,
                              fontSize: 8,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  event.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Divider(color: Colors.white10, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.schedule,
                            color: Colors.white38, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd MMM, hh:mm a')
                              .format(event.scheduledTime),
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 10),
                        ),
                      ],
                    ),
                    Text(
                      "👥 ${event.attendeesCount} Registered",
                      style: const TextStyle(
                          color: Colors.cyan,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
