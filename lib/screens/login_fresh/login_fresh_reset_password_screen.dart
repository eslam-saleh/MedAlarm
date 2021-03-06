import 'package:flutter/material.dart';
import 'package:med_alarm/config/ColorConstants.dart';
import 'package:med_alarm/custom_widgets/logging_widgets/login_fresh_loading.dart';
import 'package:med_alarm/config/language.dart';

class LoginFreshResetPassword extends StatefulWidget {
  static const id = 'RESET_PASSWORD_SCREEN';
  final Color backgroundColor;

  final Color textColor;

  final LoginFreshWords loginFreshWords;

  final String logo;

  final Function funResetPassword;

  final isFooter;

  final Widget widgetFooter;

  LoginFreshResetPassword(
      {@required this.funResetPassword,
      this.isFooter,
      this.widgetFooter,
      this.backgroundColor,
      this.textColor,
      this.loginFreshWords,
      @required this.logo});

  @override
  _LoginFreshResetPasswordState createState() =>
      _LoginFreshResetPasswordState();
}

class _LoginFreshResetPasswordState extends State<LoginFreshResetPassword> {
  TextEditingController _textEditingControllerUser = TextEditingController();

  bool isRequest = false;

  final focus = FocusNode();
  LoginFreshWords loginFreshWords;

  @override
  Widget build(BuildContext context) {
    loginFreshWords = (widget.loginFreshWords == null)
        ? LoginFreshWords()
        : widget.loginFreshWords;
    double headerSize = MediaQuery.of(context).size.height * 0.3
        - MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      (ColorConstants.gradientColor1),
                      (ColorConstants.gradientColor2),
                    ],
                  )
              ),
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: MediaQuery.of(context).padding.top,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Hero(
                              tag: 'hero-login1',
                              child: Container(
                                height: headerSize / 3,
                                width: MediaQuery.of(context).size.width * 0.8,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                      './assets/logo_MED_ALARM.png',
                                    ),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Hero(
                          tag: 'hero-login',
                          child: Container(
                            width: headerSize * 2 / 3,
                            height: headerSize * 2 / 3,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  './assets/logo.png',
                                ),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              decoration: new BoxDecoration(
                  color: Color(0xFFF3F3F5),
                  borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(25.0),
                    topRight: const Radius.circular(25.0),
                  )),
              child: buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        SizedBox(),
        Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                loginFreshWords.messageRecoverPassword,
                textAlign: TextAlign.justify,
                style: TextStyle(
                    color: widget.textColor ?? Color(0xFF0F2E48), fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                  controller: this._textEditingControllerUser,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                      color: widget.textColor ?? Color(0xFF0F2E48),
                      fontSize: 14),
                  autofocus: false,
                  onSubmitted: (v) {
                    FocusScope.of(context).requestFocus(focus);
                  },
                  decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          "assets/icon_user.png",
                          width: 15,
                          height: 15,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Color(0xFFAAB5C3))),
                      filled: true,
                      fillColor: Color(0xFFF3F3F5),
                      focusColor: Color(0xFFF3F3F5),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Color(0xFFAAB5C3))),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                              color:
                                  widget.backgroundColor ?? ColorConstants.PrimaryColor)),
                      hintText: this.loginFreshWords.hintLoginUser)),
            ),
            (this.isRequest)
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LoadingLoginFresh(
                      textLoading: this.loginFreshWords.textLoading,
                      colorText: widget.textColor,
                      backgroundColor: widget.backgroundColor,
                      elevation: 0,
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      widget.funResetPassword(context, this.setIsRequest,
                          this._textEditingControllerUser.text);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.07,
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Card(
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              color:
                                  widget.backgroundColor ?? ColorConstants.PrimaryColor,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Center(
                                    child: Text(
                                  this.loginFreshWords.recoverPassword,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                )),
                              ))),
                    ),
                  ),
          ],
        ),
        SizedBox(),
        (widget.isFooter == null || widget.isFooter == false)
            ? SizedBox()
            : widget.widgetFooter
      ],
    );
  }

  void setIsRequest(bool isRequest) {
    setState(() {
      this.isRequest = isRequest;
    });
  }
}
