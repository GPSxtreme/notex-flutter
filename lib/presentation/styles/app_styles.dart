import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/* start of color constants */
const Color kWhite = Colors.white;
// for divider lines
const Color kWhite24 = Color.fromRGBO(255, 255, 255, 0.9);
// for sub titles
const Color kWhite75 = Color.fromRGBO(255, 255, 255, 0.75);
// for checkboxes
const Color kWhiteCheckboxUS = Color.fromRGBO(217, 217, 217, 8);
const Color kWhiteCheckboxS = Color.fromRGBO(217, 217, 217, 25);
const Color kPink = Color.fromRGBO(217, 155, 255, 1);
// for both bottom dock and tile border
const Color kPinkD1 = Color.fromRGBO(100, 65, 98, 1);
// for tile card color
const Color kPinkD2 = Color.fromRGBO(45, 30, 44, 1);
const Color kRed = Colors.red;
const Color kPageBgStart = Color.fromRGBO(13, 12, 13, 1);
const Color kPageBgEnd = Color.fromRGBO(50, 34, 49, 1);
/* end of color constants */

const Gradient kPageBgGradient = LinearGradient(
  colors: [
    kPageBgStart,
    kPageBgEnd
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  stops: [0.0,1.0],
  tileMode: TileMode.clamp
);

Widget kDevLogo = Text(
  "GPS",
  style: GoogleFonts.fugazOne(color: Colors.white.withOpacity(0.13),fontSize: 20),
);

TextStyle kInter = GoogleFonts.inter(
  color: kWhite,
  fontSize: 18,
  fontWeight: FontWeight.w400
);

/// use cases : login , register page text fields etc
InputDecoration kTextFieldDecorationT1 = InputDecoration(
  labelText: '',
  fillColor: kWhite.withOpacity(0.03),
  filled: true,
  labelStyle: const TextStyle(color: Colors.white, fontSize: null),
  hintStyle: const TextStyle(color: Colors.white),
  contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
  border: const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(15)),
    borderSide: BorderSide(color: kPinkD1, width: 2.0),
  ),
  enabledBorder: const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(15)),
    borderSide: BorderSide(color: kPinkD1, width: 2.0),
  ),
  focusedBorder: const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(15)),
    borderSide: BorderSide(color: kPink, width: 2.0),
  ),
  errorBorder: const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(15)),
    borderSide: BorderSide(color: kRed, width: 2.0),
  ),
);

/// use cases : login page, register page (basically a pink btn)
ButtonStyle kBtnStyleT1 = ButtonStyle(
    backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states){
          if(states.contains(MaterialState.disabled)){
            return kPinkD1;
          } else {
            return kPink;
          }
        }
    ),
    padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.symmetric(vertical: 8)),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        )
    ),
);

/// looks like [kTextFieldDecorationT1] but a button
ButtonStyle kBtnStyleT2 = ButtonStyle(
  backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states){
        if(states.contains(MaterialState.pressed)){
          return kPinkD2;
        } else {
          return kPinkD1.withOpacity(0.3);
        }
      }
  ),
  padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.symmetric(vertical: 12)),
  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: const BorderSide(color: kPinkD1,width: 2.0)
      )
  ),
);

kSnackBar(BuildContext context,String text){
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(
      content: Text(text,style: kInter.copyWith(fontSize: 15,fontWeight: FontWeight.w400),),
    backgroundColor: kPinkD1,
    padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 30),
  ));
}