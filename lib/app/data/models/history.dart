import 'package:isar/isar.dart';
import 'package:xdnmb_api/xdnmb_api.dart';

import '../../utils/extensions.dart';

part 'history.g.dart';

@Collection()
class BrowseHistory implements PostBase {
  @override
  final Id id;

  @override
  int forumId;

  @override
  int replyCount;

  @override
  String image;

  @override
  String imageExtension;

  // UTC
  @override
  DateTime postTime;

  @override
  String userHash;

  @override
  String name;

  @override
  String title;

  @override
  String content;

  @override
  bool isSage;

  @override
  bool isAdmin;

  @override
  bool isHidden;

  // UTC
  @Index()
  DateTime browseTime;

  int? browsePage;

  int? browsePostId;

  int? onlyPoBrowsePage;

  int? onlyPoBrowsePostId;

  BrowseHistory(
      {required this.id,
      required this.forumId,
      required this.replyCount,
      this.image = '',
      this.imageExtension = '',
      required DateTime postTime,
      required this.userHash,
      String name = '',
      String title = '',
      required String content,
      this.isSage = false,
      this.isAdmin = false,
      this.isHidden = false,
      required DateTime browseTime,
      this.browsePage,
      this.browsePostId,
      this.onlyPoBrowsePage,
      this.onlyPoBrowsePostId})
      : assert((browsePage != null && browsePostId != null) ||
            (onlyPoBrowsePage != null && onlyPoBrowsePostId != null)),
        assert((browsePage != null && browsePostId != null) ||
            (browsePage == null && browsePostId == null)),
        assert((onlyPoBrowsePage != null && onlyPoBrowsePostId != null) ||
            (onlyPoBrowsePage == null && onlyPoBrowsePostId == null)),
        postTime = postTime.toUtc(),
        name = name != '无名氏' ? name : '',
        title = title != '无标题' ? title : '',
        content = content.isNotEmpty ? content : '分享图片',
        browseTime = browseTime.toUtc();

  BrowseHistory.fromPost(
      {required Post mainPost,
      DateTime? browseTime,
      required int browsePage,
      required int browsePostId,
      bool isOnlyPo = false})
      : this(
            id: mainPost.id,
            forumId: mainPost.forumId,
            replyCount: mainPost.replyCount,
            image: mainPost.image,
            imageExtension: mainPost.imageExtension,
            postTime: mainPost.postTime,
            userHash: mainPost.userHash,
            name: mainPost.name,
            title: mainPost.title,
            content: mainPost.content,
            isSage: mainPost.isSage,
            isAdmin: mainPost.isAdmin,
            isHidden: mainPost.isHidden,
            browseTime: browseTime ?? DateTime.now(),
            browsePage: !isOnlyPo ? browsePage : null,
            browsePostId: !isOnlyPo ? browsePostId : null,
            onlyPoBrowsePage: isOnlyPo ? browsePage : null,
            onlyPoBrowsePostId: isOnlyPo ? browsePostId : null);

  void update(
      {required Post mainPost,
      DateTime? browseTime,
      required int browsePage,
      required int browsePostId,
      bool isOnlyPo = false}) {
    assert(id == mainPost.id, 'id must be the same');

    forumId = mainPost.forumId;
    replyCount = mainPost.replyCount;
    image = mainPost.image;
    imageExtension = mainPost.imageExtension;
    postTime = mainPost.postTime.toUtc();
    userHash = mainPost.userHash;
    name = mainPost.name != '无名氏' ? mainPost.name : '';
    title = mainPost.title != '无标题' ? mainPost.title : '';
    content = mainPost.content.isNotEmpty ? mainPost.content : '分享图片';
    isSage = mainPost.isSage;
    isAdmin = mainPost.isAdmin;
    isHidden = mainPost.isHidden;
    this.browseTime = browseTime ?? DateTime.now().toUtc();

    if (isOnlyPo) {
      onlyPoBrowsePage = browsePage;
      onlyPoBrowsePostId = browsePostId;
    } else {
      this.browsePage = browsePage;
      this.browsePostId = browsePostId;
    }
  }

  int? toIndex({bool isOnlyPo = false}) {
    if (isOnlyPo && onlyPoBrowsePage != null && onlyPoBrowsePostId != null) {
      return onlyPoBrowsePostId!.toIndex(onlyPoBrowsePage!);
    }

    if (!isOnlyPo && browsePage != null && browsePostId != null) {
      return browsePostId!.toIndex(browsePage!);
    }

    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BrowseHistory &&
          id == other.id &&
          forumId == other.forumId &&
          replyCount == other.replyCount &&
          image == other.image &&
          imageExtension == other.imageExtension &&
          postTime == other.postTime &&
          userHash == other.userHash &&
          name == other.name &&
          title == other.title &&
          content == other.content &&
          isSage == other.isSage &&
          isAdmin == other.isAdmin &&
          isHidden == other.isHidden &&
          browseTime == other.browseTime &&
          browsePage == other.browsePage &&
          browsePostId == other.browsePostId &&
          onlyPoBrowsePage == other.onlyPoBrowsePage &&
          onlyPoBrowsePostId == other.onlyPoBrowsePostId);

  @ignore
  @override
  int get hashCode => Object.hash(
      id,
      forumId,
      replyCount,
      image,
      imageExtension,
      postTime,
      userHash,
      name,
      title,
      content,
      isSage,
      isAdmin,
      isHidden,
      browseTime,
      browsePage,
      browsePostId,
      onlyPoBrowsePage,
      onlyPoBrowsePostId);
}
