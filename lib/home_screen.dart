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
    //editing item
    if(itemKey!=null){

//check if existing then fetch and pass into TextEditingController fields
    final existingItem=items.firstWhere((element)=>element['key']==itemKey);
    userController.text=existingItem['name'];
    quantityController.text=existingItem['quantity'];

    }
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
            TextFormField(
              controller: userController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "Enter Item",
              border: OutlineInputBorder()
            ),),
            SizedBox(height: 10),
            TextFormField(controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "quantity",
              border: OutlineInputBorder()
            ),),
            SizedBox(height: 20),
            itemKey!=null?ElevatedButton(
                onPressed: (){

                  updateItemDetails(itemKey,{
                  'name':userController.text.trim(),
                  'quantity':quantityController.text.trim()

                  });
              userController.text='';
              quantityController.text='';
              Navigator.pop(context);
            }, child: Text("Update")):ElevatedButton(
                onPressed: (){

                  createItem({
                    'name':userController.text,
                    'quantity':quantityController.text

                  });
                  userController.text='';
                  quantityController.text='';
                  Navigator.pop(context);
                }, child: Text("Add new Item")),
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
    print("check stored data in box ${shoppingBox.length}");

  }

  //Update function for update data Note: using .put() to update exiting object
  Future<void>updateItemDetails(int key,Map<String,dynamic>item)async{
    debugPrint("Updating value $item");
    await shoppingBox.put(key, item);
    refreshItems();
  }
  //delete function for delete data Note: using .delete() to update exiting object
  Future<void>deleteItem(int itemKey)async{
    await shoppingBox.delete(itemKey);
    refreshItems();
  }

  //Storing items data in box with object base
  createItem(Map<String,dynamic>newItem)async
  {
    debugPrint("Adding new Item $newItem");
     await shoppingBox.add(newItem);
     //after saving item should update list
     refreshItems();
  }

  @override
  void initState() {
    super.initState();
    refreshItems();
  }

  @override
  Widget build(BuildContext context) {
    print("showing stored data in box ${shoppingBox.values}");

    return Scaffold(
      appBar: AppBar(
        title: Text("Hive Screen"),
        centerTitle: true,
      ),
      body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context,index)=>Card(
            elevation: 1.5,
            color: Colors.grey.shade200,
            margin: EdgeInsets.symmetric(horizontal: 10,vertical: 8),
            child: ListTile(
                    title: Text(items[index]['name']),
                    subtitle: Text(items[index]['quantity']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(onPressed: ()=>showForm(context, items[index]['key']), icon: Icon(Icons.edit)),
                  IconButton(onPressed: ()=>deleteItem(items[index]['key']), icon: Icon(Icons.delete)),
                ],
              ),

                  ),
          )),
      floatingActionButton: FloatingActionButton(onPressed: ()=>showForm(context,null),child: Center(child: Icon(Icons.add),),),
    );
  }
}
