import 'package:calculator/app.dart';
import 'package:calculator/calculator_widgets/binary_operator_button.dart';
import 'package:calculator/calculator_widgets/number_button.dart';
import 'package:calculator/calculator_widgets/unary_operator_button.dart';
import 'package:calculator/calculator_widgets/zero_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:volume_control/volume_control.dart';

import 'browser_page.dart';
import '../constants.dart';

enum Operation {
  none,
  divide,
  multiply,
  subtract,
  add,
  clear,
  changeSign,
  addDecimal,
  percent,
  equals
}

enum BinaryOperation {
  divide,
  multiply,
  subtract,
  add,
}

enum UnaryOperation {
  changeSign,
  percent,
}

enum OtherOperation { clear, addDecimal, equals }

// ignore: must_be_immutable
class CalculatorPage extends StatefulWidget {
  const CalculatorPage({Key? key}) : super(key: key);

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  dynamic operand1;
  dynamic operand2;
  String? operator;
  dynamic result;
  bool isOperand1Completed = false;
  final TextStyle _whiteTextStyle =
      const TextStyle(color: Colors.white, fontSize: 35.0);

  @override
  void initState() {
    super.initState();
    initializeValues();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      operand1 != null
                          ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                operand1 is double
                                    ? operand1.toStringAsFixed(2)
                                    : operand1.toString(),
                                style: _whiteTextStyle,
                                textAlign: TextAlign.right,
                              ),
                            )
                          : Container(),
                      operator != null
                          ? Text(
                              operator.toString(),
                              style: _whiteTextStyle,
                              textAlign: TextAlign.right,
                            )
                          : Container(),
                      operand2 != null
                          ? Text(
                              operand2.toString(),
                              style: _whiteTextStyle,
                              textAlign: TextAlign.right,
                            )
                          : Container(),
                      result != null
                          ? const Divider(
                              height: 5.0,
                              color: Colors.white,
                            )
                          : Container(),
                      result != null
                          ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                result is double
                                    ? result.toStringAsFixed(2)
                                    : result.toString(),
                                style: _whiteTextStyle,
                                textAlign: TextAlign.right,
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  UnaryOperatorButton(
                    text: "AC",
                    onPressed: () {
                      _otherOperationAction(OtherOperation.clear);
                    },
                  ),
                  UnaryOperatorButton(
                    text: plusOrMinusSign,
                    onPressed: () {
                      _unaryOperationAction(UnaryOperation.changeSign);
                    },
                  ),
                  UnaryOperatorButton(
                    text: percentSign,
                    onPressed: () {
                      _unaryOperationAction(UnaryOperation.percent);
                    },
                  ),
                  BinaryOperatorButton(
                    text: divideSign,
                    onPressed: () {
                      _binaryOperationAction(BinaryOperation.divide);
                    },
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  NumberButton(
                      text: "7",
                      onPressed: () {
                        _numberButtonAction("7");
                      }),
                  NumberButton(
                      text: "8",
                      onPressed: () {
                        _numberButtonAction("8");
                      }),
                  NumberButton(
                      text: "9",
                      onPressed: () {
                        _numberButtonAction("9");
                      }),
                  BinaryOperatorButton(
                    text: multiplySign,
                    onPressed: () {
                      _binaryOperationAction(BinaryOperation.multiply);
                    },
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  NumberButton(
                      text: "4",
                      onPressed: () {
                        _numberButtonAction("4");
                      }),
                  NumberButton(
                      text: "5",
                      onPressed: () {
                        _numberButtonAction("5");
                      }),
                  NumberButton(
                      text: "6",
                      onPressed: () {
                        _numberButtonAction("6");
                      }),
                  BinaryOperatorButton(
                    text: minusSign,
                    onPressed: () {
                      _binaryOperationAction(BinaryOperation.subtract);
                    },
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  NumberButton(
                      text: "1",
                      onPressed: () {
                        _numberButtonAction("1");
                      }),
                  NumberButton(
                      text: "2",
                      onPressed: () {
                        _numberButtonAction("3");
                      }),
                  NumberButton(
                      text: "3",
                      onPressed: () {
                        _numberButtonAction("3");
                      }),
                  BinaryOperatorButton(
                    text: addSign,
                    onPressed: () {
                      _binaryOperationAction(BinaryOperation.add);
                    },
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ZeroButton(
                    onPressed: () {
                      _zeroButtonAction();
                    },
                  ),
                  BinaryOperatorButton(
                    text: ".",
                    onPressed: () {
                      _otherOperationAction(OtherOperation.addDecimal);
                    },
                  ),
                  BinaryOperatorButton(
                    text: equalSign,
                    onPressed: () {
                      _otherOperationAction(OtherOperation.equals);
                    },
                    onLongPressed: () {
                      if (startsWithThree(operand1) ||
                          startsWithThree(operand2) ||
                          startsWithThree(result)) {
                        VolumeControl.setVolume(0); //Just in case we forget :-(
                        context.read<Navigation>().activePage =
                            const BrowserPage();
                      }
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void initializeValues() {
    operand1 = null;
    operand2 = null;
    result = null;
    operator = null;
    isOperand1Completed = false;
  }

  void _findOutput() {
    if (operand1 == null || operand2 == null) return;
    var exp1 = double.parse(operand1.toString());
    var exp2 = double.parse(operand2.toString());
    switch (operator) {
      case addSign:
        result = exp1 + exp2;
        break;
      case minusSign:
        result = exp1 - exp2;
        break;
      case multiplySign:
        result = exp1 * exp2;
        break;
      case divideSign:
        result = exp1 / exp2;
        break;
      case percentSign:
        result = exp1 % exp2;
        break;
    }
    if (result.toString().endsWith(".0")) {
      result = int.parse(result.toString().replaceAll(".0", ""));
    }
  }

  void _numberButtonAction(String text) {
    if (result != null) initializeValues();
    if (isOperand1Completed) {
      if (operand2 == null) {
        operand2 = text;
      } else {
        if (operand2.toString().length < 9) operand2 += text;
      }
    } else {
      if (operand1 == null) {
        operand1 = text;
      } else {
        if (operand1.toString().length < 9) operand1 += text;
      }
    }
    setState(() {});
  }

  void _zeroButtonAction() {
    if (result != null) initializeValues();
    if (isOperand1Completed) {
      if (operand2 == null || operand1 == "0") {
        operand2 = "0";
      } else {
        if (operand2.toString().length < 9) operand2 += "0";
      }
    } else {
      if (operand1 == null || operand1 == "0") {
        operand1 = "0";
      } else {
        if (operand1.toString().length < 9) operand1 += "0";
      }
    }
    setState(() {});
  }

  void _binaryOperationAction(BinaryOperation operation) {
    switch (operation) {
      case BinaryOperation.add:
        if (operand2 != null) {
          if (result == null) _findOutput();
          operand1 = result;
          operand2 = null;
          result = null;
        }
        operator = addSign;
        isOperand1Completed = true;
        break;
      case BinaryOperation.subtract:
        if (operand2 != null) {
          if (result == null) _findOutput();
          operand1 = result;
          operand2 = null;
          result = null;
        }
        operator = minusSign;
        isOperand1Completed = true;
        break;
      case BinaryOperation.multiply:
        if (operand2 != null) {
          if (result == null) _findOutput();
          operand1 = result;
          operand2 = null;
          result = null;
        }
        operator = multiplySign;
        isOperand1Completed = true;
        break;
      case BinaryOperation.divide:
        if (operand2 != null) {
          if (result == null) _findOutput();
          operand1 = result;
          operand2 = null;
          result = null;
        }
        operator = divideSign;
        isOperand1Completed = true;
        break;
    }
    setState(() {});
  }

  void _unaryOperationAction(UnaryOperation operation) {
    switch (operation) {
      case UnaryOperation.changeSign:
        if (result != null) {
          result = -result;
        } else if (isOperand1Completed) {
          if (operand2 != null) {
            operand2 = (-int.parse(operand2)).toString();
          }
        } else {
          if (operand1 != null) {
            operand1 = (-int.parse(operand1)).toString();
          }
        }
        break;
      case UnaryOperation.percent:
        if (result != null) {
          result = result / 100;
        } else if (isOperand1Completed) {
          if (operand2 != null) {
            operand2 = (double.parse(operand2) / 100).toString();
          }
        } else {
          if (operand1 != null) {
            operand1 = (double.parse(operand1) / 100).toString();
          }
        }
        break;
    }
    setState(() {});
  }

  _otherOperationAction(OtherOperation operation) {
    switch (operation) {
      case OtherOperation.clear:
        initializeValues();
        break;
      case OtherOperation.addDecimal:
        if (result != null) initializeValues();
        if (isOperand1Completed) {
          if (!operand2.toString().contains(".")) {
            if (operand2 == null) {
              operand2 = ".";
            } else {
              operand2 += ".";
            }
          }
        } else {
          if (!operand1.toString().contains(".")) {
            if (operand1 == null) {
              operand1 = ".";
            } else {
              operand1 += ".";
            }
          }
        }
        break;
      case OtherOperation.equals:
        if (result == null) _findOutput();

        break;
    }
    setState(() {});
  }

  bool startsWithThree(var value) {
    if (value == null) return false;
    return value is double
        ? operand1.toStringAsFixed(0).toString().startsWith('3')
        : operand1.toString().startsWith('3');
  }
}
