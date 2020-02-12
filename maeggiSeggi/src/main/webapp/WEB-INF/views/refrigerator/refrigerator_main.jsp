<<<<<<< HEAD
<%@page import="maeggi.seggi.fridge.FridgeVO"%>
<%@page import="java.util.ArrayList"%>
<%@page import="maeggi.seggi.loginandcustomer.memberVO"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="description" content="">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <!-- The above 4 meta tags *must* come first in the head; any other head content must come *after* these tags -->

    <!-- Title -->
    <title>매끼세끼 - 마이 냉장고</title>

    <!-- CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jquery-modal/0.9.1/jquery.modal.min.css" />
    <link href="/maeggiSeggi/common/css/refrigerator.css" rel="stylesheet">
    <link href="/maeggiSeggi/common/css/maeggiFonts.css" rel="stylesheet">
    <link rel="stylesheet" href="/maeggiSeggi/common/css/wow-alert.css">
    
    <!-- JS -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-modal/0.9.1/jquery.modal.min.js"></script>
    <script src="/maeggiSeggi/common/js/wow-alert.js"></script>
    <script type="text/javascript">
	    var fridgeList;
	    
	    $(document).ready(function() {
	    	var memId = '<%= session.getAttribute("id") %>';
	    	
	    	//냉장고 정보 로드
	    	loadFridge(memId);
	    	
	    	//냉장고 관리 모달 창 열기
	    	addDataToModal(memId);
	    	
	    	//냉장고 추가
	    	addFridge(memId);
	    	
	    	//메인 냉장고 설정
	    	setMainFridge(memId);
	    });
	    
	    function loadFridge(id) {
	    	$.ajax({
	    		url:"/maeggiSeggi/refrigerator/ajax_fridge.do",
	    		async: false,
	    		type:"get",
	    		data: {
	    			"id": id
	    			},
	    		success: function(data) {
	    			fridgeList = data;
	    			if(data.length < 1) $("#fridge_name").text("냉장고를 추가하세요!");
	    			else if(data.length == 1) {
	    				$("#fridge_name").html("<b>" + id + "</b> 님의 " + "<b>#" + data[0].name + "</b> 냉장고");
	    			}
	    			else {
	    				var flag = false;
	    				for (var i = 0; i < data.length; i++) {
	        				if(data[i].distinct_code == '1') {
	        					$("#fridge_name").html("<b>" + id + "</b> 님의 " + "<b>#" + data[i].name + "</b> 냉장고");
	        					flag = true;
	        					
	        				} else {
	        					if(flag == false) {
	        						$("#fridge_name").html("<b>" + id + "</b> 님의 " + "<b>#" + data[i].name + "</b> 냉장고");
	        						flag = true;
	        					}
	        				}
	        			}	
	    			}
	    		}
	    	});
	    }
	    
	    function addDataToModal(id) {
			$(".modal-btn").on("click", function() {
				$("#fridge_modal").modal({
					escapeClose: false,
					clickClose: false,
					showClose: false
				})
				
				$.ajax({
					url:"/maeggiSeggi/refrigerator/ajax_fridge.do",
					async: false,
		    		type:"get",
		    		data: {
		    			"id": id
		    			},
		    		success: function(data) {
						fridgeList = data;
					}
				});

				var div = $("<div id='check_box'></div>");
				var radio = "";
				var mydiv = "";
				
				if(fridgeList.length == 0) {
					radio = "<input type='radio' name='distinct_code' id='' value='0'>";
					mydiv = "<div class='fridge-img-div'><img class='fridge-img-ico' src='/maeggiSeggi/images/refrigerator.png'><input name='addF' type='text' maxlength='5' placeholder='냉장고 이름을 입력하세요.'></div>";
				} else {
					for (var i = 0; i < fridgeList.length; i++) {
						radio += "<input type='radio' name='distinct_code' id='" + fridgeList[i].refrigerator_id + "' ";
						if(fridgeList[i].distinct_code == '1') {
							radio += "checked=true value='1'>";
						}
						else radio += "value='0'>";	
						
						mydiv += "<div class='fridge-img-div'><img class='fridge-img-ico' src='/maeggiSeggi/images/refrigerator.png'><p>#" + fridgeList[i].name + "<br/>냉장고</p></div>";
					}
				}
				
				div.append(radio);
				$("#manage_fridge").empty();
				$("#manage_fridge").append(div);
				$("#manage_fridge").append(mydiv);
			});
		}
	    
	    function addFridge(id) {
	    	$(document).on("keydown",$("input[name=addF]"),function(key){
	    		if(key.keyCode == 13) {
	    			var text = $("input[name=addF]").val();
	    			var node = $("<p></p>");
	    			node.html("#" + text + "<br/>냉장고");
	    			$("#manage_fridge").children("div").last().append(node);
	    			
	    			//db저장
	    			$.ajax({
	    				url:"/maeggiSeggi/refrigerator/ajax_fridge_insert.do",
	    				type:"post",
	    				dataType:"text",
	    				data: {
	    					"member_id":id,
	    					"name":text,
	    					"distinct_code":0
	    				},
	    				success: function(data) {
	    					alert(data);
	    				},
	    				fail: function(data) {
							alert(data);
						}
	    			})
	    			
	    			//db 저장 끝난 후 지움
	    			$("input[name=addF]").remove();
	    		}
	    	})
	    }
	    
	    function setMainFridge(id) {
			$(document).on("change", "input[name=distinct_code]", function() {
				if($(this).is(":checked")) {
					$(this).val("1");
					$("#check_box").find("input").not($(this)).val("0");
				} else {
					$(this).val("0");
				}
				
				$.ajax({
					url:"/maeggiSeggi/refrigerator/ajax_update_main.do",
					type:"post",
					datatype:"text",
					data: {
						"refrigerator_id": $(this).attr('id'),
						"distinct_code": $(this).val()
					},
					success:function(data) {
						alert(data);
					},
					fail:function(data) {
						alert(data);
					}
				});
			});
		}
    </script>
    <script src="/maeggiSeggi/common/js/l_fridge.js"></script>
