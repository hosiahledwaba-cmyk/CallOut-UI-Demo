// lib/data/mock_feed_repository.dart
import '../models/post.dart';
import '../models/user.dart';

class MockFeedRepository {
  static final User _user1 = User(
    id: 'u1',
    username: 'sarah_j',
    displayName: 'Sarah Jenkins',
    avatarUrl: 'https://i.pravatar.cc/150?u=1',
    isVerified: true,
  );

  static final User _user2 = User(
    id: 'u2',
    username: 'community_helper',
    displayName: 'Safe Zone NGO',
    avatarUrl: 'https://i.pravatar.cc/150?u=2',
    isVerified: true,
  );

  static List<Post> getPosts() {
    return [
      Post(
        id: 'p1',
        author: _user1,
        content:
            "Just attended the workshop on digital safety. It's incredible how many tools are available to protect ourselves online. #StaySafe",
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 124,
        comments: 18,
      ),
      Post(
        id: 'p2',
        author: User.anonymous,
        content:
            "I finally found the courage to speak up today. If you are reading this, know that you are not alone.",
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 892,
        comments: 145,
      ),
      Post(
        id: 'p3',
        author: _user2,
        content:
            "URGENT: Flood of reports coming from the downtown district. Volunteers are en route. Please verify your location if you use the SOS feature.",
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        likes: 56,
        comments: 12,
        isEmergency: true,
      ),
    ];
  }
}
