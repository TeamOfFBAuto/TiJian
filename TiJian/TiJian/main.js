/**
 * Created by lcw on 16/5/31.
 */

defineClass('OrderInfoViewController',{
            pushToPayPageWithOrderId:function(orderId,orderNum){
            
            console.log("JSPatch 123456pppp");

            
            var pay = require('PayActionViewController').alloc().init();
            pay.orderId() = orderId;
            pay.orderNum() = orderNum;
            var price = self.valueForKey("_orderModel");
            pay.sumPrice() = price.real_price().floatValue();
            pay.payStyle() = price.payStyle().intValue();
            pay.lastViewController() = self.lastViewController();
            self.navigationController().pushViewController(pay,YES);
            }
})
