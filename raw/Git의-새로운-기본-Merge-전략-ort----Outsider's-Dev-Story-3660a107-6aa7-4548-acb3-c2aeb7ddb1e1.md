---
title: "Git의 새로운 기본 Merge 전략 ort :: Outsider's Dev Story"
notion_id: 3660a107-6aa7-4548-acb3-c2aeb7ddb1e1
last_edited: 2024-02-23T12:48:00.000Z
type: database_row
parent_db: 327e7819-aec6-4569-8c9b-e62da1ea17b1
parent_db_title: "Reading List"
---

현재 Git이 Merge 할 때 사용하는 전략이 `ort`로 바뀌었다. Git에 `ort` 머지 전략이 들어온 것은 [Git 2.33](https://github.blog/2021-08-16-highlights-from-git-2-33/#merge-ort-a-new-merge-strategy)부터였고 [Git 2.34](https://github.blog/2021-11-15-highlights-from-git-2-34/#a-new-default-merge-strategy)에서 별도의 설정 없이도 Merge할 때 사용되는 기본 전략으로 바뀌었다.


이 Merge 전략은 `git merge`와 `git pull`을 할 때 주로 사용되지만 `rebase`, `cherry-pick`, `revert`, `stash`, `checkout`에서도 사용된다. 2.34가 2021년 11월에 나왔으니 바뀐 지는 꽤 되었지만 뭐가 바뀌는지는 정확히 모르고 있어서 정리를 해봤다. 이 글 쓰는 시점의 Git 최신 버전은 [2.43.0](https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.43.0.txt)


## `resolve` 전략


Git이 2개의 브랜치를 머지할 때 변경 사항을 합치기 위해 여러 가지 전략 중 하나를 선택한다. 원래의 전략은 [3-way merge](https://en.wikipedia.org/wiki/Merge_(version_control)#Three-way_merge) 알고리즘을 사용하는 `resolve` 전략을 사용했다.


3-way merge는 A 파일과 B 파일의 차이점을 분석한 후 두 파일의 공통 조상인 C 까지 고려해서 합칠 변경 사항을 구성하고 A, B, C 셋 다 다른 경우는 충돌(Conflict)로 표시해서 사용자가 해결하도록 한다.


## `recursive` 전략


Git이 만들어진 초기인 2005년에 `resolve` 전략은 `recursive`라는 전략으로 [교체](https://github.com/git/git/commit/fbf8ac212caa74fc506434da83f8e9630b09ed12)된다. 이렇게 `recursive`로 바꾼 주요 이유는 머지할 두 브랜치가 공통된 조상이 없는 경우에도 각 브랜치에서 그 이름대로 재귀적으로 머지할 수 있어서 `resolve` 전략에서 충돌하는 경우에도 머지할 수 있고 한 브랜치에서는 파일이 수정되고 다른 브랜치에서는 파일명이 변경된 경우에도 이를 감지할 수 있기 때문이다.


이렇게 적용된 `recursive`는 오랫동안 Git의 기존 전략으로 사용되었다. 2005년에 적용되고 2021년에 나온 Git 2.33에서 바뀌었으니 16년 동안 사용된 셈이다.


## `ort` 전략


`ort`는 재귀(recursion)와 파일이름 변경 탐지를 하는 `recursive`와 같은 컨셉을 가지고 처음부터 새로 작성된 전략이다. 그래서 ort라는 이름도 Ostensibly Recursive’s Twin의 약자로 표면적으로는 Recursive의 쌍둥이라는 의미이고 이전에 비해 [훨씬 빨라졌다](https://lore.kernel.org/git/4a0f088f3669a95c7f75e885d06c0a3bdaf31f42.1628055482.git.gitgitgadget@gmail.com/).


[Git 공식 문서](https://git-scm.com/docs/merge-strategies#Documentation/merge-strategies.txt-ort)를 보면 `ort` 전략을 다음과 같이 설명하고 있다.

> 
>
> 하나의 브랜치를 가져오거나(pull) 머지할 때 사용하는 기본 머지 전략이다. 이 전략은 3-way 머지 알고리즘을 사용해서 두 개의 헤드(head)만 처리할 수 있다. 3-way 머지에 사용할 수 있는 공통 조상이 2개 이상 있다면 공통 조상의 머지된 트리를 만들어서 이를 3-way 머지의 참조 트리로 사용한다. Linux 2.6 커널 개발 기록에서 가져온 실제 머지 커밋을 대상으로 테스트한 결과 ort가 잘못된 머지도 없고 머지 충돌이 더 적게 발생했다. 또한, 이 전략은 이름 변경과 관련된 머지를 탐지하고 처리할 수 있으며 감지된 사본(detected copies)을 사용하지 않는다.
>
>

그러면 오랫동안 사용하던 `recursive` 전략을 왜 바꿀 필요가 있는지를 알아야 하는데 새로운 전략이긴 하지만 방법 자체를 바꾸었다기보다는 많은 최적화 작업을 합쳐서 `ort`라는 새로운 전략이 탄생했다고 볼 수 있고 그렇기에 이름도 `recursive`의 쌍둥이라는 이름을 가지게 된 것이다.


Git에서 `recursive` 머지의 코드 베이스는 문제를 해결하기 위해 조금만 고치다 보니 결국 고칠 수 없는 상황까지 왔습니다. 그래서 버그도 많이 발생하고 해결하기 어려운 엣지 케이스도 발생하고 있었고 개발자들도 이 부분의 코드 수정은 피하고 있었다. Git의 핵심 개발자 중 한 명인 [Elijah Newren](https://github.com/newren)가 큰 변경을 하려고 하자 초기부터 Git을 리드하고 있는 [Junio Hamano](https://github.com/gitster) 그냥 다시 작성하자는 제안하고 이에 따라 아주 대규모의 최적화 작업이 시작된다.


이 최적화 과정을 이해하려면 Git의 3-way 머지를 좀 이해해야 한다.


```plain text
A---B---C topic
    /
D---E---F---G main
```


즉, 위처럼 2개의 브랜치를 머지한다고 했을 때 각 브랜치의 최신 커밋인 `C`와 `G`, 두 브랜치의 공통 조상이 되는 커밋인 `E`까지 고려해서 머지하는 것이다. 특정 라인이 C 커밋에는 없고 G 커밋에는 있다고 했을 때 이 둘만 가지고는 이 라인이 추가된것인지 제거된 것인지 알 수 없다. 공통 조상이 E 커밋을 봤을 때 해당 라인이 있다면 C 커밋에서 제거한 것이고 E 커밋에 해당 라인이 없다면 G 커밋에서 추가된 것이다.(참고로 git에서 [diff3 설정](https://blog.outsider.ne.kr/805)을 하면 충돌이 발생했을 때 공통 조상의 내용도 같이 보여서 수정할 때 편하다.)


여기서 파일 이름 변경까지 되면 훨씬 복잡해진다. 각 브랜치에서 파일 내용을 수정할 수 있지만 파일명을 바꾸거나 파일명은 그대로이지만 디렉터리 위치가 바뀔 수 있다. Git은 파일명을 따로 추적하고 있지 않기 때문에 머지할 때 이 이름 변경을 감지해서 이름이 변경된 파일을 찾아내야 하는 것이다. 위에서 말한 대로 머지를 할 때 3개의 커밋이 필요한데 각 커밋에서 고유의 파일명 목록을 만들고 서로 일일이 비교하면서 내용의 유사성을 비교해서 파일 변경인지를 표시하게 되므로 상당히 느린 부분이다.


코딩에서 추상화는 중요한 개념이지만 때로는 경계를 만들어서 경계에 걸쳐서 어떤 작업을 하려고 할 때 어렵게 만들기도 한다. Git도 이러한 추상화로 인해서 최적화가 어려웠던 경우인데 Git에도 파일 이름 변경을 탐지하는 컴포넌트가 분리되어 있었다. 이 컴포넌트는 3개의 커밋에 대한 정보가 아니라 2개 커밋에 대한 정보만 받고 있었는데 파일 이름 변경을 추적하려면 3개 커밋의 정보가 모두 필요했기 때문에 이 추상화 경계를 넘어서 추가 정보를 제공해야 했다.


또한, rebase나 cherry-pick을 할 때도 각 커밋 단계마다 이름 변경 탐지를 하게 되는데 이게 반복적으로 진행되므로 인메모리에 캐싱해서 개선하게 된다. 당연히 왜 이전에는 안 했는지 궁금할 수 있지만 캐싱해도 동작의 차이가 없는지를 확인하는 것이 아주 복잡했기 때문에 못 했던 것인데 이번에는 몇 가지 제약사항을 가진 채 이 캐싱 최적화를 추가했다.


Git에서 Index라는 것은 보통 우리가 Stage 영역이라고 부르는 것으로 다음 커밋에 포함될 파일에 대한 정보를 가지고 있는 데이터 구조인데 `recursive` 전략에서는 이 Index 데이터 구조가 핵심이었다(working tree 포함). `ort` 전략에서는 이 Index를 사용하지 않고 `recursive`에서 성능에 영향을 많이 주던 `unpack_trees()`라는 저수준 함수의 사용을 안 하도록 바뀌었다. 그래서 이 두 가지에 의존함으로써 생긴 제약을 대부분 해결할 수 있게 되었다.


다시 정리하면 `ort`는 index와 working tree를 건드리지 않고 머지 결과를 트리로 만들어서 이 머지 결과가 나왔을 때만 `ort`가 체크아웃 로직을 이용해서 머지 결과로 이동하게 된다. index에 항목을 추가 제거하는 동작과 머지하면서 수행되는 값비싼 트리 탐색을 피할 수 있게 되어 속도가 훨씬 빨라지게 된다.


최대한 간단히 정리했지만, 이 내용은 이 수많은 최적화 작업을 주도한 [Elijah Newren](https://github.com/newren)이 작성한 6편의 글 Optimizing Git’s Merge Machinery, [#1](https://blog.palantir.com/optimizing-gits-merge-machinery-1-127ceb0ef2a1), [#2](https://blog.palantir.com/optimizing-gits-merge-machinery-2-d81391b97878), [#3](https://blog.palantir.com/optimizing-gits-merge-machinery-3-2dc7c7436978), [#4](https://blog.palantir.com/optimizing-gits-merge-machinery-part-iv-5bbc4703d050), [#5](https://blog.palantir.com/optimizing-gits-merge-machinery-part-v-46ff3710633e), [#6](https://blog.palantir.com/optimizing-gits-merge-machinery-6-7bf887a131d8)에 잘 나와 있다. 아주 긴 글이지만 한번 읽어볼 만한 좋은 글이다.


[Git 2.33 공지](https://github.blog/2021-08-16-highlights-from-git-2-33/#merge-ort-a-new-merge-strategy)에 따르면 ort가 이전보다 훨씬 빨라져서 파일명 변경이 많고 복잡한 머지의 경우 500배가 빨라졌고 rebase 과정에서 비슷한 머지를 반복해서 하게 되면 `ort`가 일부 계산을 캐싱하기 때문에 9,000배 이상 빨라진다고 한다. 이건 특수한 경우고 일반적으로도 `ort`가 `recursive`보다 약간 빠른 것으로 나타났지만 `recursive`는 상황에 따라 속도 편차가 크지만 `ort`는 일관된 속도를 보여주었다.


일반적인 상황에서 보통 머지 속도가 문제 되진 않지만 아마 머지와 리베이스를 가장 많이 실행하는 [GitHub이 ](https://github.blog/2023-07-27-scaling-merge-ort-across-github/)[`ort`](https://github.blog/2023-07-27-scaling-merge-ort-across-github/)[를 적용](https://github.blog/2023-07-27-scaling-merge-ort-across-github/)한 결과를 보면 머지 속도가 p50에서는 10배 p99에서는 5배 빨라졌고 리베이스에서도 이전에 512시간 걸리던 리베이스가 `ort`에서는 33시간으로 줄어들었다는 것을 보면 속도가 얼마나 개선되었는지 알 수 있다.


추가로 Git으로 머지할 때 다음과 같이 어떤 전략이 사용되었는지 나온다.


```plain text
Auto-merging a.txt
Merge made by the 'ort' strategy.
```


`git merge --strategy recursive BRANCH-NAME`처럼 머지할 때 `-s`나 `--strategy` 옵션으로 머지 전략을 지정하면 다른 머지 전략을 사용할 수 있다. 여기서처럼 `ort` 대신 `recursive`를 지정하면 메시지에서도 `Merge made by the 'recursive' strategy.`라고 나와서 머지 전략이 바뀌었음을 확인할 수 있다.


# 웹개발 관련

- [**How Core Web Vitals affect SEO**](https://vercel.com/blog/how-core-web-vitals-affect-seo) : Google은 Core Web Vitals로 사이트의 성능을 평가해서 SEO에 반영하는데 이 데이터를 실제 사용자에게 수집하므로 필드 데이터라고 부른다. Google은 크롬 브라우저의 실제 사용자의 75 퍼센타일로 전 세계에서 필드 데이터를 수집하기 때문에 사용자는 데스크톱이나 Android에서 Chrome을 사용해야 한다.(다른 말로 하면 iPhone 사용자는 집계되지 않는다) 지역별로 다르게 다루지 않고 전 세계에서 수집하므로 전 세계 모든 사용자에게 뛰어난 성능을 제공할 수 있어야 하고 점수는 지난 28일간의 평균 점수이므로 성능을 개선한 후 영향을 파악하려면 한 달 정도가 걸린다. Lighthouse 등으로 Core Web Vitals를 측정한 것은 실험실 데이터라고 부르는데 이러한 결과는 검색 결과에는 반영되지 않고 실제 사용자와는 다르기 때문에 성능 문제를 찾는 참고용으로 사용해야 한다.(영어)
- [**QUIC 프로토콜 | 구글 또 너야?**](https://medium.com/rate-labs/quic-%ED%94%84%EB%A1%9C%ED%86%A0%EC%BD%9C-%EA%B5%AC%EA%B8%80-%EB%98%90-%EB%84%88%EC%95%BC-932befde91a1) : QUIC 논문을 보고 내용을 정리한 글이다. 불필요한 RTT(Round Trip Time)을 줄이면 페이지 로드 시간에 큰 영향을 주기 때문에 QUIC은 TCP가 아니라 UDP 위에 구현되었는데 QUIC을 설계한 이유는 프로토콜을 변경하기 어렵고 핸드 쉐이크를 줄일 필요가 있었고 HOL 블러킹 문제를 해결하기 위해서였다. 이를 구현한 과정과 적용한 과정까지 정리되어 있다.(한국어)
- [**Celebrate a more interoperable web with Interop 2023**](https://web.dev/blog/interop-2023-wrapup?hl=en) : 브라우저간 호환성을 유지하기 위해 여러 브라우저가 벤더가 공동으로 테스트를 만들어서 상호 운용성을 개선하기 위한 Interop 2023이 마무리 되었다. [작년 초와 비교](https://web.dev/blog/interop-2023)했는때 대부분 90점대 후반으로 큰 개선이 이루어 졌고 `:has()`, 컨테이너 쿼리, 서비그리드, 색공간 등 주요한 기능이 추가되었다. 곧 Interop 2024가 발표될 예정이다.(영어)
- [**NEXT.JS APP ROUTER MIGRATION: THE GOOD, BAD, AND UGLY**](https://www.flightcontrol.dev/blog/nextjs-app-router-migration-the-good-bad-and-ugly) : Flightcontrol이라는 서비스가 Next.js의 페이지 라우터로 구축되어 있던 대시보드를 앱 라우터로 다시 구축하면서 경험한 내용을 정리했다. 중첩된 레이아웃을 구축할 수 있게 되었고 로딩 상태를 유연하게 표시할 수 있지만 실시간 업데이트를 위해 클라이언트에서 데이터 불러오는 코드를 중복으로 작성해야 했고 서버 측 오류가 쉽게 삼켜져서 추적하기에 어려웠다고 한다. 지금은 해결되었지만 개발하면서 버그가 너무 많아서 고생했고 개발 서버의 성능이 너무 안 좋아서 성숙도에 비해 너무 빨리 마케팅이 되었다고 한다.(영어)

# 그 밖의 개발 관련

- [**Jira의 이슈 정렬 방식이 Integer 방식이 아니라고?!**](https://techblog.lycorp.co.jp/ko/about-atlassian-jira-ranking-algorithm-lexorank) : 드래그 앤 드롭으로 리스트의 정렬을 조정하는 구현을 할 때 각 아이템의 정렬을 관리하는 방식에는 Integer, GreenHopper, Linked List 방식이 있습니다. Integer 방식은 위치를 변경하면 다른 모든 아이템의 값도 변경해야 하고 GreenHopper은 각 아이템 사이에 충분한 간격을 두어 쉽게 업데이트할 수 있지만 공간이 고갈되면 문제가 생긴다. Linked List는 앞뒤 아이템만 업데이트해 주면 되지만 조회할 때 풀 스캔을 해야 한다. Atlassian이 이러한 문제를 해결하기 위해 LexoRank를 만들었고 사전적 정렬을 위해 `Bucket|FixedKey:VariableKey`를 사용해서 정렬해서 O(1)로 정렬할 수 있으며 공간 고갈 시에는 무중단으로 재조정 할 수 있다.(한국어)
- [**기술 문서 사이트로 Docusaurus 활용하기**](https://techblog.lycorp.co.jp/ko/docusaurus-as-a-technical-document-website) : Line내에서고 기술 문서의 규모가 커지면서 그때그때 다른 SSG(Static Site Generator)를 쓰게 되면서 공용 SSG를 선정하게 되었다. SSG를 선정하면서 웹 문서에 필요한 기본 기능이 충실하고 새로운 기능을 자유롭게 추가할 수 있어야 한다는 기준을 정하고 2세대 SSG 도구 중에 React 기반이면서 MDX도 지원하는 Docusaurus를 선정했다. 기술 문서에 필요한 기능을 추가하기 위해 줄 바꿈 테이블, 용어집, API 레퍼런스 기능을 만든 과정을 설명한다.(한국어)
- [**Jetpack Compose로 LINE 앱 Yahoo!검색 모듈 개발하기**](https://techblog.lycorp.co.jp/ko/developing-android-ui-with-jetpack-compose) : Line에서 선언적 UI 툴킷인 Jetpack Compose를 도입한 과정을 설명한 글이다. 기존 앱을 운영하면서 도입해야 했기에 새로운 뷰에 도입하기로 하고 Composable에 도입하기로 조건을 걸고 선언적 UI를 위해 상태관리를 일원화하고 Composable을 stateless로 만들고 만든 Composable은 미리보기로 만들고 미리보기는 Pull Request에 포함하기로 하면서 Jatpack Compose 도입을 했다고 한다.(한국어)
- [**Zed is now open source**](https://zed.dev/blog/zed-is-now-open-source) : GitHub의 Atom을 만들던 개발자가 나와서 만든 Zed 에디터가 오픈소스가 되었다. 오픈소스로 해야 최고의 제품이 될 수 있고 훨씬 더 재밌을 거로 생각해서 오픈소스로 공개했다고 한다.(영어)

# 인프라 관련

- [**Maturing Istio Ambient: Compatibility Across Various Kubernetes Providers and CNIs**](https://istio.io/latest/blog/2024/inpod-traffic-redirection-ambient/) : Istio의 사이드카 없는 버전인 Ambient Mesh를 구현하고 작년 알파를 출시해서 Ambient 모드의 가치를 입증하는 데 중점 했으나 초기 메커니즘이 다른 CNI와 충돌하는 것을 알게 되었고 사용자들은 어디서나 모든 CNI 구현에서 Ambient 모드를 원한다는 것을 알게 되고 베타버전으로 가기 전에 가장 중요한 요구사항이 되었다. `istio-cni`는 기본 CNI 구현이 아니고 클러스터의 기본 CNI를 확장하는 노드 에이전트인데 이 초기 구현이 기본 CNI 구현의 네트워킹 구성과 충돌이 발생하고 적용한 네트워크 정책도 상황에 따라 Istio CNI 확장에서 적용되지 않을 수 있어서 이 요구사항을 충족할 수 없다는 게 확실해졌다. 새로운 솔루션을 찾기 시작했고 사이드카를 모방하여 파드의 네트워크 네임스페이스에서 리다이렉션을 구성하는 아이디어가 나왔고 Linux 소켓의 기본 기능을 이용해서 다른 네임스페이스 내의 수신 소켓을 생성하고 소유할 수 있다는 걸 알게 되고 이를 구현하기로 했고 그 결과 모든 트래픽 캡처와 리다이렉션이 파트의 네임스페이스 내부에서 발생하고 마치 사이드카 프록시가 있는 것처럼 보이게 되었다.(영어)
- [**GitHub-hosted runners: Double the power for open source**](https://github.blog/2024-01-17-github-hosted-runners-double-the-power-for-open-source/) : GitHub이 공개 저장소에서 사용하는 GitHub Actions은 무료로 제공하고 있었고 기존에는 2 vCPU 머신을 사용하고 있었는데 2023년 1월부터 Linux와 Windows의 러너를 새로운 4 vCPU, 16 GiB 메모리, 150 Gib 스토리지로 2배 업그레이드를 진행했다. 그 결과 기존보다 25% 속도가 빨라졌다고 한다.(영어)
- [**Slashing Data Transfer Costs in AWS by 99%**](https://www.bitsand.cloud/posts/slashing-data-transfer-costs/) : AWS에서 가용영역(AZ)간에 데이터를 전송하면 비용이 발생한다. S3는 1a, 1b 같은 AZ 단위가 아니라 리전 단위로 버킷을 저장하므로 같은 리전에 모든 AZ에서 똑같이 사용할 수 있으며 (공용 인터넷이 아니라면) 다운로드와 업로드가 무료이며 스토리지 비용은 시간단위로 부과된다. 이 두가지 특징을 이용해서 1a에 있는 인스턴스에서 1b에 있는 인스턴스로 데이터를 보낼 때 직접 보내는 대신 S3를 거쳐서 보내도록 해서 비용을 절감하겠다는 아이디어이다.(전송후에는 S3에서 지워서 스토리지 비용을 아낀다) 직접 테스트로 1TB를 전송했을 때 직접 보내면 20.48달러가 청구되었지만, S3를 통해서 보낼 때는 8센트만 청구되었다.(영어)
- [**Introducing Docker Build Cloud: A New Solution to Speed Up Build Times and Improve Developer Productivity**](https://www.docker.com/blog/introducing-docker-build-cloud/) : Docker에서 [build cloud](https://www.docker.com/products/build-cloud/)를 공개했다. 시간이 지나면서 빌드 시간은 점점 길어지는 데 빌드 클라우드를 이용하면 빌드 시간도 39배 빨라지고 멀티아키텍처 빌드도 할 수 있다고 소개한다.(영어)
- [**2023년 4분기 DDoS 위협 보고서**](https://blog.cloudflare.com/ddos-threat-report-2023-q4-ko-kr) : Cloudflare에서 2023년 4분기 DDoS 위협 보고서를 공개했다. 여기서 나오는 DDoS 공격은 처리량보다 더 많은 요청을 보내는 HTTP 요청 집중형 DDoS, 라우터/방화벽/서버에서 처리할 수 있는 패킷보다 더 많은 패킷을 보내는 IP 패킷 집중형 DDoS, 인터넷을 포화 상태로 만드는 비트 집중형 DDoS 세가지 유형이 있다. 이전에 비해 HTTP DDoS 공격을 줄어들고 Network 계층의 DDoS 공격 증가하고 있다. 분야별 지역별 DDoS 위협을 살펴볼 수 있다.(한국어)

# 볼만한 링크

- [**The Story of Grafana | The Grafana documentary: The first 10 years**](https://grafana.com/story-of-grafana/) : Grafana가 10주년을 기념해서 다큐멘터리를 만들고 있다. 1편 Democratize Metrics, 2편 Community, 3편 Open (Source) for Business까지 나왔고 4편은 곧 나올 예정이다.(영어)
- [**[리뷰] Q60MAX – 현존 최고의 HHKB 배열 기계식 키보드**](https://01010011.blog/2024/01/28/%eb%a6%ac%eb%b7%b0-q60max-%ed%98%84%ec%a1%b4-%ec%b5%9c%ea%b3%a0%ec%9d%98-hhkb-%eb%b0%b0%ec%97%b4-%ea%b8%b0%ea%b3%84%ec%8b%9d-%ed%82%a4%eb%b3%b4%eb%93%9c/) : 키크론 Q60 MAX에 대한 리뷰입니다. HHKB 키보드 배열의 장점과 정적 용량 무접점의 특징까지 설명한 뒤 키크론 Q60 MAX가 기계식임에도 좋은 키감을 커스텀 키보드이면서 완성품으로 제공하기 때문에 편의성을 주면서 커스텀도 가능해진다. 글을 읽고 나서 사고 싶어졌다.(한국어)
- [**3일 후 운명이 결정되는 팔월드라는 우연한 이야기**](https://note.com/pocketpair/n/n54f674cccc40) : 요즘 스팀에서 인기라는 팔월드라는 게임이 만들어진 과정에 대한 이야기이다. 작은 게임 회사 입장에서 퍼블리싱이 어렵다는걸 깨닫고 스팀으로 발향을 돌리면서 여러 게임을 만들다가 팔월드라는 인기 게임이 나오기까지 편의점 알바생을 고용하고 게임엔진을 교체하고 모션 디자이너를 고용하고 탈락 시켰던 사람을 채용했는데 그 사람이 너무 잘하는 등 수많은 기적 속에 팔월드라는 인기게임을 만들게 되었다는게 그걸 기적으로 설명하는 부분이 현실감있고 재미있다. 일본어인데 번역해서 보면 읽을만 하다.(일본어)
- [**Yes, good DevEx increases productivity. Here is the data.**](https://github.blog/2024-01-23-good-devex-increases-productivity/) : 개발자 경험(DevEx)을 개선하는 것은 중요한 일이지만 그에 대한 데이터는 많지 않았는데 GitHub이 [DX](https://getdx.com/)와 협업해서 생산성에 어떤 영향을 미치는지 연구했다. Slack 메시지 등 모든 방해 요소를 최소화해서 심층 작업(Deep Work)에 충분한 시간을 사용하는 개발자는 생산성이 50% 향상되고 코드에 대한 이해도가 높은 개발자가 아닌 개발자보다 생산성이 42% 높았고 피드백 루프가 중요하기 때문에 코드 리뷰가 빠른 등 처리시간이 빠르면 20% 더 혁신적이라고 느꼈다.(영어)

# IT 업계 뉴스

- [**Dave Mills has passed away**](https://elists.isoc.org/pipermail/internet-history/2024-January/009265.html) : NTP(Network Time Protocol)을 발명하고 인터넷 아키텍처 테스크 포스의 초대 의장을 하는 등 인터넷 개발에 여러 가지 기여를 했던 [Dave Mills](https://en.wikipedia.org/wiki/David_L._Mills)가 지난 17일 85세의 나이로 세상을 떠났다고 인터넷의 아버지로 알려진 Vinton Cerf가 메일링 리스트의 부고를 전했다. 삼가 고인의 명복을 빕니다.(영어)
- [**Supreme Court rejects Epic v. Apple antitrust case**](https://www.theverge.com/2024/1/16/24039983/supreme-court-epic-apple-antitrust-case-rejected) : Epic Games가 2020년 포트나이트에서 자체 결제시스템을 도입하자 Apple이 포트나이트를 앱 스토어에서 차단하면서 시작된 소송인데 대법원에서 두회사가 각기 제기한 청원을 기각함으로써 재판이 끝났다. 이 기각으로 애플은 앱 스토어에서 다른 결제 수단을 금지하는 것이 반경쟁적 행위라고 판단했으므로 애플은 다른 결제시스템을 허용해야 하게 되었고 Epic Games가 주장했던 다른 스토어를 통해서 iOS에 앱을 배포하도록 허용하도록 하는데까지는 실패했다.(영어)
- [**Adobe Gives Up on Web-Design Product to Rival Figma After Deal Collapse**](https://www.bnnbloomberg.ca/adobe-gives-up-on-web-design-product-to-rival-figma-after-deal-collapse-1.2028498) : Figma 인수를 포기한 Aodbe가 Figma의 경쟁 제품인 Adobe XD를 유지 보수 모드로 전환하고 새 기능 추가도 안 하고 따로 판매도 안 할 생각이라고 발표했다. 2022년 XD의 연간 매출은 1,700만 달러였고 개발자는 19명뿐이었다고 한다.(영어)
- [**Blue Oak Model License**](https://opensource.org/license/blue-oak-model-license/) : Open Source initiative가 권한을 최대한 부여하고 기여자를 보호하는 Blue Oak Model 라이센스를 오픈소스 라이센스로 승인했다.(영어)
- [**Notion Avatar Maker**](https://notion-avatar.vercel.app/ko) : Notion 스타일로 아바타를 만들어주는 서비스

# 버전 업데이트

- [**astro**](https://astro.build/) **v4.2** : JavaScript 웹 프레임워크, [릴리스 공지](https://astro.build/blog/astro-420/)
- [**Expo**](https://expo.dev/) **50** : React로 네이티브 앱을 만드는 플랫폼 SDK, [릴리스 공지](https://expo.dev/changelog/2024/01-18-sdk-50)
- [**Angular**](https://angular.io/) **v17.1.0** : JavaScript 프레임워크, [변경사항](https://github.com/angular/angular/releases/tag/17.1.0)
- [**GitLab**](https://about.gitlab.com/) **v16.8** : 오픈소스 설치형 Git 플랫폼, [릴리스 공지](https://about.gitlab.com/releases/2024/01/18/gitlab-16-8-released/)
- [**KEDA**](https://keda.sh/) **v2.13.0** : Kubernetes 오토스케일러, [릴리스 공지](https://github.com/kedacore/keda/releases/tag/v2.13.0)
- [**Ionic**](https://ionicframework.com/) **v7.6** : 하이브리드 모바일 앱 프레임워크, [릴리스 공지](https://ionic.io/blog/announcing-ionic-7-6)
- [**Elastic Stack**](https://www.elastic.co/kr/products) **v8.12.0** : 엘라스틱 스택, [릴리스 공지](https://www.elastic.co/kr/blog/whats-new-elasticsearch-platform-8-12-0)
- [**Terraform**](https://www.terraform.io/) **v1.7** : Infrastructure as Code 도구, [릴리스 공지](https://www.hashicorp.com/blog/terraform-1-7-adds-test-mocking-and-config-driven-remove)
    - 1.6에서 추가된 테스트 프레임워크에 `mock_provider`가 추가되었다.
- [**QueryDSL**](https://querydsl.com/) **v5.1.0** : Java용 쿼리 프레임워크, [릴리스 공지](https://github.com/querydsl/querydsl/releases/tag/QUERYDSL_5_1_0)
- [**Lottie for Android**](https://airbnb.design/lottie/) **v6.3.0** : After Effects 애니메이션 랜더링 라이브러리, [릴리스 공지](https://github.com/airbnb/lottie-android/releases/tag/v6.3.0)
- [**Grafana Beyla**](https://grafana.com/oss/beyla-ebpf/) **1.2.0** : eBPF를 이용한 자동 계측, [릴리스 공지](https://grafana.com/blog/2024/01/24/grafana-beyla-1.2-release-ebpf-auto-instrumentation-with-full-kubernetes-support/)
- [**Deno**](https://deno.land/) **v1.40.0** : TypeScript 런타임, [릴리스 공지](https://deno.com/blog/v1.40)
- [**undici**](https://undici.nodejs.org/) **v6.5.0** : Node.js HTTP 클라이언트, [릴리스 공지](https://github.com/nodejs/undici/releases/tag/v6.5.0)
- [**podman**](https://podman.io/) **v4.9.0** : 컨테이너 엔진, [릴리스 공지](https://github.com/containers/podman/releases/tag/v4.9.0)
- [**Grafana**](http://grafana.org/) **v10.3** : 매트릭 대쉬보드, [릴리스 공지](https://grafana.com/blog/2024/01/23/grafana-10.3-release-canvas-panel-updates-multi-stack-data-sources-and-more/)
- [**Relay**](https://facebook.github.io/relay/) **v16.2.0** : 데이터주도 Recat 애플리케이션용 프레임워크, [릴리스 공지](https://github.com/facebook/relay/releases/tag/v16.2.0)
- [**Armeria**](https://line.github.io/armeria/) **v1.27.0** : Java용 비동기 RPC/REST 라이브러리, [릴리스 공지](https://armeria.dev/release-notes/1.27.0/)
- [**PgBouncer**](https://www.pgbouncer.org/) **v1.22.0** : PostgreSQL 커넥션 풀, [릴리스 공지](https://www.postgresql.org/about/news/pgbouncer-1220-released-2802/)
- [**Turborepo**](https://turborepo.org/) **v1.12.0** : JavaScript/TypeScript 빌드 시스템, [릴리스 공지](https://turbo.build/blog/turbo-1-12-0)
- [**PyTorch**](http://pytorch.org/) **v2.2.0** : Python 딥러닝 프레임워크, [릴리스 공지](https://pytorch.org/blog/pytorch2-2/)
- [**Nuxt**](https://nuxt.com/) **v3.10.0** : 서버렌더링 Vue.js 애플리케이션 프레임워크, [릴리스 공지](https://nuxt.com/blog/v3-10)
- [**Nuxt UI**](https://ui.nuxt.com/) **v2.13.0** : UI 라이브러리, [릴리스 공지](https://github.com/nuxt/ui/releases/tag/v2.13.0)
- [**Prisma**](https://www.prisma.io/) **v5.9.0** : TypeScript/Node.js 데이터베이스 툴킷, [릴리스 공지](https://github.com/prisma/prisma/releases/tag/5.9.0)

# 웹개발 관련

- **OROR Forge: Figma to Code 도구 제작기** [**(1) 디자인을 코드로 만들어보자!**](https://tech.kakao.com/2024/01/09/ororforge-1/)**,** [**(2) 실전용으로 만들기**](https://tech.kakao.com/2024/01/09/ororforge-2/) : Figma로 된 디자인을 코드로 만드는 시간을 줄이기 위해 자동화 도구를 만드는 과정이다. 상용 Figma to Code 솔루션 중 Amplify Sudio와 Locofy를 살펴보면서 인상적인 기능이 있었지만, 각 한계점이 있었고 직접 만들기로 한다. 이 OROR Forge에서 Figma의 디자인을 픽셀 퍼팩트한 코드를 생성하기 위해 Figma의 Property, Auto Layout, Constraints, Text를 CSS의 Property, Flexbox, Postions, Text로 변환한 과정을 설명한다. 이를 실제 현업에서 활용하기 위해 인라인 스타일 대신 TailwindCSS를 사용하기로 하고 인라인 스타일을 TailwindCSS로 매핑하는 빌더 함수를 구현하고 HTML 코드고 React 컴포넌트로 변환해서 코드 생성을 자동화한 과정을 설명한다.(한국어)
- [**How I'm Writing CSS in 2024**](https://leerob.io/blog/css) : Vercel의 Lee Robinson이 nesting, `:has()`, 컨테이너 쿼리 등의 크로스 브라우저 지원과 CSS 도구 등에 관한 생각을 정리한 글이다. 이제 최신 CSS 기능이 대부분의 브라우저에서 지원되면서 Sass나 Less 없이도 최신 CSS를 작성할 수 있지만 컴파일러를 사용해서 사용하지 않는 스타일을 줄이고 고유한 파일명을 생성해서 캐싱할 수 있다. 동적인 화면을 위해서는 CSS를 스트리밍해야 하는데 이를 위해서 CSS 모듈, Tailwind CSS, StyleX를 사용할 수 있다.(영어)

# 그 밖의 개발 관련

- [**Rebuilding Netflix Video Processing Pipeline with Microservices**](https://netflixtechblog.com/rebuilding-netflix-video-processing-pipeline-with-microservices-4e5e6310e359) : Netflix에서 2007년 스트리밍 서비스 출시 이후 동영상 처리 파이프라인을 개선해 왔다. 2014년부터 3세대 플랫폼인 Reloaded로 운영해 왔는데 모든 미디어 자산을 처리하는 모노리식 시스템으로 만들어졌기에 수년 동안 확장되면서 복잡도가 증가하고 한계가 드러나기 시작했다. 기능이 결합하여 있어서 기능 추가가 어려웠고 모노리식 구조로 재사용되지 않아야 하는 코드도 재사용되며 개발 속도를 늦추고 배포 규모가 커져서 프로덕션에 나가기까지 2주에서 4주나 걸리게 되었다. 그래서 2018년부터 차세대 플랫폼인 Cosmos를 개발하면서 Reloaded의 확장성과 안정성은 유지하면서 유연성과 개발 속도를 목표로 하면서 마이크로 서비스로 만들게 되었고 2023년 9월에 전환을 완료했다.(영어)
- [**Python 3.13 gets a JIT**](https://tonybaloney.github.io/posts/python-gets-a-jit.html) : CPython 핵심 개발자인 Brandt Bucher가 Python 3.13에 copy-and-patch JIT을 추가하는 Pull Request를 올렸다.(현재 Draft 상태) 인터프리터는 실행할 때마다 opcode라 부르는 바이트 코드 이름을 if 문과 비교하는데 실행할 때마다 발생하는 오버헤드를 없애기 위해 시퀀스로 코드를 생성하는 것이 JIT이 하는 일이고 이번에 제안된 것은 copy-and-patch JIT이다. 인터프리터 루프는 해석한 뒤 실행하는 두 가지 과정을 거치는데 copy-and-patch JIT은 각 명령의 인스트럭션을 복사한 뒤에 바이트 코드 인수를 채우는(patch) 방식으로 진행된다. copy-and-patch JIT을 선택한 이유는 일반 Python 사용자가 이를 실행할 일은 없고 CPython을 빌드하고 패키징하는 CI 머신에서 LLVM JIT 도구만 설치하면 되기 때문이다. 초기 벤치마크에서는 2~9%의 성능 향상이 있는데 이 결과가 작아 보일 수 있으나 최적화 작업의 첫 단계로 생각하면 된다.(영어)

# 인프라 관련

- [**Prometheus Vs Victoria Metrics Load Testing**](https://zetablogs.medium.com/prometheus-vs-victoria-metrics-load-testing-3fa0cc782912) : [Prometheus](https://prometheus.io/)와 V[itoria Metrics](https://victoriametrics.com/)의 성능 비교를 한 글이다. Prometheus는 압축할 때 active time series를 메모리에 저장하지만, Vitoria Metrics는 VM insert 스토리지에 저장하므로 이는 성계의 차이는 성능에도 영향을 준다. active time series, 수집률, 수집 대상의 수를 부하 테스트를 하면서 프로덕션에 운영하는 정도의 매트릭으로 둘을 비교하고 있다. 부하가 커지면 Prometheus는 메모리가 Vitoria Metrics는 CPU가 커지는 특징이 있지만 Vitoria Metrics에 최적화한 뒤에는 전체적으로 Vitoria Metrics 리소스 사용이 훨씬 적은 것으로 나타났다.(영어)
- [**OpenTofu is going GA**](https://opentofu.org/blog/opentofu-is-going-ga/) : Terraform의 오픈소스 포크인 [OpenTofu](https://opentofu.org/)가 4개월간의 개발 후 첫 안정 버전이 릴리스했다.
- [**Announcing Builds View in Docker Desktop GA**](https://www.docker.com/blog/announcing-builds-view-in-docker-desktop-ga/) : Docker Desktop 4.26부터 빌드 뷰를 제공하기 시작했다. 빌드뷰를 통해서 실패한 빌드의 로그를 볼 수 있고 캐싱 여부도 확인할 수 있다.(영어)
- [**Target CLI: The context switcher for HashiCorp tools**](https://www.hashicorp.com/blog/target-cli-the-context-switcher-for-hashicorp-tools) : HashiCorp의 Senior Developer Advocate가 만든 [Target CLI](https://github.com/devops-rob/target-cli)의 소개 글이다. HashiCorp에는 Terraform, Vault, Boundary, Consul, Nomad 등의 도구가 있지만 각 클러스터 간의 전환을 위해서는 환경변수를 세팅해야 한다. Target CLI는 이러한 컨텍스트 프로필의 전환을 쉽게 해주는 역할을 한다.(영어)
- [**Deprecation Warnings in containerd - Getting Ready for 2.0!**](https://samuel.karp.dev/blog/2024/01/deprecation-warnings-in-containerd-getting-ready-for-2.0/) : containerd가 2017년 1.0 릴리스 이후 6년간의 개발을 통해 2.0가 나올 예정이므로 이를 준비하라고 알리는 글이다. `ctr deprecations list` 명령어로 사용량 기반으로 중단되는 기능을 확인할 수 있다.(영어)

# 볼만한 링크

- [**The More Features You Add...**](https://www.lukew.com/ff/entry.asp?2046=) : 여러 연구 결과에 따르면 사람들은 제품 사용 전에는 기능 수에 따라 품질을 판단하고 제품을 사용한 후에는 너무 많은 기능으로 사용성에 문제가 있다는 걸 깨닫게 된다고 한다. 제품의 시기에 따라 영업의 결과도 달라지는데 기업은 초기 매출을 극대화하기 위해 기능이 많은 제품을 개발하지만, 이후에는 고객 유지를 극대화하기 위해서 기능보다는 사용 편의성을 우선시해야 한다. 또한 기능이 많아지면 유지보수도 많아져서 속도도 느려지게 되므로 조심해야 한다.(영어)
- [**Cloudflare Radar Year in Review 2023**](https://radar.cloudflare.com/year-in-review/2023) : Cloudflare에서 자신들의 트래픽을 기준으로 리포트를 공개했다. 가장 많이 사용되는 인터넷 서비스와 iOS/Android 비중, API 클라이언트, 국가별 인터넷 품질, 모바일/데스크톱 비중 등을 확인할 수 있다.(영어)

# IT 업계 뉴스

- [**Introducing the GPT Store**](https://openai.com/blog/introducing-the-gpt-store) : 사람들이 많은 GPT를 확인할 수 있는 OpenAI GPT 스토어가 나왔다. 인기 많은 GPT를 확인할 수 있고 1분기 이내에 수익 프로그램을 출시해서 GTP 사용량에 따라 만든 사람한테 수익이 분배되도록 할 예정이라고 한다.(영어)
- [**Report: Unity Cutting About 1,800 People In Company's Largest Layoff**](https://kotaku.com/unity-layoffs-1800-people-jobs-25-percent-january-2024-1851150254) : Unity가 직원의 25% 정도인 1,800명을 감원할 계획이라고 한다.(영어)
- [**Disney's earliest Mickey and Minnie Mouse enter public domain as US copyright expires**](https://www.bbc.com/news/entertainment-arts-67833411) : 디즈니의 미키 마우스와 미니 마우스가 95년 뒤에는 누구나 사용할 수 있는 퍼블릭 도메인에 진입하는 저작권 법에 따라 1928년 공개된 미키 마우스와 미니 마우스를 누구나 사용할 수 있게 되었다.(영어)
- [**Tart**](https://tart.run/) : Apple Silicon 기반 macOS/Linux 가상화를 제공하는 서비스로 GitHub Actions, GitLab Runner, Buildkite 등의 러너로 사용할 수 있다.
- [**OpenPubKey**](https://github.com/openpubkey/openpubkey) : OpenID 프로바이더에서 식별자를 공개키에 바인딩하는 프로토콜의 구현체
- [**Minimalist CV**](https://github.com/bartoszjarocki/cv) : 간단한 정적 파일을 통해 이력서 페이지를 만들어주는 프로젝트.

# 버전 업데이트

- [**ReScript**](https://rescript-lang.org/) **v11.0.0** : 프로그래밍 언어(구 BuckleScript/Reason), [릴리스 공지](https://rescript-lang.org/blog/release-11-0-0)
- [**OpenTofu**](https://opentofu.org/) **v1.6.0** : Infrastructure as Code 도구, [릴리스 공지](https://github.com/opentofu/opentofu/releases/tag/v1.6.0)
- [**Nuxt UI**](https://ui.nuxt.com/) **v2.12.0** : UI 라이브러리, [릴리스 공지](https://github.com/nuxt/ui/releases/tag/v2.12.0)
- [**SQLite**](http://www.sqlite.org/) **v3.45.0** : SQL 데이터베이스 엔진, [릴리즈 공지](https://sqlite.org/draft/releaselog/3_45_0.html)
    - 새로운 JSONB 파스 트리 형식 도입
- [**Zed**](https://zed.dev/) **v0.118.1** : 코드 에디터, [릴리스 공지](https://zed.dev/releases/stable#zed-0.116.1)
- [**Kargo**](https://kargo.akuity.io/) **v0.3.0** : Kubernetes용 배포 도구, [릴리스 공지](https://github.com/akuity/kargo/releases/tag/v0.3.0)
- [**Hono**](https://hono.dev/) **v3.12.0** : 엣지용 웹 프레임워크, [릴리스 공지](https://github.com/honojs/hono/releases/tag/v3.12.0)
- [**Node.js**](http://nodejs.org/) **v20.11.0 (LTS)** : 자바스크립트 런타임, [릴리스 공지](https://nodejs.org/en/blog/release/v20.11.0)
- [**Node.js**](http://nodejs.org/) **v21.6.0 (Current)** : 자바스크립트 런타임, [릴리스 공지](https://nodejs.org/en/blog/release/v21.6.0)
- [**CDK for Terraform**](https://github.com/hashicorp/terraform-cdk) **v0.20.0** : Terraform Cloud Development Kit, [릴리스 공지](https://www.hashicorp.com/blog/cdktf-0-20-improves-implementation-of-iterators-and-enables-hcl-output)

[HashiCorp](https://www.hashicorp.com/)의 공동창업자인 [Mitchell Hashimoto](https://gist.github.com/mitchellh)가 얼마 전 [Merge vs. Rebase vs. Squash](https://gist.github.com/mitchellh/319019b1b8aac9110fcfb1862e0c97fb)라는 글을 작성했다.


Git에서 Merge, Rebase, Squash에 관한 질문을 자주 받아서 정리했다고 하는데 요약하면 다음의 내용이다.

- 셋 중 특정 전략이 100% 정답이라고 말하는 사람은 틀렸고 각 전략은 상황에 따라 다르다.
- Merge 커밋을 만드는 Merge가 히스토리를 가장 잘 표현한다고 생각해서 Merge를 선호한다.
- Merge 커밋이 있으면 쉽게 되돌릴 수 있다.
- 모든 커밋이 빌드된다면 커밋이 많을수록 git bisect가 좋아진다.
- 이상적으로 커밋은 +50/-50 정도로 유지하는 것이 좋다.
- PR에 많은 WIP 커밋이 있지만 하나의 목표라면 Squash를 한다.
- Squash할 때 Git과 GitHub이 제공하는 기본 메시지는 좋지 않아서 Squash를 할 때 커밋 메시지를 새로 작성한다.
- PR에 WIP가 많은데 각 커밋의 차이가 크다면 인터랙티브 Rebase로 커밋을 합치고 순서를 변경한다.
- 개발자들이 커밋 관리에 신경 쓰기를 기대하지만, 많은 개발자가 Git에 익숙하지 않다.
- 대규모로 인터랙티브 Rebase를 할 때는 Git GUI를 사용한다. macOS에서는 Tower를 쓰고 있다.

대부분의 내용을 공감해서 공유하면서 나는 어떻게 생각하고 있지를 고민하다 보니 그동안 개발을 하면서 내가 선호하는 방법도 다양하게 바뀌었다는 것을 깨달았다. 개발하면서 Git에 어울리게 쓰고 싶어서 한 것들도 있고 협업하다 보니내 취향과는 다르게 절충하게 된 것들도 있어서 트위터에서 글을 쓰다가 블로그에 정리하게 되었다.


## Merge


Git을 배우면 처음에 Merge에 관해 배우기 마련이다. Git에서는 브랜치를 만들어서 작업하는 게 일반적이기 때문에 작업 후에 이 브랜치를 기본 브랜치에 합치는 Merge는 아주 중요하다.


![5118444125.jpg](https://blog.outsider.ne.kr/attach/1/5118444125.jpg)


Merge하면 그래프가 위처럼 만들어지고 `Merge branch '브랜치 이른'`의 메시지를 가진 Merge 커밋이란 게 만들어진다. 이 그래프처럼 Merge 커밋이 있으면 작업할 때 브랜치가 분리되었다가 합쳐졌다는 게 시각적으로나 구조적으로 구분되고 히스토리에도 남게 된다.


물론 더 정확히 얘기하면 머지할 때 fast-forward 머지가 아닐 때만 이 머지 커밋이 생긴다. fast-forward 머지가 가능할 때는 머지커밋 없이 바로 생기고 fast-forward와 상관없이 머지 커밋을 만들려면 `git merge --no-ff` 옵션을 사용해야 한다.


초기에 Git을 배우고 익숙해지면서 주변 사람들도 Merge 커밋 선호자와 비선호자로 나뉘게 되었는데 나는 Merge 커밋이 좋은가? 안 좋은가를 많이 고민했다. 그래도 시간이 지나면서 **머지 커밋을 안 남기는 것을 더 좋아하게 되었다.**


![8020900616.jpg](https://blog.outsider.ne.kr/attach/1/8020900616.jpg)


당시 내가 가장 좋아하던 Node.js 프로젝트는 Git 히스토리를 일직선으로만 만들었다. 당시 GitHub의 Pull Request는 무조건 `--no-ff`로 머지했기 때문에 항상 머지 커밋이 남게 된다. 그래서 머지커밋을 안 남기려면 Pull Request 브랜치를 로컬에 가져와서 fast-forward로 머지한 뒤에 이를 푸시하는 방식으로 머지해야만 가능했기에 메인테이너들이 아주 바빠지게 되지만 Node.js는 항상 이렇게 했다. 그래서인지 일직선으로 유지되는 히스토리가 더 멋지다고 생각했고 머지 커밋은 나한테는 불필요한 정보가 남는 걸로 보여서 장황하게 느껴졌다.


물론 브랜치를 나누어서 작업한다는 것이 보통 하나의 작업 단위가 되기 때문에 머지 커밋을 남기면 이 작업 단위에 커밋이 여러 개 있다고 하더라도 이를 분리해서 볼 수 있고 분리되어 있으므로 필요하다면 한꺼번에 revert 할 수도 있다. 머지 커밋이 없는데 revert 한다면 커밋을 일일이 찾아야 한다. 하지만 현실에서는 머지를 통째로 revert 하는 일이 많지 않기도 하고 머지를 통째로 revert 하기보다는 수정 커밋이 새로 올라가는 게 더 자주 있는 일이라고 생각했다.


혼자 할 때는 얼마든지 내가 원하는 대로 히스토리를 관리할 수 있지만 협업하면 얘기가 달라진다. 얘기했듯이 GitHub의 Pull Request를 사용하면 항상 머지 커밋을 남길 수밖에 없었다. [Squash로 머지할 수 있는 기능은 2016년에 와서야 추가](https://github.blog/2016-04-01-squash-your-commits/)되었다.


그렇다 보니 머지 커밋을 싫어하는 내 취향과 관계없이 GitHub에서 협업할 때는 머지 커밋을 남기게 되었다. GitHub 사이트에서 머지 버튼 누르는 게 훨씬 편하고 모두가 Git을 잘 다루는 것도 아니니까 "머지는 버튼으로 안 하고 로컬에 받아서 fast-forward로 머지합니다"라고 할 수도 없어서 어쩔 수 없이 그냥 머지 커밋을 쓰게 되었다.


## Rebase


Rebase는 Git의 아주 훌륭한 기능이지만 Git을 배울 때 가장 어려워하는 기능이기도 하다. 예전에 Git 강의를 할 때도 Rebase를 알려주는 게 나을지 고민을 정말 많이 하곤 했다. 처음부터 Rebase 익히지 않는 게 나을 수도 있지만 Git을 제대로 쓰려면 Rebase를 필수라고 생각하고 있긴 하다.


Git을 쓰면서 히스토리 관리를 중요하게 생각하는 편이라 코드 리뷰할 때 커밋 메시지도 리뷰하고는 했다. 영어를 잘하는 건 아니니까 커밋 메시지의 문법을 보는 건 아니지만 WIP 라던가 아무 의미 없는 커밋 메시지를 가진 커밋이 쌓이는 건 싫어했다.


내가 커밋할 때도 Pull Request를 올리면서 모든 커밋은 인터랙티브 Rebase로(`git rebase -i`)로 히스토리를 다시 정리했다. 작업을 하면서 `A`-`B`-`C` 순으로 작업을 하는데 놓친 부분이나 수정할 게 생기면 `A`-`B`-`C`-`A'`-`B'`-`A''`-`C'` 형태로 커밋 히스토리가 복잡해 지는 게 인터랙티브 Rebase를 써서 순서를 바꾸고 커밋을 합쳐주면 다시 A-B-C 처럼 만들 수 있다.(`--fixup` 와 `--autosquash`를 쓰면 편하다.) 그래서 결과적으로 보면 처음부터 모든 경우를 고려해서 순서대로 작업한 것 같은 히스토리가 만들어지게 되는데 커밋 메시지는 모든 작업 과정을 다 담는 것이 아니라 나중에 이해할 수 있게 정리된 히스토리여야 한다고 생각하기 때문이다.


![4462388846.jpg](https://blog.outsider.ne.kr/attach/1/4462388846.jpg)


머지에서 피곤하게 느낀 건 위와 같은 상황이었다. Pull Request를 올리려고 작업을 하다 보면 작업 시간이 몇 시간에서 며칠이 걸리기도 하니까 다른 사람들의 작업도 기본 브랜치에 머지되면서 브랜치의 각 커밋이 흩어지게 된다. Git 도구를 쓰면 못할건 아니지만 머지 커밋은 상단에 바로 보이지만 그 브랜치에서 진행된 커밋을 보려고 하면 저 아래에 있어서 보기 쉽지 않은 게 싫었다. 당연히 협업자가 많으면 머지 커밋은 더 많이 생기고 히스토리는 복잡해진다.


![8210372704.jpg](https://blog.outsider.ne.kr/attach/1/8210372704.jpg)


이 문제를 해결하려면 Rebase를 하면 된다. 머지 하기 전에 Rebase를 하면 기본 브랜치를 대상으로 커밋을 다시 하게 되므로 자연히 커밋이 모이게 되고 이후에 머지를 하면 머지 커밋과 해당 브랜치의 커밋이 한 곳에 모이게 된다.


하지만 이것도 위에 Rebase로 커밋 히스토리를 정리하자는 것과 같은 상황이기 때문에 나 혼자서는 지킬 수 있는 규칙이지만 협업할 때 모두가 이렇게 하라고 하는 건 어려운 문제가 된다. 그래서 처음에는 Rebase 요청이나 커밋 히스토리에 대한 정리에 대한 요청도 많이 하곤 했지만, 시간이 지나면서 점점 커밋 히스토리를 너무 신경 쓰지 않으려고 노력하게 되었다.


Pull Request에서 Rebase를 적극적으로 사용하지 않게 된 이유가 또 하나 있는데 코드 리뷰 때문이었다. 예를 들어 변수명에 오타가 있다가 있다고 코드 리뷰를 받았을 때 이를 수정해서 올리면 새로 올라온 커밋만 보고 리뷰대로 오타가 수정되었구나!' 할 수 있다. 하지만 내가 이걸 수정한 다음 인터랙티브 Rebase로 커밋을 원래 커밋에 다시 합친 뒤에 force push를 하면 리뷰한 사람 입장에서는 전체 diff를 다시 보면서 제대로 수정되었는지 확인하기가 쉽지 않아진다. **내가 가진 Rebase 습관이 Git 관점에서는 맞는다고 생각하지만, 협업 관점에서는 오히려 문제가 되기 때문에 Rebase를 너무 적극적으로 안 하기 시작했다.**


## Squash


GitHub Pull Request가 Merge 커밋을 남기게만 동작하다가 [2016년 4월에 Squash and merge](https://github.blog/2016-04-01-squash-your-commits/) 기능이 나오고 [2016년 9월에는 Rebase and merge](https://github.blog/2016-09-26-rebase-and-merge-pull-requests/)가 나왔다.


Squash는 Pull Request의 모든 커밋을 합쳐서 하나의 커밋으로 만드는 기능이고 Rebase는 타겟 브랜치를 기준으로 모든 커밋을 다시 커밋(rebase)해서 fast-forward 머지가 가능한 상태로 만든 뒤에 머지하는 기능이다. Rebase and merge는 앞에서 말한 대로 내가 기다리던 기능이었기 때문에 나는 이쪽을 더 선호했고 그 덕에 커밋 히스토리를 한 줄로 만들 수 있게 되었다. 하지만 여전히 Pull Request에서 코드 리뷰와 관련해서 불필요한 커밋을 남길 수밖에 없는 문제는 해결되지 않았다.


![5173110327.jpg](https://blog.outsider.ne.kr/attach/1/5173110327.jpg)


그런 고민을 하던 중 지인이 자기 팀에서는 Squash를 기본으로 사용한다는 것을 알고 Squash에 관심을 가지게 되었다. Squash를 사용해 보면서 팀 단위로 협업할 때는 Squash를 선호하게 되었다.(여전히 개인 프로젝트에서는 Rebase and merge를 선호한다.) 아까 말한 대로 **머지 커밋을 사용하지 않을 수 있으면서 코드 리뷰를 위해 Pull Request 브랜치에서는 히스토리 조정을 하지 않고 머지할 때는 하나의 커밋으로 합쳐서 최종 히스토리는 깔끔하게 유지할 수 있다. 협업 때 규칙을 합의 보고 지키기 위해서는 규칙이 너무 복잡하지 않아야 하는데 그런 부분에서도 Squash는 장점이 많다.** 가끔 까먹을 때도 있지만 Squash로 합칠 때 커밋 메시지는 다시 조정하는 편이다. 안 그러면 커밋 메시지에 Pull Request에 포함된 모든 커밋 메시지가 다 포함된다.


더군다나 Pull Request의 변경 사항을 너무 크게 만들지 않게 하는 데도 유용하다. 기본적으로 코드 리뷰를 원활하게 하기 위해서는 Pull Request의 변경 사항은 너무 크지 않아야 한다. 그동안 Rebase로 히스토리 조정을 많이 해오면서 두 가지 목적의 작업은 거의 한 커밋에 안 섞는 편이다. 코드 수정을 하다가 리팩토링 할게 보인다거나 컨벤션 일부를 수정해야 해서 스타일 설정 파일을 수정해야 한다고 했을 때 이 부분만 따로 작업해서 Pull Request를 올리고 기능 추가나 버그 수정은 해당 변경 사항만 담기도록 노력하고 있다.


그렇기에 **Squash를 기본 규칙으로 가게 하면서 하나의 커밋(Pull Request 내에서는 여러 커밋이 있지만 결국은 하나로 합쳐지므로)에는 너무 많은 변경 사항이 담기지 않도록 서로 노력하는 게 더 쉬웠고 문제가 생겼을 때 Revert 할 단위도 커밋 단위로 만들 수 있게 되었다.** 결국 Pull Request 하나가 하나의 원자적 단위가 되는데 Mitchell Hashimoto 말대로 모든 커밋이 빌드할 수 있어야 하는 건 중요하고 그래야 어느 커밋으로도 되돌아갈 수 있는데 Pull Request에서 모든 커밋에서 CI를 다 돌리진 않지만, Squash로 한다면 모든 커밋에서 CI가 통과했다는 보장을 할 수 있게 된다.


Pull Request를 잘게 쪼개는 건 아주 중요하고 이건 연습이 좀 필요하다고 생각한다. 코드 리뷰를 한다는 것은 언제 머지될지 모른다는 얘기가 되므로 Pull Request를 쪼개기 시작하면 Pull Request를 올려두고 이어진 작업을 하기 위해 이전 Pull Request가 필요하게 된다. 이를 [Stacked Changes](https://www.youtube.com/watch?v=XRZPkYnWa48) 혹은 Stacked Pull Request라고 부른다. 나는 손이 느려서 그런지 예전부터 쪼개는 것에 익숙해져서인지 Stacked Pull Request는 잘 사용하지 않지만, Stacked Pull Request가 필요하다면 [Graphite](https://graphite.dev/)같은 서비스도 도움이 된다. 관련한 도구에서는 제일 잘 만들지 않았나 싶다.


AWSKRUG 플랫폼엔지니어링 모임에서 "당근 개발자 플랫폼은 어떤 문제를 해결하고 있는가?"라는 제목으로 발표했다. 현재 당근마켓 SRE팀의 딜리버리 파트에서 배포 시스템을 시작으로 해서 사내 개발자 플랫폼(IDP, Internal Developer Platform)을 만들고 있다.


플랫폼 엔지니어링을 목표로 했다기 보다는 배포 시스템을 만들고 이를 플랫폼으로 발전시키면서 고민하다 보니 어느 순간 [플랫폼 엔지니어링](https://platformengineering.org/)이라는 개념을 만나게 되었다. 사실 플랫폼 엔지니어링은 지난 십여 년간 IT를 이끈 빅테크 기업인 Google이나 Netflix 등에서 적용했던 방법이 이제 업계로 나오고 있는 거라고 생각하고 있다.


플랫폼 엔지니어링이란 개념을 너무 팔면 약 파는 기분도 들고 해서 조심하긴 했지만 그래도 관련한 일을 계속하면서 고민하고 있다 보니 하는 일에 관해서 지난 3년간 여러 번의 발표를 했다.


플랫폼 엔지니어링 관련 글은 웬만한 건 다 찾아봤다고 생각하고 있지만 또 혼자 공부하면서 이해하고 해석했기에 지난 11월 AWSKURG에서 [플랫폼엔지니어링모임](https://www.meetup.com/awskrug/events/297065221/)이 생겼길래 참석했다. 팀 내에서는 여러 번 얘기하고 했지만, 내가 해석하고 이해한 거였기 때문에 다른 회사, 다른 사람들은 플랫폼 엔지니어링을 어떻게 보고 있는지 궁금해서 참석했다. 그렇게 참석했다가 그 자리에서 다음 밋업의 발표를 제안받고 발표를 하게 되었다.


다른 콘퍼런스나 세미나보다는 점 격식 없으면서 시간 여유도 있는 편이라 이전에 못 했던 얘기를 할 수 있을 거로 생각했다. 그동안의 발표는 제한된 시간에 주제에 맞게 전달하려다 보니 개념적으로 정리해서 얘기한 게 많았다. 결국 같은 얘기이긴 하지만 저번 밋업에서 끝나고 질문을 받으면서 지난 3년간 사내 개발자 플랫폼을 만들면서 어떤 상황에서 어떤 고민을 하면서 만들었는지는 좀 더 그대로 이야기하는 것도 도움이 될 것 같다고 생각했다.


결국 발표이긴 하니까 어느 정도 정리가 필요하기는 하지만 넉넉한 시간을 이용해서 그때의 상황과 어떤 고민을 하고 어떻게 플랫폼을 만들면서 발전해 왔는지를 공유하고 싶었다. 그렇게 발표 자료를 만들다 보니 장표가 113 페이지나 나왔다. 그래도 실제로 했던 얘기를 풀어나가는 거라서 이전에 했던 다른 발표보다 크게 힘들거나 하진 않았고 오히려 다시 정리하다 보니 "그때 그런 생각을 했었지", "맞다. 그때 그랬었지"하는 생각도 나서 재밌었다.


장표가 113페이지가 되니 분량이 잘 가늠이 안 되어서 평소와 달리 발표 연습은 하지 않았다. 발표 시간이 명확하게 정해져 있진 않았고.. 그래도 평소의 발표 경험이 있다 보니 90분이 넘진 않겠느냐고 했는데 실제로 하니까 쉬는 시간 포함해서 딱 90분에 발표가 끝났다.(화면 연결을 제대로 준비하지 못해서 발표자 노트가 내 맥북에 나오지 않아서 열심히 적어놓은 내용을 기억으로만 발표해야 해서 좀 아쉬웠다. ㅠ) 끝나고 질문도 많이 나와서 질문/답변만 30분을 했다. ㅎㅎ


이전에도 발표하면서 참석자들이 꽤 있었지만 그래도 아직 플랫폼 엔지니어링은 아직 마이너한 주제라고 생각하고 있었다.(물론 난 인프라팀의 방향에서 이 방향이 맞는다고 생각하고 있다.) AWSKRUG에서 발표하는 건 처음인데 아무래도 인프라에 관심 있는 분들이 많아서 그런지 밋업치고는 상당히 많은 210명 정도가 참석해 주셔서 "어라? 플랫폼 엔지니어링에 관심이 언제 이렇게 커졌지?"하는 생각마저 들었다.


90분 발표란 게 듣는 입장에서 쉽지 않은데 많은 분이 그래도 재밌게 들어주신 거 같아서 준비하는 과정이나 발표나 꽤 즐거운 시간이었다.


# 웹개발 관련

- [**Renovate Web E2E tests with Playwright Runner**](https://engineering.mercari.com/en/blog/entry/20231224-renovate-web-e2e-tests-with-playwright-runner/) : Mercari에서 기존 E2E 테스트에 Jest-Playwright를 사용하고 있었다. 실행은 CircleCI에서 했기 때문에 CircleCI에서는 코드 실행만 하고 Moon이라는 프로젝트를 이용해서 내부 네트워크의 브라우저와 연결해서 테스트를 실행했다. 하지만 Jest-Playwright가 이제 지원 속도가 느려지기 시작했고 Moon을 통해 브라우저를 원격으로 연결하면서 재시도도 어렵고 최종 보고서에도 누락되는 문제가 있었다. Jest-Playwright 대신 Playwright를 사용하기로 하고 내부에 CI를 위한 러너를 제공해서 원격 브라우저 연결을 없앤 형태로 개선했다. 마이그레이션을 끝내기까지 6개월 정도 걸렸고 기존 E2E 테스트는 그대로 두고 새 저장소를 만들어서 테스트 케이스를 업데이트하면서 마이그레이션 했다.(영어)
- [**Next.js: We're exploring moving to Lightning CSS**](https://twitter.com/leeerob/status/1740124461683409042) : Next.js가 [Lightning CSS](https://lightningcss.dev/)로 갈아타는 것을 검토 중이라고 한다.(영어)
- [**크롬에서 서드 파티 쿠키를 폐기하기 위한 다음 단계**](https://korea.googleblog.com/2023/12/privacy-sandbox-1percent.html) : 웹사이트에서 서드파티 쿠키에 접근하는 것을 차단해서 사이트 간 추적을 제한하는 추적 보호 기능을 Chrome이 1월 4일부터 테스트한다. 전체 사용자 중 임의의 1%에만 먼저 적용되며 테스트 대상이 되는 사용자는 알림을 받게 될 예정이다.(한국어)

# 그 밖의 개발 관련

- [**GitHub Copilot Chat now generally available for organizations and individuals**](https://github.blog/2023-12-29-github-copilot-chat-now-generally-available-for-organizations-and-individuals/) : ChatGPT-4 기반의 GitHub Copilot Chat이 기존 Copiot 사용자는 모두 사용할 수 있게 열렸다. GitHub Copilot Chat을 사용하면 IDE에서 코드를 선택해서 관련 질문을 하거나 프로젝트에 연관해서 채팅으로 도움을 받을 수 있다.(영어)
- [**How to Git Stash a Specific File: A Step-by-Step Guide**](https://git.wtf/how-to-git-stash-a-specific-file-a-detailed-guide/) : 임시로 변경 사항을 저장할 수 있는 `git stash`에서 특정 파일만 stash하고 싶을 때가 있는데 `git stash push`로 특정 파일이나 디렉터리를 stash하는 방법을 설명한다.(영어)
- [**Rails: Add Brakeman by default to new apps**](https://github.com/rails/rails/issues/50501) : Ruby on Rails의 정적 분석 보안 도구인 [Brakeman](https://brakemanscanner.org/)이 Rails의 기본 구성요소로 포함되었다.(영어)

# 인프라 관련

- [**Platform Engineering at Mercari**](https://speakerdeck.com/tcnksm/platform-engineering-at-mercari) : Mercari에서 플랫폼 엔지니어링을 하면서 배운 내용을 정리한 발표 자료다. 내부 플랫폼 만들면서도 비즈니스가 최우선 가치이고 플랫폼을 지속해서 개선해야 하는 제품처럼 다뤄야 하며 개발팀과 협업해서 효과적으로 우선순위와 기능을 고를 수 있게 하면서도 적당한 거리를 두어 X-as-a-Service가 되도록 해야 한다. 그리고 플랫폼 엔지니어링은 마이그레이션을 항상 동반해야 제대로 효과를 볼 수 있다.(영어)
- **Open source log monitoring: The concise guide to Grafana Loki** [**Part 1**](https://grafana.com/blog/2023/12/11/open-source-log-monitoring-the-concise-guide-to-grafana-loki/)**,** [**Part 2**](https://grafana.com/blog/2023/12/20/the-concise-guide-to-grafana-loki-everything-you-need-to-know-about-labels/)**,** [**Part 3**](https://grafana.com/blog/2023/12/28/the-concise-guide-to-loki-how-to-get-the-most-out-of-your-query-performance/) : Grafana의 로그 수집 도구인 Loki 5주년을 맞이하여 Loki의 개념과 함께 그동안 어떻게 발전해 왔는지 설명하는 3편의 글이다.(영어)
    - Loki는 "로그 스트림을 정의하는 Prometheus 스타일의 레이블"을 작은 인덱스로 구축하도록 설계되어 이를 LogQL로 질의한다.
    - Loki는 높은 카디널리티 레이블값을 지원하도록 설계되지 않았고 오히려 그 반대로 수명이 아주 길고 매우 낮은 카디널리티의 레이블을 위해 구축되었으므로 레이블 수가 적을수록 좋다.
    - 레이블의 키-값 쌍을 통해 Ingester에 샤딩되는데 특정 Ingester에 몰리지 않도록 자동 스트림 샤딩을 도입했다.
    - Pod 이름 등 카디널리티가 높은 값을 조회하는 문제를 해결하기 위해 그동안 카디널리티가 1시간의 10만 개 미만의 스트림이라면 색인화하고 이 이상이라면 Promtail의 `pack` 단계에서 로그 라인에 카디널리티를 포함했다. 3.0에 정식으로 포함될 structured metadata를 사용하면 키-값 쌍을 인덱스가 아닌 로그와 함께 저장할 수 있게 되었다.
    - 고유 ID를 검색하는 일이 일반적인 사례라는 것을 깨닫고 Bloom filter를 도입했다.
    - 쿼리를 실행할 때 먼저 쿼리를 더 작은 시간 세그먼트로 분할하고 이를 처리할 양에 따라 샤드로 분리해서 작업 큐에 배치한다.
    - 성능 문제를 해결하기 위해 `max_concurrent`를 보통 8 정도를 권장하고 문제가 된다면 더 줄이길 권한다. 보통 수직 스케일링보다는 수평 스케일링을 더 권장한다.
    - `tsdb_max_query_parallelism`와 `split_queries_by_interval`로 병렬 처리를 조정할 수 있다. 테넌트가 수집하는 데이터가 많으면 더 많은 병렬처리를 할 수 있다.
    - 모든 쿼리에 `metrics.go`라는 로그 행을 생성하고 여기에는 실행된 쿼리의 다양한 통계가 있으므로 `metrics.go`를 조회해서 슬로우 쿼리 등을 찾을 수 있다.
- [**How Meta built the infrastructure for Threads**](https://engineering.fb.com/2023/12/19/core-infra/how-meta-built-the-infrastructure-for-threads/) : 23년 7월에 런칭한 Threads가 5일 만에 1억 명의 사용자가 가입했는데 이때 이 인프라를 책임진 두 가지 요소를 설명한다. 기존에 앱 출시를 고려했지만, 실제 출시는 결정 후 2일 만에 출시해야 했고 기존에 인프라 성숙도에 대한 믿음이 있었기에 할 수 있었다.(영어)
    - ZippyDB는 분산형 키-밸류 디비로 Meta에서 완전 관리형으로 운영되며 Meta의 인프라를 활용하도록 구축되었다. ZippyDB의 리샤딩 프로토콜을 사용하면 일관성/정확성을 보장하면서 다운타운 없이 수평적 샤딩를 늘릴 수 있고 기존 사용에서 100배가 증가하더라도 문제없도록 리샤딩을 계속 개선해 왔다.
    - XFaaS라고도 부르는 Async는 서버리스 함수 플랫폼으로 엔지니어가 프로덕션 배포까지 걸리는 시간을 줄일 수 있도록 지원하며 HackLang, Python, Haskell, Erlang 등의 언어를 지원한다. Async는 Instagram에서 이미 팔로우 중인 사람을 Threads에서도 팔로우하도록 하는 기능에 중요한 역할을 했고 5일 만에 1억 명의 사용자에게 이 기능을 제공하려면 상당한 처리량이 필요했지만, Async가 이를 잘 처리했다.
- [**Ending Support for the Dagger CUE SDK**](https://dagger.io/blog/ending-cue-support) : CI/CD 파이프라인인 Dagger의 초기 버전은 구성 언어인 [CUE](https://cuelang.org/)를 사용했지만 이후 GraphQL API를 도입하면서 다양한 프로그래밍 언어로 Dagger를 사용할 수 있도록 추가되었다. 이후 CUE용 SDK의 사용이 크게 줄어들었고 23년 12월 14일부터 CUE SDK 지원을 중단하기로 했다.(영어)

# 볼만한 링크

- [**End of Year Pay Report 2023**](https://www.levels.fyi/2023/) : 테크 기업의 연봉을 비교해 주는 levels.fyi에서 2023년 통계 보고서를 공개했다. 2023년에 비해서 연봉 인상률의 추세를 비교해서 보여주고 레벨별 높은 연봉을 주는 회사와 각 중위 연봉을 확인할 수 있다. 참고로 미국에서의 연봉 공개는 연봉에 주식 등도 포함되어 있을 수 있어서 참고해서 봐야 한다.(영어)
- [**(번역) 인공지능은 소프트웨어의 개념을 완전히 바꿀겁니다 – 빌 게이츠**](https://ebadak.news/2023/12/23/ai-agent-will-change-everything/) : 빌 게이츠가 작성한 [AI is about to completely change how you use computers](https://www.gatesnotes.com/AI-agents)를 번역한 글이다. 지금은 용도에 맞는 서비스나 앱을 사용하지만, 자연어를 이해하고 사용자의 정보를 기반으로 문제를 해결하는 AI 에이전트가 헬스케어, 교육, 생산성, 엔터테인먼트/쇼핑 분야에서 큰 변화를 불러올 것이라고 얘기한다. 그래서 다음 플랫폼은 AI 에이전트가 될 것이지만 윤리적인 문제와 기술적인 도전, 프라이버시 문제 등 현실적인 상황에 관해서도 얘기하고 있다.(한국어)
- [**Run a Node project with Deno and win prizes in the #NodeToDenoChallenge**](https://deno.com/blog/node-to-deno-challenge) : Deno에서 Node.js 프로젝트를 Deno로 실행해 보는 #NodeToDenoChallenge 를 시작한다. 1월 4일까지 Node.js 프로젝트를 Deno로 실행하고 결과를 스크린샷으로 올려서 참가할 수 있다. 이는 그동안 Node.js 호환성을 높이는 작업에 대한 자신감을 보여주면서 Node.js 사용자가 Deno를 사용해 보도록 하는 의미로 보인다.(영어)

# IT 업계 뉴스

- [**Adobe abandons $20 billion acquisition of Figma**](https://www.theverge.com/2023/12/18/24005996/adobe-figma-acquisition-abandoned-termination-fee) : [2022년 9월 Adobe가 Figma를 인수](https://news.adobe.com/news/news-details/2022/Adobe-to-Acquire-Figma/default.aspx)한다는 뉴스가 있어서 이미 인수가 된 줄 알았으나 영국 경쟁시장감독청(CMA)이 이 인수가 이뤄지면 디자인 소프트웨어 시장에 해를 끼칠 수 있다고 인수를 차단했다. 이에 Adobe는 [이번 인수를 그만하기로 발표](https://news.adobe.com/news/news-details/2023/Adobe-and-Figma-Mutually-Agree-to-Terminate-Merger-Agreement/default.aspx)했다. 기사에 따르면 이번 인수가 취소되면 위약금으로 10억 달러를 Adboe가 Figma에 줘야 한다.(영어)
- [**Cisco to Acquire Cloud Native Networking & Security Leader Isovalent**](https://isovalent.com/blog/post/cisco-acquires-isovalent/) : Cisco가 eBPF 기반 네트워킹을 지원하는 [Cilium](https://cilium.io/)을 만드는 Isovalent를 인수했다.(영어)
- [**아이디어스 운영사 백패커, 텐바이텐 인수**](https://m.mk.co.kr/news/it/10905570) : 크라우드 펀딩 [tumblbug](https://tumblbug.com/)을 운영하는 백패커가 이커머스 서비스인 [10x10](https://www.10x10.co.kr/)의 지분 80%를 매입했다.(한국어)
- [**SSH3**](https://github.com/francoismichel/ssh3) : QUIC과 TLS 1.3을 이용해서 더 안정적으로 통신하도록 만든 SSH 프로토콜
- [**Suno.ai**](https://www.suno.ai/) : 프롬프트를 입력하면 AI가 음악을 생성해 주는 서비스
- [**Stirling-PDF**](https://github.com/Stirling-Tools/Stirling-PDF) : PDF를 합치거나 나누는 등 PDF를 조작하는 다양한 기능을 할 수 있는 웹 애플리케이션으로 로컬에 직접 띄울 수 있다.

# 버전 업데이트

- [**date-fns**](https://date-fns.org/) **v3.0.0** : JavaScript Date 라이브러리, [릴리스 공지](https://blog.date-fns.org/v3-is-out/)
- [**Vue.js**](https://vuejs.org/) **v3.4 Slam Dunk** : 자바스크립트 UI 라이브러리, [릴리스 공지](https://blog.vuejs.org/posts/vue-3-4)
    - 2배 빨라진 새로운 템플릿 파서
- [**Rust**](http://www.rust-lang.org/) **1.75.0** : 프로그래밍 언어, [릴리스 공지](https://blog.rust-lang.org/2023/12/28/Rust-1.75.0.html)
- [**FastAPI**](https://fastapi.tiangolo.com/ko/) **v0.108.0** : Python 웹 프레임워크, [릴리스 공지](https://fastapi.tiangolo.com/release-notes/#01080)
- [**Nuxt.js**](https://nuxtjs.org/) **v3.9.0** : 서버렌더링 Vue.js 애플리케이션 프레임워크, [릴리스 공지](https://nuxt.com/blog/v3-9)
    - Vite 5와 Rollup 4 지원
- [**RedwoodJS**](https://redwoodjs.com/) **v6.6.0** : 풀스택 웹프레임워크, [릴리스 공지](https://github.com/redwoodjs/redwood/releases/tag/v6.6.0)
- [**Elixir**](http://elixir-lang.org/) **v1.16** : 프로그래밍 언어, [릴리스 공지](https://elixir-lang.org/blog/2023/12/22/elixir-v1-16-0-released/)
- [**GitLab**](https://about.gitlab.com/) **v16.7** : 오픈소스 설치형 Git 플랫폼, [릴리스 공지](https://about.gitlab.com/releases/2023/12/21/gitlab-16-7-released/)
- [**Open Policy Agent**](https://www.openpolicyagent.org/) **v0.60.0** : 클라우드 네이티브 환경의 정책 엔진, [릴리스 공지](https://github.com/open-policy-agent/opa/releases/tag/v0.60.0)
- [**OrbStack**](https://orbstack.dev/) **v1.2.0** : mac용 Docker 애플리케이션, [릴리스 공지](https://orbstack.dev/blog/orbstack-1.2-container-files)
- [**Meteor**](https://www.meteor.com/main) **v2.13** : 웹앱 플랫폼, [릴리스 공지](https://blog.meteor.com/new-meteor-js-2-14-updates-to-cli-and-tracker-changes-a9814e11ac70)
- [**Homebrew**](http://brew.sh/) **v4.2.0** : OS X 패키지 매니저, [릴리스 공지](https://brew.sh/2023/12/18/homebrew-4.2.0/)
- [**Bazel**](https://bazel.build/) **v7.0 LTS** : 빌드 플랫폼, [릴리스 공지](https://blog.bazel.build/2023/12/11/bazel-7-release.html)
- [**fzf**](https://github.com/junegunn/fzf) **v0.45.0** : 커맨드라인 fuzzy 파인더, [릴리스 공지](https://github.com/junegunn/fzf/releases/tag/0.45.0)
- [**Scala.js**](http://www.scala-js.org/) **v1.15.0** : Scala를 JavaScript로 변환하는 컴파일러, [릴리즈 공지](https://www.scala-js.org/news/2023/12/29/announcing-scalajs-1.15.0/)

# 회사


당근마켓에 다닌 지 3년이 넘었고 어느새 내가 다닌 회사 중에 두 번째로 오래된 회사가 되었다. 사실 2년 이상 다닌 회사는 당근마켓 포함해서 딱 2개밖에 없긴 하다. 가장 오래 다닌 회사가 3년 5개월을 다녔으니 큰일이 없으면 내년 중에 가장 오래된 회사가 될 것 같다.


SRE팀에서 딜리버리 파트로 일하면서 3년 내내 내가 하는 일은 영역만 넓어졌지 계속 똑같다. 어느새 파트는 2명에서 6명이 되었고 SRE팀도 16명으로 아주 큰 팀이 되었다.


3년째 배포 시스템을 만들고 있는데 여전히 도전적이고 재미있는 도메인이라는 생각이 든다. 배포 시스템이 사내 플랫폼 역할을 하면서 고민할 건 더 많아졌지만, Kubernetes도 점점 이해하고 [플랫폼 엔지니어링](https://platformengineering.org/)도 공부하면서 차근차근 나아가고 있다. 사내에서도 어느 정도 사내 플랫폼이 자리 잡고 인정받는 부분도 있어서 동기 부여도 많이 되고 지금까지는 꽤 잘 해내고 있다고 생각한다. 물론 초기에는 기능 구현 등에서 명확하다고 생각하는 게 많이 있었는데 기능이 많아지고 고도화되면서 점점 어느 쪽 방향으로 가야 하는지 고민되는 일이 많아지고 있지만 국내에서 어디 가도 부럽지 않을 만큼 좋은 SRE팀이라고 생각하고 협업하는 것도 즐겁고 업무 몰입도도 높은 편이라 만족스럽다.


[작년 회고](https://blog.outsider.ne.kr/1644)에서도 얘기했듯이 리드이긴 하지만 매니징을 많이 하고 있다고 생각하진 않는다. 동료들이 적극적으로 고민하면서 일해주기 때문에 점점 내가 관여하는 부분도 줄어들고 있다. 올해는 인프라실 내 지원 업무도 늘어나서 미팅이나 딜리버리 파트 외의 업무가 많아지긴 했다. 우리 파트 업무는 잘 돌아가고 있긴 하지만 가장 밀접한 우리 파트와 보내는 시간이 줄어들어서 좀 걱정된다.


![9625799777.jpg](https://blog.outsider.ne.kr/attach/1/9625799777.jpg)


이제 파트도 총 6명이 되었고 직접 작업하는 시간은 많이 줄어들었다.


![3582282454.jpg](https://blog.outsider.ne.kr/attach/1/3582282454.jpg)


큰 기능은 대부분 나눠주고 지원 업무나 내가 좀 전체적으로 파악해야 할 일 위주로 내가 하고 있다. 큰 방향성과 각 기능에서 전체적인 방향에 대한 논의에 주로 참여하고 세세한 부분은 개별 작업자가 알아서 하고 있어서 나는 주로 팀이 잘 돌아가게 지원해 주는 역할을 하고 있다. 하루에 Pull Request 리뷰를 한 번도 못 하는 날도 늘어갔는데 그래도 시간이 날 때 최대한 리뷰에 참여해서 릴리스 속도가 느려지지 않도록 지원하고 있다. 그래도 아직은 내가 전혀 모르는 작업 내용이 배포되거나 하진 않는다.(설사 늦게 볼지라도...) 아직까진 리드와 현업의 간격이 괜찮다고 느끼는 편인데 여기서 협업과 더 멀어지면 내 역량으로 할 수 있을지 자신이 없어서 이 간격을 최대한 유지하는 중이다.


올해는 어쩌다 보니 Kubernetes CPU의 사용량 추적 및 최적화가 내 업무에 큰 부분을 차지하게 되었는데 2023년에 CPU 스케줄링을 고민하고 있을 줄은 몰랐지만, 연초보다는 훨씬 이해도가 올랐지만, 여전히 이해 못 하는 부분이 많다. 너무 궁금한데 원래 잘 아는 영역도 아니고 CPU 스케줄링 커널 소스를 까본다고 알 수 있을 것 같지도 않아서 증상과 가설을 통해서 지식을 넓혀가고 있다. 어디 잘 정리된 글이 없나 싶은데 가벼운 내용의 글은 많지만, 자세히 설명된 글은 많지 않다. 이해 안 될 때는 너무 답답하지만, 개발이 다 그렇듯이 그러다가 이해하기 시작하면 또 재밌고 그렇다.


# 코딩/블로그


올해는 글을 많이 쓰는 대신 코딩을 거의 못 했다. 올해는 뭔가 집에 오면 좀 늘어져 있고 싶었던 적이 많아서 집에 오면 OTT를 보면서 쉬는 경우가 많다 보니 절대시간이 부족해서 글을 많이 쓰니까 대신 코딩을 별로 못했다. 이것저것 하고 싶은 건 많았지만, 절대시간이 줄어드니 어쩔 수 없긴 하다. 한해 쉬었으니, 내년에는 사이드 프로젝트나 오픈소스 기여를 할 수 있기를 기대하고 있다.


![8439929738.jpg](https://blog.outsider.ne.kr/attach/1/8439929738.jpg)


올해는 이 회고 글까지 포함하면 57개의 글을 썼는데 작년 68개 보다는 적지만 나름 만족할 정도로 글을 썼다. 그리고 [RetroTech](https://retrotech.outsider.dev/) 팟캐스트를 개인적으로 [시작](https://blog.outsider.ne.kr/1681)했다. 이 팟캐스트는 작년부터 생각한 것이고 팟캐스트이긴 하지만 대본 작성하느라고 나한테는 글을 쓰는 작업이나 다름없고, 올 2월부터 준비해서 총 8개의 에피소드를 올렸는데 아무리 작게 잡아서 글의 분량이나 들인 시간을 생각하면 한 에피소드에 블로그 글 3~4개 정도의 시간을 들었기 때문에 이 팟캐스트까지 포함하면 글 쓰는데 시간을 많이 쓰긴 했다.


물론 첫 주제로 골랐던 JavaScript 프레임워크를 8 에피소드나 녹음하면서 올해 내에 끝내지 못할 줄은 생각하지 못했다. 올해 내에 끝내고 다음 주제로 넘어가고 싶었는데 아쉽지만 어쩔 수 없다. 미리 준비해 둔 대본도 있어서 5편 정도는 2주마다 정기적으로 올리면서 목표로 잡았지만 2주마다 올리는 게 너무 힘들어서 조금씩 길어지면서 지금은 비정기적으로 끊기지 않고 올리는 게 목표로 바뀌었다. 약간 힘들긴 하지만 예전에 몰랐던 상황도 알게 되면서 꽤 재미있긴 하다.


처음에 시작할 때도 많은 사람이 들을 팟캐스트라고 생각하진 않았지만 또 막상 힘들게 준비했는데 구독자가 많지 않으니 아쉽긴 하다. 한편 올리면 한 50명 정도 듣는 거 같다. 구독자 수 신경을 안 쓰고 해야지 생각하고 있지만 그래도 노력이 많이 들어가니까 많이 들어줬으면 하는 바램도 있긴 하다.(재밌게 말해야 하는데 내가 말하는 거니 감이 없어서 모르겠다. ㅠ)


그리고 작년에는 열심히 못했는데 올해는 [44BITS 팟캐스트](https://podcast.44bits.io/)도 열심히 했다. 우리가 올해 24편을 녹음했는데 그중에 23편에는 참석했으니 나름 열심히 했다고 할 수 있다. 그리고 이전에는 녹음 날짜와 업로드 날짜의 차이가 너무 나서 듣는 분들이 힘들었을 텐데 (길 때는 6개월까지...) (내가 하는 건 아니지만) 이제는 녹음하면 며칠 내에 업로드가 되고 있어서 녹음하는 재미도 더 커졌다.


![8682053584.jpg](https://blog.outsider.ne.kr/attach/1/8682053584.jpg)


[RescueTime](https://www.rescuetime.com/)에서는 어차피 사용한 시간 대비니까 여전히 72% 정도는 생산성인 시간에 쓴 거로 나온다.(OTT를 맥북으로 보진 않으니까...) 그래도 작년대비 1,500시간 정도의 컴퓨터 사용량이 줄어든 걸 보면 확실히 컴퓨터 앞에 훨씬 덜 앉아있긴 했다. RescueTime이 유료라 회사 맥북도 같이 물려뒀더니만 얼마나 수집되었는지 헷갈리지만, 데이터가 섞여서 오히려 통계 보기가 안 좋은 거 같다. 회사는 따로 추적해 보고 싶긴 한데 또 결제하긴 그렇고(통계 때 분리해서 보고 싶은데 ㅠ) 내년엔 회사 장비는 빼야겠다.


![5291947391.jpg](https://blog.outsider.ne.kr/attach/1/5291947391.jpg)


[wakatime](https://wakatime.com/)도 올 초부터 결제해서 쓰고 있다.(이런 기록에 집착하는 편이다.) 이건 개인 장비에만 연결된 데이터이다.


![5341264611.jpg](https://blog.outsider.ne.kr/attach/1/5341264611.jpg)


아까 말한 대로 코딩은 거의 안 하고 글을 썼기 때문에 Sublime Text만 잡혔다. 나는 Sublime Text에서 보통 글을 작성하고 여기서는 코드 작성은 전혀 하지 않는다.


올해부터는 Google Analytics 4로 바뀌면서 통계 수치도 달라지고 뭔가 사용하기 어려워졌지만, 페이지뷰 기준으로 올해 많이 조회된 글이다.

- [Java의 Foreach 루프 사용하기](https://blog.outsider.ne.kr/271) - 2009/01/19, 12,818 Page Views
- [GitHub에서 기본 브랜치 변경하는 명령어 살펴보기](https://blog.outsider.ne.kr/1598) - 2022/05/26, 12,406 Page Views
- [Git의 기본 브랜치를 master에서 main으로 변경하기](https://blog.outsider.ne.kr/1503) - 2020/10/10, 9,555 Page Views
- [새 버전에 맞게 git checkout 대신 switch/restore 사용하기](https://blog.outsider.ne.kr/1505) - 2020/10/21, 9,431 Page Views
- [git에서 원격저장소에 branch와 tag를 push하기](https://blog.outsider.ne.kr/644) - 2011/05/23, 7,622 Page Views
- [Powerlevel10k로 zsh 설정하기](https://blog.outsider.ne.kr/1490) - 2020/07/29, 7,470 Page Views
- [Javascript에서 String을 Number타입으로 바꾸기](https://blog.outsider.ne.kr/361) - 2009/08/19, 6,901 Page Views
- [Eclipse에서 계속해서 오류날때 워크스페이스 Clean하기](https://blog.outsider.ne.kr/636) - 2011/05/05, 6,194 Page Views

아래는 올해 쓴 글 중에서만 페이지뷰가 높은 10개를 뽑아봤다.

- [Atom 개발자가 만든 텍스트 에디터 Zed](https://blog.outsider.ne.kr/1665) - 2023/04/13, 5,445 Page Views
- [Kubernetes의 CPU requests와 limits](https://blog.outsider.ne.kr/1653) - 2023/02/07, 5,057 Page Views
- [내가 생각하는 스타트업 미니멀 인프라 스택](https://blog.outsider.ne.kr/1666) - 2023/04/15, 4,245 Page Views
- [GitHub Actions에서 output 변수의 문법 변경](https://blog.outsider.ne.kr/1651) - 2023/01/30, 2,717 Page Views
- [GitHub Copilot for CLI 소개](https://blog.outsider.ne.kr/1663) - 2023/03/31, 1,492 Page Views
- [[Book] 러닝 타입스크립트 - 안정적인 웹 프로젝트 운영을 위한 타입스크립트의 모든 것](https://blog.outsider.ne.kr/1654) - 2023/02/10, 1,443 Page Views
- [Infcon 2023에서 발표한 "DevOps를 가속화하는 플랫폼 엔지니어링"](https://blog.outsider.ne.kr/1684) - 2023/08/18, 1,024 Page Views
- [기술 뉴스 #222 : 23-05-16](https://blog.outsider.ne.kr/1673) - 2023/05/16, 989 Page Views
- [Kubernetes CronJob의 스케줄 변경 시 소급 적용된다?](https://blog.outsider.ne.kr/1662) - 2023/03/23, 919 Page Views

발표는 회사 밋업까지 포함해서 3번 했다. 1월 초에도 발표가 하나 있어서 준비해야 하긴 하는데 내년 일을 내년에 해야지 하고 일단 머릿속으로만 정리 중이다.

- [공개SW 페스티벌 2023에서 발표한 "오픈소스에 기여할 때 알면 좋을 개발 프로세스"](https://blog.outsider.ne.kr/1697)

# 공부


올해는 총 12권의 책을 읽었다. 더 많이 읽고 싶었지만, 책을 느리게 읽는 편이라 많이 읽지는 못했다.


내가 좋아하는 인프라 스터디에서는 [Observability Engineering](https://blog.outsider.ne.kr/archive/202310)를 같이 읽었는데 이 스터디는 멤버도 좋고 오래 지낸 사람들이기도 해서 스터디를 하면서 배우는 게 많다. 그래서 더 어려운 주제로 선택하게 되는 거 같기도 하다. 평소에 리더십 책을 많이 읽는 편은 아닌데 동료들과 리더십 책 모임을 하면서 올해는 리더십 관련 책을 몇 권 읽게 되었다. 지나서 보면 [개발자에게 물어보세요 - 디지털 공급망으로 조직의 핵심 역량 구축하기](https://blog.outsider.ne.kr/1672)가 제일 재밌었다.


난 비소설만 읽는 편이고 그중에서 대부분이 개발 관련 책만 보기는 하는데 올해는 소설도 좀 읽고 싶어졌다. 이 블로그가 개발 블로그라서 후기를 올리진 않았지만, 동료에게 추천받은 [프로젝트 헤일메리](https://m.yes24.com/Goods/Detail/101375755)를 읽었는데 너무 재밌고 감동적이었다.(눈물 나올 뻔) 그리고 워낙 유명한 소설인 [눈물을 마시는 새 1권](https://m.yes24.com/Goods/Detail/333224)을 봤다. 문득 어렸을 때 재밌게 본 영웅문을 다시 읽어보고 싶다는 생각이 들었는데 다시 읽기엔 시간이 오래 걸릴 테니 고민하다가 이영도 작가의 드래곤 라자를 재밌게 본 기억이 나서 그 유명한 눈물을 마시는 새를 봤다. 아직 1권만 봤는데 오랜만에 보는 소설들이 꽤 재미있다. 내년에도 많이는 아니어도 소설은 약간씩은 읽어 보려고 한다.


내 삶은 엄청 루틴한 편이라 올해도 무난하게 만족하면서 보낸 한해인 것 같다. 출근을 일주일에 3일만 하고 있고 다른 회사도 재택하는 회사들도 있다 보니 확실히 예전보다는 사람들을 많이 만나진 않는 것 같다. 작년에도 건강관리에 관해 썼지만 이제 수영도 시작했으니, 건강관리도 하면서 한 해를 보내야겠다.


# 새해 복 많이 받으세요.


비밀번호 관리 서비스인 [1Password](https://1password.com/)는 2022년에 [1Password Developer Tools](https://1password.community/discussion/127893/introducing-1password-developer-tools)를 런칭하고 [SSH와 Git의 비밀키 관리 기능](https://blog.1password.com/1password-ssh-agent/)도 추가하면서 사용자의 비밀번호 관리뿐만 아니라 시스템이나 개발자의 보안을 유지할 수 있는 기능도 추가하고 있다.


작년인가 1Password의 [Connect Server](https://developer.1password.com/docs/connect)를 보고 이를 이용해서 서비스에서 시크릿 보관소로 쓸 수 있을지 궁금했던 기억이 있다. 테스트해 봐야지 하고는 아직 못하고 있었다.


최근 GitHub Universe에서 1Password 부스를 구경하다가 [1Password Developer Tools](https://1password.com/developers)에 Service Accounts라는 기능이 나왔다는 것을 알게 되었고 내가 올해 고민하던 문제의 해결책이 될 수 있겠다는 생각에 살펴봤다.


내가 생각하는 문제는 보통 로컬에서 개발 환경을 구성하기 위해서 다양한 시크릿 정보를 환경 변수에 저장해 놓고 사용하게 되고 [direnv](https://blog.outsider.ne.kr/1306)나 그 외 환경변수 관리 도구를 쓴다고 하더라도 일반적으로 이 정보는 로컬에 보통 평문으로 저장되어 있다. 개발 환경이긴 하지만 상황에 따라선 프로덕션용 시크릿이 보관되어 있을 수 있다. 물론 컴퓨터의 자체 보안이 있고 노트북을 잃어버려도 보통 암호가 걸려있어서 암호가 풀린 상태로 다른 사람에게 노트북을 주거나 공격자에게 침투당하는 상황까지 고려하는 것은 아니지만 파일을 복사하거나 백업하면서 실수로라도 이러한 시크릿이 유출될 가능성이 높다는 것이었다.


# 1Password Service Accounts


1Password Service Accounts는 올 [6월에 퍼블릭 베타로 공개](https://blog.1password.com/1password-service-accounts/)된 기능이고 지금은 베타가 끝나서 공개된 상태이다.


![5585988691.jpg](https://blog.outsider.ne.kr/attach/1/5585988691.jpg)


[1Password의 Developer Tools](https://my.1password.com/developer-tools/directory)에 들어가면 CI, Kubernetes, CLI, SSH/Git, IDE와 통합할 수 있는 메뉴가 나온다. 참고로 IDE는 현재는 VS Code만 통합할 수 있다.


![3624803287.jpg](https://blog.outsider.ne.kr/attach/1/3624803287.jpg)


GitHub Actions를 클릭해서 Service Accounts와 Connect Server 중에서 선택할 수 있게 나온다. 둘 다 시크릿은 자동화해서 연동할 수 있게 하는 기능인데 Service Accounts는 CLI를 사용해서 연동할 수 있고 Connect Server는 별도의 서버를 실행해서 연동할 수 있다. Connect Server는 나중에 또 공부해 보려고 하는 데[둘의 기능 차이](https://developer.1password.com/docs/secrets-automation)를 살펴보면 다음과 같다.


![4161871076.jpg](https://blog.outsider.ne.kr/attach/1/4161871076.jpg)


CI나 로컬에서 연동하려면 별도의 서버 관리가 필요 없는 Service Accounts가 더 적합해 보였다.


Service Accounts 생성을 클릭하면 이름을 입력할 수 있다.


![2767358670.jpg](https://blog.outsider.ne.kr/attach/1/2767358670.jpg)


생성할 서비스 어카운트가 접근할 금고(Vault)를 선택할 수 있다. 권한은 읽기만 허용하거나 읽기/쓰기까지 가능하거나 할 수 있다. 서비스 어카운트에서는 주로 읽기를 할거라고 생각했기에 읽기 권한만 부여했다.


![8275199701.jpg](https://blog.outsider.ne.kr/attach/1/8275199701.jpg)


생성이 완료되면 해당 서비스 어카운트의 인증 토큰이 나오고 이 토큰은 [1Password CLI](https://developer.1password.com/docs/cli)에서 사용할 수 있다.


![2789847765.jpg](https://blog.outsider.ne.kr/attach/1/2789847765.jpg)


이 토큰을 나중에 사용해야 하므로 1Password에 저장해 둘 수 있다.


![6796011955.jpg](https://blog.outsider.ne.kr/attach/1/6796011955.jpg)


# 1Password CLI


macOS 기준으로 [Homebrew](https://brew.sh/)를 이용해서 [설치](https://developer.1password.com/docs/cli/get-started/)하거나 [직접 다운로드](https://app-updates.agilebits.com/product_history/CLI2) 받아서 사용할 수 있다.


CLI는 `op` 라는 명령어로 사용할 수 있고 현재 최신 버전은 `2.24.0`이다.


```plain text
$ op -v
2.24.0
```


인증을 하기 위해 `OP_SERVICE_ACCOUNT_TOKEN` 환경변수에 아까 발급받은 인증 토큰을 지정한다.


```plain text
$ export OP_SERVICE_ACCOUNT_TOKEN=ops_eyJ...
```


그리고 1Password 앱의 설정의 개발자 섹션에서 "1Password CLI와 통합"을 활성화해야 한다.


![8602273020.jpg](https://blog.outsider.ne.kr/attach/1/8602273020.jpg)


이를 활성화하면 1Password의 각 시크릿에서 "보기"와 "크게 보기" 외에도 "비밀 참조 복사"라는 항목이 생기게 된다.


![7663474158.jpg](https://blog.outsider.ne.kr/attach/1/7663474158.jpg)


위는 예시로 API 키를 저장한 시크릿인데 이 "비밀 참조 복사"를 하면 `op://Dev/demo/api_key`와 같은 주소가 생긴다. 여기서 `op://[금고 이름]/[시크릿 이름]/[필드 이름]` 형태가 된다. 여기서 각 항목에 [지원하지 않는 문자](https://developer.1password.com/docs/cli/secrets-reference-syntax/#syntax-rules)가 있는 경우에는 `op://Dev/iunplqsduyobjbri45irjajgcu/password`처럼 이름 대신 UID가 생성된다.


앞에서 서비스 어카운트를 만들고 발급받은 인증 토큰을 `OP_SERVICE_ACCOUNT_TOKEN` 환경변수에 저장하면 바로 CLI를 사용할 수 있다.


`op vault list` 명령어로 금고 목록을 볼 수 있는데 해당 금고는 `Dev` 금고에만 접근 권한을 주었기 때문에 한 개만 나온다.


```plain text
$ op vault list
ID                            NAME
u7mujejocgwhnu3sxbxjehtdpm    Dev
```


CLI에서 각 아이템의 목록을 볼 수 있다.


```plain text
$ op item list
ID                            TITLE                                             VAULT            EDITED
4phd2vr5vnqt3ssrjpupdfbkfy    demo                                              Dev              10 minutes ago
bkgfwcb25abmp4wwslo4ss2qwy    Service Account Auth Token: GitHub Actions        Dev              2 weeks ago
```


1Password 앱을 켜지 않고도 특정 아이템의 자세한 내용을 확인해 볼 수 있다.(여기서 보이는 `api_key`는 임의로 만든 문자열이다.)


```plain text
$ op item get demo --vault Dev
ID:          4phd2vr5vnqt3ssrjpupdfbkfy
Title:       demo
Vault:       Dev (u7mujejocgwhnu3sxbxjehtdpm)
Created:     1 day ago
Updated:     10 minutes ago by Outsider
Favorite:    false
Version:     3
Category:    SERVER
Fields:
  api_key:    RvN4HNRk2oE.iL*42veP.UE.eDre6rPf_K*@m8!j
  관리자 콘솔:

  호스팅 제공업체:
```


CLI에서 비밀 참조를 알고 싶다면 JSON 형식으로 출력해 보면 확인할 수 있다.


```plain text
$ op item get demo --vault Dev --format json
{
  "id": "4phd2vr5vnqt3ssrjpupdfbkfy",
  "title": "demo",
  "version": 3,
  "vault": {
    "id": "u7mujejocgwhnu3sxbxjehtdpm",
    "name": "Dev"
  },
  "category": "SERVER",
  "last_edited_by": "K2ACBLCXENBKJLN2V6Y3HPRSBY",
  "created_at": "2023-12-19T08:10:17Z",
  "updated_at": "2023-12-21T01:48:25Z",
  "sections": [
    {
      "id": "hosting_provider_details",
      "label": "호스팅 제공업체"
    }
  ],
  "fields": [
    {
      "id": "password",
      "type": "CONCEALED",
      "label": "api_key",
      "value": "RvN4HNRk2oE.iL*42veP.UE.eDre6rPf_K*@m8!j",
      "reference": "op://Dev/demo/api_key"
    },
    {
      "id": "name",
      "section": {
        "id": "hosting_provider_details",
        "label": "호스팅 제공업체"
      },
      "type": "STRING",
      "label": "이름",
      "reference": "op://Dev/demo/hosting_provider_details/name"
    }
  ]
}
```


## `op read`


`op read`는 비밀 참조의 값을 읽어오는 명령어로 다음과 같이 비밀번호를 조회해 볼 수 있다.


```plain text
$ op read op://Dev/demo/api_key
RvN4HNRk2oE.iL*42veP.UE.eDre6rPf_K*@m8!j
```


이를 이용해서 특정 시크릿 값을 파일에 저장할 수도 있다.


```plain text
$ op read op://Dev/demo/api_key --out-file key.txt
/Users/outsider/temp/op-test/key.txt

$ cat key.txt
RvN4HNRk2oE.iL*42veP.UE.eDre6rPf_K*@m8!j
```


값을 확인하고자 할 때는 `op read`를 이용할 수 있지만 서비스 어카운트를 쓴다는 것 자체가 비밀번호를 직접 다루지 않기 위함이라고 생각하기 때문에 이 명령어는 CLI에 약간 익숙해 지면 쓸 일은 없어질거로 생각한다.


## `op run`


아마 서비스 어카운트에서 가장 많이 사용할 명령어라고 생각한다. 1Password 금고에 시크릿을 저장했다면 개발할 때 이를 가져다 써야 하는데 `op run`이 이 문제를 해결하는 명령어다.


```plain text
$ export API_KEY=op://Dev/demo/api_key
```


위와 같이 내가 원하는 환경변수(`API_KEY`)를 앞의 비밀 참조 값으로 설정한다.


애플리케이션에서 이 환경변수를 사용하는 상황을 테스트하기 위해 아래와같이 간단한 Node.js 코드를 작성했다. 3000 포트에 떠 있는 다른 서버에 `API_KEY` 환경 변수를 쿼리스트링으로 전달하고 `API_KEY`을 로그로 출력하고 응답받은 결과를 출력하도록 했다.


```plain text
// app.js
fetch(`http://localhost:3000?secret=${process.env.API_KEY}`)
  .then(async (res) => {
    console.log(`API_KEY: ${process.env.API_KEY}`);
    const result = await res.text();
    console.log(result);
  })
```


당연하게도 `API_KEY`의 값으로 `op://Dev/demo/api_key`가 출력되고 다른 서버의 로그에도 `op://Dev/demo/api_key`가 출력된다.


```plain text
$ node app.js
API_KEY: op://Dev/demo/api_key
Response from another server
```


이를 `op run --` 명령어와 연결해서 서버를 실행하면 환경변수 중에 존재하는 비밀 참조를 모두 찾아서 1Password 값으로 치환해서 처리해 준다.(참고로 `--`인 더블 대시는 셸에서 옵션과 인자를 구분하는 문법이다.)


```plain text
$ op run -- node app.js
API_KEY: <concealed by 1Password>
Response from another server
````

위에서 보듯이 해당 환경변수를 로그에 출력했을 때도 값이 출력되는 게 아니라 `<concealed by 1Password>`로 가려진다. 당연히 다른 서버에 전달된 쿼리스트링에는 실제 시크릿 값이 제대로 전달된다.

이렇게 하면 **로컬에서 환경변수를 관리하면서도 실제 시크릿 값을 가지고 있지 않을 수 있다. 실행명령어에 `op run`이 붙어야 하는 불편함이 있지만 보안상으로도 좋고 환경변수 파일을 그대로 GitHub에 공유한다고 하더라도 실제 시크릿 값은 포함되어 있지 않기 때문에 `.env.example` 같은 걸 만들 필요 없이 그냥 환경 파일을 공유해서 사용하는 것도 가능하고 다 참조 값이기 때문에 해당 값을 바꿀 때도 1Password에서 바꾸면 바로 로테이션시킬 수 있다.**

하지만 1Password API에 찔러서 가져오는 것이기 때문에 항상 인터넷에 연결되어 있어야 하고 당연히 API 값을 가져오느라 약간의 시간이 더 걸린다.

```bash
$ op run -- printenv API_KEY
<concealed by 1Password>

$ op run --no-masking -- printenv API_KEY
RvN4HNRk2oE.iL*42veP.UE.eDre6rPf_K*@m8!j
```


환경변수 값을 확인하고 싶을 때는 위와 같이 확인해 볼 수 있고 `--env-file` 옵션을 사용하면 사용하고자 하는 환경파일도 지정할 수 있다.


## `op inject`


셸 스크립트 등에서 비밀 참조를 변환해서 실행하고 싶다면 다음과 같이 `op inject`를 파이프로 연결하면 전달받은 문자열의 비밀 참조를 실제 값으로 치환한다.


```plain text
$ echo "API key is op://Dev/demo/api_key" | op inject
API key is RvN4HNRk2oE.iL*42veP.UE.eDre6rPf_K*@m8!j
```


여기서 비밀 참조인 `op://Dev/demo/api_key`를 처리할 때 환경변수도 섞어서 사용할 수 있다. 예를 들어 다음과 같이 같은 API 키가 DEV, Alpha, Prod 3개가 있을 때 같은 패턴으로 만들면 `op://$ENV/demo/api_key`로 환경변수에 지정하고 `ENV` 환경변수로 참조할 시크릿을 바꿔가면서 쓸 수 있다.

- `op://Dev/demo/api_key`
- `op://Alpha/demo/api_key`
- `op://Prod/demo/api_key`

# GitHub Actions에서 1Password Service Accounts


로컬에서 사용하는 방법을 알아봤으니 당연히 CI에서도 사용할 수 있다. CI에서는 GitHub 기준으로 저장소에 액션 시크릿을 설정할 수 있고 공통으로 사용하는 시크릿은 Org에 시크릿을 설정해서 공통으로 사용할 수 있다. 기본적으로 GitHub에서는 시크릿을 설정한 뒤에는 내용을 확인하기 어렵기 때문에 개인이라면 좀 낫지만, 회사 차원에서는 예전에 어떤 값을 설정했는지 확인하기 어려워서 로테이션시키기가 어려운데 이때도 1Password Service Accounts를 쓸 수 있다.


1Password에 접근하기 위해 저장소에 `OP_SERVICE_ACCOUNT_TOKEN`을 저장한다. 여기서는 데모라서 저장소에 Actions 시크릿으로 저장했지만, 회사라면 Org 시크릿으로 저장하거나 관리 정책에 따라 팀별로 따로 지정하는 등의 방법이 가능하다.


![4954728147.jpg](https://blog.outsider.ne.kr/attach/1/4954728147.jpg)


GitHub Actions에 다음과 같은 액션을 만들어 보자. 여기서는 [1password/load-secrets-action](https://github.com/1password/load-secrets-action) 액션을 사용해서 시크릿을 불러와서 원하는 환경변수에 저장할 수 있다. `export-env`를 `true`로 설정해야 다음 스텝에서도 해당 환경변수를 사용할 수 있다. 참고로 `on`에 `workflow_dispatch`로 지정한 것은 GitHub UI에서 수동으로 실행해서 테스트하기 위함이고 `Print unmasked secret` 스텝은 보통은 하면 안 되는 트릭이지만 GitHub Actions에서 [시크릿 로깅을 허용하지 않기 때문에 이를 회피해서 값을 확인하기 위한 우회법](https://stackoverflow.com/a/72881741)이다.


```plain text
name: 1Password test

on: workflow_dispatch

jobs:
  1pw-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Load secret
        uses: 1password/load-secrets-action@v1
        with:
          # Export loaded secrets as environment variables
          export-env: true
        env:
          OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}
          API_KEY: "op://Dev/mysql/password"

      - name: Print masked secret
        run: echo "Secret is $API_KEY"

      - name: Print unmasked secret
        run: echo "$API_KEY" | sed 's/./& /g'
```


이 액션을 실행해 보면 다음과 같이 1Password에서 시크릿 값을 가져와서 사용할 수 있는 것을 볼 수 있다.


![1887521362.jpg](https://blog.outsider.ne.kr/attach/1/1887521362.jpg)


이렇게 사용하면 로컬이나 CI에서 1Password의 서비스 어카운트 토큰만 저장하고 다른 시크릿은 모두 1Password에서 관리할 수 있는 구조로 만들 수 있다. 보는 관점에 따라서 1Password에 다 담아 놓는 게 좋은가 아닌가는 의견이 갈릴 수 있지만 나는 유출된 지점을 줄이면서 로테이션시킬 수 있다는 점에서 긍정적으로 보고 있다.


물론 1Password의 보안은 상당히 신뢰하는 편이지만 1Password API서버에게 장애가 생기면서 로컬이나 CI에도 영향을 받기 때문에 이 부분은 같이 고려해야 할 것으로 생각한다.


[일론 머스크 표지](https://www.aladin.co.kr/shop/wproduct.aspx?ItemId=323119574)


![8328364788.jpg](https://blog.outsider.ne.kr/attach/1/8328364788.jpg)


---


월터 아이작슨이 쓴 일론 머스크의 전기이다. [일론 머스크(Elon Musk)](https://twitter.com/elonmusk)는 요즘이야 따로 설명할 필요도 [PayPal Mafia](https://en.wikipedia.org/wiki/PayPal_Mafia) 중의 한 사람으로 [SpaceX](https://www.spacex.com/), [The Boring Company](https://www.boringcompany.com/), [Nurallink](https://neuralink.com/), [Tesla](https://www.tesla.com/) 등을 창업, 운영하고 최근에 [Twitter](https://twitter.com/)도 인수한 사람이다.


내가 일론 머스크를 언제부터 알았는지 정확하지는 않지만, PayPal 마피아가 되었을 때는 잘 몰랐던 것 같고(아마 다른 사람들에게 관심이 더 갔던 듯) 아마 Tesla에 관해 알게 되면서 일론 머스크에 대해서도 알게 되기 시작했다. 그때 인상은 참 대단한 사람이라는 생각이었고 대단한 창업가가 많이 있지만 일론 머스크는 뭔가 인류를 걱정하는 듯 SpaceX의 화성 이주 목표나 [Starlink](https://www.starlink.com/), Tesla 전기 자동차, The Boring Company의 [Hyperloop](https://www.boringcompany.com/hyperloop)를 보면서 그 스케일과 실천력에 감동하였다.

> 
>
> 내가 세어보니 그렇게 되면 여섯 개의 회사를 운영하게 되는 것이었다. 테슬라, 스페이스X 및 그것의 스타링크 사업부, 트위터, 보링컴퍼니, 뉴럴링크, 엑스닷에이아이. 이는 전성기 시절 스티브 잡스가 운영한 회사(애플과 픽사)의 3배에 달하는 숫자였다.
>
>

그렇게 좋은 인상이었다가 인상이 나빠지기 시작한 것은 Twitter를 인수한 뒤였다. 그 전에는 그냥 트위터에서 가끔 이상한 얘기하면서 어그로 끌면서 관심 모으는 인상은 있었지만 창업가는 좀 독특한 면모가 있으니 그냥 그런가보다 했고 처음 트위터 인수 얘기가 나왔을 때도 그래도 그 수많은 회사를 운영하던 사람인데 Twitter에서도 뭔가 보여줄지도 하는 기대도 있었다. 그 뒤로는 사실 실망의 연속이었고 Twitter를 X로 바꾸면서 너무 이상하게 만들어버렸다. 내가 Twitter를 워낙 좋아하기 때문에 많은 사람들이 Twitter를 떠나려고 하는 것도 마음이 불편하고 회사를 이렇게 운영한다는 것 자체도 이해하기가 어려웠다.

> 
>
> 그는 열정을 키워 자신의 괴팍함을 은폐했지만, 괴팍함 또한 발달시키는 바람에 열정이 가려지기도 했다.
>
>

이 정도가 책을 읽기 전에 내 막연한 생각이었고 일론 머스크의 전기를 읽어보면서 일론 머스크에 대해서 제대로 알지 못했다는 생각이 많이 들었다.


집투를 동생과 창업하고 페이팔과 합쳐졌다가 이후에 SpaceX를 창업하면서 연쇄적으로 회사를 차리기까지의 과정을 볼 때까지 아주 흥미롭다. 여기선 내가 전혀 모르던 얘기도 많았다.

> 
>
> 그는 몇 년 후 TED 강연에서 이렇게 말했다. "기술은 많은 사람들이 그것을 개선하기 위해 아주 열심히 노력하는 경우에만 발전할 수 있습니다."
>
>

SpaceX가 발사에 실패하고 돈이 없어서 힘들 때 Nasa의 사업을 따오는 부분이나 기존에 로켓 발사의 발주 구조를 혁신적으로 바꿔내는 부분, 치열하게 싸우면서 테슬라를 창업하는 과정 등이 꽤 재미있었다.

> 
>
> 팰컨 1호는 그렇게 지상에서 발사되어 궤도에 진입한 최초의 민간 제작 로켓이라는 새로운 역사를 기록했다.
>
>
> 
>
> 스페이스X는 우주 개척을 민영화하고 있었을 뿐만 아니라 비용 구조도 뒤엎고 있었다.
>
>
> 
>
> 머스크는 자체적으로 '바보 지수(idiot index)'라는 개념을 도입했다. 부품의 총 비용에 대한 원자재 비용의 비율을 계산해 뽑는 지수였다. 바보 지수가 높은 부품(예컨대, 원자재인 알루미늄의 가격은 100달러에 불과한데 그것으로 만든 부품은 1,000달러에 달하는 경우)은 설계가 너무 복잡하거나 제조공정이 너무 비효율적일 가능성이 높았다. 머스크의 표현을 빌리자면, "바보 지수가 높으면 당신이 멍청하다는 뜻"이었다.
>
>

다른 회사들도 많이 있지만 아무래도 SpaceX와 Tesla가 그 중심에 있고 가장 큰 사업과 혁신들이었기에 이부분에 대해서도 많이 다루고 있다. 단편적으로는 알고 있는 뉴스들도 있지만 처음부터 찾아보진 않았기 때문에 이 책에서 두 회사가 어떻게 시작되고 어떤 어려움이 있었고, 심지어 회사가 망할 수도 있는 상황에서 어려움을 극복하고 성공에 이르렀는지 보는게 꽤 흥미로웠다.

> 
>
> 경력 초기부터 머스크는 일과 삶의 균형, 즉 워라밸이라는 개념을 경멸하는 까다로운 경영자였다. 집투와 이후의 모든 회사에서 그는 휴가도 없이 하루 종일, 그리고 종종 밤늦게까지 쉴 새 없이 자신을 몰아붙였고, 다른 직원들도 그런 식으로 일하기를 기대했다.
>
>
> 
>
> 혁신적인 아이디어를 추구하며 기꺼이 공장에서 밤을 새는 머스크를 보면서 엔지니어들은 두려움 없이 색다른 해결책을 시도해볼 수 있다는 생각에 고무되었다.
>
>

당연하게도 이러한 혁신을 이루기 위해서는 치열하게 일하는 머스크가 있었다. 이전에 일론 머스크는 어떻게 저 많은 회사를 운영하는 거지? 시간이 되나? 하는 생각을 한 적이 있지만 전기를 보면서는 더 현실감 없을 정도로 치열하게 일하고 있었다. 이젠 꽤 큰 회사의 CEO이기 때문에 회사 운영에 집중할 거로 생각했는데 실제로는 각 제품의 재질이나 디자인, 기술에 다 관여하고 의논할 정도로 거의 모든 일이 일론 머스크를 중심으로 이루어지고 있었다. 이는 일론 머스크가 엔지니어들과 그런 논의를 할 수 있을 정도로 상당한 지식을 가지고 있는 거라고 할 수 있어서 그런 장면들을 보면서 감동스럽기도 했다.

> 
>
> "사람들이 해낼 수도 있겠다고 생각하는 선에서 공격적인 일정을 정하면 사람들은 더 많은 노력을 기울이려고 할 겁니다. 하지만 물리적으로 불가능한 일정을 제시하면 어떻게 되겠습니까? 엔지니어들이 바보가 아니잖아요. 사기만 떨어지게 되죠. 그것이 일론의 가장 큰 약점입니다."
>
>
> 
>
> 머스크는 반대쪽 극단으로 치닫는 것 역시 리더를 쇠약하게 만들 수 있다고 반박한다. 그는 모든 사람의 친구가 되고자 하면 기업 전체의 성공보다 눈앞에 있는 개인의 감정에 지나치게 신경 쓰게 되고, 그런 접근방식은 훨씬 더 많은 사람에게 상처를 입힐 수 있다고 마크스에게 말했다. "마크스는 그 누구도 해고하지 못했을 거예요." 머스크는 말한다. "나는 마크스에게 강조하곤 했지요. 사람들에게 열심히 일하라고 말해야 한다고 말이에요, 열심히 일하지 않으면 그들에게 어떤 변화도 일어나지 않는다고 말입니다."
>
>
> 
>
> "직원들에게 친절하게 대하려고 노력하는 것은 사실 일을 잘하고 있는 수십 명의 다른 직원들을 배려하지 않는 처사지요. 내가 문제 지점을 고치지 않으면 열심히 일하는 다른 많은 직원들에게 피해가 되는 겁니다." 머스크의 말이다.
>
>
> 
>
> 머스크가 이렇게 하는 이유는 무엇일까? "그는 진정 탁월한 만능 엔지니어들로 구성된 소규모 그룹이 일반 그룹보다 100배 더 큰 성과를 낼 수 있다고 믿습니다." 로스는 말한다.
>
>

본인이 그렇게 일하면서 그로 인해서 상상도 못할 성공까지 했기 때문인지 당연히 직원들도 그렇게 일하기를 기대한다. 대부분의 채용에도 관여한 것으로 나오는데 대부분 그냥 미친듯이 일만하는 사람을 뽑겠다는 걸로 나오고 주말이든 개인 사정이든 일론 머스크가 지금 해야겠다고 생각하면 하나도 용납하지 않는 모습, 수년동안 열심히 일해서 기여했지만 조금만 나태한 모습을 보이면 바로 해고하는 걸 보면서 엔지니어로써 공감이 되면서도 직장인으로써 묘한 감정이 들기도 했다. 책에는 안나오는데 치열하게 요구할 수는 있는데 일론 머스크가 세계 최고의 부자가 되기까지 회사의 수익이 직원들에게 월급이나 스톡옵션으로 얼마나 보상이 돌아갔는지 궁금해지긴 했다.

> 
>
> 그는 영업과 마케팅에 많은 노력을 기울이지 않았고, 그 대신에 훌륭한 제품을 만들면 판매는 저절로 따라온다고 믿었다.
>
>

요즘은 생각이 좀 달라졌지만 나도 이런 생각을 예전에는 많이 했기에 공감도 많이 되었다.

> 
>
> 레브친의 회상이다. "머스크는 말도 안 되는 소리를 지껄이기도 하지만, 때로는 다른 사람의 전문 분야에 대해 그보다 훨씬 더 많이 알고 있어 사람들을 놀라게 하곤 하죠. 나는 그가 사람들에게 동기를 부여하는 방법 중 상당 부분이 바로 때때로 드러내는 그런 예리함에 있다고 생각합니다. 그를 헛소리꾼이나 바보로 잘못 알고 있던 사람들이 전혀 기대하지 않고 있다가 그런 면모에 세게 한 방 맞은 기분이 드는 거지요."
>
>

Twitter를 인수했을 때 직원들 해고하고 엔지니어들 모아놓고 아키텍처 리뷰하고 그럴 때 Twitter 정도 규모의 아키텍처를 새로운 CEO에게 리뷰한다는 게 말도 안 된다고 생각했는데 책을 보면서는 일론 머스크라면 말이 될 수도 있겠다는 생각으로 바뀌었다. 그 이전에 SpaceX의 로켓 설계나 발사체에 대한 논의나, Tesla의 전기차에 대한 부분도 다 관여하고 심지어 엔지니어들의 접근 방법도 바꿔놓은 경우가 많기 때문이다. 내가 보거나 들은 수많은 CEO와는 (당연히도) 완전히 다른 사람이구나 싶었다.


어쨌든 일론 머스크가 오랫동안 회사를 운영하면서 기준으로 세우고 하는 것들은 엔지니어로서 공감되는 부분이 꽤 있다.

> 
>
> 공장을 설계할 때 머스크는 디자인과 엔지니어링, 제조 팀이 모두 함께 모여 있어야 한다는 자신의 철학을 따랐다. "조립라인에 있는 사람들이 즉각적으로 디자이너나 엔지니어를 붙잡아 세우고 '대체 왜 이런 식으로 만든 거요?'라고 따질 수 있어야 하는 거예요." 머스크가 뮬러에게 설명했다. "가스레인지 위에 자기 손을 올려 놓으면 뜨거워지자마자 바로 떼어내지만, 다른 사람의 손이 올라가 있으면 무언가 조치를 하는 데 시간이 더 오래 걸리기 마련이지요."
>
>
> 
>
> 머스크는 엔지니어와 디자이너가 같은 공간에서 일하게 했다. "엔지니어처럼 생각하는 디자이너와 디자이너처럼 생각하는 엔지니어를 창출하겠다는 비전이 있었던 겁니다." 폰 홀츠하우젠의 말이다.
>
>
> 
>
> "일론의 규칙 중 하나는 '가능한 한 정보 출처에 가까이 다가서라'는 것입니다." 라일리의 말이다.
>
>
> 
>
> 그는 로켓이 발사대를 떠나 시야에서 사라질 정도로 높이 올라가 폭발하는 경우, 그리하여 유용한 새 정보와 데이터를 많이 확보하게 되는 경우, 실험 발사를 성공으로 간주하겠다고 미리 선언한 바 있었다. 스타십은 그러한 목표를 달성했다. 하지만 어쨌든 로켓은 폭발했다. 대부분의 대중은 그것을 폭발로 끝난 실패로 간주할 것이다. 모니터를 바라보던 머스크의 표정이 잠시 굳어지는 듯 보였다.
>
>

SpaceX나 Tesla나 하드웨어 제조가 상당한 부분을 차지하지만 요즘 스타트업이 목적 조직을 구성하는 것도 비슷한 이유라고 생각하고 근복적으로 애자일도 비슷한 접근 방식이라고 생각한다.

> 
>
> 머스크의 알고리즘에는 다섯 가지 계명이 있다.
>
>
> 1. 모든 요구사항에 의문을 제기한다. 모든 요구사항에는 그것을 만든 사람의 이름이 나와야 한다. 법무당국이나 안전당국과 같은 부서에서 나온 요구사항은 절대 받아들여서는 안 된다. 해당 요구사항을 만든 실제 인물의 이름을 알아야 한다. 그런 다음 그가 아무리 똑똑하더라도 의문을 제기해야 한다. 똑똑한 사람들의 요구사항은 사람들이 의문을 제기할 가능성이 적기 때문에 가장 위험하다. 나의 요구사항에도 항상 의문을 제기하라. 그런 후 그 요구사항을 덜 멍청하게 만들어라.
>
>
> 2. 부품이든 프로세스든 가능한 한 최대한 제거하라. 나중에 다시 추가해야 할 수도 있다. 사실, 10퍼센트 이상 다시 추가하지 않게 된다면 충분히 제거하지 않은 것이다.
>
>
> 3. 단순화하고 최적화하라. 이는 2단계 이후에 수행해야 할 과정이다. 흔히 저지르는 실수는 존재해서는 안 되는 부품이나 프로세스를 단순화하고 최적화하는 것이다.
>
>
> 4. 속도를 높여 주기를 단축하라. 어떤 프로세스든 속도를 높일 수 있다. 하지만 이 작업은 앞의 세 단계를 수행한 이후에 수행해야 한다. 테슬라 공장에서 나는 특정 프로세스를 가속화하는 데 많은 시간을 투자한 이후에야 비로소 애초에 제거했어야 했던 것임을 깨닫는 실수를 저질렀다.
>
>
> 5. 자동화하라. 이는 마지막 단계에 해야 할 작업이다. 네바다와 프리몬트에서 내가 저지른 가장 큰 실수는 모든 단계를 자동화하는 것부터 시작했다는 것이다. 모든 요구사항에 의문을 제기하고, 부품과 프로세스를 제거하고, 버그에 대한 해결책이 나올 때까지 기다렸어야 했다.
>
>

보통 일을 하면서 정부의 프로세스나 대기업의 프로세스의 답답함에 불만을 갖지만 일론 머스크는 그 수준이 아니라 계속해서 혁신을 하려고 하는 것이 대단하다고 생각한다. 전문가들조차도 이건 안되지 하는 부분을 바꾸라고 해서 성공하는 부분들을 보면 또 다양한 분야에서 "이건 당연한 거지"라고 하는 비효율이 있을 수 있겠다는 생각이 들었다.

> 
>
> 이 알고리즘은 때로 몇 가지 부수 사항을 수반한다. 예를 들면 다음과 같다.
>
>
> * 모든 기술 관리자는 실무 경험을 갖춰야 한다. 예컨대 소프트웨어 팀 관리자는 업무 시간의 20퍼센트 이상을 코딩에 할애해야 하고, 태양광 지붕 관리자는 일정 시간 이상 지붕에 올라가 설치 작업을 해봐야 한다. 그렇지 않으면 말을 타지 못하는 기병대장이나 칼을 쓸 줄 모르는 장군과 같아진다.
>
>
> * 동지애는 위험하다. 서로가 서로의 일에 이의를 제기하기 어렵게 만든다. 동료를 내다 버리고 싶지 않은 성향도 형성된다. 이는 경계하고 피해야 할 사항이다.
>
>
> * 틀려도 괜찮다. 다만 잘못된 것을 옳다고 우겨서는 안 된다.
>
>
> * 자신이 하고 싶지 않은 일을 팀원에게 부탁하지 마라.
>
>
> * 해결해야 할 문제가 있을 때마다 경영진을 만나려 하지 마라. 경영진 바로 아래 직급의 간부 또는 당신의 두 직급 위 관리자부터 만나서 해결책을 강구하라.
>
>
> * 직원을 채용할 때는 올바른 태도를 가진 사람을 찾아야 한다. 기술은 가르칠 수 있지만 태도를 바꾸려면 뇌 이식이 필요하다.
>
>
> * 광적인 긴박감이 우리의 운영원칙이다.
>
>
> * 유일한 규칙은 물리 법칙에 따른 것들뿐이다. 그 외의 모든 것은 권장 사항이다.
>
>

물론 항상 바른 판단을 할 수는 없기에 나중에 후회하는 결정들도 나오고 나도 읽으면서 이것도 없애라고 하는 건 말도 안 되지 같은 생각이 들었다.

> 
>
> "돌이켜보면 새크라멘토 센터의 전면적 폐쇄는 실수였어요." 2023년 3월, 머스크는 이렇게 인정했다. "데이터센터 전체에 걸쳐 불필요하게 중복된 부분이 있다는 보고를 받았거든요. 하지만 새크라멘토에 7만 개의 하드코딩된 레퍼런스를 두었다는 사실은 듣지 못했지요. 그 때문에 아직도 망가진 부분이 있을 정도예요."
>
>

트위터를 인수한 과정도 책을 보고 어떤 상황이었는지 알게 되었다. 저자인 월터 아이작슨도 얘기하지만, 충동적이 결정인 느낌이 있다.

> 
>
> 그가 썼다. "오늘 밤 제안서를 보내겠습니다." 다음은 제안서의 내용이다.
>
>
> 내가 트위터에 투자한 것은 언론의 자유를 위한 세계적인 플랫폼이 될 수 있는 잠재력이 있다고 믿었기 때문입니다. 언론의 자유는 민주주의가 제대로 작동하기 위한 사회적 필수요소라는 것이 나의 믿음입니다.
>
>
> 하지만 투자한 이후 트위터가 현재의 형태로는 번창할 수도 없고, 그러한 사회적 요구에 부응할 수도 없다는 것을 깨달았습니다. 트위터를 개인 기업으로 전환해야 할 필요성을 느낀 것도 그 때문입니다.
>
>

다양한 일이 있었지만, Twitter를 엑스라는 이상한 이름으로 바꾼 것이 개인적으로 열받는 부분인데 PayPal을 엑스로 바꾸려고 시도했던 얘기가 나와서 웃음이 나기도 했다.

> 
>
> 머스크는 엑스닷컴이 회사명이어야 하고 페이팔은 그저 회사에 속한 하나의 브랜드명이어야 한다고 주장했다. 심지어 결제 시스템의 이름을 엑스-페이팔(X-PayPal)로 바꾸려고도 했다. 많은 사람이 반대했고, 특히 레브친의 반발이 심했다. 페이팔은 돈을 받을 수 있도록 도와주는 좋은 친구 pal와 같은, 이미 신뢰도가 높은 브랜드명이 되었다는 이유에서였다. 포커스 그룹에 따르면, 반대로 엑스닷컴이라는 이름은 신뢰가 가지도 않고 점잖은 자리에서 거론하기도 꺼려지는 음침한 사이트를 떠올리게 했다.
>
>

트위터 인수 후의 일은 최근 일이라서 대부분 알고 있기는 하지만 내부 사람들과 인터뷰하면서 정리해 놓은 내용이라 더 자세한 상황을 알 수 있기도 했다. SpaceX나 Tesla에서도 초기에는 꽤 많은 문제가 있었겠지만, Twitter는 최근에 더 자세히 봐서 그런지 실제로도 많은 문제를 일으키고 있긴 하다.

> 
>
> 머스크는 공학적인 문제에 대해서는 직관적인 감각을 가지고 있지만, 인간의 감정을 다룰 때는 신경망에 장애가 발생한다. 그래서 그가 트위터를 인수한 것이 그렇게 문제가 되는 것이었다. 그는 트위터를 기술 회사로 생각했지만, 사실 트위터는 인간의 감정 및 관계를 기반으로 하는 광고매체였다.
>
>
> 
>
> 머스크는 언론의 자유에 기여하는 공론의 장을 만들고 싶다는 자신의 열망에 대해 진지하게 이야기하기 시작했다. 그는 '문명의 미래'가 위태로운 상태라고 말했다. "출산율은 급감하고 있고, 사상을 검열하는 경찰이 힘을 얻고 있어요." 그는 트위터가 특정 관점을 억압하는 바람에 국민의 절반으로부터 불신을 받게 되었다고 생각했다. 이를 되돌리려면 철저한 투명성이 필요했다. "현재 우리의 목표는 이전의 모든 잘못을 청산하고 깨끗한 백지 상태에서 앞으로 나아가는 것입니다. 내가 트위터 본사에서 잠을 자고 있는 데는 이유가 있는 겁니다. 지금이 코드 레드 상황이라는 뜻입니다."
>
>
> 
>
> 테슬라와 스페이스X의 최측근 부하들은 머스크의 나쁜 아이디어를 보류시키고 그가 원치 않는 정보를 조금씩 제공하는 방식으로 그를 상대하는 방법을 익힌 상태였지만, 트위터의 기존 직원들은 그런 방법에 대해 전혀 알지 못했다.
>
>

일론 머스크는 인류를 걱정하는 태도를 자주 보이는데 언론의 자유에 관심이 있지만 방향성에 대해서 좀 고민이 든다. 그래서 꽤 좋은 능력을 갖춘 콘텐츠 검열을 하고 균형을 맞추는 사람들도 나가곤 했다. 일론 머스크가 극우적 성향을 보이고 있진 않지만, 책에서도 뒤로 갈수록 우클릭하고 있다. 물론 언론의 자유라는 것은 한쪽만 열기는 어렵다. 좋은 말(?)을 많이 하게 하면 자연히 나쁜 말도 늘어나기 마련이고 좋은 말(?)만 올리게 한다는 건 반대로 나쁜 말만 올리게 한다는 것과 또 크게 다르지 않기도 하다.


책을 읽으면서 내내 불편했던 것은 일론 머스크가 각성 바이러스 부르는 [Woke](https://en.wikipedia.org/wiki/Woke)이다.(원문을 찾아보지 않았지만, 정황상 Woke를 의미한다고 생각했다) Woke는 인종차별, 성차별 등의 사회적 불평등에 대한 인식을 개선하기 위한 용어이고 움직임인데 우리나라로 말하면 깨인 유리창이나 남녀 차별에 대한 부분이라고 할 수 있고(참고로 말하자면 나는 Woke를 지지한다) 어떤 이유에서인지 일론 머스크는 이런 부분이 문제가 오히려 많다고 생각하고 트위터에서도 기존에 너무 심한 차별 글을 올려서 퇴출당한 사람을 복구하는 등의 행동을 했다.(대표적으로 ye) 이런 부분은 동의할 수 없기에 마음이 불편했고 책에도 나오지만 언론의 자유가 중요하다고 하면서 정작 자신을 비판한 기자들은 차단한다거나 스페이스를 닫아버리는 건 이중적이라고 느낄 수밖에 없다.(책에도 나온다.)

> 
>
> 머스크에 대한 핵심적인 질문, 즉 그를 성공으로 이끈 '올인' 방식의 추진력과 그의 나쁜 행동방식이 분리될 수 있는지 여부를 놓고도 고민한다. "나는 그를 스티브 잡스와 같은 범주의 사람이라고 여기게 됐는데요. 그러니까 어떤 사람들은 그냥 개자식이지만, 그들은 또한 너무 대단한 것을 성취해서 그냥 물러앉아 '그게 패키지인 것 같아'라고 말할 수밖에 없게 되는 것과 같은 거죠." 내가 머스크가 이뤄낸 것이 그의 행동방식에 대한 변명이 될 수 있다고 생각하는 것이냐고 묻자, 마크스는 이렇게 답했다. "만약 이런 종류의 성취를 위해 세상 사람들이 지불해야 하는 대가가 진짜 개자식을 리더로 삼아야 하는 것이라면, 그것은 그럴 만한 가치가 있을 수도 있겠지요. 어쨌든 나는 그렇게 생각하게 되었어요." 그러고는 잠시 생각에 잠겼다가 덧붙였다. "하지만 나는 그렇게 되고 싶지는 않아요."
>
>

Tesla의 임시 CEO로 잠시 영입되었던 마크스의 말에 동의한다.


# 웹개발 관련

- [**Maglev - V8’s Fastest Optimizing JIT**](https://v8.dev/blog/maglev) : 2021년까지 V8의 실행 계층은 인터프리터인 Ignition과 최적화 컴파일러인 TurboFan이 있어서 모든 JavaScript 코드를 Ignition 바이트 코드로 먼저 컴파일한 후 실행한다. 실행하면서 동작 방식을 추적해서 메타데이터와 바이트 코드를 최적화 컴파일러에 제공해서 인터프리터보다 훨씬 빠르게 실행되는 고성능 머신 코드를 생성한다. Ignition과 TurboFan 간의 속도 차이가 크기 때문에 2021년 Sparkplug라는 JIT를 도입해서 성능을 개선했지만, 한계가 있었기에 훨씬 빠른 코드를 생성할 수 있도록 최적화 JIT Maglev를 도입했다. Maglev는 Sparkplug와 TurboFan 사이의 간극을 메우기 위해 도입되었다.(영어)
- [**Introducing StyleX**](https://stylexjs.com/blog/introducing-stylex/) : Meta에서 표현력, 결정성, 안정성, 확장성을 갖춘 스타일링 시스템인 [StyleX](https://stylexjs.com/)를 오픈소스로 공개했다. StyleX는 CSS-in-JS의 개발자 경험을 컴파일 도구를 사용해서 CSS 성능과 확장성을 지원할 수 있도록 설계되었다. 그래서 표현형 CSS 하위집합을 지원하며 유틸리티 클래스나 라이브러리를 학습할 필요 없이 스타일을 원자적 CSS 클래스 명으로 변환해서 최적화하며 파일/컴포넌트를 넘어서 스타일을 합칠 수 있고 타입을 지원해서 프로퍼티와 값을 세밀하게 제어할 수 있다. StyleX는 컴파일 타임과 런타임 모두에서 빠르게 설계되었다. 이 StyleX는 Facebook.com을 React로 다시 구축할 때 스타일에 더 나은 무언가가 필요하다는 것을 깨닫고 만들기 시작했고 Meta에서 Facebook, WatsApp, Instagram, Threads 등에서 수년간 사용하면서 발전시켜 오다가 이제 오픈소스로 공개한 것이다.(영어)
- [**PandaCSS와 함께 CSS-in-JS의 미래로**](https://tech.wonderwall.kr/articles/pandacss/) : 기존에 styled component를 사용하고 있었지만, PandaCSS로 바꾸게 된 배경을 설명한다. styled component를 잘 사용하고 있었지만 사용하지 않는 스타일이 번들에 포함되고 동적 기능으로 인한 성능 저하 문제가 있었고 디자인 시스템을 직접 만들기는 어려웠다고 한다. PandaCSS는 디자이너와 공유하는 토큰을 쉽게 정의할 수 있고 컴포넌트 레시피로 재사용이 쉽고 정적인 CSS를 지원해서 프레임워크를 타지 않는 장점이 있다. 한편 빌드타임에 코드를 생성하므로 토큰/레시피를 수정하면 다시 생성해 주어야 하고 다양한 방법을 지원하므로 팀에서 사용하려면 표준을 정하는 것이 좋다고 한다.(한국어)
- [**v0 is now open for everyone.**](https://twitter.com/vercel/status/1735719381739454730) : Vercel이 만든 프롬프트를 입력해서 UI 컴포넌트를 생성해 주는 서비스인 [v0](https://v0.dev/)이 이제 모두가 사용할 수 있도록 열렸다.(영어)
- [**Introducing Learn Performance**](https://web.dev/blog/introducing-learn-performance?hl=en) : web.dev에서 웹 성능에 관심이 있는 사용자를 대상으로 따른 웹페이지를 만든다는 것의 기술적 세부 사항을 설명하는 학습 코스인 [Learn Performance](https://web.dev/learn/performance?hl=en)의 초기 버전을 공개했다.(영어)

# 그 밖의 개발 관련

- [**Merge vs. Rebase vs. Squash**](https://gist.github.com/mitchellh/319019b1b8aac9110fcfb1862e0c97fb) : HashiCorp의 Mitchell Hashimoto가 Git에서 Merge, Rebase, Squash에 관한 질문을 많이 받아서 자기 생각을 정리한 글이다. 셋 중의 하나가 정답이라고 말하는 건 틀렸다고 생각하고 각 전략이 필요한 상황이 있다고 생각한다. Merge와 Merge 커밋이 히스토리를 가장 잘 표현한다고 생각하기에 Merge를 선호하며 모든 커밋이 빌드할 수 있으면서 커밋이 많을수록 `bisect`가 좋아지기에 하나의 커밋에 변경이 많은 것은 싫어하고 한 커밋은 +50/-50 정도가 가장 좋다고 생각한다. 하지만 이렇게 하려면 모두가 이 규칙을 잘 따라야 하는데 보통 쉽지 않기에 OSS에서 PR에 WIP 커밋이 많지만 대부분 작은 차이이고 PR이 하나의 목표만 있다면 Squash를 사용하는데 이때도 Git/GitHub의 기본 스쿼시 메시지가 아니라 다시 작성하는 편이다. 변경 사항이 많은 WIP가 많은 경우 rebase를 통해 적당히 스쿼시하고 순서도 조정해서 관리한다. 그리고 50개 이상의 커밋을 대규모로 인터랙티브 리베이스를 할 때 GUI가 편하다는 걸 깨달아서 Tower를 사용하고 있다.(영어)
- [**Java의 미래, Virtual Thread**](https://techblog.woowahan.com/15398/) : 우아한형제들에서 Virtual Thread(Project Loom)이 JDK 19부터 얼리 엑세스로 포함되고 JDK21에서 정식 기능이 되면서 스터디한 결과를 공유했다. 스레드를 사용할 때 더 많은 요청을 처리하면서 컨텍스트 스위칭 비용을 줄이기 위해 훨씬 가벼운 Virtual Thread의 구조와 동작 원리를 보여주고 다른 델인 Thread, Kotlin Coroutine, Reative와 비교해서 성능이 얼마나 차이 나는지도 보여준다.(한국어)
- [**Something's been bothering me about TDD**](https://www.linkedin.com/posts/olaf-thielke_systemdesign-softwareengineering-softwarearchitecture-activity-7137285276925628416-fYOH/) : [TDD만으로 좋은 시스템 설계를 할 수 있다고 생각하지 않는다는 글](https://www.linkedin.com/posts/olaf-thielke_systemdesign-softwareengineering-softwarearchitecture-activity-7137285276925628416-fYOH/)에 TDD를 만든 Kent Beck이 직접 "TDD는 디자인 필요성을 대체하지 않는다"고 설명하며 TDD가 제공하는 이점은 인터페이스 디자인에 대한 즉각적인 피드백과 인터페이스 디자인 결정과 구현 디자인 결정의 분리라고 [댓글](https://www.linkedin.com/feed/update/urn:li:activity:7137285276925628416?commentUrn=urn%3Ali%3Acomment%3A(activity%3A7137285276925628416%2C7137484009474854912)&dashCommentUrn=urn%3Ali%3Afsd_comment%3A(7137484009474854912%2Curn%3Ali%3Aactivity%3A7137285276925628416))을 달았다.(영어)
- [**SQLite JSONB has landed**](https://sqlite.org/forum/forumpost/fa6f64e3dc1a5d97) : [SQlite](https://www.sqlite.org/index.html)에 JSONB가 도입되었다.(영어)

# 인프라 관련

- [**Upgrading GitHub.com to MySQL 8.0**](https://github.blog/2023-12-07-upgrading-github-com-to-mysql-8-0/) : GitHub.com이 성장하면서 단일 MySQL에서 아키텍처를 발전해 오고 있었는데 1,200개 이상의 MySQL 호스트를 8.0으로 업그레이드한 과정이다.(영어)
    - SLO에 영향을 주지 않으면서 업그레이드하기 위해 계획, 테스트, 업그레이드에 1년이 넘게 걸렸다.
    - MySQL 5.7의 수명이 거의 종료됨에 따라 8.0 으로 업그레이드 해야 했다.
    - GitHub의 MySQL 인프라 구성
        - 1,200개 이상의 호스트로 구성되어 있고 Azure와 베어 메탈 호스트의 조합
        - 300TB 이상의 데이터를 저장하고 50개 이상의 데이터베이스 클러스터에서 초당 5,500만 건의 쿼리를 처리
        - 각 클러스터는 primary와 replicas를 이용한 고가용성 구성
        - 수평/수직 샤딩을 모두 활용하여 데이터가 파티셔닝 되어 있음
        - 대규모 도메인 영역을 위해 수평 샤딩 된 Vitess 클러스터도 있음
    - SLO/SLA를 준수하면서 업그레이드해야 하지만 모든 장애를 미리 고려할 수는 없으므로 중단없이 MySQL 5.7로 롤백할 수 있어야 한다. 다양한 워크로드가 있으므로 클러스터를 원자단위로 업그레이드하고 해야하고 혼합 버전을 오랫동안 운영해야 했다.
    - 2022년 7월부터 업그레이드 준비를 시작했다.
    - MySQL 8.0의 설정값을 결정하기 위해 벤치마크했고 두 버전을 운영해야 했기에 도구와 자동화가 두 버전을 모두 처리할 수 있어야 했다.
    - 모든 애플리케이션의 CI에 MySQL 8.0을 추가해서 CI에서 5.7과 8.0을 같이 실행했다.
    - 업그레이드 전략
        - replicas를 먼저 업그레이드하고 트래픽을 받도록 한 뒤 모니터링하면서 교체해 나가고 5.7은 롤백을 위해 띄워두었지만, 트래픽은 안 가게 함
        - Replica 토폴로지를 조정해서 8.0 primary가 5.7 primary를 복제하도록 구성하고 8.0 replicas 아래에는 5.7 세트와 8.0 세트로 구성해서 8.0만 트래픽을 처리하도록 함
        - Primary를 직접 업그레이드하지 않고 페일오버를 통해 MySQL 8.0 Replica가 Primary로 승격되도록 함
        - 백업이나 비 프로덕션을 위한 MySQL로 모두 업그레이드.
        - 롤백할 필요가 없다는 걸 확인 후 5.7 서버를 모두 제거
- [**Why We Created the Argo Project**](https://akuity.io/blog/why-we-created-the-argo-project/) : Argo 프로젝트를 Jesse Suen, Alexander Matyushentsev와 시작했던 Hong Wang이 처음에 왜 Argo 프로젝트를 시작했는지를 정리했다.(영어)
    - 셋은 Applatix라는 스타트업에서 만났는데 2016년 Applatix에서 DevOps 솔루션을 구축해서 컨테이너와 퍼블릭 클라우드를 통해 Jenkins보다 나음 경험을 제공하고자 했다.
    - Kubernetes를 알게 되고 Kuberntes 네이티브로 만들어야 한다는 것을 깨닫고는 Argo Workflows를 시작하게 되었다.
    - 2017년에는 Kubernetes에 CRD가 나오면서 이 CRD를 사용하기로 결정하고 Argo Workflows 2.0을 재작성하게 된다.
    - Intuit가 Kubernetes로 이전하는 작업을 원활하게 수행할 팀을 찾다가 Applatix를 인수하기로 결정했고 Argo Workflows 팀은 하루 빨리 대규모로 테스트하고 싶어졌다.
    - 하지만 바로 Intuit에 Kubernetes 클러스터와 네임스페이스가 너무 많았지만 이를 관리할 도구는 없다는 걸 깨달았다.
    - 처음부터 멀티 클러스터 지원이 필요했고 더 쉽게 오케스트레이션 하려면 단일 컨트롤 플레인이 필요했기에 Argo CD를 만들게 되었고 플랫폼 팀과 애플리케이션 팀이 협업해서 역량을 강화하기 위해 GUI 중심으로 만들기로 결정하게 된다.
    - Intuit에서 점점 Kubernetes로 운영하면서 장애의 50%정도가 배포때 발생하고 복구하는게 걸리는 시간(MTTR)을 단축하는데 실패했다는 걸 깨닫게 된다.
    - 이 문제 해결을 위해 블루/그린과 카나리 배포 전략을 소개하게 하고 Argo Rollouts를 만들게 되었다.
- [**A deep dive into CPU requests and limits in Kubernetes**](https://www.datadoghq.com/blog/kubernetes-cpu-requests-limits/) : Kubernetes에서 CPU 스케쥴링은 기본적으로 [CFS(Completely Fair Scheduler)](https://www.kernel.org/doc/Documentation/scheduler/sched-design-CFS.txt)에 의해서 이루어지고 1.10에서 Beta로 도입되고 1.26에서 Stable이 된 CPU Manager에서 기본 정책인 `none`을 사용하면 CFS가 CPU를 스케쥴링한다. CPU Manager의 정책을 `static`으로 설정하면 Linux CPUSets를 사용하게 된다. 이때 Guaranteed QoS 클래스에 할당된 Pod은 요청한 CPU 코어에 독점적인 엑세스를 얻게 되고 해당 코어는 공유 풀에서 제거된다. 이 독점적 코어 사용은 다른 Pod에만 적용되고 시스템 데몬에는 적용되지 않으므로 시스템 데몬에도 따로 CPU를 할당해야 한다. 그래서 `static` 정책은 컨텍스트 전환에 민감한 워크로드에 유용하지만 다른 컨테이너에 영향을 줄 수 있다.(영어)
- [**Atlantis Hardening and Review Fatigue**](https://doordash.engineering/2023/12/05/atlantis-hardening-and-review-fatigue/) : DoorDash에서 Terraform 코드를 관리하기 위해서 [Atlantis](https://www.runatlantis.io/)를 사용해서 자동화한 과정이다. Atlantis에서 Pull Request 승인을 받지 않으면 `terraform apply`를 할 수 없는데 실제로는 악의적 코드를 가져올 수도 있고 승인 요건을 우회할 수도 있고 Atlantis 설정으로 허용한 프로바이더를 지정해서 관리할 수 있다. 그리고 리뷰 피로감을 줄이기 위해 Conftest와 OPA를 사용해서 일부 변경 사항은 승인 없이 할 수 있도록 하고 사람이 봐야 하는 변경만 승인이 필요하게 할 수 있다.(영어)
- [**Kubernetes V1.27 : Safeguarding Pod with MemoryThrottlingFactor**](https://faun.pub/kubernetes-v1-27-safeguarding-pod-with-memorythrottlingfactor-cfbccde10de) : Kubernetes 1.27에 도입된 메모리 스로틀링 기능을 설명한다. 메모리 request와 limit으로 메모리를 제한하고 관리할 수 있지만 1.27은 request와 limit 간의 차이를 기본 스로틀링 계수(기본값은 0.9)로 계산해서 `memory.high`를 설정한다. `memory.high`에 가까워지면 메모리 스로틀링이 동작해서 메모리를 관리한다. 정확히 스로틀링이 동작하는 방식도 궁금한데 그 부분까지는 이글에는 나와 있지 않다.(영어)
- [**Set and scale service level objectives in Grafana Cloud: Introducing Grafana SLO**](https://grafana.com/blog/2023/11/15/set-and-scale-service-level-objectives-in-grafana-cloud-introducing-grafana-slo/) : Grafana Labs 내부에서 SLA에 맞게 알림을 설정했지만, 너무 많은 오경보가 생겼고 이를 개선한 과정을 통해 [Grafana SLO](https://grafana.com/products/cloud/slo/)를 Grafana Cloud에 출시했다.(오픈소스 제품은 아님) SLO를 통해 UI에서 SLI를 설정하고 관리할 수 있다.(영어)
- [**Open source forkers stick an OpenBao in the oven**](https://www.theregister.com/2023/12/08/hashicorp_openbao_fork/) : OpenTofu 운영자 중 한 명이면서 DevOps 관련 스타트업인 Scalr의 공동창업자이자 CEO인 Sebastian Stadil가 HashiCorp Vault의 포크인 [OpenBao 프로젝트를 공개](https://wiki.lfedge.org/display/OH/OpenBao+%28Hashicorp+Vault+Fork+effort%29+FAQ)했다. Terraform의 라이센스 변경으로 OpenTofu가 생겼듯이 Vault도 같은 이유로 포크해서 OpenBao를 만든 것이다. OpenBao는 Linux 재단의 인큐베이팅을 받고 있고 IBM 개발자들이 엣지 컴퓨팅 이니셔티브인 LF Edge를 통해 프로젝트를 주도하고 있으면 아직 IBM에 공식 승인이 있었던 것은 아니다.(영어)

# 볼만한 링크

- [**Why We’re Dropping Basecamp**](https://blogs.library.duke.edu/blog/2023/11/30/why-were-dropping-basecamp/) : Duke 대학이 10년 동안 프로젝트 관리 플랫폼인 [Basecamp](https://basecamp.com/)를 사용해 왔지만, 현재 사용 수준과 Basecamp의 모회사인 [37signals](https://37signals.com/) 경영진의 폐해로 인해 올해 12월 종료 후 구독을 갱신하지 않을 거라고 밝혔다. Basecamp는 2여 년 전 고객의 이름으로 인종차별 했던 게 알려지면서 쟁점이 되었지만 37signals는 내부 토론을 차단했는데 Duke 대학에서도 당시에 논의했지만 계속 Basecamp를 사용하기로 했다. 올여름 내부에서 37signals의 CTO인 [DHH가 대학 입학 시 인종에 대해 고려하지 않는 대법원판결을 축하는 글](https://world.hey.com/dhh/the-waning-days-of-dei-s-dominance-9a5b656c)과 [Meta에선 정치를 하지 않는다는 글](https://world.hey.com/dhh/meta-goes-no-politics-at-work-and-nobody-cares-d6409209)을 통해 다시 Basecamp 사용에 대한 검토를 다시 하게 되었다고 한다. DHH는 다양성, 형평성, 포용성(Diversity, Equity, and Inclusion, DEI)를 확고히 자리 잡은 운동이라고 하며 이후 시위를 폭동이라고 하며 사실을 왜곡하고 있고 그가 원하는 글을 쓸 수 있지만 Duke 대학도 Duke 대학의 의견이 있고 선택할 수 있다고 얘기한다. Duke 대학은 도서관이기 때문에 인류가 만들 수 있는 최악이 무엇인지 알고 있고 직장 관행이나 문화가 초래한 해약도 알고 있으며 이는 본받아야 할 모델이 아니라고 얘기한다.(영어)
- [**Introducing Gemini: our largest and most capable AI model**](https://blog.google/technology/ai/google-gemini-ai/) : Google DeepMind에서 새 대규모 언어 모델인 Gemini를 발표했다. 이 모델은 가장 성능이 뛰어난 Gemini Ultra, 다양한 업무에서 확장할 수 있는 Gemini Pro, 온디바이스 작업에 효율적인 Gemini Nano로 나뉘어져 있다.(영어)
- [**Audiobox: Generating audio from voice and natural language prompts**](https://ai.meta.com/blog/audiobox-generating-audio-voice-natural-language-prompts/) : 원하는 음성이나 음향 효과에 대한 프롬프트를 입력해서 소리를 생성할 수 있는 모델인 Audiobox를 Meta에서 공개했다.(영어)
- [**트위치 한국 서비스 철수에 담긴 경고: 콘텐츠 다양성 훼손과 인터넷의 파편화, 발신자종량제 상호접속고시 폐지로 망중립성 복원해야**](https://www.opennet.or.kr/24225) : Twitch가 전 세계와 비교해 10배가 넘는 '망 사용료'를 이유로 한국에서 사업 철수함에 따라 망 중립성 훼손에 관해서 오픈넷이 낸 보도자료이다. 국내에서 엄청난 인터넷 접속료를 감당할 수 있는 대형 플랫폼만 살아남을 수 있게 되어 콘텐츠 다양성이 훼손될 것이고 과거 논의할 기회가 있었지만, 해외 플랫폼과 비교해 역차별론으로 흘러가면서 제대로 논의할 기회를 얻지 못했다.(한국어)
- [**신입 프론트엔드 개발자가 공유하는 소소한 취준팁**](https://nvrtmd.github.io/%EC%8B%A0%EC%9E%85-%ED%94%84%EB%A1%A0%ED%8A%B8%EC%97%94%EB%93%9C-%EA%B0%9C%EB%B0%9C%EC%9E%90%EA%B0%80-%EA%B3%B5%EC%9C%A0%ED%95%98%EB%8A%94-%EC%86%8C%EC%86%8C%ED%95%9C-%EC%B7%A8%EC%A4%80%ED%8C%81/) : 비전공자로 2년 정도 교육과 프로젝트, 해커톤, 인턴쉽 등의 경험을 쌓은 뒤에 본격적인 취업 준비를 하면서 300회가 넘게 지원하면서 취업까지 성공한 뒤 그동안 경험을 정리한 글이다. 이력서는 주변 사람들에게 피드백 받고 읽는 사람 입장에서 고민해서 작성하고 과제 할 때는 해당 부분을 질문했을 때 어떻게 대답할지를 고민하면서 작성했다고 한다. 면접은 많이 볼수록 경험이 쌓이니까 가능한 한 많이 지원해 보라고 하고 있고 면접 장소에 좀 일찍 가서 컨디션이랑 복장 관리를 한 뒤에 면접하라는 팁도 제공하고 있다. 오랫동안 맘고생도 심했겠지만, 고민을 많이 하면서 준비했다는 게 느껴지는 글이다.(한국어)
- [**CIA가 CTO를 신설한 이유는**](https://brunch.co.kr/@capitaledge/60) : 미국 바이든 정부의 CIA 국장인 윌리엄 번스는 사상 처음으로 CTO 직책을 신설하고 낸드 물찬다니(Nand Mulchandani)를 CTO로 임명했다. 낸드 물찬다니는 실리콘 밸리에서 네 개의 기업을 창업하고 매각한 연쇄 창업가로 국방부의 인공지능센터에 부임한 뒤 CIA의 CTO까지 오르게 되었다. 백악관의 CTO는 오바마 정부에서 처음 신설하고 트럼프 정부에서 꽃을 피웠는데 이번에 CTO를 뽑은 CIA 국장은 이제 기술 자체가 경쟁과 분쟁의 영역이 되고 있어서 국가 안보에 영향을 미치게 되었다고 얘기했다.(한국어)

# IT 업계 뉴스

- [**Mitchell reflects as he departs HashiCorp**](https://www.hashicorp.com/blog/mitchell-reflects-as-he-departs-hashicorp) : HahiCorp의 공동창업자인 [Mitchell Hashimoto](https://twitter.com/mitchellh)가 11년 동안 일한 HashiCorp를 떠나기로 했다. 그동안 CEO에서 물러나고 리더십 팀과 이사회에서도 물러나는 등 준비를 해오다가 최근 아이도 생겼고 새로운 도전을 하기에 적절한 시기라고 판단해서 떠나기로 했다고 한다. 아직 어떤 도전을 할지는 정확히 밝히지 않았다.(영어)
- [**트위치, 6년만에 국내 철수... 내년 2월27일 서비스 접는다**](https://www.news1.kr/articles/5252845) : 게임에서 많이 사용하는 스트리밍 플랫폼 Twitch가 공식적으로 내년 2월 27일까지만 운영하고 국내 서비스를 종료하기로 했다. Twitch에서 밝힌 이유로는 망 사용료가 너무 비싸서 운영비용이 많이 들기 때문이라고 했다.(한국어)
- [**카카오, 신임 단독대표로 정신아 카카오벤처스 대표 내정**](https://www.besuccess.com/%ec%b9%b4%ec%b9%b4%ec%98%a4-%ec%8b%a0%ec%9e%84-%eb%8b%a8%eb%8f%85%eb%8c%80%ed%91%9c%eb%a1%9c-%ec%a0%95%ec%8b%a0%ec%95%84-%ec%b9%b4%ec%b9%b4%ec%98%a4%eb%b2%a4%ec%b2%98%ec%8a%a4-%eb%8c%80%ed%91%9c/) : 카카오가 카카오벤처스 정신아 대표를 새로운 대표로 내정했다.(한국어)
- [**Ghostty**](https://mitchellh.com/ghostty) : Mitchell Hashimotor가 만드는 터미널 에뮬레이터.
- [**Cody**](https://sourcegraph.com/cody) : [Sourcegraph에서 만든 AI 코딩 어시스턴트](https://sourcegraph.com/blog/cody-is-generally-available)로 VS Code, JetBrains, Neovim을 지원한다. 2024년 2월까지는 무료로 사용할 수 있다.
- [**GitHub Unwrapped**](https://githubunwrapped.com/) : React로 비디오를 만드는 [Remotion 프로젝트](https://githubunwrapped.com/)에서 2023년 GitHub의 활동으로 비디오를 만들어 주는 사이트를 공개했다.
- [**MRR Counter with linear()**](https://codepen.io/jh3y/pen/gOqNrxo) : CSS `linear()` easing 함수로 숫자가 돌아가면서 표시되는 애니메이션을 보여주는 예제 코드
- [**markdown-it-github-alerts**](https://github.com/antfu/markdown-it-github-alerts) : GitHubdl 마크다운 `blockquote`에서 Note, Tip, Caution 등을 표시해 주는 기능을 구현한 markdown-it 플러그인
- [**System Design 101**](https://github.com/ByteByteGoHq/system-design-101) : "가상 면접 사례로 배우는 대규모 시스템 설계 기초" 1, 2권의 저자인 Alex Xu가 복잡한 시스템을 시작 자료를 이용해서 쉽게 설명하는 저장소를 공개했다.
- [**Vault Benchmark**](https://github.com/hashicorp/vault-benchmark) : Vault가 어느 정도의 트래픽을 안정적으로 받아주는지 테스트할 수 있는 벤치마크 도구로 HashiCorp가 만들었다.

# 버전 업데이트

- [**Django**](https://www.djangoproject.com/) **v5.0** : Python 웹 프레임워크, [릴리스 공지](https://www.djangoproject.com/weblog/2023/dec/04/django-50-released/)
- [**SvelteKit**](https://kit.svelte.dev/) **v2.0** : Svelte의 앱 개발 프레임워크, [릴리스 공지](https://svelte.dev/blog/sveltekit-2)
    - Vite 5 지원
    - 24년에 출시될 Svelte 5를 도입하려면 SvelteKit 2로 업그레이드 권장
- [**astro**](https://astro.build/) **v4.0** : JavaScript 웹 프레임워크, [릴리스 공지](https://astro.build/blog/astro-4/)
    - Dev Toolbar 도입
    - 국제화(i18n) 라우팅
    - 실험적 증분 콘텐츠 캐시
    - View Transition API 지원
- [**Vitest**](https://vitest.dev/) **v1.0.0** : Vite 유닛 테스트 프레임워크, [릴리스 공지](https://github.com/vitest-dev/vitest/releases/tag/v1.0.0)
- [**Kubernetes**](https://kubernetes.io/) **v1.29 Mandala** : 컨테이너 오케스트레이션 도구, [릴리스 공지](https://kubernetes.io/blog/2023/12/13/kubernetes-v1-29-release/)
    - PV와 PVC에 ReadWriteOncePod 모드가 추가되어 하나의 파드만 PVC를 사용할 수 있도록 할 수 있다.
    - CSI 드라이버에서 스토리지에 접근할 때 자격증명을 할 수 있는 Node volume expansion Secret 기능이 GA가 되었다.
    - KMS v2가 GA가 되었다.
- [**Remix**](https://remix.run/) **v2.4.0** : 풀스택 웹 프레임워크, [릴리스 공지](https://github.com/remix-run/remix/releases/tag/remix%402.4.0)
- [**Deno**](https://deno.land/) **v1.39.0** : TypeScript 런타임, [릴리스 공지](https://deno.com/blog/v1.39)
    - 성능 문제로 제거했던 WebGPU API 재 도입
    - `deno coverage` 명령어에 `summary`와 `html` 리포터 추가
- [**Turborepo**](https://turborepo.org/) **v1.11.0** : JavaScript/TypeScript 빌드 시스템, [릴리스 공지](https://turbo.build/blog/turbo-1-11-0)
    - Go 대신 Rust로 작성한 새로운 기반 도입
- [**k6**](https://k6.io/) **v0.48.0** : 부하 테스트 도구, [릴리스 공지](https://grafana.com/blog/2023/12/14/new-in-grafana-k6-the-latest-oss-features-in-v0.48.0-and-user-defined-project-limits-in-grafana-cloud-k6/)
- [**pgAdmin**](https://www.pgadmin.org/) **4 v8.1** : PostgreSQL 클라이언트 도구, [릴리스 공지](https://www.postgresql.org/about/news/pgadmin-4-v81-released-2766/)
- [**alpine Linux**](https://alpinelinux.org/) **3.19.0** : Linux 배포판, [릴리스 공지](https://alpinelinux.org/posts/Alpine-3.19.0-released.html)
- [**ESLint**](http://eslint.org/) **v8.56.0** : JavaScript 코드 분석 도구, [릴리스 공지](https://eslint.org/blog/2023/12/eslint-v8.56.0-released/)
- [**Nomad**](https://www.nomadproject.io/) **v1.7** : 워크로드 오케스트레이터, [릴리스 공지](https://www.hashicorp.com/blog/nomad-1-7-improves-vault-and-consul-integrations-adds-numa-support)
- [**Electron**](http://electron.atom.io/) **v28.0.0** : 크로스 플랫폼 데스크톱 애플리케이션 플랫폼, [릴리스 공지](https://www.electronjs.org/blog/electron-28-0)
- [**flow**](https://flow.org/) **v0.224.0** : JavaScript 정적 타입 체커, [릴리스 공지](https://github.com/facebook/flow/releases/tag/v0.224.0)
- [**Safari**](https://www.apple.com/kr/safari/) **17.2** : 웹브라우저, [릴리스 공지](https://webkit.org/blog/14787/webkit-features-in-safari-17-2/)
    - 루트 `<html>` 요소의 CSS `cap`, `ex`, `ic`, `ch`와 같은 `rcap`, `rex`, `ric`, `rch` 단위 추가
    - CSS `linear()` 함수 지원
    - CSS Math 함수인 `rem()`, `mod()`, `round()` 지원
    - 반응형 이미지의 프리로딩 지원
- [**RedwoodJS**](https://redwoodjs.com/) **v6.5.0** : 풀스택 웹프레임워크, [릴리스 공지](https://github.com/redwoodjs/redwood/releases/tag/v6.5.0)
- [**Cue**](https://cuelang.org/) **v0.7.0** : 구성 언어, [릴리스 공지](https://github.com/cue-lang/cue/releases/tag/v0.7.0)
- [**Zed**](https://zed.dev/) **v0.116.1** : 코드 에디터, [릴리스 공지](https://zed.dev/releases/stable#zed-0.116.1)
- [**React Native**](http://facebook.github.io/react-native/) **v0.73.0** : React를 이용한 모바일 앱 개발 프레임워크, [릴리스 공지](https://reactnative.dev/blog/2023/12/06/0.73-debugging-improvements-stable-symlinks)
    - Android 14 지원
- [**Spring Tools**](https://spring.io/tools4) **4.21.0** : Spring 코딩 환경을 위한 도구, [릴리스 공지](https://spring.io/blog/2023/12/06/spring-tools-4-21-0-released)
- [**Storybook**](https://storybook.js.org/) **v7.6.0** : React, Vue3, Angular UI 컴포넌트 개발 도구, [릴리스 공지](https://storybook.js.org/blog/storybook-7-6/)
- [**Fresh**](https://fresh.deno.dev/) **v1.6** : Deno 풀스택 웹 프레이워크, [릴리스 공지](https://deno.com/blog/fresh-1.6)
- [**Hono**](https://hono.dev/) **v3.11.0** : 엣지용 웹 프레임워크, [릴리스 공지](https://github.com/honojs/hono/releases/tag/v3.11.0)
- [**Open Policy Agent**](https://www.openpolicyagent.org/) **v0.59.0** : 클라우드 네이티브 환경의 정책 엔진, [릴리스 공지](https://github.com/open-policy-agent/opa/releases/tag/v0.59.0)
    - OPA 1.0 릴리스를 대비하기 위해 기존 정책을 준비하기 위한 릴리스
    - OPA 1.0에서는 Rego 언어에 호환 안되는 변경사항이 있으므로 `-rego-v1` 플래그를 통해 문법을 확인할 수 있다.
- [**Docker Desktop**](https://www.docker.com/products/docker-desktop) **v4.26** : 데스크톱용 Docker 애플리케이션, [릴리스 공지](https://www.docker.com/blog/docker-desktop-4-26/)
- [**Node.js**](http://nodejs.org/) **v21.4.0 (Current)** : 자바스크립트 런타임, [릴리스 공지](https://nodejs.org/en/blog/release/v21.4.0)
- [**Flux**](https://fluxcd.io/) **v2.2.0** : Kubernetes 배포 도구, [릴리스 공지](https://github.com/fluxcd/flux2/releases/tag/v2.2.0)

지난 12월 1일 [공개SW 페스티벌 2023](https://ossfestival.kr/)에서 "오픈소스에 기여할 때 알면 좋을 개발 프로세스"라는 제목으로 발표했다. 공개SW 페스티벌은 3년전인 2020년에도 ["오픈소스 뒤에 메인테이너 있어요"](https://blog.outsider.ne.kr/1517)라는 제목으로 발표했었다.


이번에 발표 요청을 받고 고민을 많이 했다. 올해는 회사 일도 바빴고(핑계지만...) 집에 와서는 좀 쉬기 바빴던 한해라서 오픈소스 활동도, 사이드 프로젝트도 거의 못 했기 때문에 발표할 주제가 마땅치 않았고 이전에 발표한 주제를 또 하고 싶지는 않았다. 이런저런 고민을 하면서 김태곤 님한테도 연락받고 오랜만에 보는 분들도 꽤 오시는 것 같아서 사람들도 볼 겸 발표를 먼저 수락했다.(이후 이날 팀 회의가 있는 날일걸 깨달았지만 어쩔 수 없었다)


발표 수락을 하고 난 바로 [미국으로 날아갔다](https://blog.outsider.ne.kr/1695). 시차 적응도 하고 이것저것 하느라고 정신없이 보내다가 발표 제목을 내야 하는 날이 임박해서야 고민을 시작했다.


정확히는 몰랐지만, 참석자는 오픈소스를 잘 모르는 초심자들이 많을 것 같았기에 쉬운 주제로 해야 할 것 같았고 뭘 하면 좋을까 고민하다가 프로세스 생각이 났다. CI나 CLA처럼 사소하고 별거 아닌 내용이긴 하지만 또 전혀 모르면 처음에는 이해하기 어려운 프로세스를 정리해서 한번 설명하면 가볍게 들으면서 한번 듣고 나면 좀 도움이 되지 않을까 싶어서 말할 내용을 몇 가지 정리해 보니 발표할 수 있을 것 같아서 주제를 요약해서 보냈다.


발표 자료를 만들면서는 역시 어려웠다. 항상 그렇듯이 발표 스토리가 꽤 잡혀있지 않으면 만들면서 스토리 라인 잡느라고 고생하는 편인데 이번에도 역시 그랬다. 그리고 사실 내용이 너무 쉬운 내용이라 이걸 발표하는 게 맞나 하는 생각을 장표 한 장 만들 때마다 생각했다. 그래도 정리하다 보니 발표 분량은 나왔고 현장에서 발표했는데 이번엔 연습을 많이는 못 해서 말을 좀 절었던 것 같다.


전체 사람들의 느낌은 모르지만, 발표 끝나고 발표 잘 들었다고 질문하시는 분들이 있어서 그래도 몇몇 분에게는 도움이 되었구나 하고 안심했다.


이번에 특히 흥미로웠던 것은 마지막 세션이라 다른 발표자분들처럼 끝나고 질문 시간이 따로 없어서 질문이 없을 거로 생각했는데 다 끝나고 가려고 하는데 두 분이 와서 질문을 했다. 처음에는 회사에 대한 간단한 질문부터 시작해서 나도 편하게 얘기하고 있었는데 이번에 정부에서 한 행사에서 수상한(공개 SW 페스티벌은 한 해 동안 정부에서 시행한 오픈소스 사업의 시상식도 포함하고 있는데 어디서 수상했는지는 정확히 찾기가 어려웠다..) [Haetae - Your Smart Incremental Tasks](https://haetae.dev/)라는 프로젝트였는데 의존성을 추적해서 영향받는 파일의 테스트만 돌리는 등의 작업을 해주는 증분 태스크 러너였다.


코엑스에 서서 1시간 정도 얘기를 나누었는데 설명을 듣다 보니 결국 노트북도 꺼내서 설명을 듣게 되었고 가볍게 만들기 시작한 게 아니라 [Bazel](https://bazel.build/?hl=ko)부터 빌드도구나 태스크 도구에 대해서 오랫동안 고민하고 어떻게 만들어야 하는지 긴 준비 끝에 만들었음을 느낄 수 있었고 써보진 않았지만, 퀄리티도 꽤 좋아 보여서 정식 릴리스가 기대되는 프로젝트였다.


이 글은 [GitHub Universe 2023 참석기 #1](https://blog.outsider.ne.kr/1695)에서 이어진 글이다.


# Open Source Community Day


![6030442673.jpg](https://blog.outsider.ne.kr/attach/1/6030442673.jpg)


화요일은 오픈소스 커뮤니티 데이가 진행되어 GitHub Stars 뿐만 아니라 오픈소스 메인테이너들과 Microsoft MVP 들이 GitHub 본사에 초대받았다.


![4687314908.jpg](https://blog.outsider.ne.kr/attach/1/4687314908.jpg)


오전에는 GitHub HQ 오피스 투어가 있었다. GitHub 오피스 투어는 사실 여러번 해봤긴 하지만 그래도 볼때마다 좋다.


![9751195224.jpg](https://blog.outsider.ne.kr/attach/1/9751195224.jpg)


투어가 끝나고는 컨퍼런스 행사장 중 하나인 [Hyatt Regency](https://maps.app.goo.gl/bMQP6LYT8v6rfvr76)에 가니 GitHub Universe가 곧 시작됨을 느낄 수 있었다.


![7256456722.jpg](https://blog.outsider.ne.kr/attach/1/7256456722.jpg)


![9904914500.jpg](https://blog.outsider.ne.kr/attach/1/9904914500.jpg)


등록대에 가서 등록을 하니 네임택를 받을 수 있었다. 모든 세션에 다 들어갈 수 있는 All Access이고 프라이빗 행사에도 참여할 수 있는 Dark Mode라 목걸이도 보라색으로 받았다. eink로 된 네임택은 작년부터 나누어 주었던거 같은데 작년에 트위터에서 보고 부러웠는데 올해도 나누어 주어서 받을 수 있었다.


![6431383459.jpg](https://blog.outsider.ne.kr/attach/1/6431383459.jpg)


![9850958622.jpg](https://blog.outsider.ne.kr/attach/1/9850958622.jpg)


등록하면 바로 USB-C를 연결해서 현장에서 바로 내 이릅이 표시된 eink 네임택을 받을 수 있고 뒷면도 이쁘게 디자인 되어 있다. 행사 중에 이를 연결할 수 있는 키트를 주기도 하고 가이드를 주어서 직접 컴퓨터에 연결해서 모드를 바꿀수도 있는데 아직 안해봤다. 다른 사람들은 반전을 주어 다크모드로 바꾼다거나 다른 글자나 이미지를 넣는 등의 튜닝도 했다.


![6752958703.jpg](https://blog.outsider.ne.kr/attach/1/6752958703.jpg)


등록은 미리 했지만 사전 이벤트인 오픈소스 커뮤니티 데이였기 때문에 한 곳에서 오픈소스 관련 소규모 세션이 진행되었다.


![2626104394.jpg](https://blog.outsider.ne.kr/attach/1/2626104394.jpg)


GitHub 리더십 팀과의 질문답변시간도 있었고 오픈소스 관련 그룹 토론이나 GitHub 스폰서 기능에 대한 의견 교환 시간도 있었다. 리더십 팀의 규모는 모르지만 GitHub의 VP나 디렉터 직급들한테 질문을 하는 시간이었는데 여성이 3명이나 되었고 다른 곳에서도 리더들에 여성 비율이 꽤 많게 느껴졌다. 여긴 또 이렇게 우리나라 보다 앞서가는 구나 하는 생각이 들었다.


![1338215429.jpg](https://blog.outsider.ne.kr/attach/1/1338215429.jpg)


Node.js TSC 디렉터이기도 하고 OpenJS 재단이나 TC39에서도 활동하고 현재는 GitHub에서 npm과 Codespaces를 이끌고 있는 Myles Borins가 있어서 같이 사진도 찍었다. 아침부터 얼굴을 알아보고 기회를 노리고 있었고 첨에는 Myles Borins만 알아봤는데 오전부터 같이 얘기하던 사람들이 Node.js 커미터인 [Tierney Cyren](https://github.com/bnb), [Shelley Vohr](https://github.com/codebytere)이고 Electron 메인테이너인 [Samuel Attard](https://github.com/MarshallOfSound)라는 것을 금새 눈치챘다. Node.js와 JavaScript를 좋아하는 터라 너무 반가웠지만 내 짧은 영어로는 대화에 끼기는 어려웠다.


![1574360170.jpg](https://blog.outsider.ne.kr/attach/1/1574360170.jpg)


저녁에는 [Minna Gallery](https://maps.app.goo.gl/uNihtdDRsXvgnUg87)라는 곳에서 오픈소스 메인테이너 소셜 행사가 있었다. 저녁 이벤트라 그냥 갔는데 술은 계속 주는데 핑거푸드 조차 주지 않았다. 오픈소스 메인테이너 들은 신청후 참석할 수 있었는데 2015년에 Airbnb 오피스에 방문할 때 우리를 초대해줬던 [Jordan Harband](https://github.com/ljharb)도 만날 수 있었다. 8년전 한번 만났지만 그 뒤에서 [Popular Convention](https://blog.outsider.ne.kr/949)땜에 몇번 얘기했던터라 다행히고 내 닉네임을 보고 바로 알아봐주었다.


낮부터 [GitHub Campus Expert](https://githubcampus.expert/experts) 사람들이 있어서 아시아 사람들도 있길래 혹시 한국분인가 명찰을 지나가면서 유심히 봤는데 나의 동체시력으로는 알아볼 수가 없었다. GitHub Stars 중 약간 친해진 [Huan Li](https://www.linkedin.com/in/huan42/)가 한국 사람 있다고 알려줘서 [한국 Campus Expert](https://gce-korea.github.io/) 중 한분인 [김서현](https://github.com/kshjessica)님과도 인사를 나눌 수 있었다. 이번에는 유독 한국분이 적어보여서 더욱 반가웠다.


![7648475174.jpg](https://blog.outsider.ne.kr/attach/1/7648475174.jpg)


![1727408697.jpg](https://blog.outsider.ne.kr/attach/1/1727408697.jpg)


이전 같으면 공짜술이라서 신나게 마셨을테지만 미국 가기전에 몸이 꽤 아파서(아마도 술병?) 좀 정신차리고 술을 안먹고 있던터라 맥주만 약간 마셨다. 오픈소스 메인테이너 행사라 밖에 나와서 쉬는 중에 [warp](https://www.warp.dev/) 터미널 개발자도 만날 수 있었다. 오픈소스 회사라 일하다가 잠깐 놀러왔다면서 다시 들어가서 일해야 된다고 했다. 난 솔직히 아직 warp 안쓰고 [iTerm](https://iterm2.com/) 쓴다고 얘기하길 했는데 티셔츠 보내주겠다고 이메일도 적어갔다.


# GitHub Universe Day 1


![2889052379.jpg](https://blog.outsider.ne.kr/attach/1/2889052379.jpg)


GitHub Universe는 [YBCA(Yerba Buena Center for the Arts)](https://maps.app.goo.gl/usSh9AHbCfxFz5kr6)에서 진행되었다. YBCA에 도착하자 커다란 옥토캣이 사람들을 반겨주고 있었다.


샌프란시스코 바로 옆에 있는 Moscone 센터 바로 옆에 있는 문화센터인데 장소가 아주 크진 않아서 인지 바로 옆에 Hyatt Regency 2층과 길건너의 [SF MOMA](https://maps.app.goo.gl/Eo6qoFpjcus5kxop8)도 홀도 같이 사용했다. 그래서 몇개의 세션은 해당 장소로 이동해야 했는데 길을 건너야 하는게 좀 귀찮았다.


![4606431265.jpg](https://blog.outsider.ne.kr/attach/1/4606431265.jpg)


키노트는 메인 스테이지에서 진행되었는데 9시까지 가야하는데 첫날 좀 늦게 일어다서 딱 9시에 도착했더니 2층에만 자리가 있었다. CEO인 [Thomas Dohmke](https://twitter.com/ashtom)가 키노트를 진행했는데 [GitHub은 Git 기반으로 만들어졌지만 이제는 Copilot 기반으로 다시 만들어 진다](https://twitter.com/github/status/1722309261680607674)면서 AI 플랫폼이 될 것임을 얘기한 것이 가장 인상적이었다.


이 키노트에서 많은 것을 발표했다.


## GitHub Copilot Chat


[GitHub Copilot Chat](https://docs.github.com/en/copilot/github-copilot-chat)이 12월 정식 출시될 예정이고 Copilot 사용자는 바로 사용할 수 있다. 실제로 써보면 에디터에 바로 붙어있다는 것이 편의성도 있지만 코드 블럭을 지정해서 바로 질문할 수도 있고 /fix, /test 같은 명령어도 내릴 수 있다. Copilot Chat은 GPT-4 기반이고 JetBrains IDE도 지원하기 때문에 따로 GPT-4를 쓸 일이 더 줄어들 것 같다.


그리고 Copilot Chat은 github.com에도 통합될 예정이다. 이건 아직 사용해보지 못했는데 데모 화면에서는 볼 수 있었는데 내 기억에는 사이드바와 코드뷰 등에서 Copilot 아이콘으로 바로 접근할 수 있고 GitHub Mobile 앱에서도 사용할 수 있어서 ChatGPT 대용으로 쓰기도 좋을 것 같다. 어차피 내가 물어볼 것의 대부분은 코드 관련이긴 하다.


## GitHub Copilot Enterprise


Copilot Individual($10)과 Copilot Business($10)에 이어서 Copilot Enterprise가 내년 2월에 출시될 예정이다. 가격은 $39로 꽤 비싼 편이다.


발표에서는 Pull Reqeust를 올리고 버튼을 누르면 자동으로 요약을 보여주며 GitHub에 올라오는 Pull Request의 상당수에 설명이 비어있다고 설명했다. 코드 리뷰 어느정도는 자동으로 제안해주기도 하는데 이런 기능에 기대 후에 이러한 기능은 엔터프라이즈에서만 동작한다고 해서 아쉬웠다. AI의 비용을 생각하면 꼭 싸다고 할 수 없지만 GitHub Enterprise도 $21인데 Copilot Enterprise까지 쓴다면 직원당 상당한 비용이 되긴 한다.


엔터프라이즈의 가장 큰 부분은 조직내의 코드페이스로 파인 튜닝할 수 있다는 점이다. 이걸 듣고 생각이 들었던건 어디까지 튜닝이 가능하냐는 점인데 사내에 HTTP 클라이언트 같은게 있다면 코드 완성할 때 범용적인 HTTP 클라이언트가 아니라 사내에 맞춰서 해준다면 꽤 좋겠다는 생각이 들었다. 그리고 A 메서드가 deprecated되고 B 메서드를 추가한 경우 IDE에서 자동으로 B 메서드를 추천하는 식으로 한다면 사내에 커뮤니케이션을 상당히 줄여주어서 $39가 아깝지는 않겠다는 생각이 들었다.


![9245126361.jpg](https://blog.outsider.ne.kr/attach/1/9245126361.jpg)


Copilot Enterprise를 발표하고 갑자기 Microsoft의 CEO인 [Satya Nadella](https://en.wikipedia.org/wiki/Satya_Nadella)가 무대에 등장했다. 길게 있진 않았는데 GitHub이 하는 AI 행보에 힘을 실어주기 위해 나타난 것으로 보인다.


## GitHub Advanced Security


그 외에 GHAS(GitHub Advanced Security)에도 AI 기능이 많이 추가되어 IDE에서 취약점 수정 제안이 가능하고 현재는 JavaScript/TypeScript만 지원하지만 Pull Request에서도 취약점을 수정하는 제안을 자동으로 올릴 수 있게 된다. 개인적으로 GHAS는 가격($49)에 비해서 아직은 기능이 좀 부족하지 않나 싶긴 한데 AI 기능이 많이 추가되면 IDE에서도 많은 지원을 할 수 있는 Shift Left가 가능하기 때문에 꽤 쓸만해 질 수 있겠단 생각이 들었다.


## GitHub Copilot Workspace


![4170645449.jpg](https://blog.outsider.ne.kr/attach/1/4170645449.jpg)


키노트가 거의 끝난무렵 갑자기 스티브 잡스 얘기를 하면서 One more thing...이 등장했다. GitHub에서 One more thing을 보게 될 줄은 몰랐다.


![3779664271.jpg](https://blog.outsider.ne.kr/attach/1/3779664271.jpg)


그러고 발표한 것은 [GitHub Copilot Workspace](https://githubnext.com/projects/copilot-workspace/)이다. 내년에 출시 예정이라고 하는데 아직은 실험 상태로 대부분의 작업이 이슈에서 시작하는데 데모 영상을 보면 GitHub 이슈에서 워크스페이스를 열면 어떤 변경을 하면 될지 AI가 제안해 주는데 이에 대한 내용을 사람이 일부 수정하고 구현하기를 누르면 코드 수정을 보여주고 바로 Pull Request까지 올릴 수 있게 된다.


## GitHub Stars Walk of Fame


![4312209679.jpg](https://blog.outsider.ne.kr/attach/1/4312209679.jpg)


![4819099025.jpg](https://blog.outsider.ne.kr/attach/1/4819099025.jpg)


작년부터 시작된건데 행사장 일부 공간에 GitHub Stars Walk of Fame로 꾸며주고 있다. 헐리우드에 있는 Walk of Fame을 따라 한 것인데 바닥에 각 Stars의 이름이 있어서 내 이름도 발견할 수 있었다. 작년에는 다른 분께 사진만 전달받았는데 올해는 직접 볼 수 있어서 좋았다. 저 스티커는 따로 한장을 집에 가져가라고 줬는데 너무 커서 캐리어에 구겨지지 않게 넣어서 가져오기 쉽지 않았다.


## GitHub Shop


![5686860898.jpg](https://blog.outsider.ne.kr/attach/1/5686860898.jpg)


![4625771027.jpg](https://blog.outsider.ne.kr/attach/1/4625771027.jpg)


![7937296363.jpg](https://blog.outsider.ne.kr/attach/1/7937296363.jpg)


GitHub Universe에는 항상 GitHub Shop이 운영된다. 컨퍼런스 때 새로나온 제품도 있지만 기존 [GitHub Shop](https://www.thegithubshop.com/)에서 파는 제품도 좀 싸게 팔아서 이전에도 이것저것 사오긴 했었는데 이번에는 신상품 말고는 제품이 없었다.


깃헙 스웨터는 내 취향이 아니라 안샀고 후디는 집업 후디만 입는 편이라서 딱 맘에 드는 제품이 없었다. 그래서 우산이랑 키캡이랑 티셔츠만 구매했다. 원래 알고 지내던 GitHub 총판인 [단군소프트](https://www.tangunsoft.com/)의 담당자분을 오랜만에 만났더니 키캡을 사서 선물해 주셨다.(감사합니다.)


처음엔 안샀는데 스케이드보드 덱을 살지 말지 너무 고민됐다. 디자인이 딱 내취향이면 샀을텐데 이번엔 뭔가 맘에 드는듯 아닌듯 애매했는데 가격도 비쌌기 때문에 고민하다가 선뜻 하지 못했다. 다음날 세션을 듣다가 세션이 좀 재미없기도 하다가 언제 또 기회가 오겠나 하고는 세션을 나와서 사러 갔더니 마지막 남은 1개의 보드가 있었다. 마지막 남은걸 구매했더니 세션 중간에 나와서 사길 잘했다는 생각이 들었다. 당연히 스케이드 보드로 타려는건 아니고 인테리어 용도이다. 종종 GitHub 사무실이나 GitHub 직원들과 화상 미팅을 할 때 벽에 있던 스케이트 보드가 부러웠기 때문이다. 그리고 어제는 없었던 옥토캣 LED도 있어서 같이 사왔다.


## 행사장


![6199928854.jpg](https://blog.outsider.ne.kr/attach/1/6199928854.jpg)


입구에는 당연히 라운지와 등록대가 있고 가운데에는 GitHub의 부스가 있고 옆에도 다른 부스들이 있었다.


![7177665114.jpg](https://blog.outsider.ne.kr/attach/1/7177665114.jpg)


![4027221631.jpg](https://blog.outsider.ne.kr/attach/1/4027221631.jpg)


Copilot 등 새로운 기능을 살펴보고 질문할 수 있는 GitHub 부스뿐 아니라 네임텍을 찍으면 화면에 내 이름으로 랜덤 커밋 메시지가 나오거나 퀴즈를 주고 자물쇠를 풀면 열쇠고리와 키캡을 주는 이벤트도 있었다. 443 포트를 묻는 문제였는데 긴가민가 하다가 자물쇠에 0443을 입력하니까 자물쇠가 열려서 상품을 받아올 수 있었다.


GitHub 부스에서 [커스텀 프로퍼티](https://github.blog/changelog/2023-10-12-github-repository-custom-properties-beta/) 기능도 알게 되었다. 나중에 보니 이건 지난 달에 공개된 것이었는데 저장소에 부서나 중요도 등 프로퍼티를 지정할 수 있는 기능이다. 부스에서 좀 이해하고 테스트를 해보니 어딘가에 표시되는건 아니고 Org 차원에서 프로퍼티의 종류를 생성할 수 있고 이 키를 각 저장소에서 원하는 값으로 설정하는 거라 첨에는 어디 쓰는건지 잘 몰랐는데 다음날 세션을 보면서 더 이해할 수 있었다.


![5665939378.jpg](https://blog.outsider.ne.kr/attach/1/5665939378.jpg)


![7088552110.jpg](https://blog.outsider.ne.kr/attach/1/7088552110.jpg)


메인스테이지가 있는 옆건물로 가기 위한 야외에도 행사장으로 꾸며져 있어서 식사를 하거나 과자, 음료 등을 마시며 쉴 수 있는 공간이 있다. 사람들과 편하게 교류할 수 있는 공간이 넓다 보니 사람들이 많이 얘기도 하고 책상도 많아서 업무를 하는 사람도 꽤 보였다. 메인 스테이지의 발표는 야외에서도 볼 수 있게 제공하고 있었는데 자세히 보진 않았지만 밖이 밝아서 보기가 쉽진 않아서 많은 사람들이 여기서 발표를 보고 있진 않았다.


## Platform engineering: a new idea or just a new name?


![9212829757.jpg](https://blog.outsider.ne.kr/attach/1/9212829757.jpg)


![2483848724.jpg](https://blog.outsider.ne.kr/attach/1/2483848724.jpg)


[Platform engineering: a new idea or just a new name?](https://reg.githubuniverse.com/flow/github/universe23/sessioncatalog/page/sessioncatalog/session/1698054675283001a1yL)은 [Octopus Deploy](https://octopus.com/)에서 진행한 세션이었다. 키노트를 듣고 행사장 구경도 하고 부스도 보고 분위기 파악을 하고 최근 플랫폼 엔지니어링에 관해서 관심도 많고 해서 여기선 어떤 얘기를 하는지 궁금해서 들으러 갔다.


아직 컨퍼런스 장소에 익숙치 않아서 몰랐는데 이 발표의 장소가 Discussion Lounge였다는 것이다. 들어가면서 그냥 자유롭게 의자가 배치되어 있다고 생각했는데 알고 보니 이게 그룹별로 나뉘어져 있는 것이었다. 그래서 Octopus Deploy에서 주제를 던지면 각 그룹별로 토론하는 형태였다.


물론 장표를 보여주면서 설명하는 발표의 영어도 다 알아듣지 못하는 나에게 이러한 토론은 너무 알아듣기가 어려웠다. 다 알아들었다면 꽤 재미있는 자리였겠지만 못알아들어서 아쉬웠다. 중간에 나갈까도 생각했지만 너무 맨앞에 앉았기도 하고 던져주는 키워드로도 어떻게 생각하고 있는지 어느정도는 이해할 수 있어서 그냥 기다렸다. 이상하게 내가 제목만 보고 고른 세션은 몇개가 Discussion Lounge였었고 장소보고 이후에는 들어가지 않았다.


## Dark Mode


![2616283817.jpg](https://blog.outsider.ne.kr/attach/1/2616283817.jpg)


![5292826829.jpg](https://blog.outsider.ne.kr/attach/1/5292826829.jpg)


저녁에는 다크 모드 행사가 있었다. 다크 모드는 GitHub Universe의 전체 엑세스가 가능한 사람들만을 대상으로한 파티로 SF MOMA 2층에서 열렸다. 해외 컨퍼런스는 저녁에 항상 이런 네트워크 파티가 있는데 국내에는 이런 문화가 없어서 항상 아쉬운 부분이다.


![8715304158.jpg](https://blog.outsider.ne.kr/attach/1/8715304158.jpg)


![8225576449.jpg](https://blog.outsider.ne.kr/attach/1/8225576449.jpg)


![9933822229.jpg](https://blog.outsider.ne.kr/attach/1/9933822229.jpg)


여기선 다양한 음식도 나오고 술도 계속 주었는데 꽤 맛있었다. 3층으로 가면 에그노그? 라고 하는건지 핫초코 비슷한데 꽤 독한 술을 만들어 주었다. 영어도 잘 못하지만 처음엔 뭘 준다는건지 몰랐는데 따뜩한 차에 찐한 알콜이 특이한 느낌이었다. 저녁 파티를 즐기고 싶었는데 이 시각에 한국에서 빠지기 힘든 미팅이 있어서 Zoom으로 참여하느라고 파티를 잘 즐기지 못했다.


# GitHub Universe Day 2


![8953925840.jpg](https://blog.outsider.ne.kr/attach/1/8953925840.jpg)


컨퍼런스 둘째날은 좀 일찍 나가서 1층에 앉았다. 어제 AI 중심으로 바뀌는 방향성에 대해서 강조하고 GitHub Actions의 Apple Silicon 지원과 GitHub Enterprise 기능 소개, GitHub의 멀티 어카운트 지원(너무나 기다렸던 기능)을 발표했다.


## [GitHub: The best developer experience built by developers, for developers](https://reg.githubuniverse.com/flow/github/universe23/sessioncatalog/page/sessioncatalog/session/1687871147576001wSrQ)


![1651434704.jpg](https://blog.outsider.ne.kr/attach/1/1651434704.jpg)


![5529184915.jpg](https://blog.outsider.ne.kr/attach/1/5529184915.jpg)


이 세션에서는 GitHub이 오픈소스 중심의 플랫폼에서 이제는 AI 기반으로 나아가는 과정을 설명하면서 새로운 기능 등을 설명했다. GitHub은 꽤 자세히 보고 있어서 기능 자체가 나에겐 새롭지 않았지만 개인적으로 AI를 AI를 썼다는 것 자체를 마케팅 수단으로 쓰는 정도를 넘어서서 실제로 효용 가치를 가장 잘 주는 서비스 중 하나라고 생각해서 인상적이었다.


## 1 Password Rule GitHub with just a touch of your finger


![6903742817.jpg](https://blog.outsider.ne.kr/attach/1/6903742817.jpg)


스폰서 부스에서 1Password를 구경하다가 서비스 어카운트를 알게되고 테스트해봐야지 하고는 1년 가까이 미루고 있는 사이에 1Password의 Developer Tools 기능이 꽤 많이 좋아졌다는 것을 알게 되어서 세션을 참가했다. 여기서 SSH 키 관리와 서비스 어카운트를 어떻게 쓸 수 있는지 데모를 보면서 이해할 수 있었고 올해 고민하던 문제의 해결책이 될것 같아서 관심이 많이 간 세션이었다. 이 세션은 컨퍼런스장 중간에 데모 스테이지에서 소규모로 열린 세션이었는데 내가 제목을 보고 관심 가진 세션의 많은 세션이 여기서 진행된 세션이었다.


## How GitHub Securely uses GitHub


![2444029944.jpg](https://blog.outsider.ne.kr/attach/1/2444029944.jpg)


GitHub이 GitHub에서 보안관리를 어떻게 하고 있는지 설명하는 발표였고 GitHub 사람들 3명이 돌아가면서 발표를 했다.


![8143475146.jpg](https://blog.outsider.ne.kr/attach/1/8143475146.jpg)


![2541777813.jpg](https://blog.outsider.ne.kr/attach/1/2541777813.jpg)


몇가지 기억나는 것은 워크플로우에서 GitHub 외부에서 작성된 워크플로우를 직접 호출해서 사용하는 것은 거의 없고 각 단계에 다야한 검사 과정이 있지만 올해 추가된 [Repository Rulesets](https://docs.github.com/ko/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)이 현재 GitHub이 밀고 있는 보안 관리의 핵심 기능이라는 생각이 들었다.


RuleSets를 통해 중요 프로젝트는 필요한 건증단계가 모두 진행되었는지 확인하고 이를 통해서 파이프라인에서 다음 단계를 진행할지를 판단한다. 이는 GitHub이 GitHub을 개밥먹이기를 하면서 더 잘할 수 있는 방법을 고민하면서 이를 기능으로 구현한 것이 Rulesets라는 생각이 들어서 더욱 관심이 갔다.


이 세션을 꽤 괌심이 갔는데 영어를 다 알아듣지 못해서 특히나 아쉬운 세션 중 하나였다.


## 그 외...


데모 스테이지에서 Datadog의 [CI Visibility](https://www.datadoghq.com/product/ci-cd-monitoring/)에 대한 세션도 들었다. CI의 실행 상황을 추적해 주기도 하고 특히 해결하기 꽤 피곤한 freaky 테스트에 대한 모니터링을 통해서 얼마나 랜덤으로 자주 실패하는지 언제부터 실패하는지 보여주는 부분은 꽤 관심이 갔다. 컨퍼런스 가기전에 좀 살펴보기도 했는데 커미터달 한달에 $8 라서 가격대비 효용을 얻을지 좀 고민이 되었던 터라 더 아쉽다는 생각이 들었다.(좀 비싼 느낌)


데모 스테이지에서 기다리던 중 GitHub Next의 리서치 시니어 디렉터인 Idan Gazit을 찾으면 GitHub Next 스티커를 준다는 [트윗](https://x.com/GitHubNext/status/1722743530349899987?s=20)을 보았다. [GitHub Next](https://githubnext.com/)는 GitHub의 R&D 조직으로 다양한 실험을 하면서 미래 사업을 많이 연구하고 있어서 좋아하는 터라 라운지를 돌아다니니 운좋게도 금방 Idan Gazit를 찾을 수 있었다. 그래서 GitHub Next 스티커를 몇장 받았다.


오랜만에 샌프란시스코에 컨퍼런스 참석차 갔다온 경험은 역시 좋았다. 이 도시는 여전히 날 다양하게 설레이게 한다는 생각이 들었고 올해 바쁜 업무 가운데도 리프레시가 되는 기분이었다. 컨퍼런스 참석 후기는 [44bits 팟캐스트에서도 얘기](https://podcast.44bits.io/episodes/192)했다.


혼자 돌아다녀도 좋긴 하지면 여전히 영어는 너무 아쉬웠다. 이 후기 자체도 갔다온지 한달 가까이 된 시점에야 작성하고 있지만 여전히 영어 공부를 따로 하고 있지는 못하고 그래서 여전히 영어를 잘 못하는 이유이기도 하다. 이전에 그냥 참석했을 때와 달리 이번에는 GitHub Stars로 참석했기에 다른 Stars는 어느정도 유대가 있기에 쉽게 어울리고 대화할 수도 있음에도 영어가 너무 안되니 잘 끼지 못한게 아쉬웠다. 그래도 약간은 대화 나누고 링크드인을 연결한 사람들도 있다.


올해도 재밌었다.


지난 10월 30일부터 11월 11일까지 [GitHub Universe](https://githubuniverse.com/) 콘퍼런스에 참석하려고 미국 샌프란시스코에 갔다 왔다.


나는 샌프란시스코를 좋아한다. 더 정확히는 결국 소프트웨어를 가장 선도하는 회사들이 이 실리콘밸리에 모여있다 보니 이 동네에 오기만 해도 좀 설레고 지나가면서 내가 아는 회사들 간판을 볼 때마다도 설레는데, 오랜만에 가서 그런지 별고 안 해도 꽤 좋았다.


1~2년에 한 번 정도는 콘퍼런스 참석 목적으로 샌프란시스코에 가는 편이었는데 팬데믹으로 인해서 [2019년 GitHub Universe](https://blog.outsider.ne.kr/1469)를 참석하고는 4년 만에 방문하는 샌프란시스코였다. 팬데믹 후에는 샌프란시스코가 많이 위험해졌다는 소식이 많이 들려서 큰 차이 없을 거라고 하면서도 약간 걱정되었다.


막상 갔을 때는 잠시 머무는 여행자 입장에서는 큰 차이가 없게 느껴졌다. 텐더로인이나 시빅센터 부근은 예전부터 좀 위험하다고 생각해서 자주 가진 않는 편이기도 하고 이쪽은 이전보다 약하는 사람도 늘어나고 좀 더 위험해졌는지 몰라도 나는 유니언 스퀘어 부근에서 샌프란시스코 역 사이만 왔다 갔다 하는 편이라 이전과 차이가 없게 느껴졌다. 원래도 좀 길에서 냄새도 나고 노숙자도 꽤 있고 가끔 노숙자가 말도 걸고 그래서 불편하고 그랬기에 이전과 비슷하게 느껴졌다.


아무래도 한번 가기가 쉽지 않다 보니 콘퍼런스보다 일주일 먼저 가서 샌프란시스코에서 머물렀다. 샌프란시스코를 좋아하는 이유 중 하나는 매일 저녁 다양한 밋업이 있다는 것이었고 그 덕에 밋업에 참여하면서 여러 회사 오피스도 방문하고 티셔츠도 생기고 저녁까지 얻어먹고 오면서 저녁까지 심심하지 않기 때문이었다. 하지만 팬데믹 이후 커뮤니티가 회복이 안 되었는지 여기도 5일 다 출근하는 회사가 아직 적기 때문인지 [meetup](https://meetup.com/) 사이트를 아무리 찾아봐도 갈만한 밋업이 보이지 않았고 오프라인 밋업 자체가 상당히 줄어들어 보였다. 보통 와서 요즘 실리콘밸리는 이런 기술에 관심이 많다는 것을 오프라인에서 느낄 방법의 하나였는데업을 하나도 참가하지 못한 게 가장 아쉬웠다.


### 코워킹 스페이스


![5386793542.jpg](https://blog.outsider.ne.kr/attach/1/5386793542.jpg)


업무를 해야 했기에 코워킹 스페이스를 찾았다. 카페에 가면 노숙자나 이상한 사람들이 들어오기도 하고 화장실 갈 때 짐을 다 싸서 갔다가 와야 해서 불편하기 때문에 코워킹 스페이스를 보통 이용하는 편이다. 예전에 사무실이 WeWork를 이용할 때는 샌프란시스코의 WeWork를 그대로 이용할 수 있었기에 가장 편하긴 했는데 이젠 WeWork도 파산해서 어떻게 되는지는 잘 모르겠다.


이번에 간 곳은 [Trellis](https://www.trellis.social/)라는 곳이었는데 가보니 예전에도 가본 곳인데 이름만 바뀐 곳이었다. 하루 이용에 $29인데 사이트에서 예약도 가능하지만, 그냥 입구에서 결제하고 들어갈 수 있다.


![9982431040.jpg](https://blog.outsider.ne.kr/attach/1/9982431040.jpg)


여긴 인터넷과 전기는 무료이지만 커피는 바로 옆에 커피숍이 있어서 따로 사 먹어야 한다. 싼지 비싼지 좀 모호하긴 하지만 그래도 책상도 편하고 인터넷도 빠르고 입구에서 등록자만 들어오도록 관리하기 때문에 노트북 놔두고 왔다 갔다 할 수 있어서 좋다. 아쉬운 건 아침 9시부터 저녁 5시까지만 운영한다는 것이다. 그래서 5시에 나와야 했는데 저녁 9시까지 정도만 해도 좋을 텐데 아쉬웠다. 당연히 주말에도 하지 않는다. 어떤 면에서 보면 워라밸이 좋다고 할 수도 있고...


![5765925974.jpg](https://blog.outsider.ne.kr/attach/1/5765925974.jpg)


중간에 이동해야 해서 하루 종일 코워킹 스페이스를 이용하기 어려운 날은 그냥 카페를 이용했다. 스타벅스보다는 그래도 [Philz Coffee](https://philzcoffee.com/)가 쾌적해서 필즈 커피를 이용했다. 당근마켓에 입사한 뒤로는 Wayland라는 영어 이름을 쓰고 있기에 커피숍에 갈 때마다 Wayland라는 영어 이름을 시도했지만, 한번도 성공하지 못했다. 내 발음도 문제지만 일반적으로 사용하는 이름이 아니라서 더 그런 것 같다. 물론 한국 이름으로 불러줄 때도 제대로 된 적이 이전에도 한 번도 없긴 했다.


### Google Office


![2243187793.jpg](https://blog.outsider.ne.kr/attach/1/2243187793.jpg)


트위터에서 알게 된 Daniel Lee님의 초대로 [샌프란시스코에 있는 구글 오피스](https://twitter.com/dylayed)에도 갔다 왔다. 보통 구글 방문할 때는 마운틴뷰에 있는 오피스만 가봤는데 샌프란시스코 시내에도 구글 오피스가 있는 건 올해 처음 알았다. 시내라 훨씬 가까워서 다녀오기 편했고 내부는 구글 오피스 어디나 비슷한 느낌으로 깔끔하게 인테리어가 되어 있었다.


![6551830159.jpg](https://blog.outsider.ne.kr/attach/1/6551830159.jpg)


발코니에 나가서 점심을 먹었는데 베이브리지 뷰가 아주 좋았다. 점심 먹고 오피스에서 몇 시간 일하다가 간식까지 얻어먹고 나왔는데 사진을 찍지 못했다. 이 건물은 Mozilla가 있는 건물이기도 해서 몇 년 전에 방문한 적이 있긴 한데, 오랜만에 다시 오니 역시 경치가 좋았다. 건물 반대쪽으로 가면 Firefox와 Mozilla 로고가 있는 데 간 김에 사진도 한번 찍고 올 걸 그냥 온 게 아쉬웠다.


### Meta HQ


![8660677082.jpg](https://blog.outsider.ne.kr/attach/1/8660677082.jpg)


기환 님의 초대를 받아서 Meta의 오피스인 [MPK 22](https://maps.app.goo.gl/iy78riCmTfpsJts38)에 방문했다. 전에도 있었나 기억이 안 나는데 오피스가 꽤 크기 때문에 오피스를 오갈 수 있도록 자전거가 많이 있었고 주차장에 전기차 충전소가 많이 있는 게 부러웠다. 시스템이 있어서 충전 순서가 되면 알림이 와서 내려가서 충전할 수 있다고 한다.


![6560372861.jpg](https://blog.outsider.ne.kr/attach/1/6560372861.jpg)


Meta의 오피스는 MPK 20, 21, 22 이렇게 나뉘어져 있지만 건물은 하나라서 이동할 수 있다. MPK 20번 대를 쓰는 곳은 새로 만들어진 오피스이고 구 오피스는 1번 대를 쓰는데, 과거에 해커웨이라고 길의 이름을 짓고 Sun Micro Systems의 간판을 뒤집어서 페이스북의 간판으로 쓴 곳이 구 오피스이다. 몇 년 전에 방문했을 때는 MPK 22까지는 있지 않았던 거 같은데 사무실이 더 커져 있었다.


점심도 맛있었는데 얘기하면서 먹다가 사진 찍는 걸 잊었다. 오피스가 크다 보니 일식, 양식 등 다양한 종류의 구내식당이 있어서 취향에 따라 먹을 수 있었다.


![3028422151.jpg](https://blog.outsider.ne.kr/attach/1/3028422151.jpg)


구역마다 분위기가 약간씩 다른데 MPK 22는 신기한 형태로 되어 있었다. 곳곳에 커피도 주고 요거트도 주어서 밖에 나가서도 마시면서 얘기를 나누었는데 캘리포니아는 역시 날씨가 참 좋다. MPK라는 약자가 궁금했는데 Meta가 있는 지역인 Melon Park의 약자라고 한다. Google 오피스로 가는 버스는 Mountain View를 뜻하는 MTV라고 되어 있어서 버스 탈 때 이 약자로 구분해야 한다고 한다. 지역 이름을 쓰는 게 신기했는데 이 지역도 젠트리피케이션이 심하기 때문에 과거 시위 등도 있었고 해서 버스 등에 크게 Facebook이나 Google이라고 쓰는 대신 지역 이름의 약자를 쓴다고 한다.


![6549995658.jpg](https://blog.outsider.ne.kr/attach/1/6549995658.jpg)


![1545608885.jpg](https://blog.outsider.ne.kr/attach/1/1545608885.jpg)


얘기하면서 고민하다가 구 오피스에 있는 샵에 가고 싶다고 했다. 몇 년 전에 왔을 때도 티셔츠 등을 사 갔었는데 이 Meta의 SWAG을 파는 샵이 구 오피스에만 있었기에 이렇게 초대받아 왔을 때만 살 수 있다. 좀 걸어가야 해서 고민했는데 미리 말할 걸 그랬다. 다행히 시간 여유가 좀 있어서 구 오피스까지 방문했는데 새 오피스와 달리 캠퍼스 분위기가 나서 좋아하는 곳이다. 이날은 무슨 행사가 있는지 사람도 많고 외부 사람으로 보이는 사람들도 많이 있었다.


![4198866718.jpg](https://blog.outsider.ne.kr/attach/1/4198866718.jpg)


Meta 로고가 붙은 파타고니아 자켓이 있었는데 가격이 비싸서 고민하다가 파나고니아이기도 하고 또 언제든 살 수 있는 것도 아니라서 티셔츠 몇 개와 함께 구매했다. 팬데믹으로 오랫동안 새로운 티셔츠가 많지 않았는데 오랜만에 새 SWAG이 많이 생겼다.


### Meta Office


한 10년 전에 같이 프로젝트를 했던 디자이너가 얼마 전에 유럽에서 샌프란시스코 Meta로 이동했다는 것을 알게 되었다. 몇 년 전에 한국에 오셨을 때 보고 오랜만이라 연락했더니 마침 사무실이 샌프란시스코 시내에 있었다.


![8447145773.jpg](https://blog.outsider.ne.kr/attach/1/8447145773.jpg)


시내에도 Meta 오피스가 있는지는 몰랐는데 [Park Tower](https://maps.app.goo.gl/jMsPx2Q1yMBpp56T7)라는 꽤 높은 건물에 있어서 사무실에서 보이는 베이브리지 뷰가 구글 오피스와는 또 다른 느낌으로 좋았다. 샌프란시스코에서 높은 건물에 올라와 볼 일이 없어서 이렇게 높은 곳에서 샌프란시스코를 보기는 처음인 것 같다.


![7195228294.jpg](https://blog.outsider.ne.kr/attach/1/7195228294.jpg)


여기는 인스타그램 팀이 있어서 인스타그램으로 인테리어가 되어 있었다. 지금은 광고도 많아지고 예전 느낌이 덜 나지만 그래도 인스타그램은 처음 스타트업으로 나왔을 때부터 여전히 좋아하는 서비스 중 하나이다.


### Google Visitor Experience


최근에 마운틴뷰에 [Google Visitor Experience](https://visit.withgoogle.com/)가 생겼다는 걸 알고 있어서 딱히 할 일이 없는 주말에는 칼트레인을 타고 내려갔다 왔다.


![1586674087.jpg](https://blog.outsider.ne.kr/attach/1/1586674087.jpg)


이 Visitor Experience는 Google의 새로운 오피스인 [Gradient Canopy](https://realestate.withgoogle.com/bayview/)에 위치하고 있었다. 가기 전에는 이 Gradient Canopy 전체가 비지터 센터인 줄 알았는데, 가보니 Gradient Canopy는 구글의 새로운 오피스 건물 이름이었고 비지터 센터는 옆에 작게 있었다. 옆에 언덕에 올라가 보면 이 Gradient Canopy가 여러 개 있는걸 볼 수 있다. 약간 한국의 기와집 느낌도 나면서 건물이 아주 이뻐서 안에도 너무 들어가 보고 싶었다.


![6629783082.jpg](https://blog.outsider.ne.kr/attach/1/6629783082.jpg)


구글의 픽셀폰이나 Nest 등 구글의 전자 제품과 SWAG을 살 수 있는 스토어가 있고 옆에는 식당과 카페가 있었다. 설명을 보면 커뮤니티 모임 공간으로 빌려주는 공간도 있는 걸로 보였다.


### Apple Visitor Center


![9676856535.jpg](https://blog.outsider.ne.kr/attach/1/9676856535.jpg)


Google Visitor Experience 간 김에 지도 보니 Apple 비지터 센터가 멀지 않아서 우버를 타고 들렸다. Apple 비지터 센터는 가본 적이 있긴 하고 혼자 돌아다니다 보니 우버 비용이 싸진 않지만, 마운틴뷰 쪽까지 내려오긴 쉽지 않았고 주말이라 1시간에 1대 있는 기차도 시간이 남아서 어정쩡했다.


![8167397282.jpg](https://blog.outsider.ne.kr/attach/1/8167397282.jpg)


Google 스토어와 Apple 비지터 센터에서 티셔츠를 몇 장 샀다. 구글에 오프라인 공룡은 피규어도 있어서 고민했는데 생각보다 너무 크고 어디 놔둘 데가 없어서 그냥 왔다.


![6042182409.jpg](https://blog.outsider.ne.kr/attach/1/6042182409.jpg)


일요일은 별다른 일정이 없어서 [RetroTech 팟캐스트](https://retrotech.outsider.dev/) 대본도 쓸 겸 Sight Glass에서 놀았다. 여긴 샌프란시스코에서 내가 제일 좋아하는 장소인데 유일한 단점으로는 전원있는 자리가 거의 없다는 것이었다. 하지만 이제는 맥북이 M2 맥북이라서 하루 종일 놀아도 배터리 걱정이 크게 없어서 여기서 하루 종일 있을 수 있었다.


하루 종일 이라고 해도 5시까지 밖에 하지 않는다. 스타벅스는 좀 늦게까지도 하는데 스타벅스는 가기 싫었고 내가 가는 필즈커피나 사이트글라스나 다 5시까지만 해서 저녁 먹고 6시면 숙소에 와있었다. 이제는 밋업도 없어서 저녁때 달리 할것도 없었다. 숙소가 최대한 싼 숙소를 잡았기에(SWAG은 100달러 주고 구매하면서도 숙소에 100달러 쓰는 건 너무 아까워서 못 쓰겠다..) 책상이 없어서 침대에 누워서 늦게까지 앉았다 엎드렸다 하면서 컴퓨터를 했다. 또 샌프란시스코에서 7시 정도가 되면 한국이 출근 시간이 되기 때문에 슬랙을 계속 보다 보면 잠잘 시간이 되었다.


# Nova 2023


![2776777557.jpg](https://blog.outsider.ne.kr/attach/1/2776777557.jpg)


이번에 GitHub Universe에 참석하게 된 것은 내가 [GitHub Stars](https://stars.github.com/)인 것이 크다. 티켓도 지원해 주었고 약간의 여행비도 지원해 준 데다가 Nova 콘퍼런스라는 GitHub Stars를 대상으로 한 프라이빗 콘퍼런스가 있었기 때문이다. GitHub Universe는 수, 목 2일간 진행되는데 Nova 콘퍼런스는 월요일에 진행이 되었다. GitHub Stars는 현재 총 93명이 있는데 처음 생겼을 때가 팬데믹 기간이었기 때문에 그동안 온라인으로만 진행되었고 혹시나 기대했던 작년에도 국가별로 코로나 상황이 달랐기에 온라인으로 진행되었다. 다행히 올해는 오프라인/온라인으로 진행되어서 30여 명의 GitHub Stars가 모일 수 있었다.


![5235971651.jpg](https://blog.outsider.ne.kr/attach/1/5235971651.jpg)


행사는 GitHub HQ에서 진행되었는데 사실 그동안 다양한 시도로 GitHub 오피스는 많이 오긴 했다. 그래도 이번엔 정식 초대를 받은 거라 입구에서 등록하니까 왔다 갔다 할 수 있게 스티커를 주었다.


![3309281705.jpg](https://blog.outsider.ne.kr/attach/1/3309281705.jpg)


![5344965108.jpg](https://blog.outsider.ne.kr/attach/1/5344965108.jpg)


GitHub의 CEO인 Thomas Dohmke의 일정에 맞추기 위해서 인지 행사가 아침 7시부터 시작했다. 너무 일찍 일어나서 와야 했기에 너무 힘들었고 이후에도 여러 GitHub의 발표 세션이 있었지만, Nova의 각 세션은 모두 비밀이다. 대부분은 2일 뒤에 GitHub Universe에서 공개되긴 하지만 Nova는 보통 내부 제품이나 계획을 공개하고 Stars와 의견을 주고받는 형식으로 진행되기 때문에 NDA 하에 진행되므로 공개할 수는 없다.


# 웹개발 관련

- [**An Interactive Guide to CSS Grid**](https://www.joshwcomeau.com/css/interactive-guide-to-grid/) : CSS로 레이아웃을 다룰 수 있는 CSS Grid를 실제로 예제로 동작을 테스트해 보면서 설명하는 튜토리얼이다. 기본적인 Grid의 동작부터 행과 열의 지정, %와 `fr` 단위에 따라 어떻게 동작하는지, 자식 요소가 늘어날 때 Grid 레이아웃이 어떻게 동작하는지를 보여주면서 이해하기 쉽게 설명하고 다양한 레이아웃을 그리기 위한 동작 방식도 보여준다.(영어)
- [**sentry-javascript: replace prettier with biome**](https://github.com/getsentry/sentry-javascript/pull/9678) : Sentry의 JavaScript SDK에서 Prettier를 Rome의 대체제인 Biome로 교체했다.(영어)

# 그 밖의 개발 관련

- [**Bundleless: Not Doing Things Makes You Fast**](https://lucumr.pocoo.org/2023/11/30/not-doing-things-makes-you-fast/) : Armin Ronacher가 [Guillermo Rauch의 트윗](https://twitter.com/rauchg/status/1729596031434698774)을 보고 번들링 없는 개발을 지지하는 글을 작성했다. 이는 개발 중에 모듈이 많은 경우 이를 로드하는 데 오래 걸리므로 성능 문제를 해결하려면 번들링이 필요하다는 주장을 반박한 것이다. 이는 접근이 잘못된 것이고 번들링을 늘리는 것이 아니라 시작 시에 코드 실행을 줄여서 로드 시간을 줄이고 필요할 때 로딩해야 하는 것이고 사용자와 프레임워크 제작자의 목표는 번을 없이 개발할 수 있도록 하는 것을 선호해야 한다고 얘기하고 있다.(영어)
- [**The Node.js Event Loop**](https://blog.platformatic.dev/the-nodejs-event-loop) : Node.js에서 비동기 작업을 처리하는 이벤트 루프의 내부 동작을 설명하는 글이다. 서버에 요청이 몰렸을 때 어떤 영향이 있는지를 비교하기 위해 예시 프로젝트로 부하 테스트를 하면서 Event loop utilization(ELU)를 사용해서 이벤트 루프의 여유 용량을 확인하는 방법을 소개하고 fastify/under-pressure로 이벤트 루프 사용률을 지정해서 요청이 몰렸을 때 어떤 차이가 있는지를 보여준다. 이러한 결과를 통해 동기식 처리는 이벤트 루프 밖으로 빼고 비동기 호출의 수를 줄이는 방법을 모범 사례로 소개한다.(영어)

# 인프라 관련

- [**The Frugal Architect**](https://thefrugalarchitect.com/) : 검소한 아키텍트라는 뜻으로 비용을 고려한 지속할 수 있는 현대적인 아키텍처를 구축하기 위한 법칙을 Amazon의 CTO인 Werner Vogels이 정리했다.(영어)
    - 법칙 1: 비용을 비기능적 요구사항으로 만들기
    - 법칙 2: 비용과 비즈니스를 지속해서 연계하는 시스템
    - 법칙 3: 아키텍처는 절충의 연속이다.
    - 법칙 4: 관찰되지 않는 시스템은 알 수 없는 비용으로 이어진다.
    - 법칙 5: 비용 인식 아키텍처를 통한 비용 관리 구현
    - 법칙 6: 비용 최적화는 점진적으로 이뤄진다.
    - 법칙 7: 도전하지 않는 성공은 가정으로 이어진다.
- [**Top announcements of AWS re:Invent 2023**](https://aws.amazon.com/ko/blogs/korea/top-announcements-of-aws-reinvent-2023/) : AWS re:Invent 2023에서 많은 제품과 신규 기능이 공개되었다. 내가 관심 가는 부분만 적어봤는데 원글에더 더 많은 발표를 볼 수 있다.(영어)
- [**모니터링은 마틴 파울러처럼: Domain-Oriented Observability 도입기**](https://engineering.ab180.co/stories/monitoring-like-martin-fowler-domain-oriented-observability) : ab180에서 애플리케이션 내에서 로그와 메트릭을 수집하기 위해서 비즈니스 로직에 관련 로직이 포함되어 있고 테스트에서 이에 대한 검증도 포함되어 있었는데 최근에 Martin Fowler가 작성한 [Domain-Oriented Observability](https://martinfowler.com/articles/domain-oriented-observability.html)를 사내에 소개하고 이 개념으로 코드를 수정한 과정을 설명한 글이다. 기존에 비즈니스 로직과 로깅이 섞여 있었는데 이를 Instrumentation 관련 부분을 캡슐화한 Domain Probe로 분리하는 과정을 예시 코드를 개선하면서 보여주고 이제 로깅이나 메트릭 수정도 쉽게 할 수 있고 비즈니스 로직 파악도 쉽게 변경된 결과를 보여준다.(한국어)
- [**GitOps Best Practices Whitepaper**](https://akuity.io/blog/gitops-best-practices-whitepaper/) : Argo CD를 만드는 Akuity에서 GitOps 베스트 프랙티스 백서를 공개했다. 24페이지의 PDF 문서로 Git 워크플로우, 레퍼지토리 디렉터리 구조, GitOps를 사용한 CI/CD, 렌더링 된 Manifests를 설명한다.(영어)
- [**Managing resources with the Terraform AWS Cloud Control provider**](https://www.hashicorp.com/blog/managing-resources-with-the-terraform-aws-cloud-control-provider) : AWS에서 새로운 기능이 나오면 AWS Terraform 프로바이더에서 기능이 추가되어야 Terraform에서 사용할 수 있는데 [AWS Cloud Control API](https://aws.amazon.com/ko/cloudcontrolapi/)를 이용한 Terraform에서 AWS Cloud Control 프로바이더를 공개했다. 이 프로바이더는 자동으로 생성되기 때문에, AWS에 새 기능이 나오면 바로 사용할 수 있다.(영어)

# 볼만한 링크

- [**(번역 및 정리) Working In Small Batches**](https://jayden-blog-next.vercel.app/posts/from-time-to-time/article/working-in-small-batches) : DORA의 [Working in small batches](https://dora.dev/devops-capabilities/process/working-in-small-batches/)를 번역한 글이다. 일의 단위를 작은 단위로 만들어야 피드백을 빨리 발견하고 쉽게 해결할 수 있으며 효율성과 동기 부여가 높아지고 매몰 비용의 오류를 피할 수 있다. 새로운 기능을 기획할 때 몇 시간이나 며칠 단위로 작은 작업으로 나누고 이를 지속해서 릴리스할 수 있어야 함을 강조하고 있다.(한국어)
- [**Introducing Mozilla’s AI Guide, the developers onboarding ramp to AI**](https://blog.mozilla.org/en/mozilla/introducing-mozillas-ai-guide-the-developers-onboarding-ramp-to-ai/) : Mozilla에서 [AI Guide](https://ai-guide.future.mozilla.org/)를 공개했다. 이 가이드에서는 AI 기초, 언어 모델, ML 모델 선택으로 섹션이 나누어져 있다.(영어)

# IT 업계 뉴스

- Open AI의 CEO인 Sam Altman이 해고된 사건은 너무 큰 관심을 모았고 다양한 곳에서 자세히 다루었기에 큰 사건 위주로만 정리했다.
    - Greg Brockman은 상황을 파악 중이고 [자신도 이사회에서 해임되었다는 통보를 받았다고 밝힘](https://twitter.com/gdb/status/1725736242137182594)(회사 직책은 유지)
    - [Sam Altman returns as CEO, OpenAI has a new initial board](https://openai.com/blog/sam-altman-returns-as-ceo-openai-has-a-new-initial-board)* : Sam Altman이 OpenAI의 CEO로 돌아왔고 Mira가 CTO가 되고 Greg Brockman는 사장으로 돌아왔다. 새로운 이사회는 Bret Taylor(의장), Larry Summers, Adam D’Angelo로 구성되었고 Ilya는 이사회에서 물러나고 회사에 남았다.(영어)
- [**Introducing the Functional Source License: Freedom without Free-riding**](https://blog.sentry.io/introducing-the-functional-source-license-freedom-without-free-riding/) : 2008년에 BSD-3 라이센스로 시작했던 Sentry가 2019년 [Business Source License(BSL)로 바꾸었다](https://blog.sentry.io/relicensing-sentry/). 이후 오픈 소스 용어에 대한 논란이 있고 사용자의 자유와 개발자의 지속 가능성의 균형을 맞추기 위해 BSL을 발전시킨 [FSL(Funtional Source License)](https://fsl.software/)을 적용한다고 발표했다. BSL은 일정 시간 뒤에 오픈소스 라이센스로 변경되는데 이 비경쟁 기간인 기본 4년은 소프트웨어 업계에는 너무 긴 기간이고 BSL에 변경되는 날짜, 변경되는 라이센스 등 추가 사용이 가능하기 때문에 같은 BSL이라 부르기가 어렵다는 문제가 있다. FSL은 변경 날짜가 2년이고 변경되는 라이센스는 Apache 2.0나 MIT이며 추가 사용 허가를 막아서 오픈소스와 경쟁하는 상업적 제품을 만들어서 무임승차를 막는 목표에만 집중하도록 했다.(영어)
- [**Okta admits hackers accessed data on all customers during recent breach**](https://techcrunch.com/2023/11/29/okta-admits-hackers-accessed-data-on-all-customers-during-recent-breach/) : Okta에서 지난 10월 해킹으로 1%의 사용자만 영향을 받았다고 밝혔지만 [최근 공개된 내용](https://sec.okta.com/harfiles)에 따르면 모든 사용자의 데이터를 해커가 다운로드했다고 밝혔고 여기에는 이름과 이메일 주소가 대부분 포함되어 있고 일부는 전화번호와 직책 등이 포함되어 있다고 밝혔다.(영어)
- [**terkelg**](https://github.com/terkelg) : GitHub의 프로필 페이지를, SVG를 이용해서 반응형 페이지로 만든 프로젝트.
- [**AuthKit**](https://www.authkit.com/) : SSO를 제공하는 WorkOS에서 자사의 API 와 연동할 수 있는 상당히 멋진 로그인 UI를 오픈소스로 공개했다.
- [**Rsbuild**](https://github.com/web-infra-dev/rsbuild) : Rspack 기반의 빌드 도구.
- [**Wasmb By Example**](https://wasmbyexample.dev/) : 예제 프로그램으로 WebAssembly를 설명하는 사이트.

# 버전 업데이트

- [**Vite**](https://vitejs.dev/) **v5.0.0** : 프론트엔드 빌드 도구, [릴리스 공지](https://vitejs.dev/blog/announcing-vite5)
    - API 정리에 중점을 둔 릴리스
- [**LocalStack**](https://localstack.cloud/) **v3.0** : 개발 및 테스트롤 로컬 AWS 클라우드 스택, [릴리스 공지](https://blog.localstack.cloud/2023-11-16-announcing-localstack-30-general-availability/)
- [**Spring Framework**](http://projects.spring.io/spring-framework/) **v6.1.0 GA** : Java 프레임워크, [릴리스 공지](https://spring.io/blog/2023/11/16/spring-framework-6-1-goes-ga)
    - JDK 21 LTS 지원
    - 버추얼 스레드(Project Loom) 지원
- [**Spring Boot**](http://projects.spring.io/spring-boot/) **v3.2.0** : 스프링 애플리케이션의 구축을 도와주는 도구, [릴리스 공지](https://spring.io/blog/2023/11/23/spring-boot-3-2-0-available-now)
- [**Spring Data**](https://spring.io/projects/spring-data) **2023.1.0 GA** : Spring 기반 데이터 접근 라이브러리, [릴리스 공지](https://spring.io/blog/2023/11/17/spring-data-2023-1-goes-ga)
- [**Spring Security**](http://projects.spring.io/spring-security/) **v6.2 GA** : Spring 인증 프레임워크, [릴리스 공지](https://spring.io/blog/2023/11/20/spring-security-6-2-goes-ga)
- [**Spring Session**](http://projects.spring.io/spring-session/) **v3.2 GA** : 스프링의 세션관리 라이브러리, [릴리즈 공지](https://spring.io/blog/2023/11/21/spring-session-3-2-goes-ga)
- [**Spring Batch**](https://projects.spring.io/spring-batch/) **5.1 GA** : 스프링 배치 프레임워크, [릴리스 공지](https://spring.io/blog/2023/11/23/spring-batch-5-1-ga-5-0-4-and-4-3-10-available-now)
- [**Spring Vault**](https://spring.io/projects/spring-vault) **3.1** : 스프링 시크릿 관리, [릴리스 공지](https://spring.io/blog/2023/11/24/spring-vault-3-1-available)
- [**Spring Modulith**](https://spring.io/projects/spring-modulith) **v1.1 GA** : 모듈화된 스프링 부트 애플리케이션을 만들어주는 도구, [릴리스 공지](https://spring.io/blog/2023/11/24/spring-modulith-1-1-ga-and-1-0-3-released)
- [**Spring Integration**](http://projects.spring.io/spring-security/) **v6.2 GA** : Spring 네/외부 메시징 프레임워크, [릴리스 공지](https://spring.io/blog/2023/11/22/spring-integration-6-2-goes-ga)
- [**pgAdmin**](https://www.pgadmin.org/) **4 v8.0** : PostgreSQL 클라이언트 도구, [릴리스 공지](https://www.postgresql.org/about/news/pgadmin-4-v80-released-2754/)
- [**TypeScript**](http://www.typescriptlang.org/) **v5.3** : Microsoft가 만든 JavaScript transpiler, [릴리스 공지](https://devblogs.microsoft.com/typescript/announcing-typescript-5-3/)
- [**OrbStack**](https://orbstack.dev/) **v1.1.0** : mac용 Docker 애플리케이션, [릴리스 공지](https://orbstack.dev/blog/orbstack-1.1-https)
    - 설정없이도 모든 컨테이너에 자동 HTTPS 지원
- [**Rust**](http://www.rust-lang.org/) **1.74.0** : 프로그래밍 언어, [릴리스 공지](https://blog.rust-lang.org/2023/11/16/Rust-1.74.0.html)
- [**Prometheus**](https://prometheus.io/) **v2.48.0** : 모니터링 시스템, [릴리스 공지](https://github.com/prometheus/prometheus/releases/tag/v2.48.0)
- [**flow**](https://flow.org/) **v0.222.0** : JavaScript 정적 타입 체커, [릴리스 공지](https://github.com/facebook/flow/releases/tag/v0.222.0)
- [**Symfony**](https://symfony.com/) **v7.0.0** : PHP 웹 프레임워크, [릴리스 공지](https://symfony.com/blog/symfony-7-0-0-released)
- [**Grafana Agent**](https://grafana.com/docs/agent/latest/) **v0.38** : Grafana 스택의 에이전트, [릴리스 공지](https://grafana.com/blog/2023/11/29/grafana-agent-v0.38-release-new-opentelemetry-components-configuration-improvements-and-more/)
- [**three.js**](https://threejs.org/) **r159** : JavaScript 3D 라이브러리, [릴리스 공지](https://github.com/mrdoob/three.js/releases/tag/r159)
- [**PHP**](http://php.net/) **v8.3.0** : 스크립트 언어, [릴리스 공지](https://thephp.foundation/blog/2023/11/23/php-83/)
- [**Biome**](https://biomejs.dev/) **v1.4.0** : 프론트엔드 툴체인, [릴리스 공지](https://biomejs.dev/blog/biome-wins-prettier-challenge)
- [**Jotai**](https://jotai.org/) **v2.6.0** : React 상태 관리 라이브러리, [릴리스 공지](https://github.com/pmndrs/jotai/releases/tag/v2.6.0)
- [**Playwright**](https://playwright.dev/) **v1.40.0** : Chromium, Firefox, WebKit 브라우저 자동화 Node.js 라이브러리, [릴리스 공지](https://github.com/microsoft/playwright/releases/tag/v1.40.0)
- [**Zed**](https://zed.dev/) **v0.114.2** : 코드 에디터, [릴리스 공지](https://zed.dev/releases/stable#zed-0.114.2)
- [**Grafana Pyroscope**](https://grafana.com/oss/pyroscope/) **v1.2.0** : 지속적 프로파일링, [릴리스 공지](https://github.com/grafana/pyroscope/releases/tag/v1.2.0)
- [**Git**](http://git-scm.com/) **v2.43.0** : 분산 형상관리 도구, [변경사항](https://github.blog/2023-11-20-highlights-from-git-2-43/)
- [**Remix**](https://remix.run/) **v2.3.0** : 풀스택 웹 프레임워크, [변경사항](https://github.com/remix-run/remix/blob/main/CHANGELOG.md#v230)
- [**GitLab**](https://about.gitlab.com/) **v16.6** : 오픈소스 설치형 Git 플랫폼, [릴리스 공지](https://about.gitlab.com/releases/2023/11/16/gitlab-16-6-released/)
- [**RedwoodJS**](https://redwoodjs.com/) **v6.4.0** : 풀스택 웹프레임워크, [릴리스 공지](https://github.com/redwoodjs/redwood/releases/tag/v6.4.0)
- [**Flutter**](https://flutter.io/) **v3.16** : iOS, Android 네이티브 앱을 만드는 프레임워크, [릴리스 공지](https://medium.com/flutter/major-steps-this-year-on-the-journey-to-multiplatform-development-b9218b17f0f7)
- [**ESLint**](http://eslint.org/) **v8.54.0** : JavaScript 코드 분석 도구, [릴리스 공지](https://eslint.org/blog/2023/11/eslint-v8.54.0-released/)
- [**Node.js**](http://nodejs.org/) **v18.19.0 (LTS)** : 자바스크립트 런타임, [릴리스 공지](https://nodejs.org/en/blog/release/v18.19.0)
- [**Node.js**](http://nodejs.org/) **v20.10.0 (LTS)** : 자바스크립트 런타임, [릴리스 공지](https://nodejs.org/en/blog/release/v20.10.0)
- [**Node.js**](http://nodejs.org/) **v21.3.0 (Current)** : 자바스크립트 런타임, [릴리스 공지](https://nodejs.org/en/blog/release/v21.3.0)
- [**Kyverno**](https://kyverno.io/) **v1.11** : Kubernetes 정책 엔진, [릴리스 공지](https://nirmata.com/2023/11/16/kyverno-release-1-11/)

# 웹개발 관련

- [**Building towards a new default rendering model for web applications**](https://vercel.com/blog/partial-prerendering-with-next-js-creating-a-new-default-rendering-model) : Vercel에서 CDN을 더 활용하기 위해 엣지에서 성능을 최대화할 수 있도록 Next.14에서 Partial Prerendering(PPR)를 사용하는 방법을 소개하는 글이다. PPR은 `<Suspense>`를 기준으로 정적 쉘을 생성하고 이 정적 쉘은 엣지에서 바로 사용자에게 제공되는데 이를 통해 Incremental Static Regeneration(ISR)의 안정성과 속도, Server-Side Rendering(SSR)의 동적 기능을 통합한 기능이라고 설명한다.(영어)
- [**A Gentle Introduction to Islands**](https://deno.com/blog/intro-to-islands) : Deno의 웹 프레임워크인 Fresh은 Islands 아키텍처를 사용하는데 Fresh에서 Islands가 동작하는 방법을 설명한다. 웹사이트에는 JavaScript가 전혀 필요하지 않은 사이트도 있고 아주 일부만 JavaScript가 필요한 사이트도 있는데 많은 JavaScript 프레임워크는 페이지 자체를 컴포넌트로 다루기 때문에 다수의 하이드레이션 코드가 필요해지는데 아일랜드 아키텍처에서는 아일랜드에서는 아일랜드를 인식해서 필요한 부분의 JavaScript 코드만 생성해서 클라이언트에 내려주게 된다.(영어)
- [**Saga Design System: shaping the future of user experiences at Grafana Labs**](https://grafana.com/blog/2023/11/07/saga-design-system-shaping-the-future-of-user-experiences-at-grafana-labs/) : Grafana Labs에서 Grafana 내의 제품 간에 일관된 인터페이스를 제공하기 위해 디자인 시스템 [Saga](https://grafana.com/developers/saga/About/overview)를 공개했다.(영어)
- [**Expo Orbit v1: launcher app launched into orbit**](https://expo.dev/changelog/2023/11-14-orbit-v1) : Expo에서 Expo Application Services(EAS)로 빌드 후 스낵 프로젝트를 실행하는 과정을 개선하기 위해 지난 8월 Orbit을 공개했는데 반응이 좋아서 프로젝트를 진행하고 이번에 Orbit v1을 공개했다. Orbit을 이용하면 macOS 메뉴바에서 빠르게 빌드하고 실행할 수 있다.(영어)
- [**Announcing Angular.dev**](https://blog.angular.io/announcing-angular-dev-1e1205fa3039) : Augular가 새로운 사이트인 [angular.dev](https://angular.dev/)를 공개했다.(영어)

# 그 밖의 개발 관련

- [**Why we replaced Pinecone with PGVector**](https://medium.com/@jeffreyip54/why-we-replaced-pinecone-with-pgvector-2f679d253eba) : LLM 평가 인프라를 만드는 [ConfidentAI](https://www.confident-ai.com/)에서 벡터 데이터베이스인 [Pinecone](https://www.pinecone.io/)을 쓰다가 PostgreSQL에서 벡터 검색을 지원하는 [PGVector](https://github.com/pgvector/pgvector)로 갈아탄 이유를 설명한 글이다. Pinecon은 PoC할 때는 편하지만 데이터 동기화 문제와 벡터랑 용량 제한으로 결국 확장성에 문제가 생기고 PGVector의 경우 HNWS 도입으로 성능이 좋아져서 Pinecone을 대체할 만하다고 한다.(영어)
- [**Universe 2023: Copilot transforms GitHub into the AI-powered developer platform**](https://github.blog/2023-11-08-universe-2023-copilot-transforms-github-into-the-ai-powered-developer-platform/) : GitHub 콘퍼런스인 Universe에서 AI 관련 기능을 출시했다.(영어)
    - GitHub Copilot Chat이 12월 정시 출시 예정.
        - 기존 Copilot 사용자는 사용할 수 있고 GPT-4 기반이며 에디터의 코드 기반으로 질문을 하거나 `/fix`, `/test`같은 명령어를 사용할 수 있다.
        - JetBrains IDE도 지원
    - GitHub Copilot Chat이 github.com에도 통합되어 웹에서 바로 대화를 나눌 수 있으며 GitHub 앱에도 통합될 예정
    - GitHub Copilot Enterprise 출시
        - 24년 2월 정식 출시 예정
        - GitHub Copilot Enterprise 최상위 요금재로 매월 사용자당 $39(Copilot Business는 $19, 개인은 $10)
        - 회사의 github 저장소와 연결해서 비공개 코드를 기반으로 제안 가능
        - Pull Request 요약 생성 기능 지원
    - GitHub Advanced Security에서 AI 기반 보안 기능 지원
        - GitHub Copilot Chat에서 IDE에서 취약점 수정 제안
        - Pull Request에서 JavaScript/TypeScript에 대해 코드 스캐닝을 통해 AI가 취약점 수정 사안을 제안
    - GitHub Copilot Workspace
        - GitHub 이슈에서 워크스페이스를 열면 변경에 대한 제안을 AI가 해주고 이를 바로 코드 수정 및 실행한 후 Pull Request까지 열 수 있게 된다.
        - 24년 출시 예정

# 인프라 관련

- [**Post Mortem on Cloudflare Control Plane and Analytics Outage**](https://blog.cloudflare.com/post-mortem-on-cloudflare-control-plane-and-analytics-outage/) : 11월 2일 데이터센터의 전력이 나가면서 11월 2일 11:44(UTC)부터 11월 4일 04:25(UTC)까지 2일 정도 지속된 Cloudflare 장애의 포스트모템이다. 장애의 심각성 때문인지 Cloudflare의 CEO인 Matthew Prince가 복구되자마자 바로 포스트모템을 올렸다.(영어)
    - 컨트롤 플레인과 분석 서비스는 오리건주 힐즈버러 주변의 3개 데이터 센터에서 실행되고 있었으며 이 3개의 데이터 센터는 자연재해로 영향받지 않도록 충분히 떨어져 있으며 액티브-액티브로 클러스터를 이중화해서 운영할 수 있도록 충분히 가깝게 선택이 돼서 서로 데이터를 동기화하고 있었다.
    - 이 세 곳 중 하나는 PDX-DC04라고 불렀는데 가장 큰 분석 클러스터와 고가용성 클러스터의 1/3이 있었다.
    - 11월 2일 08시 50분(UTC) PDX-DC04의 유틸리티 회사인 포틀랜드 제너럴 일렉트릭(PGE)의 전력 공급 중 하나에 예기치 않은 유지보수가 발생했고 데이터센터를 운영하는 Flexential는 발전기를 돌려서 이를 보완했다.
    - Flexential는 이를 Cloudflare에 알리지 않았고 발전기와 유틸리티 라인을 같이 가동한 이유를 Flexential이 아직 알려주지 않았다.
    - 11:40(UTC) PGE의 변압기 중 하나에 그라운드 폴트가 발생했고 첫 유지보수 작업으로 인해 발생했을 것으로 추측한다.
    - 이 그라운드 폴트로 인한 보호 조치로 PDX-DC04의 모든 발전기가 중단되어 데이터센터의 전력 공급원이 모두 오프라인이 되었다.
    - 데이터센터에 UPS 장비가 있고 10분 동안 버틸 수 있었지만 4분 만에 UPS에 문제가 생기기 시작했고 데이터센터는 10분만에 발전기를 복구하지도 못했다.
    - 발전기를 복구하는데 3가지 문제가 있었는데 그라운드 폴트로 인한 문제였으므로 발전기에 물리적으로 접근해서 수동으로 재시작해야 했고, Flexential의 접근제어 시스템도 전원 공급이 되지 않아 오프라인 상태였으며, 현장 야간 근무자에 전문가가 포함되어 있지 않고 보안요원과 근무한 지 일주일 된 근무자 뿐이었다.
    - 11:44~12:01(UTC)에 UPS가 방전되어 데이터센터의 모든 전기가 끊겼지만 Flexential은 이를 Cloudflare에 알리지 않았고 전 세계를 연결하는 라우터 2대가 내려간 후 이를 알게 되었고 데이터센터에 팀을 파견했다.
    - Flexential은 12:28(UTC)에야 처음으로 전원 문제를 공지했다.
    - 고가용성으로 설계되어 다른 두 데이터센터에서 동작해야 했지만 Kafka와 Clickhouse 두 서비스는 고가용성 클러스터에 있지 않고 PDX-DC04에만 있었으면 고가용성 클러스터에 이 두 서비스에 의존성을 가진 서비스가 있었다. 고가용성 테스트도 했었지만 PDX-DC04를 모두 오프라인으로 하는 테스트는 진행하지 않았기에 이러한 의존성이 있다는 걸 놓쳤다.
    - 또한 새로운 제품이나 데이터베이스가 고가용성 클러스터에 통합되도록 요구하는 절차가 부족했다.
    - 12:48(UTC) Flexential은 발전기를 재 가동하고 과부하를 막기 위해 한 회로씩 점진적으로 켜다가 Cloudflare 회로에 문제가 있음을 발견하고 회로 차단기 교체를 시도했지만 보유 차단기보다 고장난 차단기가 많았기에 차단기를 조달해야 했다.
    - 13:40(UTC) 복구 시간을 예측할 수 없었기에 유럽에 있는 재해복구 사이트에 페일오버를 요청했다. 다행히 대부분의 서비스는 나머지 두 데이터센터에서 운영중이었으므로 컨트롤 플레인의 일부만 복구하면 되는 상황이었다.
    - 13:43(UTC) 재해복구 사이트에서 첫 서비스를 시작했다. 과부하가 걸려서 속도 제한을 구현해야 했지만 17:57(UTC) 안정적으로 서비스를 제공할 수 있게 되었다.
    - 신규 제품 등 재해복구 사이트에서 동작하지 않는 서비스가 있었고(대표적으로 동영상 스트림) 서비스 복구를 위해 1) 재해 복구 사이트에서 서비스를 다시 구현하고 2) 고가용성 클러스터로 마이그레이션하는 두 트랙을 동시에 동시에 진행했다.
    - 22:48(UTC) Flexential이 회로 차단기를 모두 교체하고 전력을 복구했음을 확인했지만 하루종일 비상상태로 일한 Cloudflare 팀은 바로 이동하기 보다는 휴식 후 아침에 데이터센터로 가기로 결정했다. 약간 복구가 늦어지지만 추가적인 실수를 줄였다고 생각한다.
    - 11월 3일 새벽부터 PDX-DC04에서 작업을 시작하고 서버를 재구축하는데 3시간이 걸렸다.
    - 11월 4일 04시 25분(UTC) 완전히 복구한다.
- [**Gateway API v1.0: GA Release**](https://kubernetes.io/blog/2023/10/31/gateway-api-ga/) : Ingress API를 다음 버전인 Kubernetes의 Gateway API가 v1이 되었다.(영어)
- [**How Grafana Labs switched to Karpenter to reduce costs and complexities in Amazon EKS**](https://grafana.com/blog/2023/11/09/how-grafana-labs-switched-to-karpenter-to-reduce-costs-and-complexities-in-amazon-eks/) : AWS EKS에서 Kubernetes를 사용하는데 처음에는 Cluster Autoscaler(CA)를 사용하고 있었지만 이후 Karpenter로 갈아탔다. CA는 인스턴스 유형을 여러개 선택하더라도 확장될 때 어느 인스턴스 유형이 선택될지는 제어할 수 없어서 제약이 되었고 스팟 인스턴스를 사용할 때 스팟 인스턴스가 부족하다고 온디맨드로 대신 띄우는 등의 작업을 없었다. 이러한 문제를 해결하기 위해 Karpenter 도입했는데 Karpenter는 Kubernetes 네이티브 리소스를 사용해서 더 유연하게 용량 관리를 할 수 있고 용량 유형도 선택할 수 있었습니다. 적용할 때는 Karpenter가 프로비저너가 없으면 아무일도 하지 않으므로 먼저 Karpenter를 배포하고 CA를 끄면서 Karpenter의 프로비저너와 노드 템플릿을 제공해서 Karpenter로 자연스럽게 교체했다. 적용 이후 유휴 비율이 50% 감소했다고 한다.(영어)
- [**Manage log volumes, metrics cardinality, monthly bills: Explore Grafana Cloud cost management tools**](https://grafana.com/blog/2023/11/14/grafana-cloud-cost-management-tools-for-metrics-logs-and-more/) : Grfana Cloud에 비용 관리 허브가 추가되었다. 여기서는 누가 로그를 가장 많이 쌓았는지 카디널리티가 낮게 집계할 수 있는 권장 규칙도 제안하고 월별 비용을 볼 수 있다. 이 기능은 오픈소스는 아니고 그라파나 클라우드의 기능이다.(영어)
- [**Platform Engineering Maturity Model**](https://tag-app-delivery.cncf.io/whitepapers/platform-eng-maturity-model/) : CNCF에서 플랫폼 엔지니어링 성숙도 모델을 공개했다. 이 성숙도 모델은 조직마다 다를 수 있으므로 [Cloud Native Maturity Model](https://maturitymodel.cncf.io/)와 같이 평가해 보는 것이 좋고 각 측면에서 성숙도가 높아질 때마다 자금과 인력에 대한 요구사항도 같이 증가하므로 최고 수준에 도달하는 게 목표라기보다는 투자 여력을 고려해서 각 단계의 자질을 고려해야 한다.(영어)
- [**Preview Environments on Kubernetes with ArgoCD**](https://piotrminkowski.com/2023/06/19/preview-environments-on-kubernetes-with-argocd/) : ArgoCD와 Tekton을 이용해서 프리뷰 환경을 구성하는 방법을 설명한다. Argo CD를 이용해서 GitHub의 Pull Request를 모니터링하다가 새 브랜치나 커밋이 올라오면 Tekton으로 빌드하고 Argo CD의 앱을 생성해서 Kubernetes 클러스터에 프리뷰 환경을 배포하는 예시를 보여준다.(영어)
- [**Service Binding and Parameter Specification via the DNS (SVCB and HTTPS Resource Records)**](https://datatracker.ietf.org/doc/rfc9460/)[ **RFC 9460**](https://datatracker.ietf.org/doc/rfc9460/) : 새로운 DNS 레코드 타입인 SVCB와 HTTPS가 표준 명세가 되었다.(영어)

# 볼만한 링크

- [**Developer Productivity Engineering at Netflix**](https://thenewstack.io/developer-productivity-engineering-at-netflix/) : Netflix의 생산성 엔지니어링 디렉터인 Kathryn Koehler가 Netflix의 개발자 생산성 엔지니어링에 관해서 설명한 글이다. Netflix의 생산성 엔지니어링 조직은 개발자의 흐름을 방해하는 모든 것을 추상화하려고 하고 있고 티어를 나누어서 지원하고 있다. DORA 등의 정량적 지표로 생산성을 추적하지만 [The SPACE of Developer Productivity](https://queue.acm.org/detail.cfm?id=3454124) 활용해서 만족도와 효율성, 성능, 협업에 대한 정성적인 지표도 추적하고 있다. 하지만 설문조사는 어렵기 때문에 개발자들과 능동적인 커뮤니케이션을 하도록 유도하고 내부 플랫폼으로 포장된 길을 제공하려고 노력하고 있다고 한다.(영어)
- [**Octoverse: The state of open source and rise of AI in 2023**](https://github.blog/2023-11-08-the-state-of-open-source-and-ai/) : GitHub 데이터를 기준으로 오픈소스 생태계를 살펴보는 Octoverse 리포트가 공개되었다. 올해 보고서에서는 GenAI의 인기가 엄청나게 커져서 Top 10 프로젝트에 처음으로 AI 프로젝트가 들어왔고 Dockerfile과 IaC의 사용량이 많이 증가했으며 처음 오픈소스에 기여한 사람이 가장 많은 해가 되었다. 추가로 HCL 도입은 36% 성장했고 인기 언어는 JavaScript, Python, TypeScript, Java, C# 순이고 처음으로 TypeScript가 Java를 넘어섰다.(영어)
- [**GitHub Transparency Center**](https://transparencycenter.github.com/) : GitHub에서 개인정보와 관련해서 정부의 요청이나 DCMA 검토 등의 데이터를 공개하는 투명성 보고서를 2년마다 공개하고 있는데 이전 데이터를 쉽게 볼 수 있도록 투명성 센터를 오픈했다.(영어)

# IT 업계 뉴스

- [**Announcing Grok**](https://x.ai/) : 일론 머스크가 만든 xAI에서 LLM인 Grok를 공개했고 현재 대기목록에 등록 후 승인받으면 사용할 수 있다. 트위터의 실시간 지식을 보유하고 약간 재치 있는 대답도 한다고 한다.(영어)
- [**How Asserts.ai will make it even easier for Grafana Cloud users to understand their observability data**](https://grafana.com/blog/2023/11/14/grafana-labs-acquires-asserts/) : Grafana Labs에서 텔레메트리를 탐색하고 원인과 해결 방법을 쉽게 찾을 수 있게 하는 스타트업인 [Asserts.ai](https://www.asserts.ai/)를 인수했다.(영어)
- [**Ruby on Rails: The Documentary**](https://www.youtube.com/watch?v=HDKUEXBF3B4) : Honeypot에서 44분 정도 분량의 Ruby on Rails 다큐멘터리를 공개했다.(영어)
- [**eBPF: Unlocking the Kernel**](https://www.youtube.com/watch?v=Wb_vD3XZYOA) : Speakeasy Productions에서 30분 분량의 eBPF 다큐멘터리를 공개했다.(영어)
- [**공유오피스 기업 위워크, 미국서 결국 파산 신청**](https://www.bbc.com/korean/articles/c2529jnzezko) : 부채가 13~54조 원이 쌓인 WeWork가 지난 6일 미국에서 파산 신청을 했다.(한국어)
- [**Datadog acquires Actiondesk**](https://www.datadoghq.com/blog/datadog-acquires-actiondesk/) : Datadog이 라이브 데이터와 통합되는 스프레드 시트 애플리케이션을 만드는 Actiondesk를 인수했다.(영어)
- [**monaspace**](https://monaspace.githubnext.com/) : GitHub에서 굵기, 기울기, 폭 3개 축이 가변인 코딩용 폰트 5종을 공개했다.
- [**xk6-disruptor**](https://k6.io/docs/javascript-api/xk6-disruptor/) : Grafana k6의 확장으로 서비스에 오류를 주입해서 의존성 있는 서비스에 오류 비율이나 레이턴시에 대한 테스트를 할 수 있다. [공지 글](https://grafana.com/blog/2023/10/17/reproducing-and-testing-distributed-system-failures-with-xk6-disruptor/) 참고
- [**sshx**](https://sshx.io/) : 웹 기반으로 실시간 협업이 가능한 터미널.
- [**Misty Programming Language**](https://www.crockford.com/misty/introduction.html) : Douglas Crockford가 만든 범용 동적 액터 언어.

# 버전 업데이트

- [**Finch**](https://github.com/runfinch/finch) **v1.0** : Linux 컨테이너를 빌드, 실행하는 CLI, [릴리스 공지](https://aws.amazon.com/ko/blogs/opensource/ready-for-flight-announcing-finch-1-0-ga/)
- [**tsx**](https://github.com/privatenumber/tsx) **v4.0.0** : TypeScript를 실행하는 CLI, [릴리스 공지](https://github.com/privatenumber/tsx/releases/tag/v4.0.0)
- [**Docusaurus**](https://docusaurus.io/) **v3.0.0** : 문서 웹사이트 생성기, [릴리스 공지](https://docusaurus.io/blog/releases/3.0)
    - MDX v3 지원
- [**LitmusChaos**](https://hub.litmuschaos.io/) **v3.0.0** : 카오스 엔지니어링 플랫폼, [릴리스 공지](https://github.com/litmuschaos/litmus/releases/tag/3.0.0)
- [**Kubescape**](https://kubescape.io/) **v3.0** : Kubernetes 보안 플랫폼, [릴리스 공지](https://kubescape.io/blog/2023/09/19/introducing-kubescape-3/)
- [**Blender**](https://www.blender.org/) **v4.0** : 2D/3D 컨텐츠 제작 도구, [릴리스 공지](https://wiki.blender.org/wiki/Reference/Release_Notes/4.0)
- [**OBS Studio**](https://obsproject.com/) **v30.0** : 비디오 녹화 및 라이브 스트리밍 프로그램, [릴리스 공지](https://github.com/obsproject/obs-studio/releases/tag/30.0.0)
- [**Vitess**](https://vitess.io/) **18.0** : MySQL 클러스터링 시스템, [릴리스 공지](https://vitess.io/blog/2023-11-07-announcing-vitess-18/)
- [**ESLint**](http://eslint.org/) **v8.53.0** : JavaScript 코드 분석 도구, [릴리스 공지](https://eslint.org/blog/2023/11/eslint-v8.53.0-released/)
- [**NextUI**](https://nextui.org/) **v2.2.0** : React UI 라이브러리, [릴리스 공지](https://nextui.org/blog/v2.2.0)
- [**Zed**](https://zed.dev/) **v0.110.2** : 코드 에디터, [릴리스 공지](https://zed.dev/releases/stable#zed-0.110.2)
- [**Deno**](https://deno.land/) **v1.38.0** : TypeScript 런타임, [릴리스 공지](https://deno.com/blog/v1.38)
- [**Grafana Tempo**](https://grafana.com/oss/tempo/) **v2.3.0** : 분산 트레이싱 백엔드, [릴리스 공지](https://grafana.com/blog/2023/11/01/grafana-tempo-2.3-release-faster-trace-queries-traceql-upgrades/)
    - 전용 문자열 속성 열을 선택할 수 있는 Parquet의 최신 백엔드 버전인 vParquet3 지원
- [**Crossplane**](https://crossplane.io/) **v1.14.0**: 외부 인프라 관리용 Kubernetes 애드온, [릴리스 공지](https://blog.crossplane.io/crossplane-v1-14/)
- [**Zed**](https://zed.dev/) **v0.112.3** : 코드 에디터, [릴리스 공지](https://zed.dev/releases/stable#zed-0.112.3)
- [**WebdriverIO**](https://webdriver.io/) **v8.2.0** : Browser 테스트 자동화도구, [릴리스 공지](https://github.com/webdriverio/webdriverio/releases/tag/v8.22.0)
- [**Prisma**](https://www.prisma.io/) **v5.6.0** : TypeScript/Node.js 데이터베이스 툴킷, [릴리스 공지](https://github.com/prisma/prisma/releases/tag/5.6.0)
- [**Grafana Beyla**](https://grafana.com/oss/beyla-ebpf/) **1.0.0** : eBPF를 이용한 자동 계측, [릴리스 공지](https://grafana.com/blog/2023/11/14/grafana-beyla-1.0-release-zero-code-instrumentation-for-application-telemetry-using-ebpf/)
- [**Istio**](https://istio.io/) **v1.20.0** : 서비스 매쉬, [릴리스 공지](https://istio.io/latest/news/releases/1.20.x/announcing-1.20/)
    - GA가 된 Gateway API 지원
- [**Prettier**](https://github.com/jlongster/prettier) **v3.1.0** : JavaScript/TypeScript 포매터. [릴리스 공지](https://prettier.io/blog/2023/11/13/3.1.0)
- [**Hono**](https://hono.dev/) **v3.10.0** : 엣지용 웹 프레임워크, [릴리스 공지](https://github.com/honojs/hono/releases/tag/v3.10.0)
- [**k6**](https://k6.io/) **v0.47.0** : 부하 테스트 도구, [릴리스 공지](https://grafana.com/blog/2023/10/19/new-in-grafana-k6-the-latest-oss-features-in-v0.47.0-and-more-efficient-performance-testing-in-grafana-cloud-k6/)
- [**astro**](https://astro.build/) **v3.5** : JavaScript 웹 프레임워크, [릴리스 공지](https://astro.build/blog/astro-350/)
- [**Argo CD**](https://argoproj.github.io/argo-cd/) **v2.9.0** : Kubernetes 배포 도구, [릴리스 공지](https://github.com/argoproj/argo-cd/releases/tag/v2.9.0)
- [**play framework**](https://playframework.com/) **v2.9.0** : Java/Scala 웹 프레임워크, [릴리스 공지](https://github.com/playframework/playframework/releases/tag/2.9.0)
- [**play framework**](https://playframework.com/) **v3.0.0** : Java/Scala 웹 프레임워크, [릴리스 공지](https://github.com/playframework/playframework/releases/tag/3.0.0)
- [**Node.js**](http://nodejs.org/) **v21.2.0 (Current))** : 자바스크립트 런타임, [릴리스 공지](https://nodejs.org/en/blog/release/v21.2.0)
- [**KubeVirt**](https://kubevirt.io/) **v1.1.0** : Kubernetes의 가상 머신 관리 애드온, [릴리스 공지](https://github.com/kubevirt/kubevirt/releases/tag/v1.1.0)

# 웹개발 관련

- [**Why I Won't Use Next.js**](https://www.epicweb.dev/why-i-wont-use-nextjs) : [Remix](https://remix.run/)가 나오고 Remix를 계속 지지하던 Kent C. Dodds가 Next.js의 문제를 지적하는 글을 썼다.(영어)
    - React의 테스트 프레임워크인 Enzyme에 불만이 있어서 Testing Library를 만들었는데 주요한 점은 이식성 때문이었다. Remix는 표준 웹 플랫폼을 그대로 이용하는 경우가 많아서 Remix에 익숙해 지면 웹에도 익숙해지지만 Next.js는 자신만의 API가 있어서 Enzyme과 비슷한 상황이라고 할 수 있다.
    - Next.js는 Vercel 외에는 배포하기가 어렵기 때문에 OpenNext가 나올 정도이다. 이는 Vercel의 호스팅을 매력적으로 만들고자 한 것이지만 어디서나 배포할 수 있도록 하는 작업의 우선순위가 낮은 것은 분명하다. Remix는 JavaScript를 실행할 수 있는 모든 곳에 배포할 수 있게 설계되었다.
    - Meta가 React를 소유할 때도 불안했지만 Vercel이 React 팀원들을 데려간 이후에는 오히려 덜 협조적으로 느껴졌다. Vercel은 Next.js와 React의 경계를 모호하게 하는 것처럼 보인다.
    - Next.js의 안정적인 기능이 React에서는 카나리아 릴리스에 있는 이상한 상황이 종종 있다.
    - 너무 많은 마법을 사용하는 데 대표적으로 `fetch`를 재정의해서 자동 캐싱을 추가한 것이다.
- [**Why I'm Using Next.js**](https://leerob.io/blog/using-nextjs) : 위 Kent C. Dodds가 쓴 글에 Vercel의 VP of DX인 Lee Robinson가 반박 글을 작성했다.(영어)
    - 웹 플랫폼을 그래도 이용해야 한다는 것에 동의하기에 Next.js도 2021년에는 미들웨어를 도입했고 이는 Remix가 출시된 해이기도 하다. 그리고 앱 라우터에서도 웹 플랫폼 API를 그대로 사용할 수 있다.
    - Vercel은 Next.js를 Docker로 배포하는 방법에 대한 예제와 가이드를 하고 있고 셀프호스팅 할 수 있는 다양한 방법이 있다. 또한 Build Output API도 제공하고 있다.
    - React와 Next.js의 경계를 모호하게 한다는 지적에 대해서는 고의가 아니며 React의 미래에 크게 걸고 있고 작업하는 중이며 경계를 명확하게 할 수 있도록 노력하고 있다.
    - `fetch`에 대한 마법도 개선하려고 노력하고 있다.
    - 마지막으로 Next.js를 좋아하는 이유는 별도의 백엔드를 만들 필요가 없고 인프라 걱정 없이 앱을 만들 수 있으면 사이트를 따르게 하는 기능을 다양하게 제공한다는 점이다.
- [**Introducing HAR Sanitizer: secure HAR sharing**](https://blog.cloudflare.com/introducing-har-sanitizer-secure-har-sharing/) : HTTP 아카이브 파일인 HAR는 웹브라우저와 웹 애플리케이션의 상호 작용에 대한 JSON 형식의 아카이브 파일인데 여기엔 인증 정보도 모두 담겨있기 때문에 세션 쿠키나 JWT 토큰이 유출되는 가장 일반적인 경로이기도 하다. Cloudflare에서는 [HAR File Sanitizer](https://har-sanitizer.pages.dev/)를 공개해서 사용자가 HAR 파일을 업로드하면 쿠키, JWT 등을 모두 제거할 수 있게 했고 이 도구는 Cloudflare Workders 기반이고 모든 처리는 클라이언트에서 진행되므로 Cloudflare에서도 내용을 볼 수 없다고 한다.(영어)

# 그 밖의 개발 관련

- [**Progress on no-GIL CPython**](https://lwn.net/Articles/947138/) : 지난 7월 Python steering council이 Global Interpreter Lock(GIL)을 선택 사항으로 만들겠다는 제안을 승인하겠다고 발표했습니다. 아직 결정 나진 않았지만, 그동안의 진행 과정을 정리한 글입니다. CPython 안정 ABI로 빌드된 확장 프로그램은 no-GIL CPython 3.13에서는 동작하지 않을 것이라서 이에 대한 해결책으로 둘을 모두 지원하는 새로운 ABI를 만들자는 의견도 있고 확장 프로그램이 두 가지 빌드를 모두 만드는 것이 오히려 비용면에서 낫다는 의견도 있다. 또한 이름에 대한 이슈도 있는데 사용자들이 테스트할 수 있도록 `python3` 외에 no-GIL도 설치해서 테스트해 봐야 하는데 `python-nogil3`, `python-nogil3.13` 등의 이름도 제안되었고 반대로 GIL이 뭔지 일반적인 개발자들이 알 필요 없으므로 nogil이라는 단어를 사용하지 않아야 한다는 의견도 있다. 이후 새로운 ABI인 abi4를 만들자는 아이디어를 채택해서 프로토타입을 개발 중이며 PEP가 필요하다는 데까지 합의가 된 상황이다.(영어)
- [**Kafka에서 파티션 증가 없이 동시 처리량을 늘리는 방법 - Parallel Consumer**](https://d2.naver.com/helloworld/7181840) : Kafka를 사용할 때 기본적으로 파티션 하나당 하나의 컨슈머만 붙을 수 있기 때문에 컨슈머가 메시지가 발행되는 속도를 따라가지 못한다면 Lag가 쌓이기 때문에 파티션을 늘려야 한다. 이는 프로듀서하고도 논의해서 늘려야 하는 부분이고 한번 늘리면 줄일 수 없기 때문에 문제가 되는데 Parallel Consumer를 이용해서 파티션을 늘리지 않고 처리량을 늘리는 방법을 설명한다. 기본 컨슈머와 Parallel Consumer의 동작 차이를 설명하고 오프셋 갱신의 처리 방법, 순서 보장 방법을 자세히 설명하고 있다.(한국어)
- [**쿠버네티스가 스프링 부트 3.0 네이티브 이미지를 만났네**](https://netmarble.engineering/spring-boot-3-0-native-image-on-kubernetes/) : 넷마블에서 JVM 이미지가 부팅 시간 때문에 팟이 늘어가는 데 걸리는 시간을 줄이기 위해 SpringBoot 3.0부터 GraalVM의 Native Image 생성 기능을 도입했다. 네이티브 이미지는 독립적으로 실행할 수 있도록 실행 환경에 맞춰서 빌드하므로 용량이 작고 부팅 시간도 크게 줄어들게 된다. 네이티브 이미지를 만드는 방법을 설명하고 이를 적용하면서 GC 설정과 리소스 설정을 적용하면서 차이를 보여주고 최종적으로는 50초였던 실행시간이 2초로 줄어들었고 이미지 크기도 300MB에서 70MB로 줄어들었다고 한다.(한국어)
- [**Base64 Encoding, Explained**](https://www.writesoftwarewell.com/base64-encoding-explained/) : 개발하면서 자주 보는 Base64의 동작 방식을 RFC 4648을 공부하고 정리한 글이다. 대소문자 알파벳, 숫자, +, /의 64개의 문자를 사용해서 Base64인데 주어진 텍스트를 이진 표현으로 변환한 뒤 각 비트를 6비트로 나누고 각 그룹을 0~63 사이의 소수로 변환한 뒤에 Base64 알파벳으로 변환한다.(영어)

# 인프라 관련

- [**Measuring Git performance with OpenTelemetry**](https://github.blog/2023-10-16-measuring-git-performance-with-opentelemetry/) : Microsoft가 Windows나 Office의 저장소를 Git으로 마이그레이션 했을 때 300GB가 넘었고 역대 가장 큰 규모였기에 성능 개선이 필요했고 Git의 성능을 알 수 있도록 [Trace2](https://github.com/git/git/blob/master/Documentation/technical/api-trace2.txt) 기능을 Git에 포함했다. 이 Trace2만으로는 분석하기가 어렵기에 이를 OpenTelemetry로 수집할 수 있도록 오픈소스 수집기인 [trace2receiver](https://github.com/git-ecosystem/trace2receiver)를 만들었다. 이를 통해 Git 명령어를 사용할 때 시간이 오래 걸리는 부분은 분석 추적해서 파악할 수 있게 되었다.(영어)
- [**Vector를 활용해 멀티 CDN 로그 및 트래픽 관리하기**](https://techblog.lycorp.co.jp/ko/managing-multi-cdn-logs-traffics-with-vector) : Line에서 멀티 CDN을 사용하면서 로그와 트래픽을 모니터링하면서 Datadog에서 만든 [Vector](https://vector.dev/)를 사용한 이야기이다. 기존에 모니터링이 있었지만, 시간이 지나면서 유지보수도 편하고 통합으로 관리할 수 있는 모니터링 체계가 필요했고 [Vector](https://vector.dev/)를 사용하게 되었다. Vector는 데이터를 수신하는 source, 데이터를 변환하는 transforms, 데이터를 전송하는 sinks 단계로 구성되는 Aggregator 구성으로 Vector를 설치해서 `log_to_metric` 기능으로 CDN 로그를 받아서 메트릭으로 변환해서 Prometheus로 쏠 수 있게 구성했다.(한국어)
- [**OWASP Kubernetes Top 10: A Comprehensive Guide**](https://medium.com/@seifeddinerajhi/owasp-kubernetes-top-10-a-comprehensive-guide-f03af6fd66ed) : OWASP(Open Web Application Security Project)의 10대 Kubernetes 취약점을 하나씩 설명한 글이다.(영어)
    1. 안전하지 않은 워크로드 구성: Alpine 등 가벼운 이미지를 사용해서 위험성을 최소화하는 것이 좋고 OPA 등으로 잘못된 구성을 차단하는 것도 좋다.
    2. 공급망 취약점: Docker Hub의 이미지에도 많은 취약점이 포함되어 있으므로 이미지 스캔을 해야 한다.
    3. 지나치게 허용적인 RBAC: RBAC Audit, Kubescan, Krane 같은 도구로 검사할 수 있다.
    4. 중앙화된 정책 시행의 부재: Admission Controller로 필요한 정책을 적용할 수 있다.
    5. 부적절한 로깅: 감사로그뿐 아니라 OS 로그, 네트워크 활동 로그 등을 남기고 모니터링해야 한다.
    6. 인증 실패: 인증할 때는 반드시 2FA로 사람이 개입하도록 해야 하면 Falco 등으로 로그인을 감사할 수 있다.
    7. 네트워크 세분화: Istio같은 서비스 메시나 CNI로 부적절한 내부 접근을 제어할 수 있다.
    8. 시크릿 관리 실패
    9. 잘못 구성된 클러스터 컴포넌트: 대표적인 실수로 Kubelet에 익명 인증 설정이 있고 kube-apiserver에서 TLS 구성을 추가
    10. 오래되고 취약점이 있는 Kubernetes 컴포넌트: Kubernetes에서 취약점이 존재하므로 취약점 정보를 모니터링하고 업데이트해야 한다.

# 볼만한 링크

- [**컴퓨터 해킹. 자유. 그리고 GNU.**](https://kldp.org/node/166455) : GNU의 40주년을 기념한 모임이 스위스에서 열렸는데 이때 참석하신 분이 올리신 후기다. 글을 잘 쓰셔서 GNU를 어떻게 느끼고 있었고 왜 참여하고 무엇을 느꼈는지를 정리해 주셨는데 느껴지는 부분이 많다.(한국어)
- [**Announcing the Recipients of the 2023 Spotify FOSS Fund**](https://engineering.atspotify.com/2023/10/announcing-the-recipients-of-the-2023-spotify-foss-fund/) : 작년에 Spotify에서 FOSS 펀드를 만들고 올해도 10만 유로(약 1억 4천만 원)로 AssertJ, Jdbi,Testcontainers, Xiph를 지원한다. 이 프로젝트는 내부 R&D 커뮤니티가 추천했다.(영어)
- [**The Startup CTO's Handbook**](https://github.com/ZachGoldberg/Startup-CTO-Handbook) : CTO의 리더십, 관리, 기술 주제를 다루는 책으로 아마존에서 판매하고 있지만 저장소에서 원문 파일과 PDF 파일을 무료로 볼 수 있다.(영어)

# IT 업계 뉴스

- [**Tracking Unauthorized Access to Okta's Support System**](https://sec.okta.com/harfiles) : Okta에서 도난당한 인증 정보를 이용한 악의적인 접근이 확인되어서 영향받은 모든 고객에게 알림을 보냈다. 이 글에는 아주 명확히 설명하고 있진 않지만, 고객센터에 HTTP 아카이브 파일인 HAR 파일을 업로드하게 하고 있는데 이 파일이 제대로 살균되지 않았고 이 파일이 도난당하면서 이 파일의 인증 정보로 공격자가 접근할 수 있었다.(영어)
- [**AI.gov**](https://ai.gov/) : 미국 바이든-해리스 행정부가 AI의 이점을 활용하고 위험을 완화하기 위해 미국 정부의 AI에 대한 방향성을 안내하고 AI 인력을 채용하기 위한 사이트를 공개했다. 이 사이트에서 AI 전문가가 정부의 움직임에 참여해 주기를 제안하고 있다.(영어)
- [**HHKB Studio**](https://www.pfu.ricoh.com/news/2023/news231025.html) : HHKB 키보드에 포인팅 스틱과 마우스 버튼, 제스처 패드가 포함된 기계식 키보드를 출시했다.(일본어)
- [**Microsoft의 급여 가이드라인 유출. 연봉, 채용 보너스 및 주식 보상범위가 직급별로 공개됨**](https://news.hada.io/topic?id=11405) : 비즈니스인사이더에서 유출된 Microsoft의 직급별 연봉과 보상 범위를 공개했다. 52 레벨부터 70 레벨까지 있으면 각 레벨별 연봉 범위와 보너스, 주식 보너스 범위를 볼 수 있다.(한국어)
- [**WintetJS**](https://github.com/wasmerio/winterjs) : Rust로 작성된 JavaScript 서비스 워커 서버로 SpiderMonkey 런타임을 사용하고 Cloudflare Workers, Deno Deploy, Vercel 처럼 WinterCG 스펙을 따름. 아주 빠를 뿐 아니라 WebAssembly로도 컴파일 가능. [릴리스 공지](https://wasmer.io/posts/announcing-winterjs-service-workers)
- [**Geist**](https://vercel.com/font/sans) : Vercel에서 오픈소스 무료 폰트를 공개했다. Sans, Mono 2가지 종류다.
- [**Skiff**](https://github.com/basecamp/kamal-skiff) : DHH가 [Kamal](https://kamal-deploy.org/)을 이용해서 정적 사이트를 nginx와 함께 배포하는 도구로 [once.com](https://once.com/)을 만들 때 사용했다고 한다.
- [**Is BGP safe yet?**](https://isbgpsafeyet.com/) : Border Gateway Protocol(BGP)를 안전하게 하려면 RRKI를 구현해야 하는데 사용하는 ISP의 BGP가 안전한지 보여주는 사이트로 Cloudflare에서 만들었다.
- [**JetBrains Writerside**](https://www.jetbrains.com/ko-kr/writerside/) : JetBrains에서 문서작성 도구를 공개했다.

# 버전 업데이트

- [**Next.js**](https://github.com/zeit/next.js) **14** : 서버렌더링 React 애플리케이션 프레임워크, [릴리스 공지](https://nextjs.org/blog/next-14)
    - App/Pages 라우터에 5,000개의 테스트를 추가한 Turbopack으로 로컬 서버 시작 시간이 53% 빨라지고 코드 갱신이 94% 빨라짐.
    - Server Actions가 Stable이 됨
    - Partial Prerendering Preview 지원
    - Next.js를 배울 수 있는 새로운 학습 사이트 Next.js Learn 공개
- [**yarn**](https://yarnpkg.com/) **v4.0.0** : Node.js 패키지 매니저, [릴리스 공지](https://yarnpkg.com/blog/release/4.0)
- [**Node.js**](http://nodejs.org/) **v20.9.0 Iron(LTS)** : 자바스크립트 런타임, [릴리스 공지](https://nodejs.org/en/blog/release/v20.9.0)
    - Node.js의 새로운 LTS 버전인 Iron으로 24년 10월까지 활성 LTS로 관리되고 26년 4월까지 유지보수 모드로 지원된다.
- [**Node.js**](http://nodejs.org/) **v21.0.0 (Current))** : 자바스크립트 런타임, [릴리스 공지](https://nodejs.org/en/blog/announcements/v21-release-announce)
    - 새 LTS가 나옴에 따라 다음 Current 버전인 21이 나왔다.
    - V8 엔진이 11.8로 업데이트되면서 안정화된 `fetch`, `WebStreams`를 지원
- [**MDX**](https://github.com/mdx-js/mdx) **v3.0.0** : JSX 확장 마크다운, [릴리스 공지](https://mdxjs.com/blog/v3/)
- [**MSW**](https://mswjs.io/) **v2.0.0** : JavaScript API Mocking 라이브러리, [릴리스 공지](https://github.com/mswjs/msw/releases/tag/v2.0.0)
- [**Playwright**](https://playwright.dev/) **v1.39.0** : Chromium, Firefox, WebKit 브라우저 자동화 Node.js 라이브러리, [릴리스 공지](https://github.com/microsoft/playwright/releases/tag/v1.39.0)
- [**Safari**](https://www.apple.com/kr/safari/) **17.1** : 웹브라우저, [릴리스 공지](https://webkit.org/blog/14735/webkit-features-in-safari-17-1/)
- [**k6**](https://k6.io/) **v0.47.0** : 부하 테스트 도구, [릴리스 공지](https://grafana.com/blog/2023/10/19/new-in-grafana-k6-the-latest-oss-features-in-v0.47.0-and-more-efficient-performance-testing-in-grafana-cloud-k6/)
- [**astro**](https://astro.build/) **v3.4** : 정적 사이트 빌더, [릴리스 공지](https://astro.build/blog/astro-340/)
    - page 컴포넌트가 이제 partial page로 인식되어 DOCTYPE 없이도 HTML을 렌더링함
- [**Hono**](https://hono.dev/) **v3.9.0** : 엣지용 웹 프레임워크, [릴리스 공지](https://github.com/honojs/hono/releases/tag/v3.9.0)
- [**Prisma**](https://www.prisma.io/) **v5.5.0** : TypeScript/Node.js 데이터베이스 툴킷, [릴리스 공지](https://github.com/prisma/prisma/releases/tag/5.5.0)
- [**Grafana**](http://grafana.org/) **v10.2** : 매트릭 대쉬보드, [릴리스 공지](https://grafana.com/blog/2023/10/24/grafana-10.2-release-grafana-panel-title-generator-interactive-visualizations-and-more/)
- [**Mikro ORM**](https://mikro-orm.io/) **v5.9.0** : TypeScript ORM, [릴리스 공지](https://github.com/mikro-orm/mikro-orm/releases/tag/v5.9.0)
- [**Jotai**](https://jotai.org/) **v2.5.0** : React 상태 관리 라이브러리, [릴리스 공지](https://github.com/pmndrs/jotai/releases/tag/v2.5.0)
- [**Storybook**](https://storybook.js.org/) **v7.5.0** : React, Vue3, Angular UI 컴포넌트 개발 도구, [릴리스 공지](https://storybook.js.org/blog/storybook-7-5/)
- [**Dagger**](https://dagger.io/) **v0.9** : CI/CD Pipeline as Code, [릴리스 공지](https://dagger.io/blog/dagger-0-9)
- [**Nuxt.js**](https://nuxtjs.org/) **v3.8.0** : 서버렌더링 Vue.js 애플리케이션 프레임워크, [릴리스 공지](https://nuxt.com/blog/v3-8)
- [**ESLint**](http://eslint.org/) **v8.52.0** : JavaScript 코드 분석 도구, [릴리스 공지](https://eslint.org/blog/2023/10/eslint-v8.52.0-released/)
- [**pgAdmin**](https://www.pgadmin.org/) **4 v7.8** : PostgreSQL 클라이언트 도구, [릴리스 공지](https://www.postgresql.org/about/news/pgadmin-4-v78-released-2738/)
- [**GitLab**](https://about.gitlab.com/) **v16.5** : 오픈소스 설치형 Git 플랫폼, [릴리스 공지](https://about.gitlab.com/releases/2023/10/22/gitlab-16-5-released/)
- [**PgBouncer**](https://www.pgbouncer.org/) **v1.21.0** : PostgreSQL 커넥션 풀, [릴리스 공지](https://www.postgresql.org/about/news/pgbouncer-1210-released-now-with-prepared-statements-2735/)
- [**CDK for Terraform**](https://github.com/hashicorp/terraform-cdk) **v0.19.0** : Terraform Cloud Development Kit, [릴리스 공지](https://www.hashicorp.com/blog/cdktf-0-19-adds-support-for-config-driven-import-and-refactoring)
- [**Zed**](https://zed.dev/) **v0.109.3** : 코드 에디터, [릴리스 공지](https://zed.dev/releases/stable#zed-0.109.3)
- [**Nuxt DevTools**](https://devtools.nuxtjs.org/) **v1.0.0** : Nuxt 개발자 도구, [릴리스 공지](https://github.com/nuxt/devtools/releases/tag/v1.0.0)
- [**Remix**](https://remix.run/) **v1.9.0** : 풀스택 웹 프레임워크, [릴리스 공지](https://github.com/remix-run/remix/releases/tag/remix%402.1.0)
    - View Transitions API의 실험적 지원
- [**Ubuntu**](https://www.ubuntu.com/) **23.10 Mantic Minotaur** : Linux 배포판, [릴리스 공지](https://canonical.com/blog/canonical-releases-ubuntu-23-10-mantic-minotaur-kr)
- [**Docker Desktop**](https://www.docker.com/products/docker-desktop) **v4.24** : 데스크톱용 Docker 애플리케이션, [릴리스 공지](https://www.docker.com/blog/docker-desktop-4-24-compose-watch-resource-saver-and-docker-engine/)
- [**Docker Desktop**](https://www.docker.com/products/docker-desktop) **v4.25** : 데스크톱용 Docker 애플리케이션, [릴리스 공지](https://www.docker.com/blog/docker-desktop-4-25/)
- [**Open Policy Agent**](https://www.openpolicyagent.org/) **v0.58.0** : 클라우드 네이티브 환경의 정책 엔진, [릴리스 공지](https://github.com/open-policy-agent/opa/releases/tag/v0.58.0)

트위터에서 역자이신 [박상민 님이 인생에서 제일로 꼽을 만큼 좋은 책이라고 얘기](https://twitter.com/sm_park/status/1689664288116678656)하는 걸 보고 이 책을 알게 되었다. 처음 이 책의 제목을 보았을 때 좀 의아한 생각이 들었다. 아마 "무엇을?"이라는 의문이었을 것 같다. 무엇을 컴퓨터라고 부른다는 것이지? 라는 생각이었다.

> 
>
> 뛰어난 프로그래머의 한 가지 특징은 추상화의 단계 사이를 너무나 쉽게 넘나드는 능력이다.
>
>
> - 도널드 커누스(Donald Knuth)
>
>

이 책은 지금의 컴퓨터가 만들어지기까지의 과정을 다루지만 그동안 많이 봤던 대로 MIT의 TMRC나 벨 연구소의 얘기보다 훨씬 과거까지 간다.

> 
>
> 이 책은 현대 컴퓨터의 근간을 이루는 아이디어와 그 아이디어를 발견한 사람들의 이야기다.
>
>
> 
>
> 오늘날 컴퓨터 기술이 눈부신 속도로 발전하고 사람들은 공학 기술의 놀라운 성취에 감탄하지만, 이 모든 걸 가능케 한 논리학자들은 쉽게 간과하곤 한다. 이 책은 그들에 대한 이야기다.
>
>

책에 나오는 대로 컴퓨터가 만들어지기까지 그 전의 논리학자들에 대한 이야기이다. 이야기의 시작은 1600년대의 라이프니츠부터 시작된다. 처음 책을 읽을 때 느낌은 여기서부터 시작한다고? 같은 기분이었다. 책의 대부분은 수학과 논리학에 대한 이야기였다. 그래서 수학을 잘 못하는 나한테는 꽤 어려웠다. 많은 증명과 논리학에 대한 이야기로 이어지는데 설명이 꽤 자세하기는 하지만 아무래도 수학을 잘 아는 편은 아니라서 대략적인 흐름 외의 자세한 부분까지는 이해하기가 어려웠다.


그럼에도 꽤 흥미롭기는 했다. 지금의 내가 접하는 컴퓨터는 모두 디지털로 된 것이지만 지금의 컴퓨터가 만들어지기 까지 수많은 수학자들이 서로 논쟁하고 자기 생각을 증명하면서 발전해 오는 과정에서 결국 튜링과 폰 노이만까지 이어지고 이들이 과거의 연구를 구현하면서 결국 컴퓨터가 만들어졌다는 것은 놀랍기까지 하다. 한편으로는 내가 수학을 더 잘했으면 이 책이 훨씬 더 재밌을 것이라는 생각도 들었다.

> 
>
> 라이프니츠의 비전은 인간의 모든 지식 또한 같은 방식으로 풀어내는 것이었다. 그는 범용의 수학 언어로 온 세상 지식을 표현하고 계산법이 지식과 지식 사이의 논리적 관계를 설명할 수 있는 완전한 지식의 백과사전을 꿈꾸었다.
>
>
> 
>
> 이 체계는 대단히 강력한데, 그중 이 문자 체계를 사용하면 말이 안 되는 것(거짓된 사실)들은 표현할 수 없다는 점이 특히 중요합니다. 무지한 사람은 그 체계를 사용할 수 없습니다. 아니면 그 체계를 사용하면서 똑똑해질 것입니다.
>
>
> 
>
> 라이프니츠는 숫자를 0과 1의 연속으로 표현하는 이진법을 발견했을 때 그 기호 체계의 간결함에 감탄했다. 그 간결한 체계가 고유한 성질을 드러내는 데 유용할 거라 믿었다. 비록 그의 믿음은 증명되지 않았지만 라이프니츠가 이진법에 특별한 관심을 보였다는 부분은 현대 컴퓨터 체계에 있어 이진법이 얼마나 중요한지를 살펴볼 때 놀랍다고 할 수 있다.
>
>
> 
>
> 능력이 부족한 다른 사람들이 그의 연구를 무시하는 상황에서 프레게는 인생 전체의 노력을 집대성하는 책 두 번째 편의 출간을 앞두고 있었습니다. 그러나 자신의 핵심적인 가정에 오류를 발견한 바로 그 순간에도 개인적인 실망은 접어두고 지적인 즐거움을 표현하며 답장을 보냈습니다. 보통 사람이라면 거의 상상하기 어려운 일이었고, 인간이 명성이나 지위를 좇기보다 창조적인 일과 지식에 헌신할 때 얼마나 위대해질 수 있는지 보여 주는 사례라 할 수 있습니다.
>
>
> 
>
> 그의 목표는 모든 수학의 기초에 논리가 있음을 보이는 것이었다. 다시 말해 논리가 다른 수학 분야 전체에 근본을 제공해야 했다. 이게 설득력을 갖기 위해서 프레게는 논리를 개발하는 과정에서 기존의 논리를 사용하지 않아야 했다.
>
>
> 그는 한 치도 틀림없이 정확한 문법을 갖춘 인공적인 언어인 개념 표기법(Begriffsschrift)을 만들어 이를 해결하려 했다. 이를 사용하면 논리적인 추론이 기호가 배열된 패턴의 단순한 기계적인 처리로 대체된다. 이것은 또한 정밀한 문법을 갖춘 최초의 정규화된 가상 언어였다. 이 관점으로 볼 때, 프레게의 개념 표기법은 오늘날 사용하는 모든 컴퓨터 언어의 시조인 것이다.
>
>
> 
>
> 괴델은 근본적으로 사람의 사고가 컴퓨터와 동일한가라는 질문을 던졌다. 인공 지능을 둘러싸고 여전히 격렬하게 논쟁이 벌어지는 질문이다.
>
>
> 
>
> 분명히 우리가 생각하는 연상(computation)의 정의는 급격하게 변했다. 연산의 정의를 이렇게 넓힐 수 있도록 한 개념적 토대는 1935년 앨런 튜링이 힐베르트의 논리 수학 문제를 해결하는 과정에서 만들어졌다.
>
>
> 
>
> 중요한 점은 튜링이 우리가 계산이라고 부르는 과정을 분석한 결과 모든 계산이 가능한 것들은 튜링 기계에서 동작하는 알고리즘으로 표현할 수 있다는 사실이다. 그래서 어떤 특정한 문제를 튜링 기계에서 수행할 수 없다고 증명한다면 그러한 문제를 해결하는 알고리즘은 존재하지 않는다고 결론 내릴 수 있다. 그리고 이게 튜링이 결정 문제를 해결하는 알고리즘이 존재하지 않는다고 증명한 방식이다. 이 과정에서 튜링이 알고리즘이 존재하는 모든 문제를 계산할 수 있는 튜링 기계를 어떻게 만드는지를 보였다. 바로 범용 컴퓨터의 수학적 모델을 만든 것이다.
>
>
> 
>
> 에니악이 계산을 위해 수를 십진수로 나타낸 반면에 에드박은 이진법을 사용해 계산을 단순하게 만들었다. 또한 에드박은 논리 제어 기관을 두고 메모리부터 명령어를 한 번에 한 개씩 읽어 계산 부분으로 넘겨주었다. 이렇게 컴퓨터를 구성하는 방식은 '폰 노이만 구조'라고 불리게 되었고 에드박 당시와는 아주 다른 부품을 사용하는 현대의 컴퓨터 역시 여전히 이 기본 구조를 따르고 있다.
>
>
> 
>
> 오늘날 우리가 사용하는 개인 컴퓨터는 칩 하나로 만들어진 범용 컴퓨터라 볼 수 있는데 칩을 구성하는 실리콘 마이크로프로세서는 시간이 갈수록 더 복잡해졌다. 그 반대의 방향인 RISC(Reduced Instruction Set Computing) 구조는 칩 내부에 최소한의 명령어들만 사용하고 그 외의 필요한 기능들은 프로그래밍으로 제공된다. 많은 컴퓨터 제작사들이 사용하는 RISC 구조는 에이스(Automatic Computin Engine)의 철학과 아주 비슷한 방향이라고 볼 수 있다.
>
>

회사에서 다른 리더들과 독서 모임으로 읽은 책이다. 책의 저자인 마이클 롭은 넷스케이프, 애플, 슬랙을 거치면서 리더로 성장한 경험을 에세이처럼 30장에 걸쳐서 조언을 제공하고 있다. 각 장은 다른 조언을 얘기하고 있어서 개별 장을 꼭 이어서 읽을 필요는 없고 모든 걸 다 따른다기보다 자신의 상황에 맞는 조언 혹은 습관만 적용하는 식으로 책을 읽을 수 있다.


리더십 책을 인상 깊게 보는 경우가 많진 않은 느낌이긴 한데 이번 책도 그렇게 인상 깊지는 않았다. 기본적으로 책이란 건 의식하든 의식하지 못하든 내가 고민하는 부분이나 가려운 부분을 긁어줄 때 좋다고 느끼기 마련이라 책을 읽는 타이밍 등이 중요하다고는 생각하는데 리더십에 대한 고민이 없다기보다는 대부분은 사람의 문제인 경우가 많아서 책에 나온 내용으로는 그리 도움받는다는 느낌을 못 받아서 그런 거 같긴 하다.


각 장은 꽤 짧은데 말하고자 하는 내용이나 예시가 잘 공감되지 않은 부분도 있고 너무 추상적인 말이거나 이어지지 않는 느낌도 있어서 책이 크게 좋게 느껴지진 않았다. 책보다는 같이 독서 모임을 하는 다른 리더들과 얘기를 나눌 수 있어서 좋았고 내가 그냥 지나친 내용을 다른 사람이 인상 깊게 느꼈다는 얘기를 들으면서 다시 한번 더 생각해 보게 되기도 했다.


책에서 인상 깊게 느꼈던 부분을 그래도 정리해 보면...

> 
>
> 내가 특히 좋아하는 리더십 습관은 일대일 회의다. 일대일 회의의 전도사라고 불릴 정도다. 수십 년에 걸쳐 매주 일대일 회의를 진행했고 직속 팀원들과 매주 얼굴을 맞댔다. 일대일 회의는 함께 일하는 사람들 간의 신뢰를 구축하는 가장 단순하고 믿을 만한 방식이다. 팀 전체에 영향을 미치는 현재의 사건에 관해 폭넓은 대화를 나눌 기회이기 때문이다.
>
>

일대일 회의는 사실 지금 있는 회사에서 거의 처음 해보고 있다. 뭐 리더 경험이 많지 않은 것도 사실이다. 그동안 내가 경력을 쌓으면서 일대일 회의를 하고 싶다거나 하는 생각을 별로 안 해서 그런지 나도 일대일 회의에 대한 가치를 아주 크게 느끼진 않고 있지만 회사에서 하고 있기도 하고 많은 책에서 권장하고 있어서 가능하면 일대일 회의는 미루지 않고 하려고 하고 있다. 여전히 일대일 회의에서 무엇을 논의해야 하는가 하는 어려움은 있지만 그래도 일대일 회의를 주기적으로 하면서(나는 지금 한 달에 한 번씩 하고 있다) 동료들의 상황을 파악할 수 있다는(어디까지 솔직히 얘기하는지는 알 수 없지만) 장점은 확실히 느껴진다.

> 
>
> 팀장 회의 후에는 반드시 회의 내용을 팀원들에게 알려주어야 한다. 회의에서 무엇을 논의했는가? 이 일에서 무엇을 배워야 하는가? 이후에는 어떤 일이 생길까? 팀원 모두는 팀장급 회의가 열렸다는 사실을 알 뿐 회의에서 '무슨 일이' 있었는지는 모른다. 회의 내용을 팀원들과 공유하라. 리더로서의 '점수'를 거저로 딸 기회다.
>
>
> 
>
> 회의 내용을 모두와 공유하라. 그렇게 하면 의사소통 오류가 줄고 사내 정치에 대한 예방 접종이 되어 면역력을 키우는 데 도움이 될 것이다. 뿐만 아니라 예상치 못한 뜻밖의 행운이 찾아오리라.
>
>

개인적으로 신경 쓰는 부분이다. 사안에 따라서 그러기 힘든 부분도 있지만 가능하면 결정이 나지 않더라도 어떤 논의를 하고 있는지 최대한 빨리 공유하려고 하고 있다. 그렇다고 회의 끝나고 팀원을 다시 모아서 회의를 여는 것도 어색하긴 해서 다음 정기 회의 때까지 기다리긴 하지만 그렇게 키워드를 공유해 놓는 것들이 나중에 진행되는 논의에서도 도움이 되는 것 같다.

> 
>
> 나는 어떤 유형의 리더를 싫어하는지 정확히 말할 수 있다. 사람들이 즉흥적으로 행동하거나 반복할 수 없도록 또는 피드백의 여지를 주지 않으려 행동 하나하나를 짚어주는 리더가 싫다.
>
>

이런 리더는 나도 싫다. 그래서 그러지 않으려고 더 노력하다 보니 어떤 면에서는 책임을 회피하고 있는 건가? 싶을 때도 있다.

> 
>
> 리더로서 당신에게는 확실한 무기가 있다. 바로 축적된 경험이다. 축적된 경험이야말로 리더가 반드시 갖춰야 하는 자질이다.
>
>

경험을 어디서 쌓는지가 문제이긴 하다. 또한 개인 엔지니어링 스킬과는 달리 경험을 쌓으면서 당연히 실패도 있고 실수도 있을 텐데 리더는 실패의 영향이 다른 사람들에게까지 더 많이 끼치게 되므로 조심스럽게 되고 조심스러워서 경험을 더 쌓기 어렵지 않나 하는 생각도 든다.

> 
>
> 매사 사소한 것까지 관리하고 통제하도록 '기본값'이 설정된 리더는 속 빈 강정이다. 팀원들이 자기만의 경험을 구축하는 기술에 관해 하나도 배울 게 없기 때문이다.
>
>

마이크로 매니징은 나도 너무 싫어하는 형태이다.

> 
>
> 사람들이 자기 생각을 거리낌없이 나누도록 멍석을 깔아주자. 획기적인 아이디어가 언제 나올지 아무도 모른다. 팀원들이 리더인 당신의 아이디어에 반박할 공산이 낮다는 사실을 명심하라. 이것은 리더가 나중에 행동해야 하는 또 다른 명백한 이유다.
>
>

리더와 팀원은 너무 나누는 건 별로 좋아하는데 또 전혀 경계가 없을 수 없기도 하다. 어려움 부분.

> 
>
> 신참 관리자로서 스스로를 증명하고 싶은 의욕을 갖는 것은 당연하다. 그래서 당신은 모든 일을 자발적으로 떠안고 주구장창 야근을 하며 무리수를 둔다. 게다가 생전 처음으로 직속 직원들이 생겼으니, 그들에게 당신의 지위를 각인하는 동시에 좋은 첫인상을 주려고 젖 먹던 힘까지 짜낸다. 관리자가 되기 전 개별 기여자였을 때는 이런 접근법이 매우 효과적이었을 것이다. 그래서 당신은 팀의 리더일 때도 이 방법이 효과적일 거라고 단정짓는다.
>
>

이렇게 되기 쉬운 거 같긴 하다. 나도 우리 파트에서 일어나는 일의 대부분을 파악하고 있으려고 하고 그렇기에 파트 규모를 늘리는데 조심스럽긴 하다. 당연히 흐름을 놓치지 않고 의사결정에 참여하려면 알고 있어야 한다고 생각하면서도 너무 많이 간섭하려고 하는 건 아닌지에 대한 걱정도 있고 어쩌면 내 능력 범위에 파트의 능력이 갇히는 건 아닌지에 대한 걱정도 있다.

> 
>
> 관리자가 되었다고 해서 갑자기 누군가에게 당신의 일을 위임하려니 본능적으로 꺼려진다. 위임은 힘과 맥락을 잃는다는 뜻인 데다 당신은 그런 상실에 익숙하지 않다.
>
>

업무에 따라 약간 다르긴 하지만 위임은 조금씩 익숙해지고 있는 것 같다.

> 
>
> 이 순간 그 상황에 대한 전적인 책임을 통감하는 관리자라면 ‘나는’이라는 단어를 아주 많이 사용할 것이다. 또한 송곳같이 날카로운 질문을 퍼부을 것이다. 그런 질문에는 그것이 그가 해결해야 하는 그의 문제라는 인식이 담겨 있다. 어차피 자신도 윗선에서 어려운 질문을 받을 것이기 때문이다. 그 관리자는 책임감을 느낀다. 그러나 그가 사용하는 단어들 사이에 꽁꽁 숨고 그가 묻는 질문들의 뒤에 음흉하게 감춰진 속내가 있다. 그는 내가 이 일을 주도한 엔지니어라면 우리는 절대로 이런 상황에 처하지 않았을 것이라고 생각하는 것이다.
>
>
> 조심하라. 신뢰를 갉아먹는 소리가 들리는 듯하다.
>
>

저런 생각이 들면 정말 힘든 것 같다. 또 모든 걸 맡기기만 하면 잘 되는 것은 아니기 때문에 어느 순간이 개입할 때이고 어느 순간이 기다려야 할 때인지가 어렵다. 그래도 요즘은 그런 고민을 거의 안 하기는 하는데 조직마다 성격이 좀 달라서 다른 조직에서는 또 어떨지 잘 모르겠다.

> 
>
> 먼저 하기 어려운 말을 하는 법을 배우고, 그런 다음 듣기 힘든 말을 적극적으로 듣는 것이다.
>
>
> 
>
> 피드백이 아무리 비판적이더라도 주의 깊게 경청하고 그저 대략적으로라도 이해하도록 노력하라.
>
>

듣기 힘든 말을 듣는 건 항상 사람으로서는 어려운 일이긴 하지만 제일 어려운 건 듣기 힘든 말도 할 수 있는 분위기인 것 같다. 기본적으로 비판적인 피드백이 없을 때 그럴 만한 일이 없는 건지 사실은 있지만 말을 안 하는 건지 판단할 수 없다고 생각한다. 보통은 후자일 가능성이 높을 텐데 그렇다고 말하라고 한다고 말하는 것도 아니니까...

> 
>
> 소소한 일을 처리하느라 쉴 새 없이 움직이지만, 정작 결과를 놓고 보면 괄목할 만한 진전을 이뤘다는 기분이 들지 않는다. 이런 삶이 바로 테크 리더의 현실이다.
>
>

수시로 이런 느낌이 드는데 테크 리더만 그런지는 잘 모르겠다.

> 
>
> 엔지니어로서 나는 여전히 관리자들의 역할에 대해 회의적이다. 심지어 내가 관리자가 되어서도 그렇다.
>
>

어느 정도는 동의한다.

> 
>
> 서로의 견해에 동의하지 않는 것도 피드백이다. 따라서 우리는 서로의 의견에 효과적으로 반대하는 법을 배울 필요가 있다. 그 방법을 빨리 배울수록 서로를 더 빨리 (그리고 더 많이) 신뢰하고 존중하게 될 것이다. 아이디어는 합의를 통해 발전하지 않는다.
>
>

중요한 말이다.


# 웹개발 관련

- [**[번역] Chakra UI의 미래**](https://velog.io/@ojj1123/the-future-of-chakra-ui) : [The future of Chakra UI](https://www.adebayosegun.com/blog/the-future-of-chakra-ui)의 번역 글로 [Chakra UI](https://chakra-ui.com/)가 앞으로 가려고 하는 방향에 관해서 설명하는 글이다. Chakra UI가 성장하면서 도전적인 문제로는 런타임 CSS-in-JS를 가진다는 문제였고 RSC가 나오면서 이 부분은 더 중요해졌다. Chakra UI는 프레임워크에 종속적이지 않아야 하고 디자인 토큰을 받을 수 있어야 하고 런타임 CSS-in-JS를 제거하고도 지금의 직관적인 Style Pros를 유지하면서 유지보수가 쉬워야 했다. 이러한 미래로 가기 위해서 UI 컴포넌트를 위한 저수준 상태 머신인 [zag](https://zagjs.com/), Zag 기반의 헤드리스 컴포넌트인 [Ark](https://ark-ui.com/), 제로 런타임 CSS-in-JS인 [panda](https://panda-css.com/)를 만들게 되었다고 한다.(한국어)
- [**Flat config rollout plans**](https://eslint.org/blog/2023/10/flat-config-rollout-plans/) : 2019년 RFC가 올라오고 2022년에야 실험적 버전을 출시한 플랫 컨피그를 9.0.0에5서 원활하게 전환할 수 있게 안내하는 글이다. 9.0.0부터는 플랫 컨피그가 기본적으로 적용되므로 `.eslintrc.*` 파일 대신 `eslint.config.js` 파일을 검색하고 기존 방식을 사용하려면 `ESLINT_USE_FLAT_CONFIG`를 `false`로 설정해야 한다. ESLint 10.0에서는 eslintrc 시스템이 완전히 제거될 예정이다.(영어)
- [**Announcing v0: Generative UI**](https://vercel.com/blog/announcing-v0-generative-ui) : 최근 Vercel에서 프롬프트를 입력하면 UI를 만들어 주는 v0을 소개하고 사람들의 높은 관심에 따라 베타로 전환하면서 유료 구독 요금제를 발표했다.(영어)

# 그 밖의 개발 관련

- [**The Internals of Deno**](https://choubey.gitbook.io/internals-of-deno/) : Deno의 내부 동작을 자세히 설명하는 무료 이북이다. Deno의 아키텍처, 스레딩 모델, 브릿지, 기반, 임포트와 Ops를 하나씩 설명하고 Deno 입문자를 위한 자료가 아니라 Deno 내부를 자세히 알고 싶은 사람들을 위한 자료다.(영어)

# 인프라 관련

- [**HTTP/2 Rapid Reset: 기록적인 공격의 분석**](https://blog.cloudflare.com/ko-kr/technical-breakdown-http2-rapid-reset-ddos-attack-ko-kr/) : 이번에 공개된 제로데이 취약점 [HTTP/2 Rapid Reset](https://www.cve.org/CVERecord?id=CVE-2023-44487)가 Cloudflare뿐 아니라 Google이나 AWS에도 공격이 있었음을 알게 되고 협력해서 해당 공격에 대처했다고 한다. HTTP/2는 스트림을 동시에 여러 개 열 수 있고 클라이언트는 스트림 취소를 할 수 있는데 이번 HTTP/2 Rapid Reset는 빠르게 취소 요청을 보내서 서버 쪽에서 스트림 종료 처리에 걸리는 시간을 이용해 서비스 거부 공격을 발생시킨다.(한국어)
- [**2023 State of DevOps Report**](https://cloud.google.com/devops/state-of-devops) : DORA의 2023년 DevOps 상태 리포트가 나왔다.(영어)
- [**Cloud Native Computing Foundation Announces Cilium Graduation**](https://www.cncf.io/announcements/2023/10/11/cloud-native-computing-foundation-announces-cilium-graduation/) : eBPF 기반 네트워킹 도구인 [cilium](https://cilium.io/)이 CNCF 졸업 프로젝트가 되었다.(영어)

# 볼만한 링크

- [**Roundtable: Development Culture**](https://www.linkedin.com/pulse/roundtable-development-culture-wook-jin-lee/) : 슈퍼셀의 이욱진 님이 한국에 오셔서 라운드테이블로 게임 업체 간 문화를 공유하는 자리를 만들고 그 결과를 공유한 자리다. 슈퍼셀을 각 게임을 만드는 담당자들이 게임 종료를 포함해서 직접 의사결정을 하고 가능한 한 투명하게 정보를 공유하려고 노력하는 문화가 재밌게 느껴졌고 슈퍼셀의 문화와 참가자들과 논의한 내용이 정리되어 있다. 개인적으로는 Disagree and commit이라는 의사결정 구조, "난 동의하지 않지만, 결정이 그렇게 났으니 따른다."라는 방식에 공감되었다.(한국어)
- [**Why being an open startup matters**](https://cal.com/blog/open-startup) : cal.com에서 기술적/운영적으로 가능한 한 공개적으로 지표를 공유하는 스타트업을 오픈 스타트업으로 정의하고 이 오픈 스타트업이 왜 중요한지를 설명한다. [https://cal.com/open](https://cal.com/open)에서 지표를 공개하고 있는데 직원의 연봉을 공개하는 것은 질투를 줄이고 인종 및 성평등을 촉진하는 효과가 있었고 cal.com도 원격 근무를 하므로 글로벌 급여를 도입할 것인지 현지화된 급여를 도입할 건인지 고민했지만, 글로벌 급여를 도입하기로 했다고 한다.(영어)

# IT 업계 뉴스

- [**LINE과 Yahoo! JAPAN이 만나 함께 새로운 기술 블로그를 시작했습니다!**](https://techblog.lycorp.co.jp/ko/blog/20231001a) : Line Corporation과 Yahoo JAPAN Corporation이 합쳐서 LY Corporation이 됨에 따라 개발 블로그도 새로 시작하게 되었다.(영어)
- [**Bruno**](https://github.com/usebruno/bruno) : Postman/Insomnia의 오픈소스 대안으로 API를 테스트해 볼 수 있는 IDE
- [**localpilot**](https://github.com/danielgross/localpilot) : GitHub Copilot을 인터넷 연결 없이도 로컬에서 사용할 수 있게 하는 앱.

# 버전 업데이트

- [**Flask**](https://flask.palletsprojects.com/) **v3.0.0** : Python 웹 프레임워크, [릴리스 공지](https://flask.palletsprojects.com/en/3.0.x/changes/#version-3-0-0)
- [**Lit**](https://lit.dev/) **v3.0.0** : 웹 컴포넌트 라이브러리, [릴리스 공지](https://lit.dev/blog/2023-10-10-lit-3.0/)
- [**Argo Workflows**](https://github.com/argoproj/argo) **v3.5.0** : 컨테이너 기반 워크플로우 엔진, [릴리스 공지](https://github.com/argoproj/argo-workflows/releases/tag/v3.5.0)
- [**astro**](https://astro.build/) **v3.3** : JavaScript 웹 프레임워크, [릴리스 공지](https://astro.build/blog/astro-330/)
- [**WebdriverIO**](https://webdriver.io/) **v8.18.0** : Browser 테스트 자동화도구, [릴리스 공지](https://github.com/webdriverio/webdriverio/releases/tag/v8.18.0)
- [**Lighthouse**](https://github.com/GoogleChrome/lighthouse) **v11.2.0** : Progressive Web Apps용 성능 분석 도구, [릴리스 공지](https://github.com/GoogleChrome/lighthouse/releases/tag/v11.2.0)
- [**Zed**](https://zed.dev/) **v0.107.6** : 코드 에디터, [릴리스 공지](https://zed.dev/releases/stable#zed-0.107.6)
- [**Kafka**](https://kafka.apache.org/) **v3.6.0** : 분산 이벤트 스트리밍 플랫폼, [릴리스 공지](https://downloads.apache.org/kafka/3.6.0/RELEASE_NOTES.html)
- [**Electron**](http://electron.atom.io/) **v27.0.0** : 크로스 플랫폼 데스크톱 애플리케이션 플랫폼, [릴리스 공지](https://www.electronjs.org/blog/electron-27-0)
- [**Python**](https://www.python.org/) **v3.12.0** : 프로그래밍 언어, [릴리스 공지](https://www.python.org/downloads/release/python-3120/)
- [**Prisma**](https://www.prisma.io/) **v5.4.0** : TypeScript/Node.js 데이터베이스 툴킷, [릴리스 공지](https://github.com/prisma/prisma/releases/tag/5.4.0)
- [**Gradle**](https://gradle.org/) **v8.4** : Java 빌드 도구, [릴리스 공지](https://docs.gradle.org/8.4/release-notes.html)
    - Java 21 지원
- [**PyTorch**](http://pytorch.org/) **v2.1.0** : Python 딥러닝 프레임워크, [릴리스 공지](https://pytorch.org/blog/pytorch-2-1/)
- [**Rails**](http://rubyonrails.org/) **v7.1.0** : Ruby 웹 프레임워크, [릴리스 공지](https://rubyonrails.org/2023/10/5/Rails-7-1-0-has-been-released)
- [**Rust**](http://www.rust-lang.org/) **1.73.0** : 프로그래밍 언어, [릴리스 공지](https://blog.rust-lang.org/2023/10/05/Rust-1.73.0.html)
- [**ESLint**](http://eslint.org/) **v8.51.0** : JavaScript 코드 분석 도구, [릴리스 공지](https://eslint.org/blog/2023/10/eslint-v8.51.0-released/)
- [**Argo CD**](https://argoproj.github.io/argo-cd/) **v2.8.0** : Kubernetes 배포 도구, [릴리스 공지](https://medium.com/@Tal-Hason/argocd-2-8-plugin-genertator-7ccfb547e161)
- [**Fresh**](https://fresh.deno.dev/) **v1.5** : Deno 풀스택 웹 프레이워크, [릴리스 공지](https://deno.com/blog/fresh-1.5)
- [**curl**](https://curl.se/) **v8.4.0** : URL로 데이터를 처리하는 CLI, [릴리스 공지](https://daniel.haxx.se/blog/2023/10/11/curl-8-4-0/)
- [**Parcel**](https://parceljs.org/) **v2.10.0** : 웹 애플리케이션 번들러, [릴리스 공지](https://github.com/parcel-bundler/parcel/releases/tag/v2.10.0)
- [**Terraform**](https://www.terraform.io/) **v1.6** : Infrastructure as Code 도구, [릴리스 공지](https://www.hashicorp.com/blog/terraform-1-6-adds-a-test-framework-for-enhanced-code-validation)
    - Test framework 도입
- [**Consul**](https://www.consul.io/) **1.17** : 서비스 디스커버리/설정 도구, [릴리스 공지](https://www.hashicorp.com/blog/announcing-consul-1-17-beta-and-hcp-consul-central)

수년째 참여하고 있는 인프라 스터디에서 그룹스터디하면서 읽은 책이다. 이 책은 트위터에서 [Daniel Lee님](https://twitter.com/dylayed)이 추천해 줘서 위시리스트에 담고 있었는데 스터디 주제를 찾다가 이 책을 선정했다. 아무래도 원서라서 은근히 미루게 되어 안 읽게 되는데 그룹스터디로 하면 끝까지 읽을 수 있다.


5월 23일에 스터디를 시작해서 매주 하면서 이번 주까지 했으니 거의 6개월 스터디를 했다. 스터디는 좋았지만 그래도 6개월은 꽤 길긴 하다. 항상 더 빨리 끝내고 싶지만, 또 스터디를 하다 보면 진도 빼는 게 목적이 아니라 공부하는 게 목적이다 보니 이야기 나누고 질문하고 하다 보면 길어지기도 하고 해서 항상 5~6개월은 하게 되는 거 같다. 그래도 이제는 [DeepL](https://www.deepl.com/)이 있어서 이전보다 훨씬 수월하게 원서로 스터디를 진행했다. 전에도 좀 이용하긴 했지만 아무래도 번역 품질이 좋아져서 후처리를 좀 덜 해도 되기도 하고 후처리를 안 해도 한국말은 좀 어색하지만, 대부분의 경우 무슨 말인지 이해는 할 수 있었다.


그리고 [New Relic](https://newrelic.com/)이나 [Datadog](https://www.datadoghq.com/)등을 써보긴 했지만 옵저버빌리티 혹은 모니터링 시스템을 구축하는 역할은 아니라서 아주 자세히는 알지 못한다. PromQL도 잘 못 쓰는 사용자 정도의 느낌이지만 인프라 업무를 하다 보니 어느 정도의 관심은 있고 주워들은 것도 있는데 같이 스터디하시는 분들이 다양한 경험들이 있어서 그룹 스터디를 한 게 혼자 읽는 것 보다 더 도움이 됐다.


이 책은 옵저버빌리티 솔루션인 [honeycomb.io](https://www.honeycomb.io/)의 Charity Majors, Liz Fong-Jones, George Miranda 세 명이 쓴 책으로 옵저버빌리티 솔루션을 만들면서 그동안 했던 많은 고민의 결과를 담은게 이 책이라고 생각한다.


Charity Majors는 honeycomb.io의 공동창업자이기도 한데 책에도 나오지만 2011년에 모바일 개발자에게 백엔드를 제공해 주는 Backend as a Service(BaaS)로 출시된 [Parse](https://en.wikipedia.org/wiki/Parse,_Inc.)에서 일했는데 Parse 특성상 한 사용자가 갑자기 서버 리소스를 다 먹거나 문제를 일으키거나 할 때 문제를 파악하면서 옵저버빌리티에 관심을 가지게 되었고 Parse가 Facebook에 인수되어 Facebook에서 일하면서 거의 모든 데이터를 다 넣어놓고 탐색하는 [Scuba](https://research.facebook.com/publications/scuba-diving-into-data-at-facebook/)를 쓰면서 옵저버빌리티에 대한 많은 생각을 가지게 되고 결국 창업까지 이어지고 이 책까지 나오게 된다.


아무래도 모니터링이나 옵저버빌리티를 고민하고 있거나 구축하는 사람들에게 도움이 될 책이라고 생각한다. 어떤 면에서는 너무 이상적인 얘기를 한다는 느낌이 들 수도 있지만 앞으로 우리가 준비해야 할 옵저버빌리티는 이래야 한다고 방향성을 제시한다는 점에서 꽤 좋았고 저자들이 많은 경험이 있기 때문에 기술적으로 고려해야 할 부분도 잘 짚어주고 있어서 도움이 많이 되었다.


## Part 1. The Path to Observability

> 
>
> 데이터베이스의 맥락에서 카디널리티는 집합에 포함된 데이터 값의 고유성을 나타냅니다. 낮은 카디널리티는 열의 집합에 중복된 값이 많다는 것을 의미합니다. 높은 카디널리티는 열에 완전히 고유한 값이 많이 포함되어 있음을 의미합니다. 단일 값을 포함하는 열은 항상 가능한 가장 낮은 카디널리티를 갖습니다. 고유 ID를 포함하는 열은 항상 가능한 가장 높은 카디널리티를 갖습니다.
>
>
> 
>
> 카디널리티는 옵저버빌리티에 중요한데, 카디널리티가 높은 정보는 거의 항상 시스템을 디버깅하거나 이해하기 위해 데이터를 식별하는 데 가장 유용하기 때문입니다.
>
>
> 
>
> 안타깝게도 메트릭 기반 툴링 시스템은 카디널리티가 낮은 차원만 합리적인 규모로 처리할 수 있습니다. 비교할 호스트가 수백 개에 불과하더라도 메트릭 기반 시스템에서는 카디널리티 키 공간의 한계에 부딪히지 않고는 호스트 이름을 식별 태그로 사용할 수 없습니다.
>
>
> 
>
> 옵저버빌리티란 새로운 코드를 배포하지 않고도 시스템이 아무리 새롭거나 기괴한 상태에 빠질 수 있는 모든 상태를 이해하고 설명할 수 있다는 것을 의미합니다.
>
>

이 책 전체적으로 높은 카디널리티를 엄청나게 강조하고 있다. 지금 사용하는 모니터링 시스템(이 책에서는 모니터링과 옵저버빌리티를 구분한다)에서는 카니널리티가 낮기 때문에 더 자세하게 파악하기가 어려운데 카디널리티를 높게 할 수 있으면 시스템의 더 자세한 내용을 관측할 수 있다.

> 
>
> 기존 모니터링 도구는 이전에 알려진 오류 조건의 존재 여부를 나타내는 알려진 임곗값(threshold)에 대해 시스템 조건을 확인하는 방식으로 작동합니다. 이는 이전에 발생한 장애 모드를 식별하는 데만 효과적이기 때문에 근본적으로 사후 대응적인 접근 방식입니다.
>
>
> 반면, 옵저버빌리티 도구는 반복적인 탐색 조사를 통해 성능 문제가 발생할 수 있는 위치와 이유를 체계적으로 파악할 수 있습니다. 옵저버빌리티는 이전에 알려졌거나 알려지지 않은 모든 장애 모드를 식별하기 위한 사전 예방적 접근 방식을 가능하게 합니다.
>
>
> 
>
> 메트릭은 일반적으로 종합적으로 볼 때 더 유용합니다. 추세 이해하기 메트릭 값을 이해하면 소프트웨어 성능에 영향을 미치는 시스템 동작에 대한 인사이트를 얻을 수 있습니다. 모니터링 시스템은 메트릭을 수집, 집계 및 분석하여 사람이 알고 싶어하는 추세를 나타내는 알려진 패턴을 선별합니다.
>
>

기존 모니터링과 옵저버빌리티를 구분해서 얘기하고 있는데 옵저버빌리티를 그래서 어떻게 이렇게 할 수 있느냐를 떠나서 모노리스로 서버 한 대가 있다면 큰 상관이 없겠지만 마이크로서비스로 서비스가 많이 떠 있다면 모니터링 자체가 상당히 어려워지기 때문에 이 내용에 동의하는 편이다. 오류가 증가하거나 레이턴시가 증가할 때 연쇄적으로 발생할 가능성이 높기 때문에 어디가 원인이고 어디가 영향받은 것인지 파악하는 것도 쉽지 않은 일이다.

> 
>
> 그 임곗값이 정확히 어디인지는 사람이 결정합니다.
>
>
> 
>
> 모니터링 기반 접근 방식에서는 팀에서 가장 오래 근무한 엔지니어가 팀에서 가장 뛰어난 디버거이자 최후의 디버거인 경우가 많기 때문에 연공서열이 지식의 핵심이라는 생각에 초점을 맞추는 경우가 많습니다
>
>
> 
>
> 옵저버빌리티 도구를 사용하면 팀에서 가장 뛰어난 디버거는 일반적으로 가장 호기심이 많은 엔지니어입니다. 옵저버빌리티를 실천하는 엔지니어는 탐색적인 질문을 통해 시스템을 조사하고, 발견한 답을 사용하여 더 개방적인 질문을 할 수 있는 능력을 갖추고 있습니다
>
>
> 
>
> 프로덕션 환경에서 알려진 임곗값을 초과하는 시스템 상태의 엣지 케이스를 찾는 모니터링 알림은 엄청난 수의 오탐, 오탐, 무의미한 노이즈를 생성합니다. 알림은 사용자 경험에 직접적인 영향을 미치는 증상에만 집중하여 더 적은 수의 알림을 트리거하는 모델로 전환되었습니다.
>
>

매트릭의 임곗값 설정도 메인 서비스 한두 개로 운영한다면 계속 운영하면서 조정하면 가능하지만 수십 개 수백 개가 된다면 이마저도 쉽지 않은 일이다.

> 
>
> 수동으로 해결해야 하고 런북에 정의할 수 있는 알려진 반복 장애는 더 이상 일반적이지 않습니다. 서비스 장애는 이러한 모델에서 알려진 반복 장애를 자동으로 복구할 수 있는 모델로 전환되었습니다. 자동으로 복구할 수 없어 알림이 트리거되는 장애는 대응하는 엔지니어가 새로운 문제에 직면하게 될 가능성이 높습니다.
>
>

최근에 많이 생각하는 일이긴 하다. 장애 대응을 문서로 만들 수 있다면 보통 자동화 처리하는 게 편하고(대표적으로 Kubernetes에서 컨테이너가 죽으면 리스타트하는 걸 들 수 있다) 결국 장애에서 문서화를 한다는 것은 사람이 판단할 수 있는 정보를 넣어야 하는데 이런 걸 결국 문서화가 어렵다. 장애 대응 문서를 그대로 따라 하면 해결이 된다면 굳이 사람이 할 필요가 있는가?

> 
>
> 기존 접근 방식의 한계는 무엇보다도 사전 프로덕션 강화에 중점을 둔다는 점입니다. 그런 다음 남은 관심은 생산 시스템에 집중하는 데 투입됩니다. 프로덕션에서 안정적인 서비스를 구축하려면 이러한 순서를 바꿔야 합니다.
>
>
> 최신 시스템에서는 엔지니어링에 대한 관심과 툴링의 대부분을 무엇보다도 프로덕션 시스템에 집중해야 합니다. 남은 관심의 주기는 스테이징 및 사전 프로덕션 시스템에 적용되어야 합니다. 스테이징 시스템에도 가치가 있습니다. 하지만 이는 본질적으로 부차적인 것입니다.
>
>
> 스테이징 시스템은 프로덕션이 아닙니다. 프로덕션에서 일어나는 일을 결코 복제할 수 없습니다. 사전 프로덕션 시스템의 무균 실험실 환경은 실제 유료 서비스 사용자가 실제 환경에서 코드를 테스트하는 것과 동일한 조건을 모방할 수 없습니다. 그런데도 많은 팀이 여전히 프로덕션을 유리성으로 취급합니다.
>
>

이건 꽤 급진적인 생각으로 느껴졌는데 생각해 보면 의미 있는 부분인 것 같다. 결국 가장 안전하게 하려면 사전 프로덕션 검증을 강화해야 하고 많은 기법이 여기에 초점이 맞춰져 있지만 시스템이 복잡해질수록 제대로 된 검증하기는 점점 어려워진다. 카오스 엔지니어링이 프로덕션에서 카오스를 만들었고 당시에도 급진적이라고 생각하면서도 멋지다고 생각했는데 아직 경험치가 부족하니 여전히 프로덕션은 좀 무섭게 느껴지는 것 같다. 이런 부분에서 생각의 전환을 할 필요가 있어 보인다.

> 
>
> 우리 팀은 회고전을 실행하여 문제를 분석하고, 미래의 우리 자신에게 문제를 처리하는 방법을 알려주는 런북을 작성하고, 다음번에 그 문제를 즉시 드러낼 수 있는 사용자 지정 대시보드(한두 개)를 만든 다음, 문제가 해결된 것으로 간주하고 넘어가곤 했습니다.
>
>

이 부분은 자주 하는 행동이라 뜨끔하면서 반성하게 되었다.

> 
>
> 저는 소프트웨어 업계에서 영웅 문화의 이러한 측면을 강조하고 싶습니다. 램프 스택 스타일의 모놀리식 시스템에서 최후의 디버거는 일반적으로 시스템을 처음부터 구축한, 가장 오래 근무한 사람이 맡습니다. 가장 연차가 높은 엔지니어가 최후의 에스컬레이션 지점입니다. 이들은 가장 많은 상처 조직과 가장 많은 중단 목록을 가지고 있으며, 필연적으로 문제를 해결하기 위해 뛰어들어야 하는 사람들입니다.
>
>
> 그 결과 이 영웅들은 진정한 휴가를 결코 가질 수 없습니다. 하와이로 신혼여행을 가던 중 새벽 3시에 호출을 받았는데, 몽고DB가 어떻게든 Parse API 서비스를 중단시켰기 때문이었습니다. 제 상사였던 CTO는 정말 미안해했습니다. 하지만 사이트는 다운되어 있었습니다. 한 시간 넘게 다운된 상태였는데 아무도 그 이유를 알아내지 못했습니다. 그래서 저를 호출했습니다. 네, 저는 불평했습니다. 하지만 마음 깊은 곳에서는 은근히 기분이 좋았습니다. 제가 필요했거든요. 제가 필요했으니까요.
>
>
> 
>
> 2013년 Facebook이 Parse를 인수한 후, 저는 Facebook이 대부분의 실시간 분석에 사용하는 데이터 관리 시스템인 Scuba를 알게 되었습니다. 이 빠르고 확장 가능한 분산형 인메모리 데이터베이스는 초당 수백만 개의 행(이벤트)을 수집합니다. 실시간 데이터를 메모리에 완전히 저장하고 쿼리를 처리할 때 수백 대의 서버에 걸쳐 집계합니다. 제 경험은 거칠었습니다. 저는 Scuba의 사용자 환경이 매우 추악하고 심지어 적대적이라고 생각했습니다. 하지만 시스템 문제 해결에 대한 저의 접근 방식을 완전히 바꿔놓은 한 가지 뛰어난 기능이 있었으니, 바로 무한히 높은 카디널리티의 차원에 대해 거의 실시간으로 데이터를 슬라이스하고 주사위를 던질 수 있게 해준다는 것이었습니다.
>
>

## Part 2. Fundamentals of Observability

> 
>
> 메트릭이란 시스템 상태를 나타내기 위해 수집된 스칼라값을 의미하며, 이러한 숫자를 그룹화하고 검색하기 위해 선택적으로 태그가 추가될 수 있습니다. 메트릭은 소프트웨어 시스템에 대한 전통적인 모니터링의 기반이 되어 왔습니다
>
>
> 
>
> 메트릭의 근본적인 한계는 사전 집계된 측정값(pre-aggregated measure)이라는 점입니다. 메트릭에 의해 생성된 수치는 미리 정의된 기간의 시스템 상태에 대한 집계된 보고서를 반영합니다.
>
>
> 
>
> 메트릭은 모두 서로 연결되지 않은 별개의 측정값으로, 동일한 요청에 속하는 메트릭을 정확히 재구성하는 데 필요한 연결 조직과 세분성이 부족합니다.
>
>
> 
>
> 메트릭은 미리 정의된 기간의 사전 정의된 관계를 종합적으로 수치로 표현한 것으로, 하나의 시스템 속성에 대한 좁은 관점의 하나에 불과합니다. 메트릭의 세부 수준이 너무 높고 시스템 상태를 다른 보기로 표시하는 기능이 너무 경직되어 있어 옵저버빌리티를 달성하기 어렵습니다. 메트릭은 옵저버빌리티의 기본 구성 요소로 사용하기에는 너무 제한적입니다.
>
>
> 
>
> 옵저버빌리티 도구가 조사자에게 유용하려면 카디널리티가 높은 쿼리를 지원할 수 있어야 합니다. 최신 시스템에서는 새로운 문제를 디버깅하는 데 가장 유용한 많은 차원이 높은 카디널리티를 가지고 있습니다. 또한 깊이 숨겨진 문제를 찾기 위해 이러한 높은 카디널리티 차원을 함께 묶어(즉, 고차원성) 조사해야 하는 경우가 많습니다. 문제를 디버깅하는 것은 종종 건초 더미에서 바늘을 찾는 것과 같습니다. 높은 카디널리티와 고차원성은 매우 복잡한 분산 시스템 건초 더미에서 매우 세밀한 바늘을 찾을 수 있게 해주는 기능입니다.
>
>

메트릭의 연결성이 필요하다는 것에는 동의한다. 물론 대부분 높은 카디널리티가 도움 된다는 것에도 동의할 것으로 생각한다. 높은 카니널리티를 담으면 메트릭 서버가 버티지 못해서 그렇지...

> 
>
> 분산 트레이싱(distributed tracing)은 애플리케이션을 구성하는 다양한 서비스에서 처리되는 단일 요청(trace라고 함)의 진행 상황을 추적하는 방법입니다. 이러한 의미에서 트레이싱은 "분산"되어 있으며, 그 기능을 수행하기 위해 단일 요청이 프로세스, 머신, 네트워크 경계를 넘나들어야 하는 경우가 많기 때문입니다.
>
>
> 
>
> 모니터링 및 옵저버빌리티 커뮤니티는 공급업체 종속 문제를 해결하기 위해 수년 동안 여러 오픈 소스 프로젝트를 만들어 왔습니다. 2016년과 2017년에 각각 클라우드 네이티브 컴퓨팅 재단 산하의 OpenTracing과 Google이 후원하는 OpenCensus가 등장했습니다. 이 경쟁적인 개방형 표준은 가장 널리 사용되는 프로그래밍 언어용 라이브러리 세트를 제공하여 원격 분석 데이터를 수집하여 사용자가 선택한 백엔드로 실시간으로 전송할 수 있도록 했습니다. 결국 2019년, 두 그룹이 힘을 합쳐 CNCF 산하의 OpenTelemetry 프로젝트를 결성했습니다.
>
>

분산 트레이싱은 알지는 꽤 되었지만 나도 그렇게 제대로 하기는 쉽지 않다. 물론 모든 기술이 그렇듯이 가까이서 기술적인 한계와 현실을 이해할수록 더 어렵게 느껴지긴 한다. OpenTelemetry은 최근에 조금씩 관심을 가지고 있는데 결국 OpenTelemetry로 가긴 하겠지만 긍정적인 미래와 걱정에 대한 생각이 둘다 있긴 하다.

> 
>
> 런북을 만드는 데 소요되는 시간이 대부분 낭비된다는 주장은 처음에는 다소 가혹해 보일 수 있습니다. 분명히 말씀드리자면, 특정 서비스의 요구 사항과 그 출발점을 팀에 빠르게 안내하기 위한 문서가 필요합니다.
>
>
> 
>
> 그러나 가능한 모든 시스템 오류와 해결 방법을 포함하는 살아있는 문서를 유지하는 것은 쓸데없고 위험한 일입니다. 이러한 유형의 문서는 금방 부실해질 수 있으며, 잘못된 문서는 문서가 없는 것보다 더 위험할 수 있습니다. 빠르게 변화하는 시스템에서는 엔지니어의 의도(엔지니어가 이름을 지정하고 수집하기로 한 치수는 무엇인가?)와 프로덕션의 실시간 최신 상태 정보가 결합하여 있기 때문에 계측 자체가 최고의 문서가 되는 경우가 많습니다.
>
>

문서에 대한 생각은 꽤 동의하는 편이다.

> 
>
> 옵저버빌리티의 진정한 힘은 문제를 디버깅하기 전에 너무 많은 것을 미리 알 필요가 없다는 것입니다. 시스템에 익숙하지 않은 경우에도 체계적이고 과학적으로 한 단계씩 단계를 밟아 단서를 따라 체계적으로 답을 찾을 수 있어야 합니다. 무언의 신호를 유추하거나, 과거의 상처 조직에 의존하거나, 익숙한 기지를 발휘하여 순식간에 올바른 결론에 도달하는 마법은 체계적이고 반복할 수 있으며 검증할 수 있는 프로세스로 대체됩니다.
>
>

결국 이 책에서 얘기하는 것은 드릴다운 할 수 있어야 한다는 것이다. 예를 들어 특정 서비스에서 레이턴시가 갑자기 튀기 시작했을 때 메트릭은 그냥 레이턴시 평균이 튀었다는 것만 알려주지만 높은 카디널리티로 다양한 정보를 담아서 모든 메트릭 간에 연결할 수 있어야 한다는 것이다. 그래서 레이턴시가 튀었을 때 클릭해서 더 자세히 들어가서 이게 특정 서버에서 발생하는지, 특정 존에서만 발생하는지, 특정 API에서 발생하는지를 구분해서 볼 수 있어야 문제를 발견할 수 있다는 것인데 동의한다.


그리고 서버의 디스크나 하드웨어 등 시스템은 모니터링으로 파악하고 애플리케이션은 옵저버빌리티로 접근해야 한다는 부분도 수긍되었다.


## Part 3. Observability for Teams

> 
>
> 이를 위한 가장 좋은 방법은 OpenTelemetry를 사용하여 애플리케이션을 계측하는 것입니다(7장 참조). OTel을 사용하면 다른 공급업체의 독점 에이전트나 라이브러리만큼 빠르고 쉽지는 않지만, 느리고 사용하기 어려운 것도 아닙니다. 처음부터 이 작업을 수행하는 데 필요한 약간의 사전 시간 투자는 나중에 여러 솔루션을 사용해 보고 어떤 솔루션이 가장 적합한지 확인하기로 할 때 큰 도움이 될 것입니다.
>
>

이 책은 2022년 6월에 나왔고 지금과 마찬가지로 OpenTelemetry는 아직 초기 단계(내 개인 생각이다.)라고 할 수 있는데 요즘 분위기와 마찬가지로 OpenTelemetry의 미래를 아주 긍정적으로 보고 있고 분산 트레이스에서 OpenTelemetry이 해결책이 될 것으로 보고 계속 OpenTelemetry를 강조하고 있다.

> 
>
> 가장 큰 문제점에서 시작하는 것과 마찬가지로, 옵저버빌리티 도구를 직접 구축할지 아니면 상용 솔루션을 구입할지 결정하는 것은 투자 수익률(ROI)을 신속하게 입증하는 것입니다.
>
>
> 
>
> 새로운 기술을 채택하는 데 있어 큰 장벽 중 하나는 매몰 비용 오류입니다. 개인과 조직은 이전에 투자한 시간, 비용, 노력의 결과로 행동이나 노력을 지속할 때 매몰 비용 오류를 범합니다.
>
>

사서 쓰냐? 만들어서 쓰냐는 어려운 부분인데 꽤 여러 관점도 다뤄주어서 좋았다. 물론 모니터링은 간단하지 않으므로 조직이 작을 때는 그냥 사서 쓰고 조직이 커지면서 구축을 고민해야 한다고 생각하긴 한다.

> 
>
> 옵저버빌리티는 코드 로직을 디버깅하기 위한 것이 아닙니다. 옵저버빌리티는 시스템에서 디버깅에 필요한 코드를 찾을 수 있는 위치를 파악하기 위한 것입니다. 옵저버빌리티 도구는 문제가 발생할 수 있는 위치를 신속하게 좁혀서 도움을 줍니다.
>
>
> 
>
> 관찰 가능성 중심 개발을 통해 엔지니어링 팀은 유리 성을 인터랙티브한 놀이터로 바꿀 수 있습니다. 프로덕션 환경은 고정된 것이 아니라 변화무쌍하며, 엔지니어는 어떤 게임에도 자신 있게 뛰어들어 승리를 거둘 수 있는 역량을 갖춰야 합니다. 그러나 옵저버빌리티를 SRE, 인프라 엔지니어 또는 운영팀의 영역으로만 간주하지 않을 때만 가능합니다. 소프트웨어 엔지니어는 옵저버빌리티를 채택하고 개발 관행에 적용하여 프로덕션에 변경을 가하는 것에 대한 두려움의 사이클을 풀어야 합니다.
>
>
> 
>
> 소프트웨어 업계에서는 일반적으로 속도와 품질 간에 상충 관계가 발생한다는 인식이 있습니다. 즉, 소프트웨어를 빠르게 릴리스하거나 고품질 소프트웨어를 릴리스할 수는 있지만 둘 다 릴리스할 수는 없다는 것입니다. "Accelerate: Building and Scaling High Performing Technology Organizations”의 핵심 내용은 이러한 역관계는 잘못된 상식이라는 것입니다. 우수한 성과를 내는 기업에서는 속도와 품질이 함께 상승하며 서로를 강화합니다. 속도가 빨라지면 장애가 더 작아지고 발생 빈도가 줄어들며, 장애가 발생하더라도 복구하기가 더 쉬워집니다. 반대로 다음과 같은 팀의 경우 느리게 움직이는 팀은 실패가 더 자주 발생하고 복구하는 데 훨씬 더 오래 걸리는 경향이 있습니다.
>
>

옵저버빌리티가 해결해야 하는 부분과 옵저버빌리티를 통해서 개발과 운영의 관행도 바꿔줄 수 있다는 부분은 꽤 좋았고 앞으로 옵저버빌리티의 미래에 대해서도 많은 인사이트를 얻을 수 있었다.

> 
>
> CPU 사용률의 변화는 백업 프로세스가 실행 중이거나 가비지 컬렉터가 정리 작업을 수행하거나 시스템에서 다른 현상이 발생할 수도 있는 지표일 수 있습니다. 즉, 이러한 상태들은 우리가 실제로 관심을 가지는 문제뿐만 아니라 시스템의 다양한 요소들을 반영할 수 있습니다. 이러한 측정치를 기반으로 경고를 발생시키면 하드웨어 기반의 단순 측정치로 인해 오류가 발생할 확률이 높아집니다. 이러한 경험이 있는 엔지니어링 팀들은 이러한 유형의 경고를 무시하거나 억제하는 경향이 있으며, "그 경고 걱정하지 마세요; 우리는 이 프로세스가 가끔 메모리가 부족해질 때가 있다는 걸 알고 있습니다."와 같은 문구를 자주 사용합니다.
>
>
> 
>
> 오류가 발생할 가능성이 높은 경고에 익숙해지는 것은 알려진 문제이자 위험한 관행입니다. 다른 산업에서는 이러한 문제를 "비정상적 허용(Normalization of Deviance)"이라고 합니다.
>
>
> 
>
> 신뢰성 있는 서비스를 제공하려면 팀은 신뢰성이 떨어지거나 노이즈가 발생하는 경고를 제거해야 합니다. 그러나 많은 팀은 이러한 불필요한 방해를 제거하는 데 두려움을 느낍니다. 이러한 경고를 제거함으로써 서비스 저하에 대해 배우는 방법이 없다는 우려가 종종 우세합니다. 그러나 이러한 전통적인 경고 유형은 알려진 미지수(known-unknowns)만 감지하는 데 도움이 됩니다.
>
>
> 
>
> 우리는 경고 기준을 두 부분의 하위 집합으로 정의합니다.
>
>
> 첫째, 경고는 서비스의 사용자 경험이 저하된 상태를 신뢰성 있게 반영해야 합니다.
>
>
> 둘째, 경고는 해결할 수 있어야 합니다.
>
>
> 경고에 대응하여 디버깅하고 조치하는 데 체계적인 방법(단순 반복적인 자동화가 아닌)이 있어야 하며, 대응자가 올바른 조치 방법을 추측하지 않아도 되어야 합니다. 이 두 가지 조건이 충족되지 않는다면 구성한 경고는 더 이상 의도한 목적을 달성하지 못하는 것입니다.
>
>
> 
>
> 전통적인 메트릭 기반의 모니터링 접근 방식은 정적인 임곗값을 사용하여 최적의 시스템 상태를 정의하는 데 의존합니다. 그러나 현대 시스템의 성능은 인프라 수준에서도 서로 다른 워크로드 하에서 동적으로 변할 수 있습니다. 정적인 임곗값은 사용자 경험에 미치는 영향을 모니터링하는 데 적합하지 않습니다.
>
>

동의하는 부분이다. 요즘 업무를 하면서도 생각하지만 경고는 상당히 조심스럽게 접근해야 한다고 보는 편이다.(그래서 지금 하고 있는 업무에서도 경고를 아직까지 만들지 못하고 있다.) 경고는 신뢰성 있어야 하고 액션 가능해야 한다. 간단해 보이지만 아주 쉽지 않고 때문에는 알림을 끄는 기능도 필요해 지는데 이 끄는 기능도 결국 많이 꺼지면 신뢰성의 문제가 생겨서 쉽지 않다. 현실 구현을 제외하고 방향성에는 아주 동의한다.

> 
>
> SLOs는 경고의 범위를 사용자들이 서비스를 체험하는 데 영향을 미치는 증상만을 고려하도록 좁힙니다.
>
>
> 
>
> "무엇(what)"과 "왜(why)"를 분리하는 것은 최대한 신호를 극대화하고 노이즈를 최소화하는 좋은 모니터링 작성에서 가장 중요한 차이 중 하나입니다.
>
>

SLO를 설명하면서 얘기한 부분이 흥미로웠고 스터디에서도 여기서 많은 논의를 했는데 내가 이해한 핵심은 What과 Why를 구분하라는 것이다. 경고를 SLO로만 해야 하는데 이는 What을 알려주라는 것이고 Why는 옵저버빌리티 시스템에 들어와서 파악할 수 있게 제공해야 한다는 것이다.

> 
>
> Slack CI의 주요 과제는 복잡성이었습니다. E2E 테스트의 실패는 코드 베이스, 인프라 및 플랫폼 런타임 변경사항이 복잡하게 상호작용한 결과일 수 있습니다. 2020년에 웹 앱 개발자의 단일 커밋에 대하여, 저희 CI 파이프라인은 30개 이상의 테스트 스위트를 GitHub를 통해 실행합니다. 이 파이프라인은 3개의 플랫폼 팀(퍼포먼스, 백엔드, 프론트엔드)과 20개의 다양한 요구사항과 전문 분야가 있는 팀/서비스에 의해 만들어졌습니다. 2020년 중반에 이르러 CI 인프라가 한계에 도달하기 시작했습니다. 테스트 실행이 월별로 10%씩 증가하면서 테스트 실행을 위해 여러 다운스트림 서비스를 확장하는 데 어려움을 겪었습니다.
>
>

Slack의 게스트 챕터가 몇 편 나오는데 CI에서 옵저버빌리티를 사용해서 단계별 성능, 오류 문제를 옵저버빌리티를 사용해서 가시성을 높인 부분이 흥미로웠다. 그동안 옵저버빌리티를 서비스 위주로만 생각해서 이런 식의 적용은 미처 생각해 보지 못했다.


## Part 4. Observability at Scale

> 
>
> 사람들은 일반적으로 자신의 시간 가격을 고려하는 데 익숙하지 않습니다. 인프라를 가동하고 소프트웨어를 구성하는 데 한 시간이 걸리면 DIY 솔루션은 본질적으로 무료인 것처럼 느껴집니다.
>
>

오픈소스를 가져가다 구축할 때 흔히들 하는 실수.

> 
>
> 옵저버빌리티는 조직의 경쟁 우위입니다. 자체 옵저버빌리티 솔루션을 구축하면 자체 관행과 문화에 깊이 뿌리내리고 기존 기관의 지식을 활용하는 솔루션을 개발할 수 있습니다. 많은 워크플로우 및 구현과 함께 작동하도록 설계된 일반적인 사전 구축 소프트웨어를 사용하는 대신, 자체 규칙에 따라 비즈니스의 맞춤형 부분과 긴밀하게 통합되도록 솔루션을 사용자 지정할 수 있습니다.
>
>
> 
>
> 자체 옵저버빌리티 솔루션을 구축하기로 할 때는 조직의 능력과 상용 시스템보다 더 나은 것을 개발할 수 있는 가능성을 모두 현실적으로 고려하는 것이 중요합니다. 조직 전체에서 채택을 장려하는 데 필요한 사용자 인터페이스, 워크플로우 유연성 및 속도를 갖춘 시스템을 제공할 수 있는 조직적 전문성을 갖추고 있습니까? 그렇지 않다면 솔루션의 단점과 해결 방법을 잘 알고 있는 사람들 외에는 널리 채택되지 않는 솔루션에 시간과 비용을 투자하고 비즈니스 기회를 잃게 될 가능성이 높습니다.
>
>
> 
>
> 상용 솔루션의 또 다른 숨겨진 비용은 시간입니다. 예, 기성 솔루션을 구매하면 가치 실현 시간을 단축할 수 있습니다. 하지만 이 경로를 선택할 때는 벤더 종속이라는 숨겨진 함정에 유의해야 합니다.
>
>
> 
>
> 옵저버빌리티 도구에 있어 구축 또는 구매라는 선택은 잘못된 이분법입니다. 선택은 단순히 구축 또는 구매로만 제한되지 않습니다. 세 번째 옵션은 구매 후 구축하는 것입니다. 실제로 이 책의 저자는 대부분의 조직에 이 접근 방식을 권장합니다. 내부 기회비용을 최소화하고 조직의 고유한 요구 사항에 맞는 솔루션을 구축할 수 있습니다.
>
>

나에게 16장 Efficient Data Storage는 가장 재밌는 부분 중 하나였다. 데이터 스토리지에 대해 많이 생각한 적이 없긴 한데 결국 책에서 얘기하는 높은 카디널리티를 고차원으로 모든 메트릭을 저장하려면 스토리지가 문제가 된다. 앞부분 읽으면서는 이런 마법의 스토리지가 있다고? 하는 느낌으로 읽을 때도 있지만 여기서 현실적으로 어떤 스토리지가 있고 각 스토리지의 장단점, 옵저버빌리티를 하려면 어떤 부분은 잘 되지만 어떤 부분에서 한계가 있는지를 잘 설명해 주고 있다. 결국 하이브리드 형을 제안하긴 하는데 현재의 기술적 상황을 잘 지적해 주었다는 느낌이 들었다.


## Part 5. Spreading Observability Culture

> 
>
> 옵저버빌리티의 목표는 엔지니어링 팀이 시스템을 개발, 운영, 철저하게 디버그하고 보고할 수 있는 역량을 제공하는 것입니다. 팀은 시스템 동작을 더 잘 이해하기 위해 시스템에 대해 임의의 질문을 함으로써 호기심을 탐구할 수 있는 권한을 부여받아야 합니다. 팀원들이 도구와 경영진의 지원을 통해 능동적으로 시스템을 조사할 수 있도록 인센티브를 제공해야 합니다.
>
>
> 
>
> 데브옵스 관행이 계속해서 주류로 자리 잡으면서, 미래 지향적인 엔지니어링 리더십 팀은 엔지니어링 팀과 운영팀 사이의 장벽을 제거합니다. 이러한 인위적인 장벽을 제거하면 팀이 소프트웨어 개발과 운영에 대해 더 많은 주인의식을 가질 수 있습니다. 옵저버빌리티는 대기 경험이 부족한 엔지니어가 장애가 발생하는 위치와 장애를 완화하는 방법을 더 잘 이해할 수 있도록 지원하여 소프트웨어 개발과 운영 사이의 인위적인 벽을 허물어뜨립니다.
>
>
> 
>
> 팀이 옵저버빌리티의 이점을 누리게 되면, 프로덕션의 이해와 운영에 대한 신뢰 수준이 높아질 것입니다. 해결되지 않은 '미스터리' 인시던트의 비율이 줄어들고 조직 전체에서 인시던트를 감지하고 해결하는 데 걸리는 시간이 단축될 것입니다. 그러나 이 시점에서 성공을 측정할 때 자주 저지르는 실수는 탐지된 전체 인시던트 수와 같은 얕은 메트릭에 지나치게 집착하는 것입니다.
>
>

옵저버빌리티에 대한 전체적인 생각의 틀을 잡게 해준 좋은 책이라고 생각하고 저자들이 옵저버빌리티에 대해 정말 오래 고민했다는 것도 느낄 수 있었다. 그래서 이 책이 서비스 홍보 책은 아니지만, 또 전혀 아니라고 할 수도 없기에 Honeycomb.io를 한번 써보고 싶다는 생각이 들었다. 가볍게 적용해 볼 옵저버빌리티가 있다면 테스트 삼아 한번 써볼 것 같긴 하다. 물론 개인적으로는 책 초반에 배경 설명이 좀 길고 반복되는 느낌이라서 좀 더 짧은 분량으로도 저자들의 의도를 잘 전달할 수 있지 않았을까 하는 생각도 든다.

