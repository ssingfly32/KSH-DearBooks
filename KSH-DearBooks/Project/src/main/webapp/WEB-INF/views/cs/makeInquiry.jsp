<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<meta name="description" content="Fastkart" />
<meta name="keywords" content="Fastkart" />
<meta name="author" content="Fastkart" />
<link rel="icon" href="/resources/assets/images/favicon/1.png"
	type="image/x-icon" />
<title>Dear Books</title>

<!-- Google font -->
<link rel="preconnect" href="https://fonts.gstatic.com" />
<link
	href="https://fonts.googleapis.com/css2?family=Russo+One&display=swap"
	rel="stylesheet" />
<link
	href="https://fonts.googleapis.com/css2?family=Exo+2:wght@400;500;600;700;800;900&display=swap"
	rel="stylesheet" />
<link
	href="https://fonts.googleapis.com/css2?family=Public+Sans:ital,wght@0,100;ㅇ0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap"
	rel="stylesheet" />

<!-- bootstrap css -->
<link id="rtl-link" rel="stylesheet" type="text/css"
	href="/resources/assets/css/vendors/bootstrap.css" />

<!-- font-awesome css -->
<link rel="stylesheet" type="text/css"
	href="/resources/assets/css/vendors/font-awesome.css" />

<!-- feather icon css -->
<link rel="stylesheet" type="text/css"
	href="/resources/assets/css/vendors/feather-icon.css" />

<!-- slick css -->
<link rel="stylesheet" type="text/css"
	href="/resources/assets/css/vendors/slick/slick.css" />
<link rel="stylesheet" type="text/css"
	href="/resources/assets/css/vendors/slick/slick-theme.css" />

<!-- Iconly css -->
<link rel="stylesheet" type="text/css"
	href="/resources/assets/css/bulk-style.css" />

<!-- Template css -->
<link id="color-link" rel="stylesheet" type="text/css"
	href="/resources/assets/css/style.css" />
<script
	src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.0/jquery.min.js"></script>
