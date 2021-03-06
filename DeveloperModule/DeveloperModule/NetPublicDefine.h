//首页
#define      QUERY_INDEX                @"queryIndex"                           //获取首页的3个模块数据
#define      QUERY_RECOM                @"queryMoreRecommendGoods"              //获取特惠精选商品
#define      QUERY_HOT                  @"queryMoreHotGoods"                    //获取热卖商品

#define     GET_HEADLINE_THEMES         @"getHeadLineThemes"                    //获取首页推荐优惠专题
#define     GET_CHEAP_THEMES            @"getCheapThemes"                       //优惠专题列表展示
#define     GET_PRODUCTS_BY_THEMEID     @"getProductsByThemeId"                 //获取优惠专题的商品列表 分页获取
#define     GET_CHEAPCOLLECTION         @"getCheapCollection"                   //获取首页特惠精选商品
#define     GET_HOTCOLLECTION           @"getHotCollection"                     //获取首页热卖商品

//分类模块        
#define     GET_CATEGORY_LIST           @"getCategoryList"                      //一级分类列表
#define     GET_SECOND_CATEGORY_LIST    @"getSecondCategoryList"                //二级分类列表
#define     GET_PRODUCT_BY_CATID        @"getCheapProductsByCatId"              //分类专题内部的优惠专题列表展示
#define     GET_PRODUCTS_BY_SECONDCATID @"getProductsBySecondCatId"             //二级分类下面的商品列表

#define     GET_CATEGORY_CHEAP_THEME    @"getCategoryCheapTheme"                //获取分类优惠专题
#define     GET_PRODUCTS_BY_CHEAPTHEME  @"getProductByChepThemeId"              //获取专题下的产品列表

//商品模块
#define     GET_PRODUCT_DETAIL          @"getProductDetail"                     //获取商品详情
#define     GET_PRODUCTID_BY_COMBINE    @"getProductIdByCombine"                //获取某一规格的商品ID和库存
#define     GET_PRODUCTS_BY_PRICE       @"getProductsByPrice"                   //按照价格排序获取
#define     GET_PRODUCTS_BY_SALES       @"getProductsBySales"                   //按照销量排序获取
#define     GET_PRODUCTS_BY_TIME        @"getProductsByTime"                    //按照时间排序获取
#define     GET_PRODUCT_NEW_DETAIL      @"getNewProductDetail"                  //获取商品最新的详情

//晒客模块
#define     GET_SHOW_LIST               @"getShowList"                          //获取晒单列表
#define     GET_SHOW_DETAIL             @"getShowDetail"                        //获取晒单详情
#define     ADD_SHOW                    @"addShow"                              //添加晒一晒
#define     GET_SHOW_REVIEWLIST         @"getShowReviewList"                    //获取评论列表
#define     ADD_SHOW_REVIEW             @"addShowReview"                        //添加晒一晒评论

#define     GET_REVIEWLIST              @"getReviewList"                        //获取商品评论列表
#define     ADD_REVIEW                  @"addReview"                            //添加评论

//购物车模块
#define     Save_Cart                   @"saveCart"                             //添加购物车
#define     Query_Cart                  @"queryCart"                            //查询购物车
#define     Update_Quantity             @"updateQuantity"                       //更新购物车商品数量
#define     Delete_Cart                 @"deleteCart"                           //删除购物车商品

//订单模块
#define     ADD_ORDER                   @"submitOrder"                          //提交订单
#define     GET_ORDERLIST_BY_TYPE       @"queryOrderList"                       //根据订单状态获取订单列表（新接口）
#define     GET_ORDER_DETAIL            @"queryOrderDetail"                     //获取订单详情
#define     GET_ADDRESS_LIST            @"queryAddressList"                     //根据用户ID获取收货地址列表
#define     ADD_ADDREDD                 @"saveAddress"                          //新增收货地址
#define     DEL_ADDREDD                 @"deleteAddress"                        //删除收货地址
#define     UPDATE_ADDRESS              @"updateAddress"                        //更新地址
#define     GET_PRODUCT_NEW_DETAIL_CART @"getNewProductDetailByCart"            //提交订单时返回商品的最新详情
#define     CONFIRM_ORDER               @"updateOrderStateByHarvest"

//搜索模块
#define     GET_HOTKEYS                 @"getHotWords"                          //获取热门搜索热词
#define     SEARCH_RESULTS              @"getSearchResult"                      //搜索产品结果

//登录注册
#define     USER_LOGIN                  @"userLogin"                            //用户登录
#define     USER_REGIST                 @"userRegist"                           //用户注册
#define     GET_USER                    @"getUser"                              //用户信息查询
#define     UPDATE_USERINFO             @"updateUserInfo"                       //更新用户信息

//更多模块
#define     FEED_BACK                   @"saveFeedBack"                         //反馈
#define     CHECK_VERSION               @"checkVersion"                         //检测版本

//推送
#define     SEND_TOKEN                  @"insertToken"