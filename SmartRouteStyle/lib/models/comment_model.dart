import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final String commentName;
  final String comment;

  const Comment({
    required this.commentName,
    required this.comment,
  });

  factory Comment.fromJson(Map<String, dynamic> map) {
    return Comment(
      commentName: map["commentName"],
      comment: map["comment"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "commentName": commentName,
      "comment": comment,
    };
  }

  @override
  List<Object?> get props => [
        commentName,
        comment,
      ];
}