<script>
	
	let isValidTitle = false;
	let isValidContent = false;
	let isValidState = false;
	let saveFile = false;	// 페이지 벗어날 때 false(refresh), true(save)
	let maximumFile = ("${requestScope.ufCount}");
	let update = false;	// 이미지를 삭제할 때 false(수정)면 사용자 기기에서 안지우고 true(작성)면 지운다.
	let postNo = new URLSearchParams(location.search).get('postNo');
	let content = ("${requestScope.inquiry.content}");
	let objList = [];
	let deleteList = [];

	
	$(function() {
		convertedContent = content.replaceAll("<br />","\r\n");
		console.log(convertedContent);
		$('#inquiryContent').text(convertedContent);
		if('${requestScope.uploadFiles}' != null && '${requestScope.uploadFiles}' != "") {
			
		files = '${requestScope.uploadFilesSeq}';
		}
		//$('.selection').find('span:eq(1)').css("color", "#dc3545 !important");
		//$('#inquiryTitle').css("color","#dc3545");
		
		
		if('${requestScope.inquiry}' != null && '${requestScope.inquiry}' != "") {
			console.log("상세 문의 보기")
			$('#postNo').val(postNo);
			$('#selectState').val("${requestScope.inquiry.inquiryType }").prop("selected",true);
			$('#selectState').attr('disabled', true);
		}
		
		//첨부파일
		$(".upFileArea").on("dragenter dragover", function(e) {
			e.preventDefault();
		});
		$(".detailUpFileArea").on("dragenter dragover", function(e) {
			e.preventDefault();
		});
		$(".detailUpFileArea").on("drop", function(e) {
			e.preventDefault();
		});
		

		$(".upFileArea").on("drop", function(e) {
			e.preventDefault();
			console.log(e.originalEvent.dataTransfer.files);
			let files = e.originalEvent.dataTransfer.files;
			let addFileCount = maximumFile;
			for(let i = 0; i < files.length; i++) {
				addFileCount++;
				console.log(addFileCount);		
				}
			if(addFileCount < 4) {
				for (let i = 0; i < files.length; i++) {
					
						let form = new FormData();
						form.append("uploadFile", files[i]); // 파일의 이름을 컨트롤러단의 MultipartFile 객체명과 맞춘다.
						$.ajax({
							url : "/cs/uploadFile",
							type : "post",
							data : form,
							dataType : "json",
							async : false,
							processData : false, // text데이터에 대해 쿼리스트링 처리를 하지 않겠다.  default = true
							contentType : false, // application/x-www-form-urlencoded 처리 안함.(인코딩 하지 않음)  default = true
							success : function(data) {
								console.log("업로드성공", data);
								if (data != null) {
									console.log(data);
									addObject(data);
									showUploadedFile(objList);
									maximumFile++;
									console.log(maximumFile);
								}
							},
							error : function(data) {
								console.log("업로드 실패", data);
							}
						});
					}
				} else {
					alert("이미지 파일은 최대 3개까지만 첨부 가능합니다.");
				}
		});
		console.log("${requestScope.inquiry.inquirySms }");
		if("${requestScope.inquiry.inquirySms }" == "Y") {
			$("input:checkbox[name='inquirySms']").prop("checked", true);
		}
		
		// 휴대폰 번호 유효성 검사
		
		$('#phoneNumber').on('blur', function () {
			let regNumber = /^01([0|1|6|7|8|9])-?([0-9]{3,4})-?([0-9]{4})$/;
			if (regNumber.test($('#phoneNumber').val())) {
				let addHyphen = $('#phoneNumber').val().replace(/[^0-9]/g, '').replace(/^(\d{2,3})(\d{3,4})(\d{4})$/, `$1-$2-$3`);
				$('#phoneNumber').val(addHyphen);
				isValidCellPhone = true;	
			} else {
				alert("올바른 전화번호가 아닙니다.");
				$('#phoneNumber').val("");
				isValidCellPhone = false;
			}
				
		});
	})
	
	function checkSms() {	// 휴대폰번호를 입력해야 답변 알림 문자 요청 가능
		console.log($("#phoneNumber").val());
		   if($("#phoneNumber").val() == null || $("#phoneNumber").val() == "") {
			   alert("휴대폰 번호를 입력하시고 체크해 주세요.");
			   console.log("!");
			   $("input:checkbox[name='inquirySms']").prop("checked", false);   
				 
			   $("input:checkbox[name='inquirySms']").removeAttr('value');
			   
		   } else {
			   if($("input:checkbox[name='inquirySms']").prop("checked")){	// 체크됐을 때
				   
				   $("input:checkbox[name='inquirySms']").val('sms');
				   } else {	// 체크 안됐을 때
					   $("input:checkbox[name='inquirySms']").removeAttr('value');
					   
				   }	   
			   // 체크된 체크박스의 value만 제출 데이터에 포함되고 체크 해제된 체크박스의 value는 아예 누락됩니다. 
			   // 또한 value를 지정하지 않은 경우의 기본 값은 문자열 on입니다.
		   }
		   console.log($("input:checkbox[name='inquirySms']").val());	// 체크하면 sms, 아니면 on
	   }
	
	function addObject(data) {
		let i = objList.length;
	    objList[i] = new Object();
	    objList[i] = data;
	    //objList[i].thumbnailFileName = data[0].thumbnailFileName;
	      
		console.log(objList);
	}
	
	
	// id가 겹치므로 삭제 버튼에는 index를 붙여서 구분
	function showUploadedFile(json) {
	//console.log("newFileName", json);
	let output = "";
	let index = 0;
	 for(let data of json){
		let name = data.thumbnailFileName.replaceAll("\\", "/");
		//output += "<img src='../resources/uploads" + name + "'/>";
		output += `<div id="\${name}"><img style="pointer-events:none" src='../resources/inquiryUploads\${name}'/>`;
		output += `<button id='\${name}\${index}' class="removeImgBtn" type="button" onclick="removeSpecificImg(this.id);"><img width="16" height="16" src="https://img.icons8.com/tiny-glyph/16/cancel.png" alt="cancel"/></button></div>`;
		index++;
	} 


	
	// upFileArea(기존 파일, 새 파일포함) > uploadFiles(기존에 사용자가 올린 파일) > insertFiles(작성이나 수정할 때 사용자가 올린 파일)
	$('.insertFiles').html(output);
} 
	
	function enlargeImg(id) {
		console.log(id);
		$('#newFile'+id).parent().addClass('active');
		$('#newFile'+id).parent().attr('id','mainEnlargeImg');
		$('#imgModal').show();
	}

	function isValidInquiry(purpose) {
		console.log(purpose);
		if($('#inquiryTitle').val() != "") {
			isValidTitle = true;
		}
		
		
		
		if($('#inquiryContent').val() != "") {
			isValidContent = true;
		}
		
		console.log($('#selectState').val());
		
		if($('#selectState').val() !="문의 유형을 선택해주세요.") {
			isValidState = true;
		}
		
		
		if(isValidTitle && isValidContent && isValidState) {
			console.log("유효성 검사 통과");
			
			if(purpose == 'save') {
				saveFile = true;
				updateInquiry("saveInquiry");
			//$('#saveInquiry').submit();
			} else if (purpose == 'change') { // 수정하려 할 때
				$('input[name=inquirySms]').removeAttr("disabled");
				 $('input').prop('readonly', false);
				 $('textarea').prop('readonly', false);
				 $('.uploadFiles').find('button').css("display", "");
				 $('#cancelButton').text('취소');
				 $('#inquiryStatus').text('1:1문의 수정');
				 update = true;
			} else { // 수정 완료 할 때
				// 변경 사항이 없을 때 업데이트 안함
				checkChanges();
				console.log(isValidTitle);
				console.log(isValidContent);
				console.log(isValidState);
				if(!isValidTitle && !isValidContent && !isValidState){
					
					alert("변경 사항이 없습니다.");
				} else {
					saveFile = true;
					updateInquiry("updateInquiry");
				}
			}
		} else {
			alert('모든 항목을 입력해주세요.');
		}
		closeConfirmModal();
	}
	
	function updateInquiry(text) {	// text를 받아 재사용(update, save, refresh)
		let mapping = text;
		console.log(mapping);
		let asyncControl = false;
		console.log(Number(postNo));
		inquiry = {
				"postNo" : Number(postNo),
				"title" : $('#inquiryTitle').val(),
				"content" : $('#inquiryContent').val(),
				"phoneNumber" : $('#phoneNumber').val(),
				"inquiryType" : $('#selectState').val(),
				"inquirySms" : $("input:checkbox[name='inquirySms']").val(),
				objList,
				deleteList,
		}
		if(mapping == "refreshFile") {
			asyncControl = true;
		} 
		
		// ajax는 기본적으로 비동기식으로 동작.
		// async : false로 설정하게 되면 ajax를 호출하여 서버에서 응답을 기다렸다가 
		// 응답을 모두 완료한 후 다음 로직 실행하는 동기식으로 변경.
		$.ajax({
			url : "/cs/"+mapping,
			type : "POST",
			contentType : "application/json",
			data : JSON.stringify(inquiry),
			async : asyncControl, // 여기랑 purpose쪽 다시 보자
			success : function(data) {
				console.log("업로드성공", data);
				if (data != null) {
					console.log(data);
					location.href="viewInquiry";
				}
			},
			error : function(data) {
				console.log("업로드 실패", data);
			}
		});
	}
	
	// 수정 시 변경사항 확인
	function checkChanges() {
		let checkTitle = "${requestScope.inquiry.title}";
		let checkStatus = "${requestScope.inquiry.inquiryType}";
		let checkContent = "${requestScope.inquiry.content}";
		let checkPhoneNumber = "${requestScope.inquiry.phoneNumber}";
		
		if($('#inquiryTitle').val() == checkTitle) {
			isValidTitle = false;
		}
		
		if($('#selectState').val() == checkStatus) {
			isValidState = false;
		}
		
		if($('#inquiryContent').val() == checkContent) {
			isValidContent = false;
		}
		
	}
	
	// 페이지 나갈 시
	window.onbeforeunload = function (e) {
		if(!saveFile) {
			
		console.log("beforeunload 실행"); 
		updateInquiry("refreshFile");
 		//window.navigator.sendBeacon('/cs/refreshFile');
 		
		}
	};
	
	// 수정 시 기존 이미지를 삭제할 때 임시저장.
	function removeFile(data) {
		let i = deleteList.length;
	    deleteList[i] = new Object();
	    deleteList[i] = data;
		console.log(deleteList);
	}
	
	// x 버튼을 눌러 한 개의 이미지를 삭제.
	function removeSpecificImg(id) {
		update = true;
		console.log(id); // tumbnailFileName+index명
		let fileName = id.slice(0, -1);
		console.log(fileName);	// thumbnailFileName
		console.log(fileName.substring(12));
		console.log(objList);	// 새로 올린 파일 리스트
		
		if(objList.length > 0) {	// 새로 올린 파일이 1개 이상 있다면
			for(let j in objList) {	// ex) j = 0, 1, 2..... (배열의 첫번째부터 반복)
				console.log(objList[j].thumbnailFileName.indexOf(fileName.substring(12)));	// 12번째까지 잘랐으니 12번째부터 일치하므로 12 리턴
		    	if(objList[j].thumbnailFileName.indexOf(fileName.substring(12)) != -1) {	// 지우려는 파일이 새로 올린 파일리스트에 존재
		    		objList.splice(j,1);	// 배열의 j번째 값 삭제
		    		update = false;	// 새로 올린 이미지를 지우기 때문에 사용자 기기에서 지워야함.
		    		
		    	}
		    }
		}
			
		$.ajax({
			url : "/cs/removeSpecificImg",
			type : "GET",
			data : {
				"fileName" : fileName,	// 썸네일 파일명
				"purpose" : update,	// false or true
			},
			dataType : "json",
			async : false,
			success : function(data) {
				console.log("클릭한 이미지 삭제 성공");
				console.log(data);
					if(update) {
					removeFile(data);	// 수정 시 임시저장용 deleteList에 추가
					}
				let div = document.getElementById(fileName);
				div.remove();	// 화면에 출력한 썸네일 삭제			
				maximumFile--;	// 첨부 가능한 최대 파일 개수 제한을 위한 변수
			},
			error : function(data) {
				console.log(data);
			}
		});
	}

	function confirmModal(purpose) {
		if(purpose == 'cancel') {
			$('#modalPurpose').text('작성을 취소하시겠습니까?');
			$('#confirmPurpose').attr('id', 'confirmCancel');
		} else if (purpose == 'change') {
			if(!update) {
			$('#modalPurpose').text('수정하시겠습니까?');
			$('#confirmPurpose').attr('id', 'confirmChange');
			
			} else {
				$('#modalPurpose').text('수정 완료하시겠습니까?');
				$('#confirmChange').attr('id', 'confirmUpdate');
			}
		} else if(purpose == 'updateCancel') {
			if(!update) {
				$('#modalPurpose').text('삭제하시겠습니까?');
				$('#confirmPurpose').attr('id', 'confirmDelete');
			} else {
			$('#modalPurpose').text('수정을 취소하시겠습니까?');
			$('#confirmChange').attr('id', 'confirmCancel');
			}
		}
		$('#confirmModal').show();
	}
	
	function returnPath(purpose) {
		console.log(purpose);
		if(purpose == 'confirmCancel') {	// 취소할 때
			if(!update) {
				location.href="/cs/serviceCenter";
			} else {
				saveFile = false;	
				location.reload(true);	// 페이지 벗어날 때 refresh(!saveFile)
			}
		} else if(purpose == 'confirmChange') {
			isValidInquiry('change');
			 $('input').css('color','black');	
			 $('textarea').css('color','black');
			 $('#phoneNumber').attr('placeholder', "-빼고 입력해주세요");
			 $('#detailUpfile').css('display', 'none');
			 $('#selectState').removeAttr('disabled');
			 $('#updateUpfileArea').css('display', '');
			$('#confirmModal').hide();
		} else if(purpose == 'confirmUpdate') {
				isValidInquiry('update');		
		} else {
			// 삭제
			location.href="/cs/delete?postNo="+postNo;
		}
	}
	
	function closeConfirmModal() {
		$('#confirmDelete').attr('id', 'confirmPurpose');
		$('#confirmModal').hide();
	}
	function closeBigImgModal() {
		$('#mainEnlargeImg').removeClass('active');
		$('#mainEnlargeImg').removeAttr('id', 'mainEnlargeImg');
		$('#imgModal').hide();
	}
