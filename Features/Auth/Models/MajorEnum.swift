//
//  MajorEnum.swift
//  UniClub
//
//  Created by 제욱 on 2/9/26.
//

import Foundation

enum MajorCatalog {

    static let all: [MajorItem] = [

        // ===== 인문대학 =====
        .init(code: "KOREAN_LANGUAGE_LITERATURE", display: "국어국문학과"),
        .init(code: "ENGLISH_LANGUAGE_LITERATURE", display: "영어영문학과"),
        .init(code: "JAPANESE_REGIONAL_CULTURE", display: "일본지역문화학과"),
        .init(code: "CHINESE_LANGUAGE_LITERATURE", display: "중어중국학과"),
        .init(code: "GERMAN_LANGUAGE_LITERATURE", display: "독어독문학과"),
        .init(code: "FRENCH_LANGUAGE_LITERATURE", display: "불어불문학과"),

        // ===== 자연과학대학 =====
        .init(code: "MATHEMATICS", display: "수학과"),
        .init(code: "PHYSICS", display: "물리학과"),
        .init(code: "CHEMISTRY", display: "화학과"),
        .init(code: "MARINE_SCIENCE", display: "해양학과"),
        .init(code: "FASHION_INDUSTRY", display: "패션산업학과"),

        // ===== 사회과학대학 =====
        .init(code: "SOCIAL_WELFARE", display: "사회복지학과"),
        .init(code: "MEDIA_COMMUNICATION", display: "미디어커뮤니케이션학과"),
        .init(code: "LIBRARY_INFORMATION_SCIENCE", display: "문헌정보학과"),
        .init(code: "CREATIVE_TALENT_DEVELOPMENT", display: "창의인재개발학과"),

        // ===== 글로벌정경대학 =====
        .init(code: "PUBLIC_ADMINISTRATION", display: "행정학과"),
        .init(code: "POLITICAL_SCIENCE_DIPLOMACY", display: "정치외교학과"),
        .init(code: "ECONOMICS", display: "경제학과"),
        .init(code: "TRADE", display: "무역학부"),
        .init(code: "CONSUMER_STUDIES", display: "소비자학과"),

        // ===== 공과대학 =====
        .init(code: "MECHANICAL_ENGINEERING", display: "기계공학과"),
        .init(code: "ELECTRICAL_ENGINEERING", display: "전기공학과"),
        .init(code: "ELECTRONIC_ENGINEERING", display: "전자공학과"),
        .init(code: "INDUSTRIAL_MANAGEMENT_ENGINEERING", display: "산업경영공학과"),
        .init(code: "MATERIALS_SCIENCE_ENGINEERING", display: "신소재공학과"),
        .init(code: "SAFETY_ENGINEERING", display: "안전공학과"),
        .init(code: "ENERGY_CHEMICAL_ENGINEERING", display: "에너지화학공학과"),
        .init(code: "BIO_ROBOT_SYSTEM_ENGINEERING", display: "바이오-로봇 시스템 공학과"),

        // ===== 정보기술대학 =====
        .init(code: "COMPUTER_ENGINEERING", display: "컴퓨터공학부"),
        .init(code: "INFORMATION_COMMUNICATION_ENGINEERING", display: "정보통신공학과"),
        .init(code: "EMBEDDED_SYSTEM_ENGINEERING", display: "임베디드시스템공학과"),

        // ===== 경영대학 =====
        .init(code: "BUSINESS_ADMINISTRATION", display: "경영학부"),
        .init(code: "DATA_SCIENCE", display: "데이터과학과"),
        .init(code: "TAXATION_ACCOUNTING", display: "세무회계학과"),
        .init(code: "TECHNO_MANAGEMENT", display: "테크노경영학과"),

        // ===== 예술체육대학 =====
        .init(code: "KOREAN_PAINTING", display: "한국화전공(조형예술학부)"),
        .init(code: "WESTERN_PAINTING", display: "서양화전공(조형예술학부)"),
        .init(code: "DESIGN", display: "디자인학부"),
        .init(code: "PERFORMING_ARTS", display: "공연예술학과"),
        .init(code: "SPORTS_SCIENCE", display: "스포츠과학부"),
        .init(code: "EXERCISE_HEALTH", display: "운동건강학부"),

        // ===== 사범대학 =====
        .init(code: "KOREAN_EDUCATION", display: "국어교육과"),
        .init(code: "ENGLISH_EDUCATION", display: "영어교육과"),
        .init(code: "JAPANESE_EDUCATION", display: "일어교육과"),
        .init(code: "MATHEMATICS_EDUCATION", display: "수학교육과"),
        .init(code: "PHYSICAL_EDUCATION", display: "체육교육과"),
        .init(code: "EARLY_CHILDHOOD_EDUCATION", display: "유아교육과"),
        .init(code: "HISTORY_EDUCATION", display: "역사교육과"),
        .init(code: "ETHICS_EDUCATION", display: "윤리교육과"),

        // ===== 도시과학대학 =====
        .init(code: "URBAN_ADMINISTRATION", display: "도시행정학과"),
        .init(code: "CONSTRUCTION_ENVIRONMENTAL_ENGINEERING", display: "건설환경공학"),
        .init(code: "ENVIRONMENTAL_ENGINEERING", display: "환경공학"),
        .init(code: "URBAN_ENGINEERING", display: "도시공학과"),
        .init(code: "ARCHITECTURAL_ENGINEERING", display: "건축공학"),
        .init(code: "URBAN_ARCHITECTURE", display: "도시건축학"),

        // ===== 생명과학기술대학 =====
        .init(code: "LIFE_SCIENCE", display: "생명과학부(생명과학전공)"),
        .init(code: "MOLECULAR_LIFE_SCIENCE", display: "생명과학부(분자의생명전공)"),
        .init(code: "BIOTECHNOLOGY", display: "생명공학부(생명공학전공)"),
        .init(code: "NANO_BIOTECHNOLOGY", display: "생명공학부(나노바이오공학전공)"),

        // ===== 융합자유전공대학 =====
        .init(code: "FREE_MAJOR", display: "자유전공학부"),
        .init(code: "INTERNATIONAL_FREE_MAJOR", display: "국제자유전공학부"),
        .init(code: "CONVERGENCE", display: "융합학부"),

        // ===== 동북아국제통상학부 =====
        .init(code: "NORTHEAST_ASIA_INTERNATIONAL_COMMERCE", display: "동북아국제통상전공"),
        .init(code: "SMART_LOGISTICS_ENGINEERING", display: "스마트물류공학전공"),
        .init(code: "IBE", display: "IBE전공"),

        // ===== 법학부 =====
        .init(code: "LAW", display: "법학부"),

        // ===== 대학원 =====
        .init(code: "KOREAN_LANGUAGE_EDUCATION", display: "한국어교육학과"),
        .init(code: "EDUCATION", display: "교육학과"),
        .init(code: "ETHICS", display: "윤리학과"),
        .init(code: "CHINESE_STUDIES", display: "중국학과"),
        .init(code: "LAW_DEPARTMENT", display: "법학과"),
        .init(code: "BUSINESS_ADMINISTRATION_DEPARTMENT", display: "경영학과"),
        .init(code: "TRADE_DEPARTMENT", display: "무역학과"),
        .init(code: "NORTHEAST_ASIA_COMMERCE", display: "동북아통상학과"),
        .init(code: "URBAN_PLANNING_POLICY", display: "도시계획·정책학과(협동과정)"),
        .init(code: "EARLY_CHILDHOOD_FOREST_NATURE_EDUCATION", display: "유아·숲·자연교육학과(협동과정)"),
        .init(code: "TOURISM_CONVENTION_ENTERTAINMENT", display: "관광컨벤션엔터테인먼트학과"),

        .init(code: "LIFE_SCIENCE_DEPARTMENT", display: "생명과학과"),
        .init(code: "CLOTHING_TEXTILES", display: "의류학과"),
        .init(code: "BEAUTY_INDUSTRY", display: "뷰티산업학과"),

        .init(code: "COMPUTER_ENGINEERING_DEPARTMENT", display: "컴퓨터공학과"),
        .init(code: "CONSTRUCTION_ENVIRONMENTAL_ENGINEERING_DEPARTMENT", display: "건설환경공학과"),
        .init(code: "ENVIRONMENTAL_ENERGY_ENGINEERING", display: "환경에너지공학과"),
        .init(code: "URBAN_CONSTRUCTION_ENGINEERING", display: "도시건설공학과"),
        .init(code: "ARCHITECTURE", display: "건축학과"),
        .init(code: "LIFE_NANO_BIOTECHNOLOGY", display: "생명·나노바이오공학과"),
        .init(code: "CLIMATE_INTERNATIONAL_COOPERATION", display: "기후국제협력학과(협동과정)"),
        .init(code: "URBAN_CONVERGENCE_COMPLEX", display: "도시융·복합학과(협동과정)"),
        .init(code: "INTELLIGENT_SEMICONDUCTOR_ENGINEERING", display: "지능형반도체공학과(협동과정)"),
        .init(code: "ARTIFICIAL_INTELLIGENCE", display: "인공지능학과(협동과정)"),
        .init(code: "FUTURE_MOBILITY", display: "미래모빌리티학과(협동과정)"),
        .init(code: "BIO_HEALTH_CONVERGENCE", display: "바이오헬스융합학과(협동과정)"),

        .init(code: "PHYSICAL_EDUCATION_DEPARTMENT", display: "체육학과"),
        .init(code: "FINE_ARTS", display: "미술학과"),
        .init(code: "DESIGN_DEPARTMENT", display: "디자인학과"),

        .init(code: "LOGISTICS_MANAGEMENT", display: "물류경영학과"),
        .init(code: "LOGISTICS_SYSTEM", display: "융합물류시스템학과"),

        .init(code: "EDUCATIONAL_ADMINISTRATION_LEADERSHIP", display: "교육행정·리더십전공"),
        .init(code: "INSTRUCTIONAL_DESIGN_CONSULTING", display: "수업설계·수업컨설팅 전공"),
        .init(code: "LIFELONG_VOCATIONAL_EDUCATION", display: "평생·직업교육전공"),
        .init(code: "COUNSELING_PSYCHOLOGY", display: "상담심리전공"),
        .init(code: "CREATIVITY_GIFTED_EDUCATION", display: "창의성·영재교육전공"),
        .init(code: "CHILD_ART_PSYCHOTHERAPY", display: "아동 예술심리치료전공"),
        .init(code: "MEDIA_EDUCATION", display: "미디어교육전공"),
        .init(code: "MECHANICAL_EDUCATION", display: "기계교육전공"),
        .init(code: "ART_EDUCATION", display: "미술교육전공"),
        .init(code: "SPORTS_CULTURE_ADMINISTRATION", display: "스포츠문화행정전공"),

        .init(code: "JUDICIAL_ADMINISTRATION", display: "사법행정학과"),
        .init(code: "CRISIS_MANAGEMENT", display: "위기관리학과"),
        .init(code: "LEGISLATIVE_SECURITY_STUDIES", display: "의회정치·안보정책학과"),

        .init(code: "URBAN_ENGINEERING_MAJOR", display: "도시공학전공"),
        .init(code: "SAFETY_ENVIRONMENTAL_SYSTEM_ENGINEERING", display: "안전환경시스템공학전공"),
        .init(code: "CONVERGENCE_DESIGN", display: "융합디자인전공"),
        .init(code: "ARCHITECTURAL_DESIGN_ENGINEERING", display: "건축학전공"),

        .init(code: "LOCAL_CULTURE", display: "지역문화학과")
    ]
}
