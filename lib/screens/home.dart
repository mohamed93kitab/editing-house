import 'package:editing_house/custom/common_functions.dart';
import 'package:editing_house/dummy_data/messengers.dart';
import 'package:editing_house/my_theme.dart';
import 'package:editing_house/presenter/cart_counter.dart';
import 'package:editing_house/repositories/cart_repository.dart';
import 'package:editing_house/screens/cart.dart';
import 'package:editing_house/screens/filter.dart';
import 'package:editing_house/screens/flash_deal_list.dart';
import 'package:editing_house/screens/messenger_list.dart';
import 'package:badges/badges.dart' as badges;
import 'package:editing_house/screens/top_selling_products.dart';
import 'package:editing_house/screens/category_products.dart';
import 'package:editing_house/screens/category_list.dart';
import 'package:editing_house/ui_sections/drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:editing_house/repositories/sliders_repository.dart';
import 'package:editing_house/repositories/category_repository.dart';
import 'package:editing_house/repositories/product_repository.dart';
import 'package:editing_house/app_config.dart';

import 'package:editing_house/ui_elements/product_card.dart';
import 'package:editing_house/helpers/shimmer_helper.dart';
import 'package:editing_house/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:editing_house/custom/box_decorations.dart';
import 'package:editing_house/ui_elements/mini_product_card.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:editing_house/screens/offers.dart';
import 'package:flutter_svg/svg.dart';

import 'new_arrival_screen.dart';
class Home extends StatefulWidget {

  Home({Key key, this.title, this.show_back_button = false, go_back = true, this.counter})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final CartCounter counter;

  final String title;
  bool show_back_button;
  bool go_back;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _current_slider = 0;
  ScrollController _allProductScrollController;
  ScrollController _featuredCategoryScrollController;
  ScrollController _mainScrollController = ScrollController();

  AnimationController pirated_logo_controller;
  Animation pirated_logo_animation;

  CartCounter counter = CartCounter();


  getCartCount()async {

    var res = await CartRepository().getCartCount();

    counter.controller.sink.add(res.count);

  }

  fetchCart(){
    getCartCount();
  }


  var _carouselImageList = [];
  var _bannerOneImageList = [];
  var _bannerTwoImageList = [];
  var _featuredCategoryList = [];

  bool _isCategoryInitial = true;

  bool _isCarouselInitial = true;
  bool _isBannerOneInitial = true;
  bool _isBannerTwoInitial = true;

  var _featuredProductList = [];
  bool _isFeaturedProductInitial = true;
  int _totalFeaturedProductData = 0;
  int _featuredProductPage = 1;
  bool _showFeaturedLoadingContainer = false;

  var _allProductList = [];
  bool _isAllProductInitial = true;
  int _totalAllProductData = 0;
  int _allProductPage = 1;
  bool _showAllLoadingContainer = false;
  int _cartCount = 0;
  // getCartCount() async {
  //   var res = await CartRepository().getCartCount();
  //   widget.counter.controller.sink.add(res.count);
  // }
  @override
  void initState() {
    // print("app_mobile_language.en${app_mobile_language.$}");
    // print("app_language.${app_language.$}");
    // print("app_language_rtl${app_language_rtl.$}");

    // TODO: implement initState
    super.initState();
    fetchCart();
    // In initState()
    if (AppConfig.purchase_code == "") {
      initPiratedAnimation();
    }

    fetchAll();

    _mainScrollController.addListener(() {
      //print("position: " + _xcrollController.position.pixels.toString());
      //print("max: " + _xcrollController.position.maxScrollExtent.toString());

      if (_mainScrollController.position.pixels ==
          _mainScrollController.position.maxScrollExtent) {
        setState(() {
          _allProductPage++;
        });
        _showAllLoadingContainer = true;
        fetchAllProducts();
      }
    });
  }




  fetchAll() {

    getCartCount();

    fetchCarouselImages();
    fetchBannerOneImages();
    fetchBannerTwoImages();
    fetchFeaturedCategories();
    fetchFeaturedProducts();
    fetchAllProducts();
  }

  fetchCarouselImages() async {
    var carouselResponse = await SlidersRepository().getSliders();
    carouselResponse.sliders.forEach((slider) {
      _carouselImageList.add(slider.photo);
    });
    _isCarouselInitial = false;
    setState(() {});
  }