</script>
<style>
.removeImgBtn {
	border: none;
}

/* .imgList {
display:flex;
} */
.uploadFiles, .insertFiles {
	display: flex;
}


</style>
</head>
<body>
	<jsp:include page="../header.jsp"></jsp:include>
	<section class="breadscrumb-section pt-0">
		<div class="container-fluid-lg">
			<div class="row">
				<div class="col-12">
					<div class="breadscrumb-contain">
						<h2>고객센터</h2>
						<nav>
							<ol class="breadcrumb mb-0">
								<li class="breadcrumb-item"><a href="index.html"> <i
										class="fa-solid fa-house"></i>
								</a></li>
								<li class="breadcrumb-item active" aria-current="page">
									고객센터</li>
							</ol>
						</nav>
					</div>
				</div>
			</div>
		</div>
	</section>
	<!-- Breadcrumb Section End -->

	<!-- User Dashboard Section Start -->
	<section class="user-dashboard-section section-b-space">
		<div class="container-fluid-lg">
			<div class="row">
				<div class="col-xxl-3 col-lg-4">
					<div class="dashboard-left-sidebar">
						<div class="close-button d-flex d-lg-none">
							<button class="close-sidebar">
								<i class="fa-solid fa-xmark"></i>
							</button>
						</div>
						<!-- <div class="profile-box">
							<div class="cover-image">
								<img src="/resources/assets/images/deer.png"
									class="img-fluid blur-up lazyload" alt="" />
							</div>

							<div class="profile-contain">
								<div class="profile-image">
									<div class="position-relative">
										<img src="#" class="blur-up lazyload update_img" alt="" />
										<div class="cover-icon">
											<i class="fa-solid fa-pen"> <input type="file"
												onchange="readURL(this,0)" />
											</i>
										</div>
									</div>
								</div>

								<div class="profile-name">
									<h3>${userInfo.memberId }</h3>
									<h6 class="text-content">
										<img width="50" height="50"
											src="https://img.icons8.com/external-vitaliy-gorbachev-lineal-vitaly-gorbachev/60/external-deer-winter-vitaliy-gorbachev-lineal-vitaly-gorbachev.png"
											alt="external-deer-winter-vitaliy-gorbachev-lineal-vitaly-gorbachev" />${userInfo.membershipGrade }</h6>
								</div>
							</div>
						</div>-->

						<ul class="nav nav-pills user-nav-pills" id="pills-tab"
							role="tablist">
							<li class="nav-item" role="presentation">
								<button class="nav-link active" id="pills-dashboard-tab"
									data-bs-toggle="pill" data-bs-target="#pills-dashboard"
									type="button" role="tab" aria-controls="pills-dashboard"
									aria-selected="true">
									<i data-feather="home"></i> 메인
								</button>
							</li>

							<li class="nav-item" role="presentation">
								<button class="nav-link" id="pills-order-tab"
									data-bs-toggle="pill" data-bs-target="#pills-order"
									type="button" role="tab" aria-controls="pills-order"
									aria-selected="false">
									<i data-feather="shopping-bag"></i>주문내역
								</button>
							</li>

							<li class="nav-item" role="presentation">
								<button class="nav-link" id="pills-profile-tab"
									data-bs-toggle="pill" data-bs-target="#pills-profile"
									type="button" role="tab" aria-controls="pills-profile"
									aria-selected="false">
									<i data-feather="user"></i> 회원정보
								</button>
							</li>

							<li class="nav-item" role="presentation">
								<button class="nav-link" id="pills-address-tab"
									data-bs-toggle="pill" data-bs-target="#pills-address"
									type="button" role="tab" aria-controls="pills-address"
									aria-selected="false">
									<i data-feather="map-pin"></i> 배송 주소록
								</button>
							</li>

							<li class="nav-item" role="presentation">
								<button class="nav-link" id="pills-wishlist-tab"
									data-bs-toggle="pill" data-bs-target="#pills-wishlist"
									type="button" role="tab" aria-controls="pills-wishlist"
									aria-selected="false">
									<i data-feather="heart"></i> 찜
								</button>
							</li>

							<li class="nav-item" role="presentation">
								<button class="nav-link" id="pills-profile-tab"
									data-bs-toggle="pill" data-bs-target="#pills-profile"
									type="button" role="tab" aria-controls="pills-profile"
									aria-selected="false">
									<i data-feather="help-circle"></i>1:1문의내역
								</button>
							</li>

							<li class="nav-item" role="presentation">
								<button class="nav-link" id="pills-review-tab"
									data-bs-toggle="pill" data-bs-target="#pills-review"
									type="button" role="tab" aria-controls="pills-review"
									aria-selected="false">
									<i data-feather="clipboard"></i>작성한 리뷰
								</button>
							</li>

							<li class="nav-item" role="presentation">
								<button class="nav-link" id="pills-profile-tab"
									data-bs-toggle="pill" data-bs-target="#pills-profile"
									type="button" role="tab" aria-controls="pills-profile"
									aria-selected="false">
									<i data-feather="smile"></i>포인트/쿠폰/적립금 내역
								</button>
							</li>
						</ul>
					</div>
				</div>

				<div class="col-xxl-9 col-lg-8">
					<button
						class="btn left-dashboard-show btn-animation btn-md fw-bold d-block mb-4 d-lg-none">
						Show Menu</button>
					<div class="dashboard-right-sidebar">
						<div class="tab-content" id="pills-tabContent">
							<div class="tab-pane fade show active" id="pills-dashboard"
								role="tabpanel" aria-labelledby="pills-dashboard-tab">
								<div class="dashboard-home">
									<div class="title">
										<h2>1:1 문의</h2>
										<span class="title-leaf"> <svg
												class="icon-width bg-gray">
                          <use
													xlink:href="/resources/assets/svg/leaf.svg#leaf"></use>
                        </svg>
										</span>
									</div>


									<c:choose>
										<c:when test="${inquiry != null && inquiry.author != 'qwer123' }">
											<div class="dashboard-title">
												<jsp:include page="./requestInquiry.jsp"></jsp:include>
												<button class="btn theme-bg-color text-white m-0"
													type="button" id="button-addon1" style="float: right"
													onclick="confirmModal('change');">
													<span>수정</span>
												</button>
												<button onclick="confirmModal('updateCancel');"
													class="btn theme-bg-color text-white m-0" type="button"
													style="float: right; margin-right: 10px !important; color: #fff !important; background-color: #6c757d !important;">
													<span id="cancelButton">삭제</span>
												</button>
											</div>
										</c:when>
										<c:when test="${inquiry != null && inquiry.author eq 'qwer123' }">
										<jsp:include page="./requestInquiry.jsp"></jsp:include>
										<button class="btn theme-bg-color text-white m-0"
													type="button" id="button-addon1" style="float: right"
													onclick="location.href='/cs/viewInquiry'">
													<span>목록으로 가기</span>
												</button>
										</c:when>
										<c:otherwise>
											<div class="dashboard-title">
												<jsp:include page="./requestInquiry.jsp"></jsp:include>
												<button class="btn theme-bg-color text-white m-0"
													type="button" id="button-addon1" style="float: right"
													onclick="isValidInquiry('save')">
													<span>등록</span>
												</button>
												<button onclick="confirmModal('cancel')"
													class="btn theme-bg-color text-white m-0" type="button"
													id="button-addon1"
													style="float: right; margin-right: 10px !important; color: #fff !important; background-color: #6c757d !important;">
													<span>취소</span>
												</button>
											</div>
										</c:otherwise>
									</c:choose>
									<!-- The Modal -->
									<div class="modal" id="confirmModal">

										<div class="modal-dialog">
											<div class="modal-content">
												<div class="modal-body">
													<div id="modalPurpose"></div>
												</div>
												<!-- Modal footer -->
												<div class="modal-footer">

													<button type="button" class="btn btn-success"
														onclick="closeConfirmModal()">취소</button>
													<button type="button" class="btn btn-primary"
														data-bs-dismiss="modal" id="confirmPurpose"
														onclick="returnPath(this.id);">확인</button>

												</div>

											</div>
										</div>
									</div>
								</div>
								<!-- 모달 끝 -->


							</div>
						</div>
					</div>
				</div>
			</div>
		</div>


	</section>
	<jsp:include page="../footer.jsp"></jsp:include>
</body>
</html>