import "package:flutter/material.dart";
import "../models/user_profile_model.dart";

class ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final bool isMyProfile;
  final VoidCallback? onEditPressed;
  final VoidCallback? onFollowPressed;
  final bool isFollowing;

  const ProfileHeader({super.key, 
    required this.profile,
    required this.isMyProfile,
    this.onEditPressed,
    this.onFollowPressed,
    this.isFollowing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Cover Image
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[300],
          ),
          child: profile.coverImage != null
              ? Image.network(
                  profile.coverImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                    );
                  },
                )
              : Container(
                  color: Colors.grey[300],
                ),
        ),

        // Avatar & Info
        Positioned(
          top: 140,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: profile.avatar != null
                        ? NetworkImage(profile.avatar!)
                        : null,
                    child: profile.avatar == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  const SizedBox(width: 16),

                  // Username & Badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              profile.getDisplayName(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (profile.isVerified)
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(
                                  Icons.verified,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                        Text(
                          "@${profile.username}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        if (profile.vipTier != "free")
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                profile.vipTier!.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[800],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Actions
                  if (!isMyProfile)
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: "block",
                          child: Text("Block"),
                        ),
                        const PopupMenuItem(
                          value: "report",
                          child: Text("Report"),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Bio
              if (profile.bio != null && profile.bio!.isNotEmpty)
                Text(
                  profile.bio!,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 12),

              // Info Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (profile.country != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              profile.country!,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    if (profile.birthday != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.cake, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              profile.getAgeFromBirthday(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    if (profile.website != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.link, size: 16, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text(
                              profile.website!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Action Buttons
              Row(
                children: [
                  if (isMyProfile)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onEditPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text("Edit Profile"),
                      ),
                    )
                  else
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onFollowPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isFollowing ? Colors.grey : Colors.blue,
                        ),
                        child: Text(isFollowing ? "Following" : "Follow"),
                      ),
                    ),
                  const SizedBox(width: 8),
                  if (!isMyProfile)
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                      ),
                      child: const Icon(Icons.message, color: Colors.black),
                    ),
                ],
              ),
            ],
          ),
        ),

        // Online Status
        Positioned(
          top: 180,
          right: 16,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: profile.isOnline ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
