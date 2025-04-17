

##  프로젝트 개요

| 항목 | 내용 |
|------|------|
| 플랫폼 | iOS (UIKit 기반) |
| 아키텍처 | MVVM + UseCase + Repository + Router |
| 사용 기술 | UIKit, Firebase, SnapKit, Then, Kingfisher, ActiveLabel |
| 주요 기능 | 회원가입, 로그인, 트윗 CRUD, 팔로우/언팔로우, 멘션, 댓글, 좋아요, 프로필 수정, 실시간 동기화 등 |

---

##  아키텍처 설계

본 프로젝트는 유지보수성과 테스트 용이성을 위해 다음과 같은 구조를 따릅니다:
Presentation → UseCase → Repository → Service → 외부 API/Firebase

### ✅ MVVM 기반 UI 설계
- ViewController는 UI 구성 및 이벤트 처리만 담당
- ViewModel은 상태 관리와 비즈니스 로직 호출 전담
- View ↔ ViewModel 간 클로저 바인딩으로 의존성 최소화

### ✅ UseCase 중심의 비즈니스 로직 분리
- 모든 주요 기능은 ViewModel이 직접 처리하지 않고
- 각 기능 단위 UseCase를 통해 수행
- SRP(단일 책임 원칙)를 유지하면서 기능 테스트 및 교체가 쉬운 구조 구성  
  예: TweetUploadUseCase, EditProfileUseCase, LogoutUseCase 등

### ✅ Repository + Service 패턴 도입
- Repository는 ViewModel/UseCase와 Data Layer의 중간 인터페이스 역할
- Service는 실제 Firebase, Storage 등과 통신하는 세부 구현 담당
- Firebase 의존성을 격리하여 향후 REST API 등으로 교체 용이

### ✅ DIContainer를 통한 전역 의존성 주입 관리
- AppDIContainer를 통해 ViewController에 필요한
  UseCase / Repository / Router 등을 명시적으로 생성 및 주입
- 모든 의존성은 생성자 기반 주입을 사용하여 테스트 Mock 교체 및 의존성 추적이 쉬운 구조 확보

### ✅ Router 패턴 적용으로 화면 전환 책임 분리
- 각 화면의 이동은 ViewController가 아닌 전담 Router 객체에서 처리
- DIContainer로부터 Router도 주입받도록 설계하여
  ViewController의 책임을 단순화하고 전환 흐름을 테스트 가능하게 설계

### ✅ NotificationCenter 기반 실시간 데이터 동기화
- Explorer, Feed, Detail 화면 간 유저 데이터 변경사항을 실시간 반영
- Notification 패턴을 활용하여, 별도 Firebase 재요청 없이 로컬 캐시만으로 즉각 UI 갱신 처리

### ✅ 프로토콜 기반 추상화 및 캡슐화
- 각 계층 (UseCase, Repository, Router)는 프로토콜로 추상화되어 ViewModel/Controller가 구현체에 의존하지 않음
- 내부 구현은 외부에서 보이지 않도록 숨기고 인터페이스 수준으로만 상호작용하도록 설계
- 이로 인해 Mock 객체를 활용한 테스트 작성이 용이하고, 의존성 교체 시에도 기존 구조 수정 없이 대응 가능

---

## 🔧 기술 스택

UIKit, MVVM, Firebase (Auth, Realtime DB, Storage), SnapKit, Then, Kingfisher, ActiveLabel

---

## ✨ 주요 기능

- 회원가입 (이미지 포함 계정 생성 및 Firebase 연동)
- 로그인 (이메일/비밀번호 기반 Auth 처리)
- 트윗 업로드 (텍스트 기반 트윗 실시간 업로드)
- 팔로우 / 언팔로우 (유저 간 팔로우 상태 관리 및 실시간 반영)
- 트윗 좋아요 (상태 관리 + 즉시 UI 반영)
- 트윗 리플 (댓글 작성 및 실시간 댓글 목록 처리)
- 멘션 기능 (ActiveLabel 기반 유저 멘션 및 프로필 이동 처리)
- 프로필 수정 (닉네임, 소개, 이미지 변경 및 실시간 반영)
- 프로필 화면 필터 (트윗, 리플, 좋아요 탭별 데이터 관리 및 표시)
- 로그아웃 (루트 전환 및 세션 종료 처리)
- 커스텀 알럿 


---

## 🎯 주요 설계 포인트

- ViewModel에서 UI 상태를 클로저 기반으로 전달 (`Rx`, `Combine` 없이 바인딩)
- NotificationCenter를 활용한 다중 화면 실시간 데이터 동기화
- DIContainer를 통한 팩토리 기반 의존성 관리
- 단일 책임 원칙(SRP)에 기반한 계층 설계

---

## 💬 기타

- 테스트 코드는 포함되지 않았으며, 추후 `XCTest` 기반 유닛 테스트 작성 예정

---

## 📸 데모 GIF

> 
https://www.notion.so/A-1d8e121de2fd80959e3beeca802e8751?pvs=4
---


## 📂 프로젝트 구조

```bash
A/
├── App/                         # 앱 진입점 및 DI 관련
│   └── DIProtocol/              # 의존성 주입 프로토콜 정의
├── Core/                        # 앱 전반에 걸친 핵심 유틸리티
│   ├── Constants/               # 전역 상수
│   └── Extensions/              # Swift 확장(Extension)
├── Resources/                   # 리소스 파일
│   └── Assets.xcassets/         # 이미지 에셋
├── Shared/                      # 공유 가능한 타입 및 유틸
│   └── Enums/                   # 열거형
│       ├── UI/                  # UI 관련 Enum
│       ├── Navigation/          # 네비게이션 관련 Enum
│       └── Error/               # 에러 타입 Enum
├── Domain/                      # 도메인 레이어
│   ├── Models/                  # 모델 객체
│   │   └── ModelProtocols/      # 모델 프로토콜
│   ├── UseCase/                 # 유즈케이스 구현
│   │   └── UseCaseProtocols/    # 유즈케이스 프로토콜
│   └── Factories/               # 팩토리 클래스
├── Data/                        # 데이터 레이어
│   ├── Repository/              # 저장소 (Repository)
│   │   └── RepositoryProtocols/ # 저장소 프로토콜
│   └── Service/                 # 실제 데이터 통신 서비스
└── Presentation/                # UI 레이어
    ├── Auth/                    # 인증 관련 화면
    ├── Tweet/
    │   ├── UploadTweet/         # 트윗 업로드 화면
    │   └── TweetViewModelProtocols/ # 뷰모델 프로토콜
    ├── Explorer/                # 탐색(Explorer) 화면
    ├── Profile/
    │   └── FilterView/          # 프로필 필터 뷰
    ├── EditProfile/             # 프로필 수정 화면
    ├── Notification/            # 알림 화면
    ├── Alert/                   # 커스텀 얼럿
    ├── Router/                  # 화면 전환 담당 라우터
    └── Common/                  # 공통 UI 컴포넌트


