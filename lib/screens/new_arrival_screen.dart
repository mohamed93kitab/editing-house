import 'package:editing_house/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../custom/useful_elements.dart';
import '../helpers/shimmer_helper.dart';
import '../repositories/product_repository.dart';
import '../ui_elements/product_card.dart';

class NewArrival extends StatefulWidget {
  const NewArrival();

  @override
  State<NewArrival> createState() => _NewArrivalState();
}

class _NewArrivalState extends State<NewArrival> {
  ScrollController _mainScrollController = ScrollController();
  ScrollController _offerProductScrollController;

  int _newArrivalProductPage = 1;
  bool _showNewArrivalLoadingContainer = false;
  bool _isNewArrivalProductInitial = true;
  List _NewArrivalProductList = [];

  fetchOfferProducts() async {
    var productResponse =
    await ProductRepository().getNewArrivalProducts(page: _newArrivalProductPage);

    _NewArrivalProductList.addAll(productResponse.products);
    _isNewArrivalProductInitial = false;
    _showNewArrivalLoadingContainer = false;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    fetchOfferProducts();
    _mainScrollController.addListener(() {
      //print("position: " + _xcrollController.position.pixels.toString());
      //print("max: " + _xcrollController.position.maxScrollExtent.toString());

      if (_mainScrollController.position.pixels ==
          _mainScrollController.position.maxScrollExtent) {
        setState(() {
          _newArrivalProductPage++;
        });
        _showNewArrivalLoadingContainer = true;
        fetchOfferProducts();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _mainScrollController.dispose();
  }

  reset() {
    _NewArrivalProductList.clear();
    _isNewArrivalProductInitial = true;
    _newArrivalProductPage = 1;
    _showNewArrivalLoadingContainer = false;
    setState(() {});
  }

  fetchAll() {
    fetchOfferProducts();
  }

  Future<void> _onRefresh() async {
    reset();
    fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.light_bg,
      appBar: AppBar(
        leading: Builder(
          builder: (context) =>
              UsefulElements.backButton(context, color: 'black'),
        ),
        title: Text(AppLocalizations.of(context).home_screen_new_arrival, style: TextStyle(
            color: MyTheme.medium_grey
        ),),
        centerTitle: true,
        backgroundColor: MyTheme.white,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
              onRefresh: _onRefresh,
              child: CustomScrollView(
                  controller: _mainScrollController,
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  slivers: <Widget>[

                    SliverList(
                        delegate: SliverChildListDelegate([

                          buildNewArrivalList(context),

                        ])
                    )

                  ])
          ),

          Align(
              alignment: Alignment.bottomCenter,
              child: buildProductLoadingContainer())

        ],
      ),
    );
  }


  Widget buildNewArrivalList(context) {
    if (_isNewArrivalProductInitial && _NewArrivalProductList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper().buildProductGridShimmer(
              scontroller: _offerProductScrollController));
    } else if (_NewArrivalProductList.length > 0) {
      return MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          itemCount: _NewArrivalProductList.length,
          shrinkWrap: true,
          padding: EdgeInsets.only(top: 20.0, bottom: 10, left: 18, right: 18),
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return ProductCard(
              id: _NewArrivalProductList[index].id,
              image: _NewArrivalProductList[index].thumbnail_image,
              name: _NewArrivalProductList[index].name,
              main_price: _NewArrivalProductList[index].main_price,
              stroked_price: _NewArrivalProductList[index].stroked_price,
              has_discount: _NewArrivalProductList[index].has_discount,
              discount: _NewArrivalProductList[index].discount,
              currency_symbol: _NewArrivalProductList[index].currency_symbol,
            );
          });
    } else {
      return Container(); // should never be happening
    }
  }

  Container buildProductLoadingContainer() {
    return Container(
      height: _showNewArrivalLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(AppLocalizations.of(context).common_loading_more_products),
      ),
    );
  }
}
