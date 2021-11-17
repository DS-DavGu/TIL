# [REVIEW] Recommender System in E-learning

Zhang Q, Lu J, Zhang G. Recommender Systems in E-learning. J Smart Environ Green Comput 2021;1:76-89 . http://dx.doi.org/10.20517/jsegc.2020.06
[https://oaepublishstorage.blob.core.windows.net/1966336c-a037-485a-89d4-294de0b15df0/4015.pdf](https://oaepublishstorage.blob.core.windows.net/1966336c-a037-485a-89d4-294de0b15df0/4015.pdf)






**논문 요약:** 
현재 E-learning 쪽의 레코멘더 시스템으로 연구되었던 최신 현황들 파악. 2021년 최신 논문



1. **(뻔한) 인트로 부분**

- 어차피 e-learning 플랫폼의 추천이라 해도 크게 다를 건 없음.
    - 결국은 네 개의 카테고리 중 하나에 들어갈 것
    
    1) 컨텐츠 기반
    2) CF 기반
    3) Knowledge 기반
    4) 하이브리드
- 그렇지만 기존의 e커머스나 OTT 쪽 모델을 그대로 쓰기는 어려운 부분들이 존재함
    
    1) 학습자의 요구사항이나 학습 activity의 면면이 uncertain/vague한 부분들이 존재...
    
    예: 본인들이 무슨 skill을 필요로 하고 어떤 코스를 들어야 하는지조차 모르지만
    대신 어떤 job을 찾는지는 알고 있음
    (learner route rec?)
    
    2) 학습 맥락의 중요성.
    
    - course를 듣는 이유
    - learning style
        - full-time learner와 fragmentary time learner에 대해서 다른 추천이 이루어져야 할 가능성도 존재
    
    3) 선수과정에 대한 고려가 필요할 수 있음
    
    - 조금 더 고민해보자면 AI Basic한 부분을 먼저 많이 들었을수록 AI 논문리뷰 코스를 더 많이 추천해 준다던가..
    
    4) learning route가 필요한 유저들도 존재할 수 있음.
    
    - 어떠한 지식을 연속적으로 쌓고 싶은 경우
        - 한 코스 추천만 원하는 게 아니라 A→B→C로 이어지는 learning route를 주세요가 요구사항일수도.
        
- 이러한 부분 때문에 E-learning 추천은 life-long learner(장기 학습자, 고학습자들)의 추천 relevance와 UX를 발전시키기 위한 방향성으로 발전해 왔음.







1. **주요 기술들**

다 알고 있는 내용이지만 한번 더 정리하자면...

---

- **컨텐츠 기반 추천**
    
    
    - 컨텐츠/유저에 대한 메타가 충분할 때 사용할 수 있는 방식
    - 유저가 좋아했던 컨텐츠와 "유사한" 컨텐츠를 추천함
    - 메타를 구성하는 방식도 다양함
        - prerequisite structure를 표현하기 위해 hierarchial tree 구조를 사용한다던지..
    - 세 가지 방식을 좀 소개하자면...
    
    1) Semantic-based 추천
    
    - 아이템으로부터 semantic 추출하여 유사도 계산
    - 전통적으로는 bag-of-words 같은 방식으로
        - 자카드/코사인 거리 계산하는 방식..
    - 워드 임베딩 기술이 발전하면서...
        - item의 word를 latent representation하여 DNN으로 돌림
        - user의 like/dislike를 output으로 두고 latent space update하는 방식으로(ncf의 임베딩 공간 로직이랑 비슷하네...)
        - Mikolov T, Sutskever I, Chen K, Corrado GS, Dean J. Distributed representations of words and phrases and their compositionality. Advances in Neural Information Processing Systems 2013;26:3111–19ㅇ
    
    2) Attribute-based 추천
    
    - 컨텐츠의 structured meta data를 이용하여 유사도 계산...
        - 카테고리, 선수과정...
    - 중요한 건 이 attributes들의 관계를 계층적 트리 구조로 나타낼 수 있다?
        - 정확히 무슨 내용인지는 해당 논문을 확인해봐야 할듯...
        - Salehi M. Application of implicit and explicit attribute based collaborative filtering and BIDE for learning resource recommendation. Data & Knowledge Engineering 2013;87:130–45.
    - 이런 경우도 있음. 유저가 "나 이런거 듣고 싶어"라고 명시적으로 표현했던 정보가 있다고 할 때...(knowledge 기반 추천)
        - 그것이 컨텐츠의 meta와 linguistically matching이 잘 안 되는 경우 존재...
    - new keywords: fuzzy requirement tree / fuzzy category tree
    
    3) Query-based recommendation
    
    - 유저가 직접 search해서 찾은 아이템들 → 관심있는 키워드?
        - Wang D, Liang Y, Xu D, Feng X, Guan R. A content ­based recommender system for computer science publications. Knowledge Based Systems 2018;157:1–9.
    - 이 search query를 이용 시 장점은 다음과 같다...
        - 학습 이력에서 드러나지 않는 current interest를 반영할 수 있음
        - 쿼리 정보 + 유저 프로파일을 결합하여 모델링 가능
            1. Meng F, Gao D, Li W, Sun X, Hou Y. A unified graph model for personalized query­oriented reference paper recommendation. In: Proceedings of the 22nd ACM International Conference on Information & Knowledge Management; 2013. pp. 1509–12.
            2. Cai X, Han J, Li W, Zhang R, Pan S, et al. A three­layered mutually reinforced model for personalized citation recommendation. IEEE Transactions on Neural Networks and Learning Systems 2018;29:6026–37.
        - 문제는 유저가 뭘 검색해야 할 줄 몰라서 검색쿼리 자체가 정확하지 않을수 있음...
            - 새로 배우는 분야라서 뭘 찾을지 모르는것
    

---

- 협업 필터링

    - feedback(explicit or implicit) 기반의 추천 모델링
    - 크게 model-based와 memory-based
        - model-based : similarity btw entities를 모델 기반으로 찾기
        - memory-based : similarity를 알아서 찾기...
    
    1) Context-aware 추천
    
    - 여기서 context라는 건 유저와 시스템의 interaction에 영향을 주는 모든 요소들...
        - 다른 유저, 위치 등...
        - 학습 목표, 학습 시간, 디바이스, ...
    
    2) Deep CF 기반 추천
    
    - RNN을 활용해서 러너와 아이템의 sequential interaction을 모델링하는 경우
    

---

- Knowledge 기반

    - 지식 기반 추천은 다음과 같을 때 사용됨
    - 유저 레이팅은 충분하지 않음 & 아이템 컨텐츠가 복잡한 domain 지식을 포함하고 있을 때...
    - 콜드스타트/data sparsity 문제에서 비교적 자유로운 편
    - 대신 ontology 등의 pre-model 절차가 필요하고 비용도 쎄다...









