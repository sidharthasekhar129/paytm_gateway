import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'dart:math';

import 'package:paytm_gateway/payment.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',

      home: PaytmKaro(),
    );
  }
}




TextEditingController mail=new TextEditingController();
class PaytmKaro extends StatefulWidget {
  @override
  _PaytmKaroState createState() => _PaytmKaroState();
}

class _PaytmKaroState extends State<PaytmKaro> {
  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('Back',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: <Widget>[
                Positioned(
                    top: -MediaQuery.of(context).size.height * .15,
                    right: -MediaQuery.of(context).size.width * .4,
                    child: BezierContainer()),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: MediaQuery.of(context).size.height * .3),
                        Container(
                          padding: EdgeInsets.only(left: 6,top: 8),
                          alignment: Alignment.topLeft,
                          child: Text("Enter Amount:",style: TextStyle(fontSize: 20,color: Colors.black,
                              fontWeight: FontWeight.w600,fontFamily: "Spectral"),),
                        ),
                        Container(

                          height: 50,
                          alignment: Alignment.topLeft,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black26,

                          ),
                          margin: EdgeInsets.all(6),
                          padding: EdgeInsets.only(left: 6),

                          child:  TextField(
                            controller: mail,
                            style: TextStyle(fontWeight: FontWeight.w600,fontFamily: "Spectral",fontSize: 18,color: Colors.white),
                            decoration: InputDecoration(border: InputBorder.none,hintText: "5000",hintStyle: TextStyle(color: Colors.black45)),
                            //readOnly: true,
                          ),
                        ),
                        Text("Note: You will be redirected to paytm gateway",
                          textAlign: TextAlign.center,style: TextStyle(fontSize: 15,fontFamily: "Spectral",fontWeight: FontWeight.w600,color: Colors.black),),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                            context, MaterialPageRoute(builder: (context) => PaymentScreen()));
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 20),
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(vertical: 13),
                            alignment: Alignment.center,

                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.grey.shade200,
                                      offset: Offset(2, 4),
                                      blurRadius: 5,
                                      spreadRadius: 2)
                                ],
                                gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [Color(0xfffbb448), Color(0xfff7892b)])),
                            child: Text(
                              'pay',
                              style: TextStyle(fontSize: 20, color: Colors.white,fontFamily: "Spectral",fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                      ],
                    ),

                  ),
                ),


                Positioned(top: 40, left: 0, child: _backButton()),
              ],
            ),
          ),
        ));
  }
}
class BezierContainer extends StatelessWidget {
  const BezierContainer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Transform.rotate(
          angle: -pi / 3.5,
          child: ClipPath(
            clipper: ClipPainter(),
            child: Container(
              height: MediaQuery.of(context).size.height *.5,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xfffbb448),Color(0xffe46b10)]
                  )
              ),
            ),
          ),
        )
    );
  }
}
class ClipPainter extends CustomClipper<Path>{
  @override

  Path getClip(Size size) {
    var height = size.height;
    var width = size.width;
    var path = new Path();

    path.lineTo(0, size.height );
    path.lineTo(size.width , height);
    path.lineTo(size.width , 0);

    /// [Top Left corner]
    var secondControlPoint =  Offset(0  ,0);
    var secondEndPoint = Offset(width * .2  , height *.3);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);



    /// [Left Middle]
    var fifthControlPoint =  Offset(width * .3  ,height * .5);
    var fiftEndPoint = Offset(  width * .23, height *.6);
    path.quadraticBezierTo(fifthControlPoint.dx, fifthControlPoint.dy, fiftEndPoint.dx, fiftEndPoint.dy);


    /// [Bottom Left corner]
    var thirdControlPoint =  Offset(0  ,height);
    var thirdEndPoint = Offset(width , height  );
    path.quadraticBezierTo(thirdControlPoint.dx, thirdControlPoint.dy, thirdEndPoint.dx, thirdEndPoint.dy);



    path.lineTo(0, size.height  );
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }


}