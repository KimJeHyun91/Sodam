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


  // =============================== 이웃추가 ===============================

document.getElementById("open_add_modal").addEventListener("click", () => {
    document.getElementById("add_modal").style.display = "block";
  });
  document.getElementById("close_add_modal").addEventListener("click", () => {
    document.getElementById("add_modal").style.display = "none";
  });
  window.addEventListener("click", e => {
    if (e.target === document.getElementById("add_modal")) {
      document.getElementById("add_modal").style.display = "none";
    }
  });

  document.getElementById("member_add_button").addEventListener("click", async () => {
    const id = document.getElementById("input_id").value.trim();
    const password = document.getElementById("input_password").value.trim();
    const confirmPassword = document.getElementById("input_password_verification").value.trim();
    const email = document.getElementById("input_email").value.trim();
    const nickname = document.getElementById("input_nickname").value.trim();
    const name = document.getElementById("input_name").value.trim();
    const birthday = document.getElementById("input_birthday").value.trim();
    const authorization = document.getElementById("input_authorization").value.trim();
    const agree = document.getElementById("input_agree").checked;

    if (!id || !password || !confirmPassword || !email || !nickname || !name || !birthday || !authorization) {
      alert("모든 항목을 입력해주세요."); return;
    }
    if (password !== confirmPassword) {
      alert("비밀번호가 일치하지 않습니다."); return;
    }
    if (!agree) {
      alert("개인정보 수집에 동의해주세요."); return;
    }

    try {
      const token = localStorage.getItem("admin_auth_token");
      const res = await fetch("/member/add", {
        method: "POST",
        headers: { "Content-Type": "application/json", "Authorization": "Bearer " + token },
        body: JSON.stringify({ id, password, email, nickname, name, birthday, authorization })
      });
      if (res.ok) {
        alert("이웃 추가 성공");
        document.getElementById("add_modal").style.display = "none";
        get_member_list_button.click();
      } else {
        alert("이웃 추가 실패: " + await res.text());
      }
    } catch (err) {
      console.error("이웃 추가 중 오류", err);
      alert("서버 오류로 추가에 실패했습니다.");
    }
  });

  // ID 중복 확인
  document.getElementById("check_id_button").addEventListener("click", async () => {
    const id = document.getElementById("input_id").value.trim();
    if (!id) return alert("아이디를 입력해주세요.");
    try {
      const res = await fetch(`/member/id_check?id=${id}`);
      const code = await res.text();
      document.getElementById("id_error").textContent =
        code === "1010" ? "사용 가능한 아이디입니다." : "이미 사용 중인 아이디입니다.";
    } catch (err) {
      document.getElementById("id_error").textContent = "서버 오류 발생";
    }
  });

  // 이메일 인증번호 발송
  document.getElementById("send_email_button").addEventListener("click", async () => {
    const email = document.getElementById("input_email").value.trim();
    if (!email) return alert("이메일을 입력해주세요.");
    try {
      const res = await fetch("/auth/send-code-signup", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email })
      });
      const result = await res.json();
      alert(result.message || "인증번호가 전송되었습니다.");
    } catch (err) {
      alert("인증번호 발송 실패");
    }
  });

  // 이메일 인증번호 검증
  document.getElementById("verify_email_button").addEventListener("click", async () => {
    const email = document.getElementById("input_email").value.trim();
    const code = document.getElementById("input_email_code").value.trim();
    if (!email || !code) return alert("이메일과 인증번호를 입력해주세요.");
    try {
      const token = localStorage.getItem("admin_auth_token");
      const res = await fetch("/auth/verify-code", {
        method: "POST",
        headers: { "Content-Type": "application/json", "Authorization": "Bearer " + token },
        body: JSON.stringify({ email, code })
      });
      const result = await res.json();
      document.getElementById("email_code_error").textContent =
        result.status === "success" ? "✅ 인증 성공" : result.message || "❌ 인증 실패";
    } catch (err) {
      document.getElementById("email_code_error").textContent = "❌ 인증 중 오류 발생";
    }
  });
});
