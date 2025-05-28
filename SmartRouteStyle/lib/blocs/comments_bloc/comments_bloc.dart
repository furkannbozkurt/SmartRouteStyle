import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_routes/models/comment_model.dart';

part 'comments_event.dart';
part 'comments_state.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final SharedPreferences _sharedPreferences;
  CommentsBloc(this._sharedPreferences) : super(CommentsState.initial()) {
    on<CommentsLoad>((event, emit) {
      final comments = _sharedPreferences.getString("comments");
      if (comments != null) {
        final jsonData = jsonDecode(comments) as List;
        commentsList = jsonData.map((e) => Comment.fromJson(e)).toList();
      }
    });
    on<CommentsFetch>((event, emit) {
      emit(state.copyWith(commentsOption: none()));
      final filteredComments = commentsList
          .where((element) => element.commentName == event.commentName)
          .toList();
      emit(state.copyWith(commentsOption: some(filteredComments)));
    });
    on<CommentAdd>((event, emit) async {
      final newComment = Comment(
        commentName: event.commentName,
        comment: event.comment,
      );
      commentsList.add(newComment);
      final jsonData = commentsList.map((e) => e.toMap()).toList();
      await _sharedPreferences.setString("comments", jsonEncode(jsonData));
      add(CommentsFetch(commentName: event.commentName));
    });
  }

  List<Comment> commentsList = [];
}
