import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

/*
    Class renders header section for edit-screens
 */
class EditScreenHeader extends StatelessWidget {
  final String smallTitle;
  final String title;
  final Function checkAction;
  final Function abortAction;

  EditScreenHeader({
    this.smallTitle = 'Bearbeiten',
    this.title = '',
    this.checkAction,
    this.abortAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme
          .of(context)
          .primaryColor,
      height: MediaQuery
          .of(context)
          .size
          .height * 0.2,
      padding: EdgeInsets.only(left: 8, right: 8, top: 0, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.white,
            ),
            onPressed: abortAction,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    smallTitle,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                AutoSizeText(
                  title,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.check,
              color: Colors.white,
            ),
            onPressed: checkAction,
          ),
        ],
      ),
    );
  }

}
