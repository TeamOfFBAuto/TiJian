/**
 * Created by lcw on 16/5/31.
 */

//订单详情页->支付页 显示价格total_fee改为real_price
defineClass('OrderInfoViewController', [ ], { pushToPayPageWithOrderId_orderNum:function(orderId,orderNum) {
            
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

defineClass('GPushView', [ ], {
            
            qingkongshaixuanBtnClicked: function() {
            
            console.log("xxxxx");
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