  fetchBannerOneImages() async {
    var bannerOneResponse = await SlidersRepository().getBannerOneImages();
    bannerOneResponse.sliders.forEach((slider) {
      _bannerOneImageList.add(slider.photo);
    });
    _isBannerOneInitial = false;
    setState(() {});
  }

  fetchBannerTwoImages() async {
    var bannerTwoResponse = await SlidersRepository().getBannerTwoImages();
    bannerTwoResponse.sliders.forEach((slider) {
      _bannerTwoImageList.add(slider.photo);
    });
    _isBannerTwoInitial = false;
    setState(() {});
  }

  fetchFeaturedCategories() async {
    var categoryResponse = await CategoryRepository().getFeturedCategories();
    _featuredCategoryList.addAll(categoryResponse.categories);
    _isCategoryInitial = false;
    setState(() {});
  }

  fetchFeaturedProducts() async {
    var productResponse = await ProductRepository().getFeaturedProducts(
      page: _featuredProductPage,
    );

    _featuredProductList.addAll(productResponse.products);
    _isFeaturedProductInitial = false;
    _totalFeaturedProductData = productResponse.meta.total;
    _showFeaturedLoadingContainer = false;
    setState(() {});
  }

  fetchAllProducts() async {
    var productResponse =
        await ProductRepository().getAllProducts(page: _allProductPage);

    _allProductList.addAll(productResponse.products);
    _isAllProductInitial = false;
    _totalAllProductData = productResponse.meta.total;
    _showAllLoadingContainer = false;
    setState(() {});
  }

  reset() {
    _carouselImageList.clear();
    _bannerOneImageList.clear();
    _bannerTwoImageList.clear();
    _featuredCategoryList.clear();

    _isCarouselInitial = true;
    _isBannerOneInitial = true;
    _isBannerTwoInitial = true;
    _isCategoryInitial = true;
    _cartCount = 0;

    setState(() {});

    resetFeaturedProductList();
    resetAllProductList();
  }

  Future<void> _onRefresh() async {
    reset();
    fetchAll();
  }

  resetFeaturedProductList() {
    _featuredProductList.clear();
    _isFeaturedProductInitial = true;
    _totalFeaturedProductData = 0;
    _featuredProductPage = 1;
    _showFeaturedLoadingContainer = false;
    setState(() {});
  }

  resetAllProductList() {
    _allProductList.clear();
    _isAllProductInitial = true;
    _totalAllProductData = 0;
    _allProductPage = 1;
    _showAllLoadingContainer = false;
    setState(() {});
  }

