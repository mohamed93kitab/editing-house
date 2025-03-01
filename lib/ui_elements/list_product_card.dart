import 'package:editing_house/custom/box_decorations.dart';
import 'package:editing_house/helpers/shared_value_helper.dart';
import 'package:editing_house/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:editing_house/screens/product_details.dart';
import 'package:intl/intl.dart' as Intl;
class ListProductCard extends StatefulWidget {
  int id;
  String image;
  String name;
  String main_price;
  String stroked_price;
  bool has_discount;
  var currency_symbol;

  ListProductCard(
      {Key key,
      this.id,
      this.image,
      this.name,
      this.main_price,
      this.stroked_price,
      this.has_discount,
      this.currency_symbol
      })
      : super(key: key);

  @override
  _ListProductCardState createState() => _ListProductCardState();
}

class _ListProductCardState extends State<ListProductCard> {
  @override
  Widget build(BuildContext context) {
    var formatter = Intl.NumberFormat('#,###,000');
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ProductDetails(
            id: widget.id,
          );
        }));
      },
      child: Container(
        decoration: BoxDecorations.buildBoxDecoration_1(),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Container(
              width: 100,
              height: 100,
              child: ClipRRect(
                  borderRadius: BorderRadius.horizontal(
                      left: app_language_rtl.$ ? Radius.zero : Radius.circular(6), right: app_language_rtl.$ ? Radius.circular(6) : Radius.zero
                  ),
                  child: Image.network(
                    widget.image,
                    fit: BoxFit.cover,
                  ))),
          Container(
            padding: EdgeInsets.only(top: 10, left: 12,right: 12,bottom: 14),
            width: 240,
            height: 100,
           //color: Colors.red,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  //color:Colors.blue,
                  child: Text(
                    widget.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,

                    style: TextStyle(
                        color: MyTheme.font_grey,
                        fontSize: 14,
                        height: 1.6,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                Container(
                  //color:Colors.green,
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Text(
                        formatter.format(int.parse(widget.main_price)) + " " + widget.currency_symbol,
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        style: TextStyle(
                            color: MyTheme.accent_color,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      widget.has_discount
                          ? Text(
                            " " + formatter.format(int.parse(widget.stroked_price)) + " " + widget.currency_symbol,
                            textAlign: TextAlign.left,
                            maxLines: 1,
                            style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: MyTheme.medium_grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w400),
                          )
                          : Container(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
