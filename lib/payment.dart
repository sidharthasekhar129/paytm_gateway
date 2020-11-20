import 'dart:convert';

 import 'package:flutter/material.dart';
import 'package:paytm_gateway/Constants.dart';
import 'package:webview_flutter/webview_flutter.dart';


class PaymentScreen extends StatefulWidget {

  final String amount;

  PaymentScreen({this.amount});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  WebViewController _webController;
  bool _loadingPayment = true;
  String _responseStatus = STATUS_LOADING;
  var paytmResponse;


  String _loadHTML() {
    return "<html> <body onload='document.f.submit();'> <form id='f' name='f' method='post' action='$PAYMENT_URL'><input type='hidden' name='orderID' value='ORDER_${DateTime.now().millisecondsSinceEpoch}'/>" +
        "<input  type='hidden' name='custID' value='${ORDER_DATA["custID"]}' />" +
        "<input  type='hidden' name='amount' value='${widget.amount}' />" +
        "<input type='hidden' name='custEmail' value='${ORDER_DATA["custEmail"]}' />" +
        "<input type='hidden' name='custPhone' value='${ORDER_DATA["custPhone"]}' />" +
        "</form> </body> </html>";
  }

  void getData() {
    _webController.evaluateJavascript("document.body.innerText").then((data) {
      var decodedJSON = jsonDecode(data);
      Map<String, dynamic> responseJSON = jsonDecode(decodedJSON);
      final checksumResult = responseJSON["status"];
           paytmResponse = responseJSON["data"];

      print("Status: "+paytmResponse["STATUS"]);//
      print("Order_ID: "+paytmResponse["ORDERID"]);
      print("TXN_ID: "+paytmResponse["TXNID"]);
      print("Bank_TXN_ID: "+paytmResponse["BANKTXNID"]);
      print("Currency: "+paytmResponse["CURRENCY"]); //
      print("TXN_Amount: "+paytmResponse["TXNAMOUNT"]);//
      print("TXN_Date: "+paytmResponse["TXNDATE"]);
      print("Bank_Name: "+paytmResponse["BANKNAME"]);
      print("Payment_Mode: "+paytmResponse["PAYMENTMODE"]);
      print("Res_Code: "+paytmResponse["RESPCODE"]);
      print("Res_Message: "+paytmResponse["RESPMSG"]);



      if (paytmResponse["STATUS"] == "TXN_SUCCESS") {
        if (checksumResult==0) {

          //save cart info to order and clear the cart
          this.setState((){
            _responseStatus = STATUS_SUCCESSFUL;
          });

        } else {
          this.setState((){
            _responseStatus = STATUS_CHECKSUM_FAILED;
          });

        }
      } else if (paytmResponse["STATUS"] == "TXN_FAILURE") {
        this.setState((){
          _responseStatus = STATUS_FAILED;
        });

      }

    });
  }

  Widget getResponseScreen() {
    switch (_responseStatus) {
      case STATUS_SUCCESSFUL:
        return PaymentSuccessfulScreen(paytmResponse);
      case STATUS_CHECKSUM_FAILED:
        return CheckSumFailedScreen();
      case STATUS_FAILED:
        return PaymentFailedScreen(paytmResponse);
    }
    return PaymentSuccessfulScreen(paytmResponse);
  }

  @override
  void dispose() {
    _webController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Stack(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: WebView(
                  debuggingEnabled: false,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (controller){
                    _webController = controller;
                    _webController
                        .loadUrl(new Uri.dataFromString(_loadHTML(), mimeType: 'text/html').toString());
                  },
                  onPageFinished: (page){
                    if (page.contains("/process")) {
                      if (_loadingPayment) {
                        this.setState(() {
                          _loadingPayment = false;
                        });
                      }
                    }
                    if (page.contains("/paymentReceipt")) {
                      getData();
                    }
                  },
                ),
              ),
              (_loadingPayment)
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : Center(),
              (_responseStatus != STATUS_LOADING) ? Center(child:getResponseScreen()) : Center()
            ],
          )
      ),
    );
  }
}

// ignore: must_be_immutable
class PaymentSuccessfulScreen extends StatelessWidget {
  var paytmResponse;
  PaymentSuccessfulScreen(var paytmResponse){
    this.paytmResponse=paytmResponse;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(80),
                    color: Colors.lightBlue,
                  ),
                  child: Icon(Icons.check,color: Colors.white,size: 55,),
                ),
                SizedBox(height: 35,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Payment Succesful!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25,decoration:TextDecoration.none),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(paytmResponse["CURRENCY"]+": "+paytmResponse["TXNAMOUNT"],
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25,decoration:TextDecoration.none),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(paytmResponse["TXNDATE"],
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18,decoration:TextDecoration.none),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(paytmResponse["ORDERID"],
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18,decoration:TextDecoration.none),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("TXN_ID"+paytmResponse["BANKTXNID"],
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18,decoration:TextDecoration.none),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text("Thank you for making the payment!",textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20,decoration:TextDecoration.none,  color: Colors.lightBlue,
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                MaterialButton(
                    color: Colors.black,
                    child: Text(
                      "Close",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName("/"));
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PaymentFailedScreen extends StatelessWidget {
  var paytmResponse;

   PaymentFailedScreen(var paytmResponse){
    this.paytmResponse=paytmResponse;
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(80),
                    color: Colors.lightBlue,
                  ),
                  child: Icon(Icons.close,color: Colors.white,size: 55,),
                ),

                SizedBox(height: 35,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(paytmResponse["STATUS"],
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25,decoration:TextDecoration.none),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(paytmResponse["RESPCODE"]+": "+paytmResponse["RESPMSG"],
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20,decoration:TextDecoration.none),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(paytmResponse["CURRENCY"]+": "+paytmResponse["TXNAMOUNT"],
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20,decoration:TextDecoration.none),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(paytmResponse["TXNDATE"],
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18,decoration:TextDecoration.none),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(paytmResponse["ORDERID"],
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18,decoration:TextDecoration.none),
                  ),
                ),

                SizedBox(
                  height: 10,
                ),
                Text("Transaction failed,Try again later",textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20,decoration:TextDecoration.none,  color: Colors.lightBlue,),
                ),
                SizedBox(
                  height: 25,
                ),
                MaterialButton(
                    color: Colors.black,
                    child: Text(
                      "Close",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName("/"));
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CheckSumFailedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(80),
                    color: Colors.lightBlue,
                  ),
                  child: Icon(Icons.close,color: Colors.white,size: 55,),
                ),
                SizedBox(height: 35,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Oh Snap!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Problem Verifying Payment, If you balance is deducted please contact our customer support and get your payment verified!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18,decoration:TextDecoration.none,  color: Colors.lightBlue,),
                ),
                SizedBox(
                  height: 10,
                ),
                MaterialButton(
                    color: Colors.black,
                    child: Text(
                      "Close",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName("/"));
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
