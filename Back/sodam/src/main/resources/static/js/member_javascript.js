document.addEventListener("DOMContentLoaded", async function () {
  const get_member_list_button = document.getElementById("get_member_list_button");
  const output_member_list = document.getElementById("output_member_list");
  const member_search_input = document.getElementById("member_search_input");

  let memberList = [];

  // ✅ 관리자 토큰 체크
  let admin_auth_token = localStorage.getItem("admin_auth_token");
  if (!admin_auth_token) {
    try {
      const token_response = await fetch("/admin/get_admin_token");
      if (token_response.ok) {
        const token_data = await token_response.json();
        if (token_data.token) {
          admin_auth_token = token_data.token;
          localStorage.setItem("admin_auth_token", admin_auth_token);
        } else {
          alert("관리자 토큰 발급 실패");
          location.href = "/admin_login";
          return;
        }
      } else {
        alert("관리자 인증이 필요합니다. 로그인 페이지로 이동합니다.");
        location.href = "/admin_login";
        return;
      }
    } catch (e) {
      console.error("관리자 토큰 요청 에러:", e);
      alert("토큰 요청 중 오류 발생. 로그인 페이지로 이동합니다.");
      location.href = "/admin_login";
      return;
    }
  }

  // ✅ 토큰 검증 함수
  function tokenVerification() {
    const token = localStorage.getItem("admin_auth_token");
    if (!token) {
      alert("인증 토큰 없음. 다시 로그인해주세요.");
      location.href = "/admin_login";
    }
    return token;
  }

  // ✅ 이웃 테이블 렌더링 함수
  function renderMemberTable(data) {
    output_member_list.innerHTML = "";
    if (data.length === 0) {
      output_member_list.innerHTML = "<tr><td colspan='10'>검색 결과 없음</td></tr>";
      return;
    }
    data.forEach(item => {
      output_member_list.innerHTML += `
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
          <td>
            <button class="member_modify_button" value="${item.id}">수정</button>
            <button class="member_delete_button" value="${item.id}">삭제</button>
          </td>
        </tr>`;
    });
  }

// 삭제
output_member_list.addEventListener("click", function(event) {
  if (event.target && event.target.classList.contains('member_delete_button')) {
    const delete_member_id = event.target.value;
    if (confirm(`정말 ${delete_member_id}님을 삭제하시겠습니까?`)) {
      const current_token = tokenVerification();
      fetch(`/member/delete?id=${delete_member_id}`, {
        method: "DELETE",
        headers: {
          'Authorization': 'Bearer ' + current_token
        }
      })
      .then(response => {
        if (response.status === 401) {
          alert("세션이 만료되었거나 인증에 실패했습니다. 다시 로그인 해주세요.");
          localStorage.removeItem("admin_auth_token");
          window.location.href = "/admin_login";
          return Promise.reject("Unauthorized");
        }
        return response.text();
      })
      .then(response_text => {
        alert(response_text);
        get_member_list_button.click(); // 목록 새로고침
      })
      .catch(error => {
        console.error("이웃 삭제 서버 통신 에러: " + error);
      });
    }
  }
});

  // ✅ 전체 이웃 불러오기
  get_member_list_button.addEventListener("click", function () {
    const token = tokenVerification();
    output_member_list.innerHTML = "<tr><td colspan='10'>불러오는 중...</td></tr>";

    fetch("/member/get_member_list", {
      headers: { 'Authorization': 'Bearer ' + token }
    })
      .then(response => response.json())
      .then(data => {
        memberList = data;
        renderMemberTable(memberList);
      })
      .catch(() => {
        output_member_list.innerHTML = "<tr><td colspan='10'>불러오기 실패</td></tr>";
      });
  });

  // ✅ 검색 입력시 즉시 필터링
  member_search_input.addEventListener("input", function () {
    const keyword = member_search_input.value.trim().toLowerCase();
    const filtered = memberList.filter(member =>
      member.email.toLowerCase().includes(keyword) ||
      member.nickname.toLowerCase().includes(keyword) ||
      member.name.toLowerCase().includes(keyword)
    );
    renderMemberTable(filtered);
  });

  // ✅ 로그아웃
  const logout_button = document.getElementById("logout_button");
  logout_button.addEventListener("click", function () {
    if (confirm("로그아웃 하시겠습니까?")) {
      localStorage.removeItem("admin_auth_token");
      const form = document.createElement("form");
      form.method = "POST";
      form.action = "/logout";
      document.body.appendChild(form);
      form.submit();
    }
  });

  // ✅ 기타 기능 (id, email 중복 확인, 이웃 추가/삭제 등)은 기존에 작성한 그대로 유지하면 됩니다

    document.getElementById("open_add_modal").addEventListener("click", function () {
      document.getElementById("add_modal").style.display = "block";
    });
    document.getElementById("close_add_modal").addEventListener("click", function () {
      document.getElementById("add_modal").style.display = "none";
    });
    window.addEventListener("click", function (event) {
      if (event.target === document.getElementById("add_modal")) {
        document.getElementById("add_modal").style.display = "none";
      }
    });
});


