import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}
JavascriptChannel snackBarJavaScriptChannel(context){
  return JavascriptChannel(
      name: "SnackBarJsChannel",
      onMessageReceived: (message){
        Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(message.message)),
        );
      });


}
class _MyHomePageState extends State<MyHomePage> {
  final Completer<WebViewController> controller=Completer<WebViewController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Web view"),
      actions: [
        NavigationControls(webViewControllerFuture:controller.future)
      ],),

      body: WebView(
        initialUrl: "http://google.com",
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (webController){
          controller.complete(webController);
        },
        javascriptChannels: <JavascriptChannel>[
          snackBarJavaScriptChannel(context)
        ].toSet(),

      )
    );
  }
}

 class NavigationControls  extends StatelessWidget {
  NavigationControls({@required this.webViewControllerFuture});
  Future<WebViewController> webViewControllerFuture;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future:webViewControllerFuture ,
        builder: (context,snapshot){
        final isWebViewReady=snapshot.connectionState==ConnectionState.done;
        final controller=snapshot.data;
        return Row(
          children: [
            IconButton(
                icon: Icon (Icons.arrow_back_ios,color: Colors.white,),
                onPressed: !isWebViewReady? null: ()async{
                  print('back button clicked');
                  if(await controller.canGoBack()){
                    controller.goBack();
                  }else{
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Do you want to exit'),
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('No'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                SystemNavigator.pop();
                              },
                              child: Text('Yes'),
                            ),
                          ],
                        ));
                  }
                }
            ),
            IconButton(
                icon: Icon (Icons.arrow_forward_ios,color: Colors.white,),
                onPressed: !isWebViewReady? null: ()async{
                  print('forword button clicked');
                  if(await controller.canGoForward()){
                    controller.goForward();
                  }else{

                  }
                }
            ),
            IconButton(
                icon: Icon (Icons.refresh,color: Colors.white,),
                onPressed: !isWebViewReady? null: ()async{
                  print("refresh Button clicked");
                  controller.reload();
                }
            ),
            IconButton(
                icon: Icon (Icons.info,color: Colors.white,),
                onPressed: !isWebViewReady? null: ()async{
                  controller.evaluateJavascript("SnackBarJsChannel");
                }
            ),
          ],
        );
        });
  }



}




