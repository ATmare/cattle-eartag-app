import 'package:flutter/material.dart';

/*
    Class returns a Header for Sliver-based scrollable screens
 */
class SliverHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final int amountAnimals;

  SliverHeader(this.title, this.subtitle, [this.amountAnimals = 0]);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floating: false,
      expandedHeight: 120.0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding:
            EdgeInsets.only(top: 0.0, bottom: 20.0, left: 20.0, right: 20.0),
        title: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (amountAnimals > 0)
                    Text(
                      amountAnimals.toString() + '/ 8',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                        color: amountAnimals > 8
                            ? Theme.of(context).errorColor
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                ],
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
