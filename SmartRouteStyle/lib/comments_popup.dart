import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_routes/blocs/comments_bloc/comments_bloc.dart';

Future<void> showCommentsPopup(BuildContext context,
    {required String commentsName}) {
  context.read<CommentsBloc>().add(CommentsFetch(commentName: commentsName));
  final textController = TextEditingController();
  return showDialog(
    context: context,
    builder: (context) {
      return BlocBuilder<CommentsBloc, CommentsState>(
        builder: (context, state) {
          return state.commentsOption.fold(() {
            return SizedBox();
          }, (a) {
            return Dialog(
              child: Container(
                height: MediaQuery.sizeOf(context).height * 0.9,
                width: MediaQuery.sizeOf(context).width * 0.9,
                child: Column(
                  children: [
                    SizedBox(height: 12),
                    Text(
                      "Yorumlar",
                      style: TextStyle(fontSize: 24.0),
                    ),
                    SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: a.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              "${index + 1}. ${a[index].comment}",
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 24.0,
                        left: 16.0,
                        right: 16.0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: textController,
                            decoration: InputDecoration.collapsed(
                              hintText: "Yorum ekle",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            onSubmitted: (value) {
                              context.read<CommentsBloc>().add(
                                    CommentAdd(
                                      commentName: commentsName,
                                      comment: value,
                                    ),
                                  );
                            },
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CommentsBloc>().add(CommentAdd(
                              commentName: commentsName,
                              comment: textController.text,
                            ));
                        textController.clear();
                      },
                      child: Text(
                        "Yorum Yap",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0)
                  ],
                ),
              ),
            );
          });
        },
      );
    },
  );
}
