import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  TextEditingController userController=TextEditingController();
  TextEditingController quantityController=TextEditingController();

  //creating Item list for holding data
  List<Map<String,dynamic>> items=[];
  //make box for referencing
  final shoppingBox=Hive.box("shopping_box");

  showForm(BuildContext context,int ?itemKey)async{
    showModalBottomSheet(
        context: context,
        elevation: 5,
        builder: (_){
      return Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 15,
          left: 15,
          right: 15
        ),
        child:  Column(
          mainAxisSize: MainAxisSize.min,
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextFormField(controller: userController,keyboardType: TextInputType.text,decoration: InputDecoration(
              border: OutlineInputBorder()
            ),),
            SizedBox(height: 10),
            TextFormField(controller: quantityController,keyboardType: TextInputType.number,decoration: InputDecoration(
              border: OutlineInputBorder()
            ),),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: (){

                  createItem({
                    'name':userController.text,
                    'quantity':quantityController.text

                  });
              userController.text='';
              quantityController.text='';
              Navigator.pop(context);
            }, child: Text("Insert")),
            SizedBox(height: 30,)
          ],
        ),

      )
      ;
    });
  }

  //Show stored data on UI & update UI
  void refreshItems(){
    final data=shoppingBox.keys.map((key){
      final item=shoppingBox.get(key);
      return {'key':key,'name':item['name'],'quantity':item['quantity']};
    }).toList();
    setState(() {
      items=data.reversed.toList();
    });
  }

  //Storing items data in box with object base
  createItem(Map<String,dynamic>newItem)async{
     await shoppingBox.add(newItem);
     print("check stored data in box ${shoppingBox.length}");
     //after saving item should update list
     refreshItems();
  }

  @override
  Widget build(BuildContext context) {
    print("showing stored data in box ${shoppingBox.values}");

    return Scaffold(
      appBar: AppBar(
        title: Text("Hive Screen"),
      ),
      body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context,index)=>ListTile(
        title: Text(items[index]['name']),
        trailing: Text(items[index]['quantity']),

      )),
      floatingActionButton: FloatingActionButton(onPressed: ()=>showForm(context,null),child: Center(child: Icon(Icons.add),),),
    );
  }
}