</head>

<body class="bg-amond">
	<!-- ******Refrigerator Area Start ****** -->
	<div class="fridge-area">
		<div class="col-12">
			<!-- ****** Theme Select Area Start ****** -->
			<div class="button-area col-1">
				<button class="ig-btn fridge-btn btn-orange btn-fill-vert-o">
					<p>주재료</p>
				</button>
				<button class="ig-btn fridge-btn btn-orange btn-fill-vert-o">
					<p>부재료</p>
				</button>
				<button class="ig-btn fridge-btn btn-orange btn-fill-vert-o">
					<p>양념</p>
				</button>
				<!-- <a class="modal-btn fridge-btn btn-orange btn-fill-vert-o" type="button">레시피</a> -->
				<a class="modal-btn fridge-btn btn-orange btn-fill-vert-o" href="#fridge_modal">냉장고</a>
			</div>
			<!-- ****** Theme Select Area End ****** -->
			<!-- ****** Ingredient Select Area Start ****** -->
			<div class="refrigerator-area col-5" id="selectIngredientBox">
				<form class="select-wrapper" name="ingrediennt_select_form"
					method="POST" action="">
					<ul id="ig_list" class="sort-list">
						<li>
							<div class="" id="ingredient_1" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>계란</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_2" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>쌀</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_1" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>계란</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_2" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>쌀</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_1" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>계란</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_2" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>쌀</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_1" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>계란</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_2" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>쌀</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_1" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>계란</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_2" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>쌀</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_1" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>계란</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_2" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>쌀</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_1" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>계란</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_2" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>쌀</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_1" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>계란</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_2" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>쌀</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_1" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>계란</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_2" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>쌀</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_1" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>계란</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_2" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>쌀</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_1" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>계란</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_2" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>쌀</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_1" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>계란</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_2" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>쌀</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_1" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>계란</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_2" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>쌀</p>
							</div>
						</li>
					</ul>
				</form>
				<div id="input_search">
					<input type="text" placeholder="재료명을 입력하세요.">
					<a><i class="fa fa-search fa-2x" aria-hidden="true"></i></a>
				</div>
			</div>
			<!-- ****** Ingredient Select Area End ****** -->

			<!-- ****** My Fridge Area Select Area End ****** -->
			<div class="refrigerator-area col-5">
				<div class="fridge-wrapper">
					<img id="fridge-image" src="/maeggiSeggi/images/refrigerator.png">
					<!-- 냉장고 div로 배경이미지를 넣거나 border 속성으로 구분.. -->
					<ul id="fridge" class="list-scroll fridge-list">
						<!-- 동적으로 추가되어야 함 -->
						
					</ul>
				</div>
				<p id="fridge_name"></p>
			</div>

		</div>
	</div>
    
    <!-- 모달 창입니다 ---------------------------------------------------------------------- -->
    <div id="fridge_modal" class="modal" role="dialog" aria-hidden="true">
    	<div id="manage_fridge">
    		<div id="check_box">
    		</div>
    		<div class="fridge-img-div">
  				<img class="fridge-img-ico" src="">
  				<p></p>
  			</div>
    	</div>
    	
    	<div id="pm-btn">
    		<button class="plus-btn" title="냉장고 추가"><i class="fas fa-plus-circle fa-2x" style="color:orange;"></i></button>
    		<button class="plus-btn" title="냉장고 제거"><i class="fas fa-minus-circle fa-2x" style="color:gray;"></i></button>
    	</div>
  		<a href="#" class="" rel="modal:close" style="padding-left: 95%; position: static;">Close</a>
	</div>
