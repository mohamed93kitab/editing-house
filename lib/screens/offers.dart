import 'package:editing_house/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../custom/useful_elements.dart';
import '../helpers/shimmer_helper.dart';
import '../repositories/product_repository.dart';
import '../ui_elements/product_card.dart';

class Offers extends StatefulWidget {
  const Offers();

  @override
  State<Offers> createState() => _OffersState();
}

class _OffersState extends State<Offers> {
  ScrollController _mainScrollController = ScrollController();
  ScrollController _offerProductScrollController;

  int _offerProductPage = 1;
  bool _showOfferLoadingContainer = false;
  bool _isAllProductInitial = true;
  List _offerProductList = [];

  fetchOfferProducts() async {
    var productResponse =
    await ProductRepository().getOfferProducts(page: _offerProductPage);

    _offerProductList.addAll(productResponse.products);
    _isAllProductInitial = false;
    _showOfferLoadingContainer = false;
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
          _offerProductPage++;
        });
        _showOfferLoadingContainer = true;
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
    _offerProductList.clear();
    _isAllProductInitial = true;
    _offerProductPage = 1;
    _showOfferLoadingContainer = false;
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
        title: Text(AppLocalizations.of(context).home_screen_flash_deal, style: TextStyle(
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

                      buildOffersList(context),

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


  Widget buildOffersList(context) {
    if (_isAllProductInitial && _offerProductList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper().buildProductGridShimmer(
              scontroller: _offerProductScrollController));
    } else if (_offerProductList.length > 0) {
      return MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          itemCount: _offerProductList.length,
          shrinkWrap: true,
          padding: EdgeInsets.only(top: 20.0, bottom: 10, left: 18, right: 18),
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return ProductCard(
              id: _offerProductList[index].id,
              image: _offerProductList[index].thumbnail_image,
              name: _offerProductList[index].name,
              main_price: _offerProductList[index].main_price,
              stroked_price: _offerProductList[index].stroked_price,
              has_discount: _offerProductList[index].has_discount,
              discount: _offerProductList[index].discount,
              currency_symbol: _offerProductList[index].currency_symbol,
            );
          });
    } else {
      return Container(); // should never be happening
    }
  }

  Container buildProductLoadingContainer() {
    return Container(
      height: _showOfferLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(AppLocalizations.of(context).common_loading_more_products),
      ),
    );
  }
}
