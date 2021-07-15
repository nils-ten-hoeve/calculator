
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

const equal_sign = "\u003D";

const add_sign = "\u002B";

const minus_sign = "-";

const multiply_sign = "\u00D7";

const divide_sign = "\u00F7";

const percent_sign = "%";

const plus_or_minus_sign = "+/-";

const clear_sign = "AC";

const media_file_icon =Icons.lock_outline_sharp;

const browser_icon =Icons.star_border_outlined;

const settings_icon =Icons.settings;

final List<int> cipherKey=utf8.encoder.convert ( 'A 32 character Aes cipher key!@#');

final hiveCipher =HiveAesCipher(cipherKey);
