package com.project.controller.ksh;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.inject.Inject;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import com.project.service.ksh.payment.OrderService;
import com.project.vodto.CouponInfos;
import com.project.vodto.NonOrderHistory;
import com.project.vodto.ShippingAddress;
import com.project.vodto.kjy.Memberkjy;
import com.project.vodto.ksh.OrderInfo;
import com.project.vodto.ksh.OrderIdAndQty;
import com.project.vodto.ksh.PaymentDTO;

@Controller
@RequestMapping(value = "/order/*")
public class OrderController {

	@Inject
	private OrderService os;

	// 리스트, 상세 -> 결제 페이지
	@RequestMapping(value = "requestOrder")
	public String getRequestOrder(@RequestParam("productId") String productId, @RequestParam("qty") int qty,
			Model model, HttpServletRequest request) {
		
		String path = "/order/requestOrder";
		String orderId = (String) request.getAttribute("orderId");
		model = this.returnPath(orderId, model, new OrderIdAndQty(), request, productId, qty);
		if (orderId.contains("N")) {
			path = "/order/requestNonOrder";
		}
		return path;
	}

	// 장바구니 -> 결제 페이지
	@RequestMapping(value = "requestOrder", method = RequestMethod.POST)
	public String postRequestOrder(Model model, OrderIdAndQty items, HttpServletRequest request) {
		
		String path = "/order/requestOrder";
		String orderId = (String) request.getAttribute("orderId");
		model = this.returnPath(orderId, model, items, request, "", 0);
		System.out.println(items.toString());
		if (orderId.contains("N")) {
			path = "/order/requestNonOrder";
		}

		return path;
	}

	public Model returnPath(String orderId, Model model, OrderIdAndQty items, HttpServletRequest request,
			String productId, int qty) {
		String impKey = (String) request.getAttribute("impKey");

		if (!productId.equals("") && qty > 0) {
			List<String> productIds = new ArrayList<String>();
			productIds.add(productId);
			items.setProductId(productIds);
			List<Integer> productQty = new ArrayList<Integer>();
			productQty.add(qty);
			items.setProductQuantity(productQty);
		}

		// 회원인지
		if (orderId.contains("O")) {
			// 쿠폰, 포인트, 적립금, 배송 주소록
			HttpSession session = request.getSession();
			Memberkjy member = (Memberkjy) session.getAttribute("loginMember");

			// member 다시 조회
			try {
				Memberkjy memberInfo = os.getMemberInfo(member.getMemberId());
				List<ShippingAddress> shippingAddr = os.getShippingAddress(member.getMemberId());
//						List<ShippingAddress> otherAddr = new ArrayList<ShippingAddress>();

				for (ShippingAddress saddr : shippingAddr) {
					if (saddr.getBasicAddr() == 'Y') {
						model.addAttribute("basicAddr", saddr);
					}
				}
				model.addAttribute("member", memberInfo);
				model.addAttribute("shippingAddr", shippingAddr);
				System.out.println(shippingAddr.toString());
				// 쿠폰이 한 개라도 있으면
				if (member.getCouponCount() > 0) {
					List<CouponInfos> couponInfos = os.getCouponInfos(member.getMemberId());
					model.addAttribute("couponInfos", couponInfos);
					System.out.println(couponInfos.toString());
				}
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}

		List<String> productCategory = new ArrayList<String>();
		List<OrderInfo> productInfos = new ArrayList<OrderInfo>();
		PaymentDTO pd = new PaymentDTO();

		try {
			// 결제 페이지에 뿌려줄 상품 정보 가져오기
			productInfos = os.getProductInfo(items.getProductId()); // current_quantity 변경 예정(구매하려는 수량으로)

			int index = 0;
			int totalAmount = 0;

			// 재고 조회
			for (OrderInfo i : productInfos) {
				if (i.getCurrentQuantity() < items.getProductQuantity().get(index)) {
					i.setAdequacy("N");
					// path = "/commonError";
				} else {
					i.setAdequacy("Y");
				}
				i.setProductQuantity(items.getProductQuantity().get(index));
				i.setCalculatedPrice(i.getProductQuantity() * i.getSellingPrice());

				productCategory.add(i.getCategoryKey());
				totalAmount += i.getCalculatedPrice();
				index++;
			}
			if (totalAmount >= 10000) {
				pd.setShippingFee(0);
			} else {
				pd.setShippingFee(3000);
			}
			pd.setTotalAmount(totalAmount);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		System.out.println(productInfos.toString());
		model.addAttribute("productCategory", productCategory);
		model.addAttribute("paymentInfo", pd);
		model.addAttribute("orderId", orderId);
		model.addAttribute("productInfos", productInfos);
		model.addAttribute("impKey", impKey);

		return model;
	}

	@RequestMapping(value = "orderComplete", method = RequestMethod.POST)
	public String orderComplete(HttpServletRequest request, Model model, @RequestParam("orderNo") String orderNo) {
		// 주문 결제 완료하고 주문 내역 창 띄우기

		// 디폴트는 회원 주문 완료페이지
		String path = "/order/orderComplete";
		
		if(orderNo.contains("N")) { // 비회원 주문일 때
			path = "/order/nonOrderComplete";
		} 
		
		System.out.println("결제 완료하고 주문 내역 저장하기");

		Map<String, Object> paymentDetail = new HashMap<String, Object>();

		if(request.getSession().getAttribute("orderNo") != null) {
			orderNo = (String) request.getAttribute("orderNo");
		}
		System.out.println(orderNo);
		
		
		try {
//			 결제랑 주문상세 조회
			paymentDetail = os.getPaymentDetail(orderNo);
			System.out.println("paymentDetail 조회 - " + paymentDetail.toString());

		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		model.addAttribute("paymentDetail", paymentDetail);
		
		return path;
	}
	

}