  initPiratedAnimation() {
    pirated_logo_controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    pirated_logo_animation = Tween(begin: 40.0, end: 60.0).animate(
        CurvedAnimation(
            curve: Curves.bounceOut, parent: pirated_logo_controller));

    pirated_logo_controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        pirated_logo_controller.repeat();
      }
    });

    pirated_logo_controller.forward();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pirated_logo_controller?.dispose();
    _mainScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    //print(MediaQuery.of(context).viewPadding.top);
    return WillPopScope(
      onWillPop: () async {
        CommonFunctions(context).appExitDialog();
        return widget.go_back;
      },
      child: Directionality(
        textDirection:
            app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: MyTheme.light_bg,
              key: _scaffoldKey,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(76),
                child: buildAppBar(statusBarHeight, context),
              ),
              drawer: MainDrawer(),
              body: Stack(
                children: [
                  RefreshIndicator(
                    color: MyTheme.accent_color,
                    backgroundColor: Colors.white,
                    onRefresh: _onRefresh,
                    displacement: 0,
                    child: CustomScrollView(
                      controller: _mainScrollController,
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      slivers: <Widget>[
                        SliverList(
                          delegate: SliverChildListDelegate([
                            AppConfig.purchase_code == ""
                                ? Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      9.0,
                                      16.0,
                                      9.0,
                                      0.0,
                                    ),
                                    child: Container(
                                      height: MediaQuery.of(context).size.width < 600 ? 140 : 200,
                                      color: Colors.black,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                              left: 20,
                                              top: 0,
                                              child: AnimatedBuilder(
                                                  animation:
                                                      pirated_logo_animation,
                                                  builder: (context, child) {
                                                    return Image.asset(
                                                      "assets/pirated_square.png",
                                                      height:
                                                          pirated_logo_animation
                                                              .value,
                                                      color: Colors.white,
                                                    );
                                                  })),
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 24.0, left: 24, right: 24),
                                              child: Text(
                                                "This is a pirated app. Do not use this. It may have security issues.",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(height: 18,),

                            buildHomeCarouselSlider(context),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                18.0,
                                0.0,
                                18.0,
                                18,
                              ),
                              child: buildHomeMenuRow1(context),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                18.0,
                                0.0,
                                18.0,
                                0.0,
                              ),
                              child: buildHomeMenuRow2(context),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                18.0,
                                20.0,
                                18.0,
                                0.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)
                                        .home_screen_featured_categories,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 165,
                              child: buildHomeFeaturedCategories(context),
                            ),
                            _bannerOneImageList.length == 0 ? Container() : buildHomeBannerOne(context),
                          ]),
                        ),



                        SliverList(
                          delegate: SliverChildListDelegate([
                            Container(
                              color: MyTheme.secondary_color,
                              child: Stack(
                                children: [
                                  Container(
                                    height: 180,
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Image.asset("assets/background_1.png")
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10.0, right: 18.0, left: 18.0),
                                        child: Text(
                                          AppLocalizations.of(context)
                                              .home_screen_featured_products,
                                          style: TextStyle(
                                              color: MyTheme.accent_color,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      buildHomeFeatureProductHorizontalList()
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        ),

                        SliverList(
                          delegate: SliverChildListDelegate([
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                18.0,
                                18.0,
                                20.0,
                                0.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)
                                        .home_screen_all_products,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  buildHomeAllProducts2(context),
                                ],
                              ),
                            ),
                            Container(
                              height: 80,
                            )
                          ]),
                        ),
                      ],
                    ),
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: buildProductLoadingContainer())
                ],
              )),
        ),
      ),
    );
  }

  Widget  buildHomeAllProducts(context) {
    if (_isAllProductInitial && _allProductList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper().buildProductGridShimmer(
              scontroller: _allProductScrollController));
    } else if (_allProductList.length > 0) {
      //snapshot.hasData

      return GridView.builder(
        // 2
        //addAutomaticKeepAlives: true,
        itemCount: _allProductList.length,
        controller: _allProductScrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.618),
        padding: EdgeInsets.all(16.0),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          // 3
          return ProductCard(
              id: _allProductList[index].id,
              image: _allProductList[index].thumbnail_image,
              name: _allProductList[index].name,
              main_price: _allProductList[index].main_price,
              stroked_price: _allProductList[index].stroked_price,
              has_discount: _allProductList[index].has_discount,
            discount: _allProductList[index].discount,
            currency_symbol: _allProductList[index].currency_symbol
          );
        },
      );
    } else if (_totalAllProductData == 0) {
      return Center(
          child: Text(
              AppLocalizations.of(context).common_no_product_is_available));
    } else {
      return Container(); // should never be happening
    }
  }

  Widget buildHomeAllProducts2(context) {
    if (_isAllProductInitial && _allProductList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper().buildProductGridShimmer(
              scontroller: _allProductScrollController));
    } else if (_allProductList.length > 0) {
      return MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          itemCount: _allProductList.length,
          shrinkWrap: true,
          padding: EdgeInsets.only(top: 20.0, bottom: 10, left: 18, right: 18),
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return ProductCard(
                id: _allProductList[index].id,
                image: _allProductList[index].thumbnail_image,
                name: _allProductList[index].name,
                main_price: _allProductList[index].main_price,
                stroked_price: _allProductList[index].stroked_price,
                has_discount: _allProductList[index].has_discount,
              discount: _allProductList[index].discount,
              currency_symbol: _allProductList[index].currency_symbol,
            );
          });
    } else if (_totalAllProductData == 0) {
      return Center(
          child: Text(
              AppLocalizations.of(context).common_no_product_is_available));
    } else {
      return Container(); // should never be happening
    }
  }

  Widget  buildHomeFeaturedCategories(context) {
    if (_isCategoryInitial && _featuredCategoryList.length == 0) {
      return ShimmerHelper().buildHorizontalGridShimmerWithAxisCount(
          crossAxisSpacing: 14.0,
          mainAxisSpacing: 14.0,
          item_count: 10,
          mainAxisExtent: 120.0,
          controller: _featuredCategoryScrollController);
    } else if (_featuredCategoryList.length > 0) {
      //snapshot.hasData
      return GridView.builder(
          padding:
              const EdgeInsets.only(left: 18, right: 18, top: 13, bottom: 20),
          scrollDirection: Axis.horizontal,
          controller: _featuredCategoryScrollController,
          itemCount: _featuredCategoryList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 90),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return CategoryProducts(
                    category_id: _featuredCategoryList[index].id,
                    category_name: _featuredCategoryList[index].name,
                  );
                }));
              },
              child: Column(
               // mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 90,
                      height: 90,
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: MyTheme.white,
                          borderRadius: BorderRadius.circular(88),
                          border: Border.all(width: 1, color: MyTheme.accent_color.withOpacity(.6))
                      ),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(88),
                          child: Image.network(
                             _featuredCategoryList[index].icon,
                            fit: BoxFit.cover,
                            width: 90,
                          ))),
                  Container(
                    margin: EdgeInsets.only(top: 12),
                    alignment: Alignment.center,
                    color: MyTheme.accent_color,
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 4),
                    child: Text(
                      _featuredCategoryList[index].name,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: true,
                      style:
                          TextStyle(fontSize: 11, color: MyTheme.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          });
    } else if (!_isCategoryInitial && _featuredCategoryList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context).home_screen_no_category_found,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }

  Widget buildHomeFeatureProductHorizontalList() {
    if (_isFeaturedProductInitial == true && _featuredProductList.length == 0) {
      return Row(
        children: [
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 64) / 3)),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 64) / 3)),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 160) / 3)),
        ],
      );
    } else if (_featuredProductList.length > 0) {
      return SingleChildScrollView(
        child: SizedBox(
          height: 248,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                setState(() {
                  _featuredProductPage++;
                });
                fetchFeaturedProducts();
              }
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(18.0),
              separatorBuilder: (context, index) => SizedBox(
                width: 14,
              ),
              itemCount: _totalFeaturedProductData > _featuredProductList.length
                  ? _featuredProductList.length + 1
                  : _featuredProductList.length,
              scrollDirection: Axis.horizontal,
              //itemExtent: 135,

              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              itemBuilder: (context, index) {
                return (index == _featuredProductList.length)
                    ? SpinKitFadingFour(
                        itemBuilder: (BuildContext context, int index) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                          );
                        },
                      )
                    : MiniProductCard(
                        id: _featuredProductList[index].id,
                        image: _featuredProductList[index].thumbnail_image,
                        name: _featuredProductList[index].name,
                        main_price: _featuredProductList[index].main_price,
                        stroked_price:
                            _featuredProductList[index].stroked_price,
                        has_discount: _featuredProductList[index].has_discount,
                        currency_symbol: _featuredProductList[index].currency_symbol
                );
              },
            ),
          ),
        ),
      );
    } else {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)
                .product_details_screen_no_related_product,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    }
  }