</body>
=======
<%@page import="maeggi.seggi.fridge.FridgeVO"%>
<%@page import="java.util.ArrayList"%>
<%@page import="maeggi.seggi.loginandcustomer.memberVO"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="description" content="">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <!-- The above 4 meta tags *must* come first in the head; any other head content must come *after* these tags -->

    <!-- Title -->
    <title>매끼세끼 - 마이 냉장고</title>

    <!-- CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jquery-modal/0.9.1/jquery.modal.min.css" />
    <link href="/maeggiSeggi/common/css/refrigerator.css" rel="stylesheet">
    <link href="/maeggiSeggi/common/css/maeggiFonts.css" rel="stylesheet">
    <link rel="stylesheet" href="/maeggiSeggi/common/css/wow-alert.css">
    
    <!-- JS -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-modal/0.9.1/jquery.modal.min.js"></script>
    <script src="/maeggiSeggi/common/js/wow-alert.js"></script>
    <script type="text/javascript">
	    var fridgeList;
	    
	    $(document).ready(function() {
	    	var memId = '<%= session.getAttribute("id") %>';
	    	
	    	$.ajax({
	    		url:"/maeggiSeggi/refrigerator/ajax_fridge.do",
	    		async: false,
	    		type:"get",
	    		data: {
	    			"id": memId
	    			},
	    		success: function(data) {
	    			fridgeList = data;
	    			if(data.length < 1) $("#fridge_name").text("냉장고를 추가하세요!");
	    			else if(data.length == 1) {
	    				$("#fridge_name").html("<b>" + memId + "</b> 님의 " + "<b>#" + data[0].name + "</b> 냉장고");
	    			}
	    			else {
	    				var flag = false;
	    				for (var i = 0; i < data.length; i++) {
	        				if(data[i].distinct_code == '1') {
	        					$("#fridge_name").html("<b>" + memId + "</b> 님의 " + "<b>#" + data[i].name + "</b> 냉장고");
	        					flag = true;
	        					
	        				} else {
	        					if(flag == false) {
	        						$("#fridge_name").html("<b>" + memId + "</b> 님의 " + "<b>#" + data[i].name + "</b> 냉장고");
	        						flag = true;
	        					}
	        				}
	        			}	
	    			}
	    		}
	    	});
	    	
	    	//냉장고 관리 모달 창 열기
	    	addDataToModal();
	    });
	    
	    function addDataToModal() {
			$(".modal-btn").on("click", function() {
				$("#fridge_modal").modal({
					escapeClose: false,
					clickClose: false,
					showClose: false
				})
				
				for (var i = 0; i < fridgeList.length; i++) {
					var fridge = fridgeList[i];
					mydiv = "<div class='fridge-img-div'><img class='fridge-img-ico' src='/maeggiSeggi/images/refrigerator.png'><p>#" + fridge.name + "<br/>냉장고</p></div>";
					$("#manage_fridge").empty();
					$("#manage_fridge").append(mydiv);
				}
			})
		}
    </script>
    <script src="/maeggiSeggi/common/js/l_fridge.js"></script>
