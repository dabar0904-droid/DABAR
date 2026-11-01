# 다바르 로고

기존 `index.html` 표지의 유리병·여명의 갈대 문양을 로고 크기에 맞게 다듬었습니다. 표지의 송명체와 다섯 감정 색상을 그대로 사용합니다.

| 파일명 (SVG / PNG) | 용도 |
| --- | --- |
| `dabar-logo-dark` | 어두운 배경의 기본 가로형 로고, 900 × 400 |
| `dabar-logo-light` | 아이보리 배경의 가로형 로고, 900 × 400 |
| `dabar-logo-transparent` | 밝은 배경에 올리는 투명 가로형 로고, 900 × 400 |
| `dabar-icon` | 프로필·앱 아이콘용 정사각형, 1024 × 1024 |
| `dabar-symbol-gold` | 어두운 배경에 올리는 투명 금빛 심볼, 512 × 512 |

SVG의 모든 글자는 윤곽선으로 변환되어 별도 글꼴 설치나 인터넷 연결이 필요 없습니다. 웹·인쇄에는 SVG, 일반 업로드에는 PNG를 사용하세요. 작은 파비콘에서는 심볼의 세부 선이 덜 보일 수 있습니다.

색상: 먹색 `#211F1B`, 아이보리 `#EDE8DC`, 금색 `#D9BE72`. 밝은 배경용 금색은 가독성을 위해 `#947C3E`를 사용했습니다.

생성 방식: 기존 벡터 문양을 코드로 정리하고 System.Drawing으로 SVG 윤곽선과 PNG를 제작했습니다. 생성형 이미지 도구는 사용하지 않았습니다.

재생성: Windows PowerShell에서 `powershell -ExecutionPolicy Bypass -File scripts/build-brand.ps1`을 실행합니다. 송명체 원본과 SIL Open Font License는 `fonts/`에 포함되어 있습니다. 출처: https://github.com/google/fonts/tree/main/ofl/songmyung
