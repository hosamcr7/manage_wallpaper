import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';


class BackEnd extends ChangeNotifier{

  FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future <List<String>> categoryTypesStream()async {
    List<String> cards=[];

    await FirebaseFirestore.instance
        .collection('categories').get().then((QuerySnapshot querySnapshot) => {
      querySnapshot.docs.forEach((doc) {
        final String title=doc.data()['title'];
        //final int  color=doc.data()['color'];
        cards.add(title);
      })
    });
    return cards;
  }

  Future createNewCategory({String title,int color})async{
    await _fireStore.collection('categories').doc(title).set({"title":title,"color":color});
    Get.snackbar("Done", "uploaded done",backgroundColor: Colors.white);
  }





  Future chooseMultiImages({String category})async{
    List<Asset> images=  await MultiImagePicker.pickImages(
      maxImages: 10,
      enableCamera: false,
    );
    images.isEmpty?print("empty"):await uploadMultiImagesForCategory(imageToUpload: images,category: category);

  }



  Future uploadMultiImagesForCategory({List<Asset> imageToUpload,String category}) async {


    var  imagesUrls=await Future.wait(imageToUpload.map((e) =>completeUpload(element: e,category: category) ));
    print(imagesUrls);

  }

  Future completeUpload({Asset element,String category})async{
    Reference storageReference = FirebaseStorage.instance.ref().child(category).child(element.hashCode.toString());
    ByteData byteData = await element.getByteData();
    List<int> imageData = byteData.buffer.asUint8List();
    UploadTask uploadTask = storageReference.putData(imageData,);
    await uploadTask.whenComplete(() =>  print('File Uploaded'));
    await storageReference.getDownloadURL().then((fileURL) async {
      DocumentReference reference = _fireStore.collection('categories').doc(category).collection("images").doc();
      reference.set({'link': fileURL,'time':FieldValue.serverTimestamp()});
      print(fileURL);
    });
    await storageReference.getDownloadURL().then((fileURL) async {
      DocumentReference reference = _fireStore.collection('all').doc();
      reference.set({'link': fileURL,'time':FieldValue.serverTimestamp()});
      return fileURL;
    });
  }




  Future chooseImage({String category}) async {
    File chosenImage;
    final picker = ImagePicker();
    await picker.getImage(source: ImageSource.gallery,).then((image) {
      chosenImage = File(image.path);
    });
    chosenImage!=null? await uploadImageForCategory(imageToUpload: chosenImage,category: category):print('null file');

  }
  Future uploadImageForCategory({File imageToUpload,String category}) async {
    Reference storageReference = FirebaseStorage.instance
        .ref().child(category).child(imageToUpload.hashCode.toString());
    UploadTask uploadTask = storageReference.putFile(imageToUpload,);
    await uploadTask.whenComplete(() =>  print('File Uploaded'));

    await storageReference.getDownloadURL().then((fileURL) async {
      DocumentReference reference = _fireStore.collection('categories').doc(category).collection("images").doc();
      reference.set({'link': fileURL,'time':FieldValue.serverTimestamp()});
      print(fileURL);
    });
    await storageReference.getDownloadURL().then((fileURL) async {
      DocumentReference reference = _fireStore.collection('all').doc();
      reference.set({'link': fileURL,'time':FieldValue.serverTimestamp()});
    });

  }



}