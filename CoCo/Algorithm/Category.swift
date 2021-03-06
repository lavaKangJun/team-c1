//
//  Category.swift
//  CoCo
//
//  Created by 최영준 on 25/01/2019.
//  Copyright © 2019 Team CoCo. All rights reserved.
//

import Foundation

enum Category: String, CaseIterable {
    case feed = "사료"
    case snack = "간식"
    case bowelProducts = "배변용품"
    case healthCare = "건강/관리"
    case beautyBath = "미용/목욕"
    case toyTraining = "장난감/훈련"
    case cushionHouse = "쿠션/하우스"
    case fashionProducts = "패션용품"
    case outdoorProducts = "야외용품"
    case tablewareWaterDispenser = "식기/급수기"

    // MARK: - Methods
    /**
     해당 Category에 포함되는 상세 카테고리 String 리스트를 반환한다.
     - Author: [최영준](https://github.com/0jun0815)
     - Parameters:
        - pet: Pet 타입(강아지/고양이)
     */
    func getData(pet: Pet) -> [String] {
        switch (self) {
        case .feed:
            return (pet == .dog) ?
                ["건식사료", "소프트사료", "캔사료", "수제사료", "분유/우유"] :
                ["건식사료", "캔사료", "파우치사료", "분유", "수제사료"]
        case .snack:
            return (pet == .dog) ?
                ["개껌", "사사미", "수제간식", "비스킷/시리얼/쿠키", "동결/건조간식", "캔/파우치", "저키/스틱", "통살/소시지", "음료"] :
                ["캔/파우치", "스틱", "츄르", "건조간식", "쿠키", "사사미", "캣닢/캣그라스", "수제간식", "소시지"]
        case .bowelProducts:
            return (pet == .dog) ?
                ["배변패드", "배변판", "기저귀", "탈취제/소독제", "물티슈/크리너", "배변유도제", "배변봉투"] :
                ["모래", "모래삽", "배변유도제", "후드형화장실", "평판형화장실", "거름망형화장실", "탈취제/소독제", "기저귀"]
        case .healthCare:
            return (pet == .dog) ?
                ["영양제", "눈세정", "귀세척", "유산균", "치약", "칫솔", "구강청결제", "구강티슈"] :
                ["영양제", "유산균", "구강 관리용품", "오메가3", "귀세척", "눈세정"]
        case .beautyBath:
            return (pet == .dog) ?
                ["샴푸/린스/비누", "에센스/향수", "브러시/빗", "이발기", "미용가위", "발톱/발 관리", "드라이기", "타월/가운", "기타용품"] :
                ["샴푸", "에센스/향수", "브러시/빗", "이발기/가위", "발톱/발 관리", "드라이기", "드라이룸", "타월/가운", "물티슈"]
        case .toyTraining:
            return (pet == .dog) ?
                ["노즈워크", "장난감/토이", "공/원반", "훈련용품"] :
                ["낚시/막대", "오뎅꼬치", "카샤카샤", "토이/쿠션/공", "터널/주머니", "자동장난감", "스크래쳐", "레이저포인터"]
        case .cushionHouse:
            return (pet == .dog) ?
                ["쿠션/방석", "하우스", "매트", "계단", "안전문", "울타리"] :
                ["캣타워", "숨숨집", "하우스", "방석"]
        case .fashionProducts:
            return (pet == .dog) ?
                ["패딩/아우터", "올인원/원피스", "티셔츠", "기타의류", "악세서리"] :
                ["옷", "신발"]
        case .outdoorProducts:
            return ["목줄", "가슴줄", "목걸이/인식표", "리드줄", "캐리어", "유모차", "카시트", "슬링백"]
        case .tablewareWaterDispenser:
            return ["식기/식탁", "자동급식기", "급수기/물병", "정수기/필터", "사료통/사료스푼"]
        }
    }
}