</head>

<body class="bg-amond">
	<!-- ******Refrigerator Area Start ****** -->
	<div class="fridge-area">
		<div class="col-12">
			<!-- ****** Theme Select Area Start ****** -->
			<div class="button-area col-1">
				<button class="ig-btn fridge-btn btn-orange btn-fill-vert-o">
					<p>주재료</p>
				</button>
				<button class="ig-btn fridge-btn btn-orange btn-fill-vert-o">
					<p>부재료</p>
				</button>
				<button class="ig-btn fridge-btn btn-orange btn-fill-vert-o">
					<p>양념</p>
				</button>
				<a class="modal-btn fridge-btn btn-orange btn-fill-vert-o" type="button">레시피</a>
				<a class="modal-btn fridge-btn btn-orange btn-fill-vert-o" type="button" href="#manage_fridge" rel="modal:open">냉장고</a>
			</div>
			<!-- ****** Theme Select Area End ****** -->
			<!-- ****** Ingredient Select Area Start ****** -->
			<div class="refrigerator-area col-5" id="selectIngredientBox">
				<form class="select-wrapper" name="ingrediennt_select_form"
					method="POST" action="">
					<ul id="ig_list" class="sort-list">
						<li>
							<div class="" id="ingredient_1" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>계란</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_2" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>쌀</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_1" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>계란</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_2" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>쌀</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_1" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>계란</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_2" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>쌀</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_1" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>계란</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_2" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>쌀</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_1" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>계란</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_2" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>쌀</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_1" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>계란</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_2" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>쌀</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_1" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>계란</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_2" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>쌀</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_1" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>계란</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_2" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>쌀</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_1" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>계란</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_2" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>쌀</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_1" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>계란</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_2" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>쌀</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_1" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>계란</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_2" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>쌀</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_1" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>계란</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_2" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>쌀</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_1" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>계란</p>
							</div>
						</li>
						<li>
							<div class="" id="ingredient_2" draggable="true">
								<img src="/maeggiSeggi/images/ingredients.jpg">
								<p>쌀</p>
							</div>
						</li>
					</ul>
				</form>
				<div id="input_search">
					<input type="text" placeholder="재료명을 입력하세요.">
					<a><i class="fa fa-search fa-2x" aria-hidden="true"></i></a>
				</div>
			</div>
			<!-- ****** Ingredient Select Area End ****** -->

			<!-- ****** My Fridge Area Select Area End ****** -->
			<div class="refrigerator-area col-5">
				<div class="fridge-wrapper">
					<img id="fridge-image" src="/maeggiSeggi/images/refrigerator.png">
					<!-- 냉장고 div로 배경이미지를 넣거나 border 속성으로 구분.. -->
					<ul id="fridge" class="list-scroll fridge-list">
						<!-- 동적으로 추가되어야 함 -->
						
					</ul>
				</div>
				<p id="fridge_name"></p>
			</div>

		</div>
	</div>
    
    <!-- 모달 창입니다 ---------------------------------------------------------------------- -->
    <div id="fridge_modal" class="modal" role="dialog" aria-hidden="true">
    	<div id="manage_fridge">
    		<div class="fridge-img-div">
  				<img class="fridge-img-ico" src="">
  				<p></p>
  			</div>
    	</div>
    	
    	<div id="pm-btn">
    		<button class="plus-btn" title="냉장고 추가"><i class="fas fa-plus-circle fa-2x" style="color:orange;"></i></button>
    		<button class="plus-btn" title="냉장고 제거"><i class="fas fa-minus-circle fa-2x" style="color:gray;"></i></button>
    	</div>
  		<a href="#" class="" rel="modal:close" style="padding-left: 95%; position: static;">Close</a>
	</div>
</body>
>>>>>>> branch 'master' of https://github.com/leeyj341/MyFridge.git
</html>