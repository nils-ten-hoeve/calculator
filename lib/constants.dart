import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

const equalSign = "\u003D";

const addSign = "\u002B";

const minusSign = "-";

const multiplySign = "\u00D7";

const divideSign = "\u00F7";

const percentSign = "%";

const plusOrMinusSign = "+/-";

const clearSign = "AC";

const mediaFileIcon = Icons.perm_media_outlined;

const browserIcon = Icons.star_border_outlined;

const settingsIcon = Icons.settings;

final List<int> cipherKey =
    utf8.encoder.convert('A 32 character Aes cipher key!@#');

final hiveCipher = HiveAesCipher(cipherKey);