Widget  buildHomeMenuRow1(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return TopSellingProducts();
              }));
            },
            child: Container(
              height: 90,
              width: MediaQuery.of(context).size.width / 3 - 4,
              decoration: BoxDecorations.buildBoxDecoration_3(radius: 18),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                        height: 20,
                        width: 20,
                        child: SvgPicture.asset("assets/best_selling.svg", color: MyTheme.white)),
                  ),
                  Text(AppLocalizations.of(context).home_screen_top_sellers,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: MyTheme.white,
                          fontWeight: FontWeight.w300)),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 14.0),
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
               // return FlashDealList();
                return Offers();
              }));
            },
            child: Container(
              height: 90,
              decoration: BoxDecorations.buildBoxDecoration_3(radius: 18),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                        height: 20,
                        width: 20,
                        child: SvgPicture.asset("assets/outlet.svg", color: MyTheme.white)),
                  ),
                  Text(AppLocalizations.of(context).home_screen_flash_deal,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: MyTheme.white,
                          fontWeight: FontWeight.w300)),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

 Widget buildHomeMenuRow2(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                // return CategoryList(
                //   is_top_category: true,
                // );
                return NewArrival();
              }));
            },
            child: Container(
              height: 90,
              width: MediaQuery.of(context).size.width / 3 - 4,
              decoration: BoxDecorations.buildBoxDecoration_3(radius: 18),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                        height: 20,
                        width: 20,
                        child: SvgPicture.asset("assets/new_arrival.svg", color: MyTheme.white,)),
                  ),
                  Text(
                    AppLocalizations.of(context).home_screen_new_arrival,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: MyTheme.white,
                        fontWeight: FontWeight.w300),
                  )
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          width: 14.0,
        ),
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Filter(
                  selected_filter: "brands",
                );
              }));
            },
            child: Container(
              height: 90,
              width: MediaQuery.of(context).size.width / 3 - 4,
              decoration: BoxDecorations.buildBoxDecoration_3(radius: 18),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Container(
                        height: 28,
                        width: 28,
                        child: SvgPicture.asset("assets/brands.svg", color: MyTheme.white, width: 30, height: 30,fit: BoxFit.contain,)),
                  ),
                  Text(AppLocalizations.of(context).home_screen_brands,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: MyTheme.white,
                          fontWeight: FontWeight.w300)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

