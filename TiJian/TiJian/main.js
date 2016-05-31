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

    console.log("优惠劵1");

    if (self.type() == 2) {
        require('NSMutableArray');
        require('CouponModel');
        require('NSArray')
        var arr = NSMutableArray.arrayWithCapacity(1);
        var tempArr;
        var tab0Array = self.valueForKey("_tab0Array");

        console.log(tab0Array);
        var count = tab0Array.count();
        console.log(count);
        for (var i = 0; i < count; i++) {

            var arr2 = tab0Array.objectAtIndex(i);
            console.log(arr2);

            var count2 = arr2.count();
            console.log(count2);

            for (var j = 0; j < count2; j++) {

                var model = arr2.objectAtIndex(j);
                console.log(model);
                var isUsed = model.isUsed();
                console.log("isUsed:" + isUsed);
                if (isUsed){
                    var type = model.type().intValue();
                    console.log("type:" +  type);

                    if (type = 4){
                        model.setType("1");
                        model.setFull_money("0");
                        model.setMinus_money(model.newer_money());
                    }
                    tempArr = arr.toJS()
                    tempArr.push(model);
                    console.log(tempArr);
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







