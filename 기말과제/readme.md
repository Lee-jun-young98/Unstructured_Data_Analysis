# 패혈증 예측

---

---

# 개요

---

- 패혈증이란?
- 미생물에 감염되어 발열, 빠른 맥박, 호흡수 증가, 백혈구 수의 증가 또는 감소 전신에 걸친 염증 반응이 나타나는 상태
- 전신에 모두 나타날 수 있으며, 관련 증상으로는 반점, 자반, 근육통 등이 있음
- 진단 방법
    1. 체온이 38도 이상으로 올라가는 발열 증상
    2. 체온이 36도 이하로 내려가는 저체온증
    3. 호흡수가 분당 24회 이상으로 증가(빈호흡)
    4. 분당 90회 이상의 심박수(빈맥)
    5. 혈액 검사상 백혈구 수의 증가 혹은 감소
    - 위의 증상 중 두 가지 이상의 증상을 보이는 경우 **패혈증**이라 진단 내릴 수 있음
- 참고 자료

[서울대학교병원](http://www.snuh.org/health/nMedInfo/nView.do?category=DIS&medid=AA000043)

- 위의 정보를 통해 MIMIC2 Dataset를 이용하여 패혈증 환자를 예측함
- 데이터셋 정보
    
    [MIMIC2 original ICU](https://www.kaggle.com/datasets/drscarlat/mimic2-original-icu?resource=download)
    

---

---

# Dataset

- 총 39개의 데이터셋이 존재하며 그 중 **Chartevents, icd9, d_chartitems** 데이터를 사용하여 분석을 진행함

---

### Chartevents

![Untitled1](%E1%84%91%E1%85%A2%E1%84%92%E1%85%A7%E1%86%AF%E1%84%8C%E1%85%B3%E1%86%BC%20%E1%84%8B%E1%85%A8%E1%84%8E%E1%85%B3%E1%86%A8%206629c84d088940a0908052e874bb7618/Untitled.png)

![Untitled](%E1%84%91%E1%85%A2%E1%84%92%E1%85%A7%E1%86%AF%E1%84%8C%E1%85%B3%E1%86%BC%20%E1%84%8B%E1%85%A8%E1%84%8E%E1%85%B3%E1%86%A8%206629c84d088940a0908052e874bb7618/Untitled%201.png)

- “subect_id”, “icustay_id” 외에 총 16가지의 열이 존재
- 총 34240620개의 행으로 이루어져 있음

---

---

### ICD9

![Untitled](%E1%84%91%E1%85%A2%E1%84%92%E1%85%A7%E1%86%AF%E1%84%8C%E1%85%B3%E1%86%BC%20%E1%84%8B%E1%85%A8%E1%84%8E%E1%85%B3%E1%86%A8%206629c84d088940a0908052e874bb7618/Untitled%202.png)

![Untitled](%E1%84%91%E1%85%A2%E1%84%92%E1%85%A7%E1%86%AF%E1%84%8C%E1%85%B3%E1%86%BC%20%E1%84%8B%E1%85%A8%E1%84%8E%E1%85%B3%E1%86%A8%206629c84d088940a0908052e874bb7618/Untitled%203.png)

- “subject_id”, “hadm_id” 외에 총 5가지의 열이 존재

---

---

### d_chartitems

![Untitled](%E1%84%91%E1%85%A2%E1%84%92%E1%85%A7%E1%86%AF%E1%84%8C%E1%85%B3%E1%86%BC%20%E1%84%8B%E1%85%A8%E1%84%8E%E1%85%B3%E1%86%A8%206629c84d088940a0908052e874bb7618/Untitled%204.png)

![Untitled](%E1%84%91%E1%85%A2%E1%84%92%E1%85%A7%E1%86%AF%E1%84%8C%E1%85%B3%E1%86%BC%20%E1%84%8B%E1%85%A8%E1%84%8E%E1%85%B3%E1%86%A8%206629c84d088940a0908052e874bb7618/Untitled%205.png)

- “item id”, “label”외에 총 4개의 컬럼이 존재
- 위의 진단 방법에 해당하는 item 검색
    - Respiratory Rate(618) : 호흡 수
    - Heart rate(211) : 심박수(맥박수)
    - Urine Leukocytes(3819) : 백혈구(에스테라제)
    - temperature(676) : 체온

---

---

# 데이터 전처리

---

### ICD9

- 패혈증 종류

![Untitled](%E1%84%91%E1%85%A2%E1%84%92%E1%85%A7%E1%86%AF%E1%84%8C%E1%85%B3%E1%86%BC%20%E1%84%8B%E1%85%A8%E1%84%8E%E1%85%B3%E1%86%A8%206629c84d088940a0908052e874bb7618/Untitled%206.png)

- “SEPTICEMIA”가 포함되는 문자열을 가진 패혈증이 24가지 존재
- 24가지 패혈증 종류로 패혈증 환자의 개수를 파악
    - 총 940명의 패혈증 환자가 존재
    
    ![Untitled](%E1%84%91%E1%85%A2%E1%84%92%E1%85%A7%E1%86%AF%E1%84%8C%E1%85%B3%E1%86%BC%20%E1%84%8B%E1%85%A8%E1%84%8E%E1%85%B3%E1%86%A8%206629c84d088940a0908052e874bb7618/Untitled%207.png)
    
    → 데이터 라벨링 진행
    
    - 패혈증을 진단 받았을 때 1
    - 패혈증이 아닐 때 0

---

---

### Chartevents

- 전체 데이터에서 itemid = 618, 211, 676인 행만 추출

![Untitled](%E1%84%91%E1%85%A2%E1%84%92%E1%85%A7%E1%86%AF%E1%84%8C%E1%85%B3%E1%86%BC%20%E1%84%8B%E1%85%A8%E1%84%8E%E1%85%B3%E1%86%A8%206629c84d088940a0908052e874bb7618/Untitled%208.png)

- 필요하지 않은 열 삭제 → 'elemid', 'cgid', 'cuid', "realtime",'value1', 'value2', 'value2num', 'value2uom', 'resultstatus', 'stopped’
- 사용자 정의 함수(data_merge)를 통하여 “subject_id”, “icustay_id”, “charttime”을 기준으로 동일한 시간대의 데이터를 합침
    
    ```python
    def data_merge(df, subject_id):
        """
        item_id 조건에 맞는 행만 추출해서 dataframe 생성
        """
        data_merge = pd.DataFrame(columns = ["subject_id", "icustay_id", "item_id1", "charttime", "Heart_rate", "item_id1_uom", "item_id2", "Respiratory_Rate", "item_id2_uom", "item_id3", "temperature", "item_id_3_uom"])
        count = 0
        for i in subject_id:
            data = df[df["subject_id"] == i]
            data = data.dropna()
            data_hr = data[data["itemid"] == 211]
            data_rr = data[data["itemid"] == 618]
            data_temp = data[data["itemid"] == 676]
            hi = pd.merge(data_hr, data_rr, how = 'inner', on = ['subject_id', 'icustay_id', 'charttime'])
            total_sub = pd.merge(hi, data_temp, how = 'inner', on = ['subject_id', 'icustay_id', 'charttime'])
            total_sub.columns = ["subject_id", "icustay_id", "item_id1", "charttime", "Heart_rate", "item_id1_uom", "item_id2", "Respiratory_Rate", "item_id2_uom", "item_id3", "temperature", "item_id_3_uom"]
            data_merge = pd.concat([data_merge, total_sub])
            count += 1
            print("{} 번째 subject_id : {} 완료".format(count, i))
            
        return data_merge
    ```
    

![Untitled](%E1%84%91%E1%85%A2%E1%84%92%E1%85%A7%E1%86%AF%E1%84%8C%E1%85%B3%E1%86%BC%20%E1%84%8B%E1%85%A8%E1%84%8E%E1%85%B3%E1%86%A8%206629c84d088940a0908052e874bb7618/Untitled%209.png)

- 29414개의 행과 13개의 열이 생성됨
- 진단 조건을 이용하여 데이터 라벨링을 진행
    1. 체온이 38도 이상으로 올라가는 발열 증상
    2. 체온이 36도 이하로 내려가는 저체온증
    3. 호흡수가 분당 24회 이상으로 증가(빈호흡)
    4. 분당 90회 이상의 심박수(빈맥)
    
    → 위의 조건을 만족할 경우 “SEPTICEMIA”열에 1, 아니면 0으로 라벨링을 진행
    
    →  0 : 27576, 1 : 1838개의 라벨 데이터가 생성
    
    ![Untitled](%E1%84%91%E1%85%A2%E1%84%92%E1%85%A7%E1%86%AF%E1%84%8C%E1%85%B3%E1%86%BC%20%E1%84%8B%E1%85%A8%E1%84%8E%E1%85%B3%E1%86%A8%206629c84d088940a0908052e874bb7618/Untitled%2010.png)
    

---

---

# 데이터 훈련

---

### 데이터 설명 및 실험 진행

![Untitled](%E1%84%91%E1%85%A2%E1%84%92%E1%85%A7%E1%86%AF%E1%84%8C%E1%85%B3%E1%86%BC%20%E1%84%8B%E1%85%A8%E1%84%8E%E1%85%B3%E1%86%A8%206629c84d088940a0908052e874bb7618/Untitled%2011.png)

- 29414의 row로 이루어져 있으며 12개의 변수와 1개의 label(”**SEPTICEMIA**”)가 존재

![Untitled](%E1%84%91%E1%85%A2%E1%84%92%E1%85%A7%E1%86%AF%E1%84%8C%E1%85%B3%E1%86%BC%20%E1%84%8B%E1%85%A8%E1%84%8E%E1%85%B3%E1%86%A8%206629c84d088940a0908052e874bb7618/Untitled%2012.png)

- 위의 5가지 알고리즘을 사용
- Train : validation : test = 5.5 : 1.5 : 3으로 하였으며 StarifieldKFold(n = 5)사용

---

---

### 데이터 분석

- 변수 시각화

![Untitled](%E1%84%91%E1%85%A2%E1%84%92%E1%85%A7%E1%86%AF%E1%84%8C%E1%85%B3%E1%86%BC%20%E1%84%8B%E1%85%A8%E1%84%8E%E1%85%B3%E1%86%A8%206629c84d088940a0908052e874bb7618/Untitled%2013.png)

- SEPTICEMIA

![Untitled](%E1%84%91%E1%85%A2%E1%84%92%E1%85%A7%E1%86%AF%E1%84%8C%E1%85%B3%E1%86%BC%20%E1%84%8B%E1%85%A8%E1%84%8E%E1%85%B3%E1%86%A8%206629c84d088940a0908052e874bb7618/Untitled%2014.png)

- label 불균형을 해소하기 위해 SMOTE 알고리즘을 사용하여 over sampling을 진행
- Heart_rate, Respiratory_Rate, temperature 변수가 모두 다른 scale를 가지므로 standardscaler를 진행

---

---

# 데이터 모델링

---

### 머신러닝 모델

---

![Untitled](%E1%84%91%E1%85%A2%E1%84%92%E1%85%A7%E1%86%AF%E1%84%8C%E1%85%B3%E1%86%BC%20%E1%84%8B%E1%85%A8%E1%84%8E%E1%85%B3%E1%86%A8%206629c84d088940a0908052e874bb7618/Untitled%2015.png)

- Accuracy, ROC AUC, Precision, Recall, F1의 지표로 측정하였으며 Tree 모형 모델(Decision Tree, RandomFroest)의 성능이 높게 나오는 것을 알 수 있음

---

---

### 딥러닝 모델

- ANN 모델 사용
- activation : ‘relu’
- optimizer : ‘rmsprop’
- epochs = 50
- batch_size = 32
- Accuracy, loss 그래프

![Untitled](%E1%84%91%E1%85%A2%E1%84%92%E1%85%A7%E1%86%AF%E1%84%8C%E1%85%B3%E1%86%BC%20%E1%84%8B%E1%85%A8%E1%84%8E%E1%85%B3%E1%86%A8%206629c84d088940a0908052e874bb7618/Untitled%2016.png)

![Untitled](%E1%84%91%E1%85%A2%E1%84%92%E1%85%A7%E1%86%AF%E1%84%8C%E1%85%B3%E1%86%BC%20%E1%84%8B%E1%85%A8%E1%84%8E%E1%85%B3%E1%86%A8%206629c84d088940a0908052e874bb7618/Untitled%2017.png)

---

## 결론

- 딥러닝 모델이 Tree 형식 모델인 Decision Tree와 RandomForest를 제외하고 다른 모델에 비해 성능이 좋은 것을 알 수 있음

---

---
