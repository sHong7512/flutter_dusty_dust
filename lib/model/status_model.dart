import 'package:flutter/material.dart';

class StatusModel {
  // 단계
  final int level;

  // 단계 이름
  final String label;

  // 색상
  final Color primaryColor;
  final Color darkColor;
  final Color lightColor;
  final Color detailFontColor;

  // 이모티콘 이미지
  final String imagePath;

  // 코멘트
  final String comment;

  // 대기 수치 관련 최소치
  final double minFineDust;
  final double minUltraFineDust;
  final double minO3;
  final double minNO2;
  final double minCO;
  final double minSO2;

  StatusModel({
    required this.level,
    required this.label,
    required this.primaryColor,
    required this.darkColor,
    required this.lightColor,
    required this.detailFontColor,
    required this.imagePath,
    required this.comment,
    required this.minFineDust,
    required this.minUltraFineDust,
    required this.minO3,
    required this.minNO2,
    required this.minCO,
    required this.minSO2,
  });

}