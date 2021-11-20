# Omitted Variable Bias

- Omitted Variable Bias(OVB)는 회귀 문제에서 종속변수에 대한 설명에 중요한 변수임에도 불구하고 OLS 수식에서 누락되어버린 변수를 말한다.
- 이로 인해 OLS Estimator의 Bias를 불러 일으킨다.

- 심플 케이스로 다음과 같은 population model의 경우를 생각해보자.
    - y = b0 + b1x1 + b2x2 + e

- 그런데, x2를 수집할 수 없는 상황이라고 하자.
    - 그럼 현재 상황은...
    - y` = b0` + b1`x
    - 이런 경우를 underspecified model이라고 한다.
    - 만약 b1^과 b2^을 구할 수 있었다면...
        - b1` = b1^ + b2^**δ 이라고 할 수 있겠지..**
    - 이 때 **δ는 x2를 x1에 regress한 것이다.**
    
- 그렇다면 b1`의 bias는...
    - E( β1`) 
    = E( β1^ + β2^δ`)
    = E( β1^) +E( β2^)δ` 
    = β1` + β2`δ`
        (since it is known E(B1^) = B1 as they are unbiased estimators)
    - 따라서 b1의 Bias는...
    - Bias(˜β1) = E( ˜β1) − β1 = β2˜δ.
