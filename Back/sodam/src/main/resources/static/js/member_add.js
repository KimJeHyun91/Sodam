document.addEventListener("DOMContentLoaded", function () {
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

    if (!isValidId(id)) {
      alert("아이디는 영소문자 포함, 숫자 포함 6~15자여야 합니다."); return;
    }
    if (!isValidPassword(password, id)) {
      alert("비밀번호는 특수문자/영문자/숫자 포함 8~16자이며, 아이디와 4자 이상 겹치면 안 됩니다."); return;
    }
    if (!isPasswordConfirmed(password, confirmPassword)) {
      alert("비밀번호가 일치하지 않습니다."); return;
    }
    if (!isValidName(name)) {
      alert("이름은 한글 2~10자여야 합니다."); return;
    }
    if (!isValidNickname(nickname)) {
      alert("별칭은 한글 2~8자 + 숫자 최대 4자이며, 부적절한 단어를 포함할 수 없습니다."); return;
    }
    if (!id || !password || !confirmPassword || !email || !nickname || !name || !birthday || !authorization) {
      alert("모든 항목을 입력해주세요."); return;
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
        document.getElementById("get_member_list_button").click();
      } else {
        alert("이웃 추가 실패: " + await res.text());
      }
    } catch (err) {
      console.error("이웃 추가 중 오류", err);
      alert("서버 오류로 추가에 실패했습니다.");
    }
  });

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

function isValidId(id) {
  const regex = /^(?=.*[a-z])[a-z0-9]{6,15}$/;
  return regex.test(id);
}

function isValidPassword(password, id) {
  const lengthCheck = /^.*(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#$%^&*()\-_=+]).{8,16}$/;
  const overlapCheck = id && password.includes(id.substring(0, 4));
  return lengthCheck.test(password) && !overlapCheck;
}

function isPasswordConfirmed(password, confirmPassword) {
  return password === confirmPassword;
}

function isValidName(name) {
  const regex = /^[가-힣]{2,10}$/;
  return regex.test(name);
}

const BAD_WORDS = ["바보", "멍청이", "욕설"]; // 예시
function isValidNickname(nickname) {
  const regex = /^[가-힣]{2,8}\d{0,4}$/;
  const hasBadWord = BAD_WORDS.some(word => nickname.includes(word));
  return regex.test(nickname) && !hasBadWord;
}

