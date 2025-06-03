// 📁 models/models.dart

/// 캐릭터 역할 (MBTI 또는 직업 같은 개념)
enum CharacterRole { fisherman, poet, playboy, beauty }

/// 칸 색상 유형
enum CellColorType { sky, white, black, pink, yellow }

/// 보드 칸 정보
class BoardCell {
  final int number; // 칸 번호 (1~72)
  final CellColorType color; // 색상
  bool isTeleport; // 텔레포트 기능 여부
  int? teleportTarget; // 텔레포트 목적지
  bool isLadder; // 사다리 기능 여부
  int? ladderTarget; // 사다리 목적지

  BoardCell({
    required this.number,
    required this.color,
    this.isTeleport = false,
    this.teleportTarget,
    this.isLadder = false,
    this.ladderTarget,
  });
}

/// 플레이어 정보
class Player {
  final String name; // 예: '어부'
  final CharacterRole role; // 역할
  int position; // 현재 위치 (1~72)
  bool isFinished; // 도착 여부

  Player({
    required this.name,
    required this.role,
    this.position = 1,
    this.isFinished = false,
  });
}
