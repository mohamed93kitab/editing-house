import 'package:editing_house/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:editing_house/screens/product_details.dart';
import 'package:editing_house/custom/box_decorations.dart';
import 'package:intl/intl.dart' as Intl;
class MiniProductCard extends StatefulWidget {
  int id;
  String image;
  String name;
  String main_price;
  String stroked_price;
  bool has_discount;
  var currency_symbol;

  MiniProductCard({Key key, this.id, this.image, this.name, this.main_price,this.stroked_price,this.has_discount, this.currency_symbol})
      : super(key: key);

  @override
  _MiniProductCardState createState() => _MiniProductCardState();
}

class _MiniProductCardState extends State<MiniProductCard> {
  @override
  Widget build(BuildContext context) {
    var formatter = Intl.NumberFormat('#,###,000');

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ProductDetails(id: widget.id);
        }));
      },
      child: Container(
        width: 135,
        decoration: BoxDecorations.buildBoxDecoration_1(),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                    width: double.infinity,
                    child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(6), bottom: Radius.zero),
                        child: Image.network(
                          widget.image,
                          fit: BoxFit.cover,
                        ))),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(8, 4, 8, 6),
                child: Text(
                  widget.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                      color: MyTheme.font_grey,
                      fontSize: 12,
                      height: 1.2,
                      fontWeight: FontWeight.w400),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 widget.has_discount ? Padding(
                    padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Text(
                      formatter.format(int.parse(widget.stroked_price)) + " " + widget.currency_symbol,
                      maxLines: 1,
                      style: TextStyle(
                          decoration:TextDecoration.lineThrough,
                          color: MyTheme.medium_grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ) :Container(),

                  Container(
                    padding: EdgeInsets.all(0),
                    child: Text(
                      formatter.format(int.parse(widget.main_price)) + " " + widget.currency_symbol,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: MyTheme.accent_color,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              )


            ]),
      ),
    );
  }
}
