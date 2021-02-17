import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:manage_wallpaper/back_end.dart';
import 'package:get/get.dart';
//import 'package:wallpaper_manager/up_to_cat.dart';





class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {



  bool loading=false;
  Future initFire()async{
    setState(() {
      loading=true;
    });
    var load=await Firebase.initializeApp();
    if (load !=null){
      print('nameeee:'+load.name);
      setState(() {
        loading=false;
      });
    }

  }















  void createNewCat()async{
    String name='';
    Color _color=Colors.red;
    await showDialog(
        context: context,
        builder: (BuildContext context){
      return AlertDialog(
        title: Text("create New Category"),
        content: SizedBox(
          height: Get.height/2,
          child: Column(
            children: [
              TextField(onChanged: (t){name=t;},decoration: InputDecoration(hintText: 'title'),),
              Expanded(
                child: MaterialColorPicker(
                  elevation: 0,
                  physics: BouncingScrollPhysics(),
                  onMainColorChange: (Color color) {_color=color;print(color);},
                  selectedColor: _color,
                  allowShades: false,
                ),
              ),
            ],
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: (){
              name.isNotEmpty? context.read<BackEnd>().createNewCategory(title: name.trim(),color: _color.value):print('null');
              Navigator.pop(context);
            },color: Colors.lightBlue,child: Text('done'),
          ),
          MaterialButton(
            onPressed: (){
              Navigator.pop(context);
            },color: Colors.red,child: Text('cancel'),
          ),
        ],
      );
    }
    );

  }



  void addToCat()async{
    await showDialog(
        context: context,
        builder: (BuildContext context){
      return Dialog(
       child: Material(child: SizedBox(height: Get.height/2,child: UploadToCategory())),
      );
    }
    );

  }






  @override
  void initState() {
    initFire();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return ModalProgressHUD(
      inAsyncCall: loading,
      progressIndicator: CircularProgressIndicator(),
      child: Scaffold(
        appBar: AppBar(

          title: Text('manager'),
        ),
        body: Center(

          child: Column(

            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              MaterialButton(color: Colors.orange,onPressed: (){
                addToCat();
              },child: Text('upload to categories'),),
            //  MaterialButton(color: Colors.orange,onPressed: (){uploadToExclusive();},child: Text('upload to exclusive'),),
              MaterialButton(color: Colors.orange,onPressed: (){createNewCat();},child: Text('upload new category'),),
            ],
          ),
        ),
      ),
    );
  }
}




class UploadToCategory extends StatefulWidget {
  @override
  _UploadToCategoryState createState() => _UploadToCategoryState();
}

class _UploadToCategoryState extends State<UploadToCategory> {


  List<DropdownMenuItem> cards=[];
  String selectedType='';
  void getData()async{
    setState(() {loading=true;});
    List<String> ccc= await context.read<BackEnd>().categoryTypesStream();
   setState(() {
     if(ccc.isNotEmpty){
       ccc.forEach((element) { cards.add(DropdownMenuItem(value: element, child: Center(child: Text( element,maxLines: 2,)),)); });
       selectedType=ccc[0];
       loading=false;
     }
     else{Get.back();}
   });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }


  void single()async{
    setState(() {loading=true;});
    await context.read<BackEnd>().chooseImage(category: selectedType);
    setState(() {loading=false;});
    Get.back();
    Get.snackbar("Done", "uploaded done",backgroundColor: Colors.white);
  }

  Future multi()async{
    setState(() {loading=true;});
    await context.read<BackEnd>().chooseMultiImages(category: selectedType);
    setState(() {loading=false;});
    Get.back();
    Get.snackbar("Done", "uploaded done",backgroundColor: Colors.white);
  }

  bool loading=false;

  @override



  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall:loading ,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,

        children: [
          Text("Upload to category"),
          Row(
            children: [
              Expanded(child: Icon(Icons.category)),
              Expanded(
              flex: 2,
                child: Card(elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0),),
                    child: DropdownButton(isExpanded: true,underline: Container(),value:selectedType ,hint:Text(selectedType,textAlign: TextAlign.center,maxLines: 1,) ,disabledHint:Center(child: Text(selectedType,maxLines: 2,)) ,items:cards, onChanged: (i){setState(() {selectedType=i;});})),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: MaterialButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },color: Colors.red.shade300,child: Text('cancel'),
                ),
              ),
              Expanded(
                child: MaterialButton(
                  onPressed: (){
                     if(selectedType!=''){
                       single();
                     }
                  },color: Colors.lightBlue,child: Text('one image'),
                ),
              ),
              Expanded(
                child: MaterialButton(
                  onPressed: (){
                    if(selectedType!=''){
                      multi();
                    }
                  },color: Colors.green,child: Text('multi images'),
                ),
              ),

            ],
          )
        ],
      ),
    );
  }
}
