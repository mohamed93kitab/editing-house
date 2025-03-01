import 'package:editing_house/custom/box_decorations.dart';
import 'package:editing_house/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:editing_house/screens/product_details.dart';
import 'package:editing_house/app_config.dart';
import 'package:intl/intl.dart' as Intl;
class ProductCard extends StatefulWidget {

  int id;
  String image;
  String name;
  String main_price;
  String stroked_price;
  bool has_discount;
  var discount;
  var currency_symbol;

  ProductCard({Key key,this.id, this.image, this.name, this.main_price,this.stroked_price,this.has_discount,this.discount ,this.currency_symbol}) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    var formatter = Intl.NumberFormat('#,###,000');
    print((MediaQuery.of(context).size.width - 48 ) / 2);
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ProductDetails(id: widget.id,);
        }));
      },
      child: Container(
        padding: EdgeInsets.only(bottom: 12),
        decoration: BoxDecorations.buildBoxDecoration_1(radius: 18).copyWith(

        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                        width: double.infinity,
                        //height: 158,
                        child: ClipRRect(
                          clipBehavior: Clip.hardEdge,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(18), bottom: Radius.zero),
                            child: Image.network(
                              widget.image,
                              fit: BoxFit.cover,
                            ))),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Text(
                      widget.name,
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      style: TextStyle(
                          color: MyTheme.font_grey,
                          fontSize: 14,
                          height: 1.3,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      widget.has_discount ?
                      Padding(
                        padding: EdgeInsets.fromLTRB(6, 0, 6, 0),
                        child: Text(
                          formatter.format(int.parse(widget.stroked_price)) + " " + widget.currency_symbol,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              decoration:TextDecoration.lineThrough,
                              color: MyTheme.medium_grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                      ):Container(height: 0.0,),

                      Padding(
                        padding: EdgeInsets.fromLTRB(6, 0, 6, 0),
                        child: Text(
                          formatter.format(int.parse(widget.main_price)) + " " + widget.currency_symbol,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              color: MyTheme.accent_color,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ]),

            Visibility(
              visible: widget.has_discount,
              child: Positioned.fill(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    padding: EdgeInsets.symmetric(horizontal: 12,vertical: 6),
                    decoration: BoxDecoration(
                      color: MyTheme.accent_color,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x14000000),
                          offset: Offset(-1, 1),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      widget.discount??"",
                      style: TextStyle(
                        fontSize: 10,
                        color: const Color(0xffffffff),
                        fontWeight: FontWeight.w700,
                        height: 1.8,
                      ),
                      textHeightBehavior:
                      TextHeightBehavior(applyHeightToFirstAscent: false),
                      softWrap: false,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
