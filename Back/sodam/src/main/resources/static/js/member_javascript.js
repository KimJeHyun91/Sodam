document.addEventListener(
	"DOMContentLoaded",
	 async function(){
		// 페이지 로드시 토큰이 없으면 가져오기
		console.log(1234);
		let admin_auth_token=localStorage.getItem("admin_auth_token");
		if(!admin_auth_token){
			try{
				const token_response=await fetch("/admin/get_admin_token");
				if(token_response.ok){
					const token_data=await token_response.json();
					if(token_data.token){
						admin_auth_token=token_data.token;
						localStorage.setItem("admin_auth_token", admin_auth_token);
						console.log("관리자 토큰이 발급되었습니다.");
					}else{
						alert("관리자 토큰 발급에 실패했습니다.");
						window.location.href="/admin_login";
						return;
					}
				}else{
					if(token_response.status===401||token_response.status===403){
						alert("관리자 인증이 필요합니다. 로그인 페이지로 이동합니다.");
						window.location.href="/admin_login";
						return;
					}
				}
			}catch (error){
				console.error("관리자 토큰 요청 에러 : "+error);
				alert("토큰 요청 중 오류가 발생했습니다. 로그인 페이지로 이동합니다.");
				window.location.href="/admin_login";
				return;
			}	
		}
		
		// 토큰 확인
		function tokenVerification(){
			const current_token=localStorage.getItem("admin_auth_token");
			if(!current_token){
				alert("인증 토큰이 없습니다. 다시 로그인해주세요.");
				window.location.href="/admin_login";
				return;
			}else{
				return current_token;
			}
		}
		
		// 로그 아웃
		const logout_button=document.getElementById("logout_button");
		logout_button.addEventListener(
			"click",
			function(){
				if(confirm("로그아웃 하시겠습니까?")){
					localStorage.removeItem("admin_auth_token");
					console.log("관리자 토큰이 삭제되었습니다.");
					
					const csrf_token=document.querySelector("meta[name='_csrf']")?.getAttribute("content");
					const csrf_header_name=document.querySelector("meta[name='_csrf_header']")?.getAttribute("content");
					
					const logout_form=document.createElement("form");
					logout_form.method="POST";
					logout_form.action="/logout";
					
					if(csrf_token){
						const csrf_input=document.createElement("input");
						csrf_input.type='hidden';
						csrf_input.name='_csrf';
						csrf_input.value=csrf_token;
						logout_form.appendChild(csrf_input);
					}
					
					document.body.appendChild(logout_form);
					logout_form.submit();
				}
			}
		)
		
		// 전체 이웃 불러오기
		const get_member_list_button=document.getElementById("get_member_list_button");
		const output_member_list=document.getElementById("output_member_list");
		get_member_list_button.addEventListener(
			"click",
			function(){
				const current_token=tokenVerification();
				const get_member_list_button=document.getElementById("get_member_list_button");
				const output_member_list=document.getElementById("output_member_list");
				output_member_list.innerHTML="<tr><td>불러오는 중...</td></tr>";
				
				fetch(
					"/member/get_member_list",
					{
						headers:{
							'Authorization':'Bearer '+current_token
						}
					}
					)
					.then(response=>{
						if(response.status===401){
							alert("세션이 만료되었거나 인증에 실패했습니다. 다시 로그인해주세요.");
							localStorage.removeItem("admin_auth_token");
							window.location.href="/admin_login";
							return Promise.reject('Unauthorized');
						}
						if(response.status===403){
							alert("해당 API에 접근할 권한이 없습니다.");
							return Promise.reject('Forbidden');
						}
						return response.json();
					})
					.then(response=>{
						output_member_list.innerHTML="";
						if(response.length>0){
							response.forEach(item=>{
								output_member_list.innerHTML+=`
									<tr>
										<td>${item.id}</td>
										<td>*****</td>
										<td>${item.email}</td>
										<td>${item.nickname}</td>
										<td>${item.name}</td>
										<td>${item.birthday}</td>
										<td>${item.created_date}</td>
										<td>${item.last_modified_date}</td>
										<td>${item.authorization}</td>
										<td><button type="button" class="member_modify_button" value="${item.id}">수정</button></td>
										<td><button type="button" class="member_delete_button" value="${item.id}">삭제</button></td>
									</tr>
								`;
								
							})
						}else{
							output_member_list.innerHTML="데이터 없음";
						}
					})
					.catch(response=>{
						console.log("전체 이웃 불러오기 통신 에러");
					})
			}
		)
		
		// 접속 이름 중복 확인
		const id_check_button=document.getElementById("id_check_button");
		id_check_button.addEventListener(
			"click",
			function(){
				const current_token=tokenVerification();
				
				const input_id_element=document.getElementById("input_id");
				const input_id_value=document.getElementById("input_id").value;
				
				fetch(
						`/member/id_check?id=${input_id_value}`,
					{
						method:"GET",
						headers:{
									'Authorization':'Bearer '+current_token
								}
					}
				).then(response=>{
					return response.text();
				}).then(data=>{
					if(data=="1011"){
						alert("중복된 접속이름입니다.");
						input_id_element.focus();
						input_id_element.value="";
					}else if(data=="1010"){
						alert("입력하신 접속이름은 사용가능합니다.");
					}
					
					
				}).catch(error=>{
					console.log(error);
				})
				
			}
		)
		
		// 손글주소 중복 확인
		const email_check_button=document.getElementById("email_check_button");
		email_check_button.addEventListener(
			"click",
			function(){
				const current_token=tokenVerification();
				
				const input_email_element=document.getElementById("input_email");
				const input_email_value=document.getElementById("input_email").value;
				
				fetch(
					`/member/email_check?email=${input_email_value}`,
					{
						headers:{
							'Authorization':'Bearer '+current_token
						}
					}
				).then(response=>{
					return response.text();
				}).then(data=>{
					if(data=="1061"){
						alert("중복된 손글주소입니다.");
						input_email_element.focus();
						input_email_element.value="";
					}else if(data=="1060"){
						alert("입력하신 손글주소는 사용가능합니다.");
					}
					
				})
			}
			
		)
		
		// 손글주소 인증
		const send_email_verification_code=document.getElementById("send_email_verification_code");
		send_email_verification_code.addEventListener(
			"click",
			function(){
				const current_token=tokenVerification();
				
				const input_email_element=document.getElementById("input_email");
				const input_email_value=document.getElementById("input_email").value;
				
				 
			}
		)
		
		// 새로운 이웃 추가
		const member_add_button=document.getElementById("member_add_button");
		member_add_button.addEventListener(
			"click",
			function(){
				const current_token=tokenVerification();
				
				const input_id=document.getElementById("input_id");
				const input_password=document.getElementById("input_password");
				const input_email=document.getElementById("input_email");
				const input_nickname=document.getElementById("input_nickname");
				const input_name=document.getElementById("input_name");
				const input_birthday=document.getElementById("input_birthday");
				const input_authorization=document.getElementById("input_authorization");
				
				// 정규식 추가
				
				const new_member={
					id:input_id.value.trim(),
					password:input_password.value.trim(),
					email:input_email.value.trim(),
					nickname:input_nickname.value.trim(),
					name:input_name.value.trim(),
					birthday:input_birthday.value.trim(),
					authorization:input_authorization.value.trim()
				};
				
				fetch(
					"/member/add",
					{
						method:"POST",
						headers:{
							'Content-Type':'application/json',
							'Authorization':'Bearer '+current_token
						},
						body:JSON.stringify(new_member)
					}
				).then(response=>{
					if(response.status===401){
						alert("세션이 만료되었거나 인증에 실패했습니다. 다시 로그인 해주세요.");
						localStorage.removeItem("admin_auth_token");
						window.location.href="/admin_login";
						return Promise.reject("Unauthorized");
					}
					return response.text();
				}).then(response_text=>{
					alert(response_text);
					get_member_list_button.click();
				}).catch(error=>{
					console.error("이웃 추가 서버 통신 에러 : "+error);
				})
				
			}
		)
		
		// 이웃 삭제
		output_member_list.addEventListener(
			"click",
			function(event){
				if(event.target&&event.target.classList.contains('member_delete_button')){
					const delete_member_id=event.target.value;
					if(confirm(`정말 ${delete_member_id}님을 삭제하시겠습니까?`)){
						const current_token=tokenVerification();
						fetch(
							`/member/delete?id=${delete_member_id}`,
							{
								method:"DELETE",
								headers:{
									'Authorization':'Bearer '+current_token
								}
							}
						).then(response=>{
							if(response.status===401){
								alert("세션이 만료되었거나 인증에 실패했습니다. 다시 로그인 해주세요.");
								localStorage.removeItem("admin_auth_token");
								window.location.href="/admin_login";
								return Promise.reject("Unauthorized");
							}
							return response.text();
						}).then(response_text=>{
							alert(response_text);
							get_member_list_button.click();
						}).catch(error=>{
							console.error("이웃 삭제 서버 통신 에러 : "+error);
						})
					}
				}
				
			}
		)
		
		// 이웃 수정
		output_member_list.addEventListener(
			"click",
			function(event){
				if(event.target&&event.target.classList.contains('member_modify_button')){
					const current_token=tokenVerification();
					const member_id=event.target.value;
					const modify_id=document.getElementById("modify_id");
					const modify_email=document.getElementById("modify_email");
					const modify_nickname=document.getElementById("modify_nickname");
					const modify_name=document.getElementById("modify_name");
					const modify_birthday=document.getElementById("modify_birthday");
					const modify_authorization=document.getElementById("modify_authorization");
					modify_email.removeAttribute("disabled");
					modify_nickname.removeAttribute("disabled");
					modify_name.removeAttribute("disabled");
					modify_birthday.removeAttribute("disabled");
					modify_authorization.removeAttribute("disabled");							
					console.log("1234");
					fetch(
						`/member/get_member_object?id=${member_id}`,
						{
							method:"GET",
							headers:{
									'Authorization':'Bearer '+current_token
							}
						}
					)
					.then(response=>{
						if(response.status===401){
							alert("세션이 만료되었거나 인증에 실패했습니다. 다시 로그인해주세요.");
							localStorage.removeItem("admin_auth_token");
							window.location.href="/admin_login";
							return Promise.reject('Unauthorized');
						}
						if(response.status===403){
							alert("해당 API에 접근할 권한이 없습니다.");
							return Promise.reject('Forbidden');
						}
						return response.json();
					})
					.then(data=>{
						modify_id.value=data.id;
						modify_email.value=data.email;
						modify_nickname.value=data.nickname;
						modify_name.value=data.name;
						modify_birthday.value=data.birthday;
						modify_authorization.value=data.authorization;
					})
					.catch(error=>{
						console.log("접속 이름에 해당하는 정보를 불러오는 중 오류 발생 : "+error)
					})
				}
			}
		)
		
		
		
		
		
	}	
)