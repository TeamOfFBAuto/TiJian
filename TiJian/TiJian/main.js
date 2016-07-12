/**
 * Created by lcw on 16/5/31.
 */

//订单详情页->支付页 显示价格total_fee改为real_price
defineClass('OrderInfoViewController', [ ], { pushToPayPageWithOrderId_orderNum:function(orderId,orderNum)
{
            
            var pay = require('PayActionViewController').alloc().init();
            //setter
            pay.setOrderId(orderId);
            pay.setOrderNum(orderNum);
            require('OrderModel')
            var model = self.valueForKey("_orderModel");
            var real_price = model.valueForKey("real_price");
            pay.setSumPrice(real_price);
            var style = model.valueForKey("pay_type");
            pay.setPayStyle(style);
            
            pay.setLastViewController(self.lastViewController());
            
            self.navigationController().pushViewController_animated(pay,true);
} })


//订单列表-> 显示价格total_fee改为real_price
defineClass('OrderViewController', [ ], { clickToAction:function(sender) {
            
            var actionTyp = sender.valueForKey("actionType");
            if(actionTyp == 1) {
                var mode = sender.valueForKey("aModel");
                var orderId = mode.valueForKey("order_id");
                var orderNu = mode.valueForKey("order_no");
                var sumPri = mode.valueForKey("real_price");
                var paySty = mode.valueForKey("pay_type");
                self.pushToPayPageWithOrderId_orderNum_sumPrice_payStyle(orderId,orderNu,sumPri,paySty);

            }else
            {
                self.ORIGclickToAction(sender);
            }
}})

//筛选
defineClass('GPushView', [ ], {

    qingkongshaixuanBtnClicked: function() {

        require('NSMutableDictionary');
        self.setSelectDic(null);
        self.setSelectDic(NSMutableDictionary.dictionaryWithCapacity(1));
        self.tf_low().setText(null);
        self.tf_high().setText(null);

        self.tab1().reloadData();
        self.tab2().reloadData();
        self.tab3().reloadData();
        self.tab4().reloadData();
    }
})

//优惠劵->新人优惠劵特殊处理 type = 4在选择使用时修改为type = 1,满减处理
defineClass('MyCouponViewController', [ ], {useBtnClicked:function() {

    if (self.type() == 2) {
        require('NSMutableArray');
        require('CouponModel');
        require('NSArray')
        var arr = NSMutableArray.arrayWithCapacity(1);
        var tempArr;
        var tab0Array = self.valueForKey("_tab0Array");

        var count = tab0Array.count();
        for (var i = 0; i < count; i++) {

            var arr2 = tab0Array.objectAtIndex(i);

            var count2 = arr2.count();

            for (var j = 0; j < count2; j++) {

                var model = arr2.objectAtIndex(j);
                var isUsed = model.isUsed();
                if (isUsed){
                    var type = model.type().intValue();
                    if (type = 4){
                        model.setType("1");
                        model.setFull_money("0");
                        model.setMinus_money(model.newer_money());
                    }
                    tempArr = arr.toJS()
                    tempArr.push(model);
                }
            }


        }

        self.delegate().setUserSelectYouhuiquanArray(tempArr);
        self.delegate().jisuanPrice();
        self.navigationController().popViewControllerAnimated(YES);
    }else
    {
        self.ORIGuseBtnClicked();
    }

    
    
}})

//+ (BOOL)isValidateIDCard:(NSString *)value
//重写身份证号验证
defineClass('LTools', [ ], {

},{ isValidateIDCard:function(value)
{
    console.log("验证身份证");
    var num = value.length();
    if (num == 15 || num == 18)
    {
        return true;
    }
    return false;
}})


//修复首页右上角活动入口,未开启定位时未获取活动信息bug
defineClass('HomeViewController', [ ], { alertView_clickedButtonAtIndex:function(alertView,buttonIndex)
{
        var tag = alertView.tag();
        if (tag == 25) {
            self.ORIGalertView_clickedButtonAtIndex(alertView, buttonIndex);
        } else {
            self.getUnreadActivityNum();
            self.ORIGalertView_clickedButtonAtIndex(alertView, buttonIndex);
        }
}})

//体检报告下方资讯详情页每页分享按钮 version 3.0开始
defineClass('NewMedicalReportController',[],{didSelectRowAtIndexPath_tableView:function(indexPath, tableView)
{
    var section = indexPath.section();

    if (section == 0)
    {
        self.ORIGdidSelectRowAtIndexPath_tableView(indexPath,tableView);
    }else
    {
        var articleArray = self.valueForKey("_articleArray");
        var indexRow = indexPath.row();
        var acticleModel = articleArray.objectAtIndex(indexRow);

        var shareImageUrl = acticleModel.valueForKey("cover_pic");
        var shareTitle = acticleModel.valueForKey("title");
        var content = acticleModel.valueForKey("summary");
        var url = acticleModel.valueForKey("url");

        require('NSMutableDictionary');
        var dict = NSMutableDictionary.dictionaryWithCapacity(1);
        dict.setObject_forKey(shareImageUrl, 'shareImageUrl');
        dict.setObject_forKey(shareTitle, 'shareTitle');
        dict.setObject_forKey(content, 'shareContent');
        require('MiddleTools');

        MiddleTools.pushToWebFromViewController_weburl_extensionParams_moreInfo_hiddenBottom_updateParamsBlock(self,url,dict,true,true,null);
    }
}});