Widget  buildHomeCarouselSlider(context) {
    if (_isCarouselInitial && _carouselImageList.length == 0) {
      return Padding(
          padding:
              const EdgeInsets.only(left: 18, right: 18, top: 0, bottom: 20),
          child: ShimmerHelper().buildBasicShimmer(height: 120));
    } else if (_carouselImageList.length > 0) {

      return Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
                aspectRatio: MediaQuery.of(context).size.width < 600 ? 338 / 140 : 310 / 100,
                viewportFraction: 1,
                initialPage: 0,
                enableInfiniteScroll: true,
                reverse: false,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 5),
                autoPlayAnimationDuration: Duration(milliseconds: 1000),
                autoPlayCurve: Curves.easeInExpo,
                enlargeCenterPage: false,
                scrollDirection: Axis.horizontal,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current_slider = index;
                  });
                }),
            items: _carouselImageList.map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Padding(
                    padding: const EdgeInsets.only(
                        left: 18, right: 18, top: 0, bottom: 0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          //color: Colors.amber,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(color: MyTheme.soft_accent_color.withOpacity(.2), offset: Offset(1, 4), blurRadius: 18),
                              ]
                            ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(18)),
                                child: Image.network(
                                   i,
                                  height: MediaQuery.of(context).size.width < 600 ? 140 : 260,
                                  fit: BoxFit.cover,
                                ))),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _carouselImageList.map((url) {
                int index = _carouselImageList.indexOf(url);
                return Container(
                  width: _current_slider == index ? 14 : 12,
                  height: _current_slider == index ? 9 : 7,
                  margin: EdgeInsets.only(
                      bottom: 18, left: 4.0, right: 4, top: 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _current_slider == index
                        ? MyTheme.accent_color
                        : Color.fromRGBO(112, 112, 112, .3),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    } else if (!_isCarouselInitial && _carouselImageList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context).home_screen_no_carousel_image_found,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }

Widget  buildHomeBannerOne(context) {
    if (_isBannerOneInitial && _bannerOneImageList.length == 0) {
      return Padding(
          padding:
              const EdgeInsets.only(left: 18.0, right: 18, top: 10, bottom: 20),
          child: ShimmerHelper().buildBasicShimmer(height: 120));
    } else if (_bannerOneImageList.length > 0) {
      return Padding(
        padding: app_language_rtl.$
            ? const EdgeInsets.only(right: 9.0)
            : const EdgeInsets.only(left: 9.0),
        child: CarouselSlider(
          options: CarouselOptions(
              aspectRatio: 270 / 120,
              viewportFraction: .99,
              initialPage: 0,
              padEnds: false,
              enableInfiniteScroll: false,
              reverse: false,
              autoPlay: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _current_slider = index;
                });
              }),
          items: _bannerOneImageList.map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 9.0, right: 9, top: 20.0, bottom: 20),
                  child: Container(
                    //color: Colors.amber,
                      width: double.infinity,
                      decoration: BoxDecorations.buildBoxDecoration_1(),
                      child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          child: Image.network(
                            i,
                            fit: BoxFit.cover,
                          ))),
                );
              },
            );
          }).toList(),
        ),
      );
    } else if (!_isBannerOneInitial && _bannerOneImageList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context).home_screen_no_carousel_image_found,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }

 Widget buildHomeBannerTwo(context) {
    if (_isBannerTwoInitial && _bannerTwoImageList.length == 0) {
      return Padding(
          padding:
              const EdgeInsets.only(left: 18.0, right: 18, top: 10, bottom: 10),
          child: ShimmerHelper().buildBasicShimmer(height: 120));
    } else if (_bannerTwoImageList.length > 0) {
      return Padding(
        padding: app_language_rtl.$
            ? const EdgeInsets.only(right: 9.0)
            : const EdgeInsets.only(left: 9.0),
        child: CarouselSlider(
          options: CarouselOptions(
              aspectRatio: 270 / 120,
              viewportFraction: 0.7,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 5),
              autoPlayAnimationDuration: Duration(milliseconds: 1000),
              autoPlayCurve: Curves.easeInExpo,
              enlargeCenterPage: false,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index, reason) {
                setState(() {
                  _current_slider = index;
                });
              }),
          items: _bannerTwoImageList.map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 9.0, right: 9, top: 20.0, bottom: 10),
                  child: Container(
                      width: double.infinity,

                      decoration: BoxDecorations.buildBoxDecoration_1(),
                      child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          child: Image.network(
                            i,
                            fit: BoxFit.fill,
                          ))),
                );
              },
            );
          }).toList(),
        ),
      );
    } else if (!_isCarouselInitial && _carouselImageList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context).home_screen_no_carousel_image_found,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }

  AppBar buildAppBar(double statusBarHeight, BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      leading: IconButton(
        onPressed: (){
          _scaffoldKey.currentState.openDrawer();
        },
        icon: Container(
           width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: MyTheme.soft_accent_color
            ),
            child: Icon(Icons.menu, color: MyTheme.accent_color,)),
      ),
      actions: [
        // GestureDetector(
        //   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MessengerList())),
        //   child: Container(
        //     child: Padding(
        //         padding: const EdgeInsets.only(left: 15, right: 15, top: 18, bottom: 18),
        //         child: Image.asset("assets/chat.png",
        //             height: 22,
        //             color: Color.fromRGBO(153, 153, 153, 1))
        //       // padding: EdgeInsets.all(4),
        //
        //
        //     ),
        //   ),
        // ),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Cart(has_bottomnav: false, counter: counter))),
          child: Container(
              child: Padding(
                padding: app_language_rtl.$ ? EdgeInsets.only( left: 30.0, right: 15, top: 18) : EdgeInsets.only( left: 15, right: 30, top: 18),
                child:
                badges.Badge(
                  // toAnimate: false,
                  // shape: badges.BadgeShape.circle,
                  // badgeColor: MyTheme.accent_color,
                  // borderRadius: BorderRadius.circular(10),
                  child:
                  Image.asset(
                    "assets/heart.png",
                    color:  Color.fromRGBO(153, 153, 153, 1),
                    height: 22,
                  ),
                  // padding: EdgeInsets.all(4),
                  // badgeContent: StreamBuilder<int>(
                  //     stream: counter.controller.stream,
                  //     builder: (context, snapshot) {
                  //       if(snapshot.hasData)
                  //         return Text(snapshot.data.toString()+"", style: TextStyle(color: Colors.white,fontSize: 8));
                  //       return Text("0", style: TextStyle(color: Colors.white,fontSize: 8));
                  //     }
                  // ),
                ),
              ),
              ),
        ),
      ],
      // Don't show the leading button
      backgroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
      // title: Padding(
      //     // padding:
      //     //     const EdgeInsets.only(top: 40.0, bottom: 22, left: 18, right: 18),
      //     padding:
      //     const EdgeInsets.only(top: 20.0, bottom: 22, left: 0, right: 0),
      //     child: GestureDetector(
      //         onTap: () {
      //           Navigator.push(context, MaterialPageRoute(builder: (context) {
      //             return Filter();
      //           }));
      //         },
      //         child: buildHomeSearchBox(context))),
    );
  }

  buildHomeSearchBox(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: MyTheme.accent_color.withOpacity(.5)),
        borderRadius: BorderRadius.circular(12)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context).home_screen_search,
              style: TextStyle(fontSize: 13.0, color: MyTheme.accent_color.withOpacity(.5)),
            ),
            Image.asset(
              'assets/search.png',
              height: 16,
              //color: MyTheme.dark_grey,
              color: MyTheme.accent_color.withOpacity(.5),
            )
          ],
        ),
      ),
    );

  }

  Container buildProductLoadingContainer() {
    return Container(
      height: _showAllLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(_totalAllProductData == _allProductList.length
            ? AppLocalizations.of(context).common_no_more_products
            : AppLocalizations.of(context).common_loading_more_products),
      ),
    );
  }
}
