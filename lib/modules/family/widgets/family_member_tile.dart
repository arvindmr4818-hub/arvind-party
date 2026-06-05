import 'package:flutter/material.dart';
import '../models/family_member_model.dart';

class FamilyMemberTile extends StatelessWidget {
  final FamilyMemberModel member;
  final VoidCallback onKickPressed;

  const FamilyMemberTile({
    super.key,
    required this.member,
    required this.onKickPressed,
  });

  @override
  Widget build(BuildContext context) {
    String roleLabel = member.role.toString().split('.').last.toUpperCase();
    Color roleColor =
        member.role == FamilyRole.owner || member.role == FamilyRole.coOwner
            ? const Color(0xffFF8906)
            : Colors.cyan;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xff15141F),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Avatar with online status indicator dot ring
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(member.avatar),
              ),
              if (member.isOnline)
                Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xff15141F), width: 1.5),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Details Matrix block description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(roleLabel,
                          style: TextStyle(
                              color: roleColor,
                              fontSize: 7,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Today Contribution: 🛡️ ${member.todayContribution}",
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),

          // Action menu context trigger
          IconButton(
            icon: const Icon(Icons.person_remove_alt_1_outlined,
                color: Colors.white24, size: 18),
            onPressed: onKickPressed,
          ),
        ],
      ),
    );
  }
}
