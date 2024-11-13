import 'package:flutter/material.dart';
import 'package:secure_notes/localization/demo_localisations.dart';

String getTranslated(BuildContext context, String key){
  return DemoLocalization.of(context).getTranslatedValue(key) ?? '';

}
